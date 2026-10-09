// LockMachine: simulador do leitor, conferências, registro, login e painel.
document.addEventListener("DOMContentLoaded", () => {
  const root = document.documentElement;
  const DAY = 86400000;
  const today = new Date();
  const daysFromNow = (days) => new Date(today.getTime() + days * DAY);
  const formatDate = (date) => new Intl.DateTimeFormat("pt-BR").format(date);
  const formatTime = (date) => new Intl.DateTimeFormat("pt-BR", { hour: "2-digit", minute: "2-digit" }).format(date);

  // Só anima quando há GSAP e a pessoa não pediu movimento reduzido.
  const motionOK = () => Boolean(window.gsap) && !window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (window.gsap && window.SplitText) gsap.registerPlugin(SplitText);

  // Dados de demonstração: operadores, máquinas e datas são fictícios.
  // As validades partem da data de hoje, para a demonstração nunca envelhecer.
  const OPERATORS = {
    marina: { name: "Marina Costa", rfid: "0182", training: { prensas: daysFromNow(150), tornos: daysFromNow(12) } },
    carlos: { name: "Carlos Souza", rfid: "0247", training: { prensas: daysFromNow(210), tornos: daysFromNow(-40), fresadoras: daysFromNow(95) } },
    pedro: { name: "Pedro Alves", rfid: "0115", training: { tornos: daysFromNow(64), fresadoras: daysFromNow(300) } },
  };

  const MACHINES = {
    "prensa-01": { name: "Prensa 01", requires: "prensas", skill: "operação de prensas" },
    "torno-03": { name: "Torno 03", requires: "tornos", skill: "operação de tornos" },
    "fresa-02": { name: "Fresa 02", requires: "fresadoras", skill: "operação de fresadoras" },
  };

  // A regra do LockMachine: a capacitação que a máquina exige precisa estar
  // registrada para o operador e dentro da validade.
  const checkAccess = (operator, machine, now = new Date()) => {
    const validUntil = operator.training[machine.requires];
    if (!validUntil) return { granted: false, reason: "missing" };
    if (validUntil < now) return { granted: false, reason: "expired", validUntil };
    const daysLeft = Math.ceil((validUntil - now) / DAY);
    return { granted: true, reason: daysLeft <= 30 ? "expiring" : "valid", validUntil, daysLeft };
  };

  const describe = (operator, machine, result) => {
    if (result.reason === "missing") return `${operator.name} não tem capacitação registrada em ${machine.skill}. A máquina permanece bloqueada.`;
    if (result.reason === "expired") return `A capacitação de ${operator.name} em ${machine.skill} venceu em ${formatDate(result.validUntil)}. A máquina permanece bloqueada.`;
    return `${operator.name} tem capacitação em ${machine.skill} válida até ${formatDate(result.validUntil)}.`;
  };

  // Registro de tentativas: vale para esta sessão do navegador e aparece no painel.
  const STORAGE_KEY = "lockmachine.tentativas";

  const readAttempts = () => {
    try {
      return JSON.parse(sessionStorage.getItem(STORAGE_KEY)) ?? [];
    } catch {
      return [];
    }
  };

  const saveAttempts = (attempts) => {
    try {
      sessionStorage.setItem(STORAGE_KEY, JSON.stringify(attempts));
    } catch {
      // Sem armazenamento, o registro vale só enquanto esta página estiver aberta.
    }
  };

  let attempts = readAttempts();

  const element = (tag, className, text) => {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text) node.textContent = text;
    return node;
  };

  const statusChip = (granted) => element("span", `status ${granted ? "status--ok" : "status--blocked"}`, granted ? "Liberado" : "Bloqueado");

  // Registro na página do projeto
  const logList = document.querySelector("[data-log]");
  const logEmpty = document.querySelector("[data-log-empty]");

  const renderLog = (announce = false) => {
    if (!logList) return;
    logEmpty.hidden = attempts.length > 0;
    logList.replaceChildren(...attempts.slice(0, 5).map((attempt) => {
      const item = element("li");
      const who = element("span", "log-who");
      who.append(element("b", "", attempt.operator), element("span", "", `RFID ${attempt.rfid} · ${attempt.machine}`));
      item.append(element("time", "data", attempt.time), who, statusChip(attempt.granted));
      return item;
    }));

    // A tentativa nova cai na lista como uma ficha.
    if (announce && motionOK() && logList.firstElementChild) {
      gsap.from(logList.firstElementChild, { rotationX: -80, transformOrigin: "50% 0%", transformPerspective: 600, autoAlpha: 0, duration: 0.6, ease: "expo.out" });
    }
  };

  renderLog();

  // Simulador do leitor ------------------------------------------------------
  const signal = document.querySelector("[data-signal]");
  const reader = document.querySelector("[data-reader]");

  if (signal && reader) {
    const word = signal.querySelector("[data-word]");
    const message = signal.querySelector("[data-message]");
    const flood = signal.querySelector("[data-flood]");
    const symbol = signal.querySelector(".signal-symbol");
    const shape = signal.querySelector("[data-shape]");
    const glyphs = { stop: signal.querySelector('[data-glyph="stop"]'), go: signal.querySelector('[data-glyph="go"]') };
    const verdict = signal.querySelector("[data-verdict]");
    const verdictWarn = signal.querySelector("[data-verdict-warn]");
    const badge = reader.querySelector("[data-badge]");
    const pad = reader.querySelector("[data-pad]");
    const ping = pad.querySelector(".reader-ping");
    const token = (name) => getComputedStyle(root).getPropertyValue(name).trim();
    const DISC = 58; // raio de canto que faz da chapa um disco
    const SQUARE = 13; // raio de canto da chapa quadrada

    // A palavra de sinal vira nove plaquetas, uma por letra (BLOQUEADO é a mais longa).
    const letters = Array.from({ length: 9 }, () => element("span"));
    const setWord = (text) => letters.forEach((letter, index) => { letter.textContent = text[index] ?? ""; });
    setWord(word.textContent.trim());
    word.replaceChildren(...letters);

    // O crachá e o leitor acompanham o que está escolhido.
    const selected = () => ({ operator: OPERATORS[reader.elements.operator.value], machine: MACHINES[reader.elements.machine.value] });

    const fillStage = () => {
      const { operator, machine } = selected();
      badge.querySelector("[data-badge-name]").textContent = operator.name;
      badge.querySelector("[data-badge-rfid]").textContent = `RFID ${operator.rfid}`;
      pad.querySelector("[data-pad-machine]").textContent = `Leitor da ${machine.name}`;
    };

    reader.addEventListener("change", (event) => {
      if (event.target.name !== "operator" || !motionOK()) {
        fillStage();
        return;
      }
      // Trocar de operador vira o crachá.
      gsap.timeline()
        .to(badge, { rotationY: 90, duration: 0.14, ease: "power2.in" })
        .call(fillStage)
        .to(badge, { rotationY: 0, duration: 0.4, ease: "expo.out" });
    });

    fillStage();
    if (window.gsap) gsap.set(badge, { transformPerspective: 600 });

    // Fora da tela, as animações de espera do leitor param.
    new IntersectionObserver(([entry]) => signal.classList.toggle("is-away", !entry.isIntersecting)).observe(signal);

    let timeline;
    let ledTimer;

    reader.addEventListener("submit", (event) => {
      event.preventDefault();
      const { operator, machine } = selected();
      const now = new Date();
      const result = checkAccess(operator, machine, now);
      const state = result.granted ? "granted" : "denied";
      const wasGranted = signal.dataset.state === "granted";
      const colorChanges = wasGranted !== result.granted;

      attempts = [{ time: formatTime(now), operator: operator.name, rfid: operator.rfid, machine: machine.name, granted: result.granted }, ...attempts].slice(0, 20);
      saveAttempts(attempts);

      // Troca o que a placa diz. Sozinha, já deixa a página no estado final.
      const swap = () => {
        signal.dataset.state = state;
        pad.dataset.led = state;
        setWord(result.granted ? "Liberado" : "Bloqueado");
        message.textContent = `${operator.name} · ${machine.name}`;
        verdict.textContent = `${describe(operator, machine, result)} Tentativa registrada às ${formatTime(now)}.`;
        verdictWarn.hidden = result.reason !== "expiring";
        if (result.reason === "expiring") verdictWarn.querySelector("span:last-child").textContent = `Atenção: esta capacitação vence em ${result.daysLeft} dias.`;
        renderLog(true);
      };

      // Se a placa saiu da tela, volta até ela para o veredito ser visto.
      if (signal.getBoundingClientRect().top < 0) signal.scrollIntoView({ behavior: motionOK() ? "smooth" : "auto" });

      if (!motionOK()) {
        swap();
        shape.setAttribute("rx", result.granted ? SQUARE : DISC);
        if (window.gsap) gsap.set(badge, { x: 0, y: 0, rotation: 0, scale: 1 });
        clearTimeout(ledTimer);
        ledTimer = setTimeout(() => { pad.dataset.led = "idle"; }, 1800);
        return;
      }

      // Um toque novo conclui o anterior antes de começar.
      timeline?.progress(1);

      const box = signal.getBoundingClientRect();
      const padBox = pad.getBoundingClientRect();
      const badgeBox = badge.getBoundingClientRect();
      const antenna = { x: padBox.left + 26, y: padBox.top + padBox.height / 2 };
      const origin = { x: antenna.x - box.left, y: antenna.y - box.top };
      const reach = Math.hypot(Math.max(origin.x, box.width - origin.x), Math.max(origin.y, box.height - origin.y));
      const toX = gsap.getProperty(badge, "x") + padBox.left + Math.min(64, padBox.width * 0.3) - (badgeBox.left + badgeBox.width / 2);
      const toY = gsap.getProperty(badge, "y") + antenna.y - (badgeBox.top + badgeBox.height / 2);
      const outgoing = wasGranted ? glyphs.go : glyphs.stop;
      const incoming = result.granted ? glyphs.go : glyphs.stop;
      const arrive = 0.3; // o crachá encosta no leitor
      const decide = arrive + 0.3; // o leitor termina de ler
      const landed = decide + (colorChanges ? 0.45 : 0.1); // a placa mostra o veredito
      const scramble = { progress: 0 };

      timeline = gsap.timeline({ defaults: { ease: "expo.out" } });

      // 1. O crachá vai até o leitor e a placa apaga o que dizia.
      timeline
        .to(badge, { x: toX, y: toY, rotation: 6, scale: 0.92, duration: arrive, ease: "power3.out", overwrite: true }, 0)
        .to(letters, { rotationX: -88, autoAlpha: 0, transformPerspective: 700, duration: 0.18, ease: "power2.in", stagger: 0.018 }, 0)
        .to(message, { autoAlpha: 0, duration: 0.15, ease: "power1.in" }, 0)
        .to(outgoing, { scale: 0.55, opacity: 0, svgOrigin: "60 60", duration: 0.25, ease: "power2.in" }, 0);

      // 2. O leitor lê: o pulso dispara e o número do RFID embaralha.
      timeline
        .call(() => {
          pad.dataset.led = "reading";
          message.textContent = `Lendo RFID ${operator.rfid}`;
        }, null, arrive)
        .fromTo(ping, { scale: 1, opacity: 0.9 }, { scale: 9, opacity: 0, duration: 0.6, ease: "power2.out", immediateRender: false }, arrive)
        .to(message, { autoAlpha: 1, duration: 0.08 }, arrive)
        .to(scramble, {
          progress: 1,
          duration: decide - arrive,
          ease: "none",
          onUpdate: () => {
            const code = scramble.progress < 1 ? String(Math.floor(Math.random() * 10000)).padStart(4, "0") : operator.rfid;
            message.textContent = `Lendo RFID ${code}`;
          },
        }, arrive);

      // 3. A cor do veredito se espalha a partir do leitor, como um disco de placa.
      if (colorChanges) {
        timeline
          .set(flood, { x: origin.x, y: origin.y, xPercent: -50, yPercent: -50, scale: 0, autoAlpha: 1, backgroundColor: token(result.granted ? "--green" : "--red") }, decide)
          .to(flood, { scale: (reach * 2) / flood.offsetWidth, duration: landed - decide, ease: "power2.inOut" }, decide);
      }

      // 4. A placa mostra o veredito: a chapa muda de forma, as letras giram.
      timeline
        .to(message, { autoAlpha: 0, duration: 0.1, ease: "power1.in" }, landed - 0.1)
        .call(swap, null, landed)
        .set(flood, { autoAlpha: 0 }, landed)
        .set([glyphs.stop, glyphs.go], { scale: 1, opacity: 1 }, landed)
        .to(shape, { attr: { rx: result.granted ? SQUARE : DISC }, duration: 0.55 }, landed)
        .fromTo(incoming, { scale: 0.55, opacity: 0 }, { scale: 1, opacity: 1, svgOrigin: "60 60", duration: 0.5, immediateRender: false }, landed)
        .fromTo(incoming.querySelectorAll("[data-draw]"), { strokeDasharray: 1, strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: 0.45, ease: "power2.inOut", stagger: 0.12, immediateRender: false }, landed + 0.05)
        .fromTo(letters, { rotationX: 88, autoAlpha: 0 }, { rotationX: 0, autoAlpha: 1, transformPerspective: 700, duration: 0.6, stagger: 0.03, immediateRender: false }, landed)
        .fromTo(message, { y: 10, autoAlpha: 0 }, { y: 0, autoAlpha: 1, duration: 0.5, immediateRender: false }, landed + 0.12)
        .to(badge, { x: 0, y: 0, rotation: 0, scale: 1, duration: 0.7 }, landed + 0.25);

      // Liberado: o símbolo assenta. Bloqueado: a placa balança a cabeça.
      if (result.granted) {
        timeline.fromTo(symbol, { rotation: -14, scale: 0.9 }, { rotation: 0, scale: 1, duration: 0.8, immediateRender: false }, landed);
      } else {
        timeline
          .to(symbol, { keyframes: { x: [0, -16, 13, -9, 5, 0] }, duration: 0.5, ease: "power2.out" }, landed)
          .call(() => navigator.userActivation?.hasBeenActive && navigator.vibrate?.(60), null, landed);
      }

      const sheen = window.signage?.sweep(signal);
      if (sheen) timeline.add(sheen, landed + 0.1);
      timeline.call(() => { pad.dataset.led = "idle"; }, null, landed + 1.8);
    });

    // Arrastar o crachá até o leitor também vale como aproximar.
    if (window.gsap) {
      let grab = null;

      const overPad = () => {
        const card = badge.getBoundingClientRect();
        const target = pad.getBoundingClientRect();
        return card.right > target.left && card.left < target.right && card.bottom > target.top && card.top < target.bottom;
      };

      const release = () => {
        if (!grab) return;
        grab = null;
        badge.classList.remove("is-dragging");
        pad.classList.remove("is-target");
        if (overPad()) reader.requestSubmit();
        else gsap.to(badge, { x: 0, y: 0, rotation: 0, scale: 1, duration: motionOK() ? 0.6 : 0, ease: "expo.out" });
      };

      badge.addEventListener("pointerdown", (event) => {
        timeline?.progress(1);
        grab = { x: event.clientX - gsap.getProperty(badge, "x"), y: event.clientY - gsap.getProperty(badge, "y") };
        badge.setPointerCapture(event.pointerId);
        badge.classList.add("is-dragging");
        gsap.to(badge, { scale: 1.05, rotation: -4, duration: motionOK() ? 0.2 : 0, ease: "power2.out" });
      });

      badge.addEventListener("pointermove", (event) => {
        if (!grab) return;
        gsap.set(badge, { x: event.clientX - grab.x, y: event.clientY - grab.y });
        pad.classList.toggle("is-target", overPad());
      });

      badge.addEventListener("pointerup", release);
      badge.addEventListener("pointercancel", release);
    }
  }

  // As três conferências -----------------------------------------------------
  const checks = document.querySelector("[data-checks]");

  if (checks && window.gsap && window.ScrollTrigger) {
    const section = checks.closest("section");
    const items = gsap.utils.toArray(".step", checks);
    const discs = items.map((item) => item.querySelector(".sign-item-symbol"));
    const stamps = items.map((item) => item.querySelector(".step-check"));
    const rail = checks.querySelector("[data-rail]");
    const fill = checks.querySelector("[data-rail-fill]");
    const pass = checks.querySelector("[data-pass]");
    const plates = checks.querySelector("[data-decision]").children;
    const media = gsap.matchMedia();

    // Tela larga: a seção fica presa enquanto o crachá passa pelas conferências.
    media.add("(min-width: 60rem) and (min-height: 34rem) and (prefers-reduced-motion: no-preference)", () => {
      // Distância do início do trilho até o centro de um disco.
      const at = (disc) => {
        const target = disc.getBoundingClientRect();
        return target.left + target.width / 2 - rail.getBoundingClientRect().left;
      };

      gsap.set(items, { opacity: 0.28 });
      gsap.set(stamps, { scale: 0, rotation: -40 });
      gsap.set(fill, { scaleX: 0 });
      gsap.set(plates, { y: 60, autoAlpha: 0 });
      gsap.set(pass, { x: -70, autoAlpha: 1 });

      const timeline = gsap.timeline({
        defaults: { ease: "none" },
        scrollTrigger: {
          trigger: section,
          start: () => `top ${document.querySelector(".topbar").offsetHeight}px`,
          end: "+=1500",
          pin: true,
          scrub: 0.6,
          invalidateOnRefresh: true,
        },
      });

      items.forEach((item, index) => {
        timeline
          .to(pass, { x: () => at(discs[index]) - pass.getBoundingClientRect().width / 2, duration: 1, ease: "power1.inOut" })
          .to(fill, { scaleX: () => at(discs[index]) / rail.offsetWidth, duration: 1, ease: "power1.inOut" }, "<")
          .to(item, { opacity: 1, duration: 0.25 }, ">-0.1")
          .to(stamps[index], { scale: 1, rotation: 0, duration: 0.3, ease: "back.out(2.2)" }, "<")
          .fromTo(discs[index], { scale: 1 }, { scale: 1.1, duration: 0.15, yoyo: true, repeat: 1 }, "<");
      });

      // Depois da terceira, o crachá segue e a decisão aparece.
      timeline
        .to(pass, { x: () => rail.offsetWidth + 70, autoAlpha: 0, duration: 0.7, ease: "power1.in" })
        .to(fill, { scaleX: 1, duration: 0.7 }, "<")
        .to(plates, { y: 0, autoAlpha: 1, duration: 0.6, stagger: 0.3, ease: "power2.out" }, "<0.2")
        .to({}, { duration: 0.4 });
    });

    // Tela estreita: cada conferência acende quando entra na tela.
    media.add("(max-width: 59.99rem) and (prefers-reduced-motion: no-preference), (max-height: 33.99rem) and (prefers-reduced-motion: no-preference)", () => {
      items.forEach((item, index) => {
        const trigger = { trigger: item, start: "top 78%", once: true };
        gsap.from(item, { opacity: 0.28, duration: 0.5, scrollTrigger: trigger });
        gsap.from(stamps[index], { scale: 0, rotation: -40, duration: 0.5, ease: "back.out(2.2)", delay: 0.15, scrollTrigger: trigger });
      });
      gsap.from(plates, { y: 40, autoAlpha: 0, duration: 0.7, ease: "expo.out", stagger: 0.15, scrollTrigger: { trigger: plates[0], start: "top 85%", once: true } });
    });

    // A seção presa aumenta a página: as posições são recalculadas na ordem da tela.
    ScrollTrigger.sort();
    ScrollTrigger.refresh();
  }

  // Login de demonstração ----------------------------------------------------
  const login = document.querySelector("[data-demo-login]");

  if (login) {
    const sign = login.closest("[data-login-sign]");
    const head = sign.querySelector(".login-head");
    const error = login.querySelector("[data-form-message]");
    const { email, senha: password } = login.elements;

    // A placa de acesso restrito é fixada ao abrir.
    sign.style.animation = "none";
    sign.style.visibility = "visible";
    if (motionOK()) {
      gsap.from(sign, { y: -70, rotation: -3, autoAlpha: 0, duration: 0.9, ease: "expo.out" });
      if (window.SplitText) {
        const split = SplitText.create(head.querySelector(".sign-word"), { type: "words, chars" });
        gsap.from(split.chars, { rotationX: 90, autoAlpha: 0, transformPerspective: 700, duration: 0.6, ease: "expo.out", stagger: 0.035, delay: 0.3, onComplete: () => split.revert() });
      }
    }

    login.addEventListener("submit", (event) => {
      event.preventDefault();
      const missing = [email, password].find((field) => !field.value.trim());
      const invalid = missing ?? (email.validity.valid ? null : email);
      [email, password].forEach((field) => field.setAttribute("aria-invalid", String(field === invalid)));

      // Acesso negado: a placa balança a cabeça, como no simulador.
      if (invalid) {
        error.textContent = missing ? "Preencha o e-mail e a senha para continuar." : "Digite um e-mail válido, como supervisor@empresa.com.";
        invalid.focus();
        if (motionOK()) gsap.fromTo(sign, { x: 0 }, { keyframes: { x: [0, -14, 12, -8, 5, 0] }, duration: 0.5, ease: "power2.out" });
        return;
      }

      error.textContent = "";
      const enter = () => { window.location.href = "dashboard.html"; };
      if (!motionOK()) {
        enter();
        return;
      }

      // Acesso aceito: a placa vira "Liberado" e o painel abre.
      gsap.timeline()
        .to(head, { rotationX: 90, transformPerspective: 800, duration: 0.18, ease: "power2.in" })
        .call(() => {
          sign.dataset.state = "granted";
          head.querySelector(".sign-word").textContent = "Liberado";
          head.querySelector("p").textContent = "Abrindo o painel de demonstração.";
        })
        .to(head, { rotationX: 0, duration: 0.35, ease: "expo.out" })
        .call(enter, null, "+=0.1");
    });
  }

  // Painel do supervisor -----------------------------------------------------
  const rail = document.querySelector("[data-dashboard-sidebar]");
  const railButton = document.querySelector("[data-open-sidebar]");

  const setRail = (open) => {
    rail.classList.toggle("open", open);
    railButton.setAttribute("aria-expanded", String(open));
  };

  railButton?.addEventListener("click", () => setRail(true));
  document.querySelectorAll("[data-close-sidebar]").forEach((button) => button.addEventListener("click", () => setRail(false)));
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && rail?.classList.contains("open")) setRail(false);
  });

  const dateLabel = document.querySelector("[data-dashboard-date]");
  if (dateLabel) dateLabel.textContent = new Intl.DateTimeFormat("pt-BR", { dateStyle: "full" }).format(today);

  // As tentativas feitas no simulador entram no topo da tabela e nos totais.
  const rows = document.querySelector("[data-attempt-rows]");
  const sessionGranted = attempts.filter((attempt) => attempt.granted).length;

  if (rows && attempts.length) {
    rows.prepend(...attempts.map((attempt) => {
      const row = element("tr", "is-session");
      const who = element("td");
      const result = element("td");
      who.append(element("strong", "", attempt.operator), element("small", "data", `RFID ${attempt.rfid}`));
      result.append(statusChip(attempt.granted));
      row.append(element("td", "data", attempt.time), who, element("td", "", attempt.machine), result);
      return row;
    }));

    const add = (name, amount) => {
      const counter = document.querySelector(`[data-count="${name}"]`);
      counter.textContent = String(Number(counter.textContent) + amount).padStart(2, "0");
    };
    add("granted", sessionGranted);
    add("denied", attempts.length - sessionGranted);

    const note = document.querySelector("[data-session-note]");
    note.textContent = attempts.length === 1 ? "Inclui 1 tentativa feita por você no simulador (em amarelo)." : `Inclui ${attempts.length} tentativas feitas por você no simulador (em amarelo).`;
  }

  // Gráfico de tentativas por hora, desenhado a partir da tabela que está no HTML.
  const chart = document.querySelector("[data-chart]");

  if (chart) {
    const SVG = "http://www.w3.org/2000/svg";
    const plot = chart.querySelector("[data-chart-plot]");
    const table = chart.querySelector("[data-chart-table]");
    const body = table.querySelector("tbody");
    const tip = element("div", "chart-tip");
    const count = (amount, one, many) => `${amount === 1 ? one : many}`;

    if (attempts.length) {
      const row = element("tr");
      row.append(element("td", "", "agora"), element("td", "", String(sessionGranted)), element("td", "", String(attempts.length - sessionGranted)));
      body.append(row);
      chart.querySelector("[data-chart-note]").textContent = "Hoje, das 7h às 14h, e as suas tentativas (agora).";
    }

    const data = [...body.rows].map((row) => ({
      hour: row.cells[0].textContent,
      granted: Number(row.cells[1].textContent) || 0,
      denied: Number(row.cells[2].textContent) || 0,
    }));

    const shape = (tag, attributes, text) => {
      const node = document.createElementNS(SVG, tag);
      Object.entries(attributes).forEach(([name, value]) => node.setAttribute(name, value));
      if (text !== undefined) node.textContent = text;
      return node;
    };

    // Coluna com a ponta de cima arredondada e a base reta.
    const column = (x, top, bottom, width, rounded) => {
      const radius = rounded ? Math.min(4, (bottom - top) / 2) : 0;
      return `M${x} ${bottom}V${top + radius}Q${x} ${top} ${x + radius} ${top}H${x + width - radius}Q${x + width} ${top} ${x + width} ${top + radius}V${bottom}Z`;
    };

    const describeHour = (entry) => `${entry.hour}: ${entry.granted} ${count(entry.granted, "liberado", "liberados")}, ${entry.denied} ${count(entry.denied, "bloqueado", "bloqueados")}`;

    const render = () => {
      const width = plot.clientWidth;
      const height = 220;
      const margin = { top: 20, right: 6, bottom: 26, left: 26 };
      const innerWidth = width - margin.left - margin.right;
      const innerHeight = height - margin.top - margin.bottom;
      const peak = Math.max(...data.map((entry) => entry.granted + entry.denied));
      const max = Math.max(6, Math.ceil(peak / 2) * 2);
      const y = (value) => margin.top + innerHeight - (value / max) * innerHeight;
      const band = innerWidth / data.length;
      const bar = Math.min(24, band * 0.5);
      const svg = shape("svg", { viewBox: `0 0 ${width} ${height}`, role: "group", "aria-label": "Tentativas por hora, liberadas e bloqueadas" });

      for (let tick = 0; tick <= max; tick += 2) {
        svg.append(
          shape("line", { class: "chart-grid", x1: margin.left, x2: width - margin.right, y1: y(tick), y2: y(tick) }),
          shape("text", { class: "chart-tick", x: margin.left - 8, y: y(tick) + 4, "text-anchor": "end" }, String(tick)),
        );
      }

      data.forEach((entry, index) => {
        const x = margin.left + band * index + (band - bar) / 2;
        const total = entry.granted + entry.denied;
        const group = shape("g", { class: "chart-band", tabindex: "0", role: "img", "aria-label": describeHour(entry) });
        const columns = shape("g", { class: "chart-columns" });

        if (entry.granted) columns.append(shape("path", { class: "chart-ok", d: column(x, y(entry.granted), y(0), bar, !entry.denied) }));
        // O bloqueado empilha acima, com 2px de respiro entre os dois.
        if (entry.denied) columns.append(shape("path", { class: "chart-blocked", d: column(x, y(total), y(entry.granted) - (entry.granted ? 2 : 0), bar, true) }));

        group.append(
          shape("rect", { class: "chart-hit", x: margin.left + band * index + 1, y: margin.top - 14, width: band - 2, height: innerHeight + 14, rx: 4 }),
          columns,
          shape("text", { class: "chart-hour", x: x + bar / 2, y: height - 8, "text-anchor": "middle" }, entry.hour),
        );
        // Só os bloqueios levam o número: são eles que pedem atenção.
        if (entry.denied) group.append(shape("text", { class: "chart-value", x: x + bar / 2, y: y(total) - 6, "text-anchor": "middle" }, String(entry.denied)));

        const show = () => {
          const granted = element("div");
          const denied = element("div");
          granted.append(element("b", "", String(entry.granted)), ` ${count(entry.granted, "liberado", "liberados")}`);
          denied.append(element("b", "", String(entry.denied)), ` ${count(entry.denied, "bloqueado", "bloqueados")}`);
          tip.replaceChildren(granted, denied, element("span", "", entry.hour));
          tip.style.left = `${x + bar / 2}px`;
          tip.style.top = `${y(total)}px`;
          tip.hidden = false;
        };
        const hide = () => { tip.hidden = true; };

        group.addEventListener("pointerenter", show);
        group.addEventListener("focus", show);
        group.addEventListener("pointerleave", hide);
        group.addEventListener("blur", hide);
        svg.append(group);
      });

      tip.hidden = true;
      plot.replaceChildren(svg, tip);
      return svg;
    };

    // Com o gráfico na tela, a tabela vira uma opção recolhida.
    table.open = false;
    const first = render();
    if (motionOK()) gsap.from(first.querySelectorAll(".chart-columns"), { scaleY: 0, transformOrigin: "50% 100%", duration: 0.7, ease: "power3.out", stagger: 0.05, delay: 0.15 });

    let lastWidth = plot.clientWidth;
    new ResizeObserver(() => {
      if (plot.clientWidth === lastWidth) return;
      lastWidth = plot.clientWidth;
      render();
    }).observe(plot);
  }

  // Entrada do painel: rápida, para não fazer ninguém esperar.
  if (document.querySelector(".summary") && motionOK()) {
    document.querySelectorAll(".summary strong").forEach((figure) => {
      const end = Number(figure.textContent);
      const digits = figure.textContent.length;
      const counter = { value: 0 };
      gsap.to(counter, { value: end, duration: 0.8, ease: "power2.out", onUpdate: () => { figure.textContent = String(Math.round(counter.value)).padStart(digits, "0"); } });
    });
    gsap.from("[data-attempt-rows] tr", { y: 8, autoAlpha: 0, duration: 0.35, ease: "power2.out", stagger: 0.04 });
    gsap.from(".machine-plate", { y: 18, autoAlpha: 0, duration: 0.5, ease: "expo.out", stagger: 0.06 });
  }
});
