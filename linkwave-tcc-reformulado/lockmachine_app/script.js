// LockMachine: simulador do leitor, registro de tentativas, login e painel.
document.addEventListener("DOMContentLoaded", () => {
  const DAY = 86400000;
  const today = new Date();
  const daysFromNow = (days) => new Date(today.getTime() + days * DAY);
  const formatDate = (date) => new Intl.DateTimeFormat("pt-BR").format(date);
  const formatTime = (date) => new Intl.DateTimeFormat("pt-BR", { hour: "2-digit", minute: "2-digit" }).format(date);

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

  const statusChip = (granted) => {
    const chip = document.createElement("span");
    chip.className = `status ${granted ? "status--ok" : "status--blocked"}`;
    chip.textContent = granted ? "Liberado" : "Bloqueado";
    return chip;
  };

  const element = (tag, className, text) => {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text) node.textContent = text;
    return node;
  };

  // Registro na página do projeto
  const logList = document.querySelector("[data-log]");
  const logEmpty = document.querySelector("[data-log-empty]");

  const renderLog = () => {
    if (!logList) return;
    logEmpty.hidden = attempts.length > 0;
    logList.replaceChildren(...attempts.slice(0, 5).map((attempt) => {
      const item = element("li");
      const who = element("span", "log-who");
      who.append(element("b", "", attempt.operator), element("span", "", `RFID ${attempt.rfid} · ${attempt.machine}`));
      item.append(element("time", "data", attempt.time), who, statusChip(attempt.granted));
      return item;
    }));
  };

  renderLog();

  // Simulador do leitor ------------------------------------------------------
  const signal = document.querySelector("[data-signal]");
  const reader = document.querySelector("[data-reader]");

  if (signal && reader) {
    const word = signal.querySelector("[data-word]");
    const message = signal.querySelector("[data-message]");
    const flood = signal.querySelector("[data-flood]");
    const stopSymbol = signal.querySelector('[data-symbol="stop"]');
    const goSymbol = signal.querySelector('[data-symbol="go"]');
    const verdict = document.querySelector("[data-verdict]");
    const verdictWarn = document.querySelector("[data-verdict-warn]");
    const submit = reader.querySelector("[type=submit]");
    const canAnimate = () => window.gsap && !window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const token = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

    // A palavra de sinal vira nove plaquetas, uma por letra (BLOQUEADO é a mais longa).
    const SLOTS = 9;
    const letters = Array.from({ length: SLOTS }, () => element("span"));
    const setWord = (text) => letters.forEach((letter, index) => { letter.textContent = text[index] ?? ""; });
    setWord(word.textContent.trim());
    word.replaceChildren(...letters);

    let timeline;

    reader.addEventListener("submit", (event) => {
      event.preventDefault();
      const operator = OPERATORS[reader.elements.operator.value];
      const machine = MACHINES[reader.elements.machine.value];
      const now = new Date();
      const result = checkAccess(operator, machine, now);
      const state = result.granted ? "granted" : "denied";
      const colorChanges = (signal.dataset.state === "granted") !== result.granted;

      attempts = [{ time: formatTime(now), operator: operator.name, rfid: operator.rfid, machine: machine.name, granted: result.granted }, ...attempts].slice(0, 20);
      saveAttempts(attempts);

      // Troca o que a placa diz. Sozinha, já deixa a página no estado final.
      const swap = () => {
        signal.dataset.state = state;
        setWord(result.granted ? "Liberado" : "Bloqueado");
        message.textContent = `${operator.name} · ${machine.name}`;
        verdict.textContent = `${describe(operator, machine, result)} Tentativa registrada às ${formatTime(now)}.`;
        verdictWarn.hidden = result.reason !== "expiring";
        if (result.reason === "expiring") verdictWarn.querySelector("span:last-child").textContent = `Atenção: esta capacitação vence em ${result.daysLeft} dias.`;
        renderLog();
      };

      // Se a placa saiu da tela, volta até ela para o veredito ser visto.
      if (signal.getBoundingClientRect().top < 0) signal.scrollIntoView({ behavior: canAnimate() ? "smooth" : "auto" });

      if (!canAnimate()) {
        swap();
        return;
      }

      // Um toque novo conclui o anterior antes de começar.
      timeline?.progress(1);
      const active = signal.dataset.state === "granted" ? goSymbol : stopSymbol;
      const next = result.granted ? goSymbol : stopSymbol;
      const box = signal.getBoundingClientRect();
      const button = submit.getBoundingClientRect();
      const x = button.left + button.width / 2 - box.left;
      const y = button.top + button.height / 2 - box.top;
      const reach = Math.hypot(Math.max(x, box.width - x), Math.max(y, box.height - y));

      timeline = gsap.timeline({ defaults: { ease: "expo.out" } });
      timeline
        .to(letters, { rotationX: -88, autoAlpha: 0, duration: 0.18, ease: "power2.in", stagger: 0.018, transformPerspective: 700 }, 0)
        .to(message, { autoAlpha: 0, duration: 0.15, ease: "power1.in" }, 0)
        .to(active, { scale: 0.82, duration: 0.2, ease: "power2.in" }, 0);

      // A cor do veredito se espalha a partir do leitor, como um disco de placa.
      if (colorChanges) {
        timeline
          .set(flood, { x, y, xPercent: -50, yPercent: -50, scale: 0, autoAlpha: 1, backgroundColor: token(result.granted ? "--green" : "--red") }, 0)
          .to(flood, { scale: (reach * 2) / flood.offsetWidth, duration: 0.5, ease: "power2.inOut" }, 0);
      }

      const landed = colorChanges ? 0.5 : 0.24;
      timeline
        .call(swap, null, landed)
        .set(flood, { autoAlpha: 0 }, landed)
        .set(active, { scale: 1 }, landed)
        .fromTo(letters, { rotationX: 88, autoAlpha: 0 }, { rotationX: 0, autoAlpha: 1, duration: 0.6, stagger: 0.03, transformPerspective: 700, immediateRender: false }, landed)
        .fromTo(message, { y: 10, autoAlpha: 0 }, { y: 0, autoAlpha: 1, duration: 0.5, immediateRender: false }, landed + 0.12);

      // Liberado: o símbolo assenta. Bloqueado: a placa balança a cabeça.
      if (result.granted) {
        timeline.fromTo(next, { scale: 0.7, rotation: -12 }, { scale: 1, rotation: 0, duration: 0.7, immediateRender: false }, landed);
      } else {
        timeline.to(next, { keyframes: { x: [0, -14, 12, -8, 5, 0] }, duration: 0.5, ease: "power2.out" }, landed);
      }
    });
  }

  // As três conferências acendem em ordem, conforme a rolagem ------------------
  const steps = document.querySelector("[data-steps]");
  if (steps && window.gsap && window.ScrollTrigger) {
    gsap.matchMedia().add("(prefers-reduced-motion: no-preference)", () => {
      gsap.from(steps.querySelectorAll(".step-check"), {
        scale: 0,
        rotation: -30,
        transformOrigin: "50% 50%",
        duration: 0.4,
        ease: "none",
        stagger: 0.5,
        scrollTrigger: { trigger: steps, start: "top 72%", end: "bottom 62%", scrub: 0.5 },
      });
    });
  }

  // Login de demonstração ----------------------------------------------------
  const login = document.querySelector("[data-demo-login]");
  login?.addEventListener("submit", (event) => {
    event.preventDefault();
    const email = login.elements.email.value.trim();
    const password = login.elements.senha.value.trim();
    const error = document.querySelector("[data-form-message]");
    if (!email || !password) {
      error.textContent = "Preencha o e-mail e a senha para continuar.";
      return;
    }
    error.textContent = "";
    window.location.href = "dashboard.html";
  });

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
  if (rows && attempts.length) {
    rows.prepend(...attempts.map((attempt) => {
      const row = element("tr", "is-session");
      const who = element("td");
      who.append(element("strong", "", attempt.operator), element("small", "data", `RFID ${attempt.rfid}`));
      const result = element("td");
      result.append(statusChip(attempt.granted));
      row.append(element("td", "data", attempt.time), who, element("td", "", attempt.machine), result);
      return row;
    }));

    const add = (name, amount) => {
      const counter = document.querySelector(`[data-count="${name}"]`);
      counter.textContent = String(Number(counter.textContent) + amount).padStart(2, "0");
    };
    const granted = attempts.filter((attempt) => attempt.granted).length;
    add("granted", granted);
    add("denied", attempts.length - granted);

    const note = document.querySelector("[data-session-note]");
    note.textContent = attempts.length === 1 ? "Inclui 1 tentativa feita por você no simulador (em amarelo)." : `Inclui ${attempts.length} tentativas feitas por você no simulador (em amarelo).`;
  }
});
