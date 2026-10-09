// Comportamento comum aos dois sites: menu, a placa como objeto e o movimento.
document.addEventListener("DOMContentLoaded", () => {
  const root = document.documentElement;

  // Menu (telas estreitas) -----------------------------------------------------
  const menuButton = document.querySelector("[data-menu-toggle]");
  const menu = document.querySelector("[data-menu]");

  const setMenu = (open) => {
    menu.toggleAttribute("data-open", open);
    menuButton.setAttribute("aria-expanded", String(open));
    menuButton.setAttribute("aria-label", open ? "Fechar menu" : "Abrir menu");
    menuButton.querySelector(".icon").className = `icon ${open ? "icon--close" : "icon--menu"}`;
  };

  menuButton?.addEventListener("click", () => setMenu(!menu.hasAttribute("data-open")));
  menu?.querySelectorAll("a").forEach((link) => link.addEventListener("click", () => setMenu(false)));
  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape" || !menu?.hasAttribute("data-open")) return;
    setMenu(false);
    menuButton.focus();
  });

  // Chave das animações (rodapé) -----------------------------------------------
  // Só aparece quando o sistema pede movimento reduzido: a pessoa pode ligar as
  // animações por conta própria e desligar de novo. Quem decide e guarda a
  // escolha é o head.js.
  const motionSwitch = document.querySelector("[data-motion-switch]");

  if (motionSwitch && motion.reducedBySystem) {
    const status = motionSwitch.querySelector("[data-motion-status]");
    const toggle = motionSwitch.querySelector("[data-motion-toggle]");

    if (motion.forced) {
      status.textContent = "Animações ligadas neste navegador.";
      toggle.textContent = "Desligar animações";
    }

    toggle.addEventListener("click", () => {
      if (!motion.force(!motion.forced)) status.textContent = "Este navegador não permite guardar a escolha.";
    });
    motionSwitch.hidden = false;
  }

  // A placa como objeto: filete duplo, parafusos e barra de progresso ------------
  const SVG = "http://www.w3.org/2000/svg";
  const NOTCH = 0.85; // raio do arco que desvia do parafuso, em diâmetros de parafuso
  const GAP = 0.28; // distância entre o filete grosso e o fino, na mesma medida

  const decoration = (tag, className) => {
    const node = document.createElement(tag);
    node.className = className;
    node.setAttribute("aria-hidden", "true");
    return node;
  };

  // Quatro parafusos. A fenda (o <b>) é a parte que gira.
  const screws = () => {
    const group = decoration("span", "screws");
    group.append(...Array.from({ length: 4 }, () => {
      const head = document.createElement("i");
      head.append(document.createElement("b"));
      return head;
    }));
    return group;
  };

  // Contorno de uma caixa que desvia dos quatro cantos com um arco. `offset` é a
  // distância do centro do parafuso até o canto; `radius`, o raio do desvio.
  const notched = (width, height, offset, radius) => {
    const reach = offset + Math.sqrt(Math.max(radius ** 2 - offset ** 2, 0));
    const arc = `A${radius} ${radius} 0 0 0`;
    return `M${reach} 0H${width - reach}${arc} ${width} ${reach}V${height - reach}${arc} ${width - reach} ${height}H${reach}${arc} 0 ${height - reach}V${reach}${arc} ${reach} 0Z`;
  };

  // As medidas vêm da CSS: a caixa dos parafusos é a do filete, e cada parafuso
  // já está no lugar. Aqui só se desenham as duas linhas em volta deles.
  const drawFrame = (surface) => {
    const box = surface.querySelector(":scope > .screws");
    const head = box.firstElementChild;
    const [thick, thin] = surface.querySelectorAll(":scope > .frame path");
    const radius = head.offsetWidth * NOTCH;
    const gap = head.offsetWidth * GAP;
    thick.setAttribute("d", notched(box.offsetWidth, box.offsetHeight, head.offsetLeft, radius));
    thin.setAttribute("d", notched(box.offsetWidth - 2 * gap, box.offsetHeight - 2 * gap, head.offsetLeft - gap, radius + gap));
    thin.setAttribute("transform", `translate(${gap} ${gap})`);
  };

  // Quando a placa ou o parafuso mudam de tamanho, o filete é redesenhado.
  const resized = new ResizeObserver((entries) => entries.forEach((entry) => drawFrame(entry.target.closest(".has-frame"))));

  document.querySelectorAll(".signal, .band--stop, .band--warn, .band--must, .band--safe, .plate").forEach((surface) => {
    const frame = document.createElementNS(SVG, "svg");
    const hardware = screws();
    frame.setAttribute("class", "frame");
    frame.setAttribute("aria-hidden", "true");
    frame.append(...["frame-line", "frame-line frame-line--thin"].map((className) => {
      const line = document.createElementNS(SVG, "path");
      line.setAttribute("class", className);
      line.setAttribute("pathLength", "1");
      return line;
    }));
    surface.classList.add("has-frame");
    surface.prepend(frame, hardware);
    drawFrame(surface);
    resized.observe(hardware);
    resized.observe(hardware.firstElementChild);
  });

  const signal = document.querySelector(".signal");
  const progress = signal ? decoration("span", "progress") : null;
  if (progress) document.querySelector(".topbar")?.append(progress);

  // Páginas sem a placa de abertura entram com os blocos data-rise subindo.
  const stages = [...document.querySelectorAll("[data-intro]")].filter((stage) => !stage.closest(".signal"));
  const reveal = (stage) => {
    stage.style.animation = "none";
    stage.style.visibility = "visible";
  };

  // Sem GSAP (ou com movimento reduzido) a página fica completa e parada.
  if (!window.gsap || !window.ScrollTrigger) {
    signal?.classList.add("is-open");
    document.querySelectorAll("[data-intro]").forEach(reveal);
    return;
  }
  gsap.registerPlugin(ScrollTrigger);
  if (window.SplitText) gsap.registerPlugin(SplitText);
  gsap.config({ nullTargetWarn: false });

  // motion.query (do head.js) vale quando a página pode animar: o sistema
  // permite, ou a pessoa ligou as animações pela chave do rodapé.
  const media = gsap.matchMedia();

  media.add(motion.query, () => {
    // Desenha os traços marcados com data-draw (eles têm pathLength="1").
    const draw = (scope) => gsap.fromTo(
      scope.querySelectorAll("[data-draw]"),
      { strokeDasharray: 1, strokeDashoffset: 1 },
      { strokeDashoffset: 0, duration: 0.6, ease: "power2.inOut", stagger: 0.18 },
    );

    // A placa é fixada: os dois filetes se desenham e os parafusos são apertados
    // em cruz (um canto, depois o oposto), como numa chapa de verdade. Cada
    // parafuso chega de fora e a fenda dá uma volta e meia até parar. A escala
    // inicial não passa de 1.6 para o parafuso nunca sair da placa no celular.
    const mount = (surface) => {
      const timeline = gsap.timeline();
      const lines = surface.querySelectorAll(":scope > .frame path");
      const heads = surface.querySelectorAll(":scope > .screws i");
      if (lines.length) timeline.fromTo(lines, { strokeDasharray: 1, strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: 1.1, ease: "power2.inOut", stagger: 0.12 }, 0);
      [0, 3, 1, 2].forEach((corner, order) => {
        const head = heads[corner];
        if (!head) return;
        const at = 0.35 + order * 0.13;
        timeline
          .from(head, { scale: 1.6, autoAlpha: 0, duration: 0.5, ease: "power3.out" }, at)
          .from(head.firstElementChild, { rotation: -540, duration: 0.9, ease: "power3.out" }, at);
      });
      return timeline;
    };

    // As letras da palavra de sinal giram como plaquetas, uma a uma.
    const flipWord = (word, timeline, at) => {
      if (!word) return;
      gsap.set(word, { autoAlpha: 0 });
      timeline.call(() => {
        gsap.set(word, { autoAlpha: 1 });
        const split = word.children.length || !window.SplitText ? null : SplitText.create(word, { type: "chars", smartWrap: true });
        const letters = split ? split.chars : word.children.length ? [...word.children] : word;
        gsap.from(letters, {
          rotationX: 90,
          autoAlpha: 0,
          transformPerspective: 700,
          duration: 0.6,
          ease: "expo.out",
          stagger: 0.045,
          onComplete: () => split?.chars[0]?.isConnected && split.revert(),
        });
      }, null, at);
    };

    // A mensagem sobe linha por linha, de trás de uma máscara.
    const riseLines = (message, timeline, at) => {
      if (!message) return;
      gsap.set(message, { autoAlpha: 0 });
      timeline.call(() => {
        gsap.set(message, { autoAlpha: 1 });
        if (!window.SplitText) {
          gsap.from(message, { y: 20, autoAlpha: 0, duration: 0.7, ease: "expo.out" });
          return;
        }
        const split = SplitText.create(message, { type: "lines", mask: "lines" });
        gsap.from(split.lines, {
          yPercent: 110,
          duration: 0.8,
          ease: "expo.out",
          stagger: 0.09,
          onComplete: () => split.lines[0]?.isConnected && split.revert(),
        });
      }, null, at);
    };

    // O brilho do esmalte atravessa a placa.
    const sweep = (surface) => {
      let sheen = surface.querySelector(":scope > .sheen");
      if (!sheen) {
        sheen = decoration("span", "sheen");
        surface.prepend(sheen);
      }
      return gsap.fromTo(sheen, { xPercent: -100, autoAlpha: 1 }, {
        xPercent: 100,
        duration: 1.1,
        ease: "power2.inOut",
        onComplete: () => gsap.set(sheen, { autoAlpha: 0 }),
      });
    };

    // O script de cada site pode pedir o brilho (por exemplo, no veredito).
    window.signage = { sweep };

    // Abertura: a placa é parafusada na tela ------------------------------------
    let opening;

    const open = () => {
      const stage = signal?.querySelector("[data-intro]");
      signal?.classList.add("is-open");
      if (!stage || root.classList.contains("vt")) return;
      const symbol = signal.querySelector(".signal-symbol");
      stage.style.animation = "none";
      stage.style.visibility = "visible";

      opening = gsap.timeline({ defaults: { ease: "expo.out" } });
      opening
        .add(mount(signal), 0)
        .from(symbol, { xPercent: -80, rotation: -200, autoAlpha: 0, duration: 1 }, 0.15)
        .add(draw(symbol), 0.6);
      flipWord(signal.querySelector(".sign-word"), opening, 0.55);
      riseLines(signal.querySelector(".sign-message"), opening, 0.85);
      opening
        .from(signal.querySelector(".signal-panel"), { y: 56, autoAlpha: 0, duration: 0.9 }, 0.95)
        .add(sweep(signal), 1.25);
    };

    // Quem chega por transição entre páginas já vê a placa pronta.
    window.addEventListener("vt-arrival", () => opening?.progress(1), { once: true });
    (document.fonts?.ready ?? Promise.resolve()).then(open);

    stages.forEach((stage) => {
      reveal(stage);
      if (root.classList.contains("vt")) return;
      gsap.from(stage.querySelectorAll("[data-rise]"), { y: 44, autoAlpha: 0, duration: 0.9, ease: "expo.out", stagger: 0.12 });
    });

    // Cada placa entra do jeito do seu símbolo ----------------------------------
    const symbolIn = {
      // Proibido: o disco assenta, o anel se fecha e a barra corta.
      stop: (symbol) => gsap.timeline()
        .from(symbol, { scale: 0.5, rotation: -50, autoAlpha: 0, duration: 0.8, ease: "expo.out" })
        .add(draw(symbol), 0.2),
      // Atenção: pisca como um sinalizador e o ponto de exclamação cai.
      warn: (symbol) => gsap.timeline()
        .fromTo(symbol, { autoAlpha: 0 }, { keyframes: { autoAlpha: [0, 1, 0.15, 1, 0.3, 1] }, duration: 0.8, ease: "none" })
        .from(symbol.querySelector("[data-mark]"), { y: -26, autoAlpha: 0, duration: 0.5, ease: "expo.out" }, 0.35),
      // Condição segura: a chapa é carimbada e o visto se desenha.
      safe: (symbol) => gsap.timeline()
        .from(symbol, { scale: 1.35, rotation: 10, autoAlpha: 0, duration: 0.7, ease: "expo.out" })
        .add(draw(symbol), 0.25),
      // Siga: a seta chega pela esquerda.
      go: (symbol) => gsap.timeline()
        .from(symbol, { xPercent: -70, autoAlpha: 0, duration: 0.8, ease: "expo.out" }),
    };

    gsap.utils.toArray("[data-sign]").forEach((band) => {
      const timeline = gsap.timeline({ scrollTrigger: { trigger: band, start: "top 68%", once: true } });
      const symbol = band.querySelector(".symbol");
      const rest = band.querySelectorAll("[data-follow]");

      timeline.add(mount(band), 0);
      if (symbol) timeline.add((symbolIn[band.dataset.sign] ?? symbolIn.stop)(symbol), 0.15);
      flipWord(band.querySelector(".sign-word"), timeline, 0.3);
      riseLines(band.querySelector(".sign-message"), timeline, 0.55);
      if (rest.length) timeline.from(rest, { y: 28, autoAlpha: 0, duration: 0.8, ease: "expo.out", stagger: 0.1 }, 0.7);
    });

    // A seta do "siga" continua apontando enquanto a placa está na tela.
    gsap.utils.toArray("[data-nudge]").forEach((arrow) => {
      gsap.to(arrow, {
        x: 8,
        duration: 0.6,
        ease: "sine.inOut",
        repeat: -1,
        yoyo: true,
        scrollTrigger: { trigger: arrow, toggleActions: "play pause resume pause" },
      });
    });

    // Placas que formam uma lista são fixadas uma a uma, uma única vez.
    gsap.utils.toArray("[data-mount]").forEach((list) => {
      gsap.from(list.children, {
        y: 44,
        rotation: -2,
        autoAlpha: 0,
        duration: 0.9,
        ease: "expo.out",
        stagger: 0.09,
        scrollTrigger: { trigger: list, start: "top 84%", once: true },
      });
    });

    // As chapas menores também são fixadas quando entram na tela.
    gsap.utils.toArray(".plate").forEach((plate) => {
      gsap.timeline({ scrollTrigger: { trigger: plate, start: "top 85%", once: true } }).add(mount(plate), 0.2);
    });

    // Linhas de uma lista são reveladas da esquerda para a direita.
    gsap.utils.toArray("[data-wipe]").forEach((list) => {
      gsap.fromTo(list.children, { clipPath: "inset(0 100% 0 0)" }, {
        clipPath: "inset(0 0% 0 0)",
        duration: 0.9,
        ease: "power3.inOut",
        stagger: 0.14,
        clearProps: "clipPath",
        scrollTrigger: { trigger: list, start: "top 82%", once: true },
      });
    });

    // Discos de placa chegam rolando, como moedas.
    gsap.utils.toArray("[data-roll]").forEach((list) => {
      const trigger = { trigger: list, start: "top 80%", once: true };
      gsap.from(list.querySelectorAll(".sign-item-symbol"), { xPercent: -140, rotation: -220, autoAlpha: 0, duration: 1.1, ease: "expo.out", stagger: 0.14, scrollTrigger: trigger });
      gsap.from(list.querySelectorAll(".sign-item-text"), { y: 24, autoAlpha: 0, duration: 0.8, ease: "expo.out", stagger: 0.14, delay: 0.3, scrollTrigger: trigger });
    });

    // Fita de isolamento: corre sozinha e acelera com a rolagem -------------------
    gsap.utils.toArray("[data-tape]").forEach((tape) => {
      const track = tape.querySelector(".tape-track");
      const unit = track.innerHTML;
      for (let copies = 0; copies < 12 && track.scrollWidth < window.innerWidth * 1.2; copies += 1) track.insertAdjacentHTML("beforeend", unit);
      track.insertAdjacentHTML("beforeend", track.innerHTML);

      const loop = gsap.to(track, { xPercent: -50, duration: track.scrollWidth / 140, ease: "none", repeat: -1, paused: true });
      const watcher = ScrollTrigger.create({
        trigger: tape,
        start: "top bottom",
        end: "bottom top",
        onToggle: (self) => (self.isActive ? loop.play() : loop.pause()),
        onUpdate: (self) => {
          const push = gsap.utils.clamp(-6, 6, self.getVelocity() / 200);
          gsap.to(loop, {
            timeScale: push < 0 ? push - 1 : push + 1,
            duration: 0.2,
            overwrite: true,
            onComplete: () => gsap.to(loop, { timeScale: 1, duration: 1.2, overwrite: true }),
          });
        },
      });
      if (watcher.isActive) loop.play();
    });

    // Barra de progresso da rolagem.
    if (progress) gsap.to(progress, { scaleX: 1, ease: "none", scrollTrigger: { start: 0, end: "max", scrub: 0.3 } });

    return () => {
      delete window.signage;
    };
  });

  // Reação ao mouse: só onde há cursor de verdade --------------------------------
  media.add(`${motion.query} and (hover: hover) and (pointer: fine)`, () => {
    const cleanups = [];
    const on = (target, type, handler) => {
      target.addEventListener(type, handler);
      cleanups.push(() => target.removeEventListener(type, handler));
    };

    // Os símbolos balançam no parafuso quando o cursor passa.
    gsap.utils.toArray(".symbol, .sign-item-symbol, .signal-symbol").forEach((symbol) => {
      on(symbol, "pointerenter", () => gsap.to(symbol, { keyframes: { rotation: [0, -8, 6, -3, 0] }, duration: 0.8, ease: "power1.out", overwrite: "auto" }));
    });

    // Os parafusos dão meia-volta quando o cursor passa perto deles.
    gsap.utils.toArray(".has-frame").forEach((surface) => {
      const box = surface.querySelector(":scope > .screws");
      const near = new Set();
      on(surface, "pointermove", (event) => {
        const area = surface.getBoundingClientRect();
        const x = event.clientX - area.left - box.offsetLeft;
        const y = event.clientY - area.top - box.offsetTop;
        [...box.children].forEach((head) => {
          const close = Math.hypot(x - head.offsetLeft, y - head.offsetTop) < head.offsetWidth * 3;
          if (close && !near.has(head)) gsap.to(head.firstElementChild, { rotation: "+=180", duration: 0.7, ease: "power3.out" });
          if (close) near.add(head);
          else near.delete(head);
        });
      });
      on(surface, "pointerleave", () => near.clear());
    });

    // As placas marcadas com data-tilt inclinam acompanhando o cursor.
    gsap.utils.toArray("[data-tilt]").forEach((card) => {
      gsap.set(card, { transformPerspective: 800 });
      const tiltX = gsap.quickTo(card, "rotationX", { duration: 0.5, ease: "power3.out" });
      const tiltY = gsap.quickTo(card, "rotationY", { duration: 0.5, ease: "power3.out" });
      on(card, "pointermove", (event) => {
        const box = card.getBoundingClientRect();
        tiltY(((event.clientX - box.left) / box.width - 0.5) * 14);
        tiltX((0.5 - (event.clientY - box.top) / box.height) * 12);
      });
      on(card, "pointerleave", () => {
        tiltX(0);
        tiltY(0);
      });
    });

    // O esmalte da abertura reflete a luz onde o cursor está.
    gsap.utils.toArray(".signal").forEach((surface) => {
      on(surface, "pointermove", (event) => {
        const box = surface.getBoundingClientRect();
        surface.style.setProperty("--mx", `${event.clientX - box.left}px`);
        surface.style.setProperty("--my", `${event.clientY - box.top}px`);
      });
      on(surface, "pointerenter", () => surface.style.setProperty("--gloss", 1));
      on(surface, "pointerleave", () => surface.style.setProperty("--gloss", 0));
    });

    return () => cleanups.forEach((cleanup) => cleanup());
  });

  // As posições mudam quando a fonte termina de carregar.
  document.fonts?.ready.then(() => ScrollTrigger.refresh());
});
