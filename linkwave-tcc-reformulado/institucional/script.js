// LinkWave: os símbolos das placas ganham vida própria.
// O menu, as entradas e a reação ao mouse estão em ../assets/js/base.js.
document.addEventListener("DOMContentLoaded", () => {
  if (!window.gsap || !window.ScrollTrigger) return;

  gsap.matchMedia().add(motion.query, () => {
    const center = "60 60";
    const whileVisible = (trigger) => ({ trigger, toggleActions: "play pause resume pause" });

    // As três barras da marca crescem e depois oscilam como um sinal.
    const wave = document.querySelector("[data-wave]");
    if (wave) {
      gsap.timeline({ delay: 0.9, scrollTrigger: whileVisible(wave) })
        .from(wave.children, { scaleY: 0, transformOrigin: "50% 100%", duration: 0.7, ease: "power3.out", stagger: 0.12 })
        .to(wave.children, { scaleY: 0.8, transformOrigin: "50% 100%", duration: 0.9, ease: "sine.inOut", stagger: { each: 0.2, repeat: -1, yoyo: true } });
    }

    // Clareza: o olho pisca de vez em quando.
    const eye = document.querySelector("[data-eye]");
    if (eye) {
      gsap.timeline({ repeat: -1, repeatDelay: 3.2, delay: 2, scrollTrigger: whileVisible(eye) })
        .to(eye, { scaleY: 0.08, svgOrigin: center, duration: 0.1, ease: "power2.in" })
        .to(eye, { scaleY: 1, svgOrigin: center, duration: 0.18, ease: "power2.out" });
    }

    // Segurança: o capacete é colocado.
    const helmet = document.querySelector("[data-helmet]");
    if (helmet) gsap.from(helmet, { y: -46, autoAlpha: 0, duration: 0.7, ease: "power3.out", delay: 0.7, scrollTrigger: { trigger: helmet, start: "top 80%", once: true } });

    // Aplicação: a engrenagem gira conforme a página rola.
    const gear = document.querySelector("[data-gear]");
    if (gear) gsap.to(gear, { rotation: 360, svgOrigin: center, ease: "none", scrollTrigger: { trigger: gear, start: "top bottom", end: "bottom top", scrub: 0.6 } });
  });
});
