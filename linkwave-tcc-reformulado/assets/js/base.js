// Comportamento comum aos dois sites: menu e movimento de entrada das listas.
document.addEventListener("DOMContentLoaded", () => {
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

  // Sem GSAP (ou com movimento reduzido) a página fica completa e parada.
  if (!window.gsap || !window.ScrollTrigger) return;
  gsap.registerPlugin(ScrollTrigger);

  gsap.matchMedia().add("(prefers-reduced-motion: no-preference)", () => {
    // Placas que formam uma lista são "fixadas" uma a uma, uma única vez.
    gsap.utils.toArray("[data-mount]").forEach((list) => {
      gsap.from(list.children, {
        y: 36,
        rotation: -1.5,
        autoAlpha: 0,
        duration: 0.8,
        ease: "expo.out",
        stagger: 0.08,
        scrollTrigger: { trigger: list, start: "top 84%", once: true },
      });
    });
  });

  // As posições mudam quando a fonte termina de carregar.
  document.fonts?.ready.then(() => ScrollTrigger.refresh());
});
