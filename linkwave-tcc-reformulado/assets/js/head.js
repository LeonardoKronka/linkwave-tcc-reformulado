// Carregado no <head> de todas as páginas, antes de a página aparecer.
// Marca que há JavaScript, decide se a página pode animar e avisa quando ela
// chega por uma transição entre páginas, para a abertura não competir com ela.
document.documentElement.classList.add("js");

// Movimento -------------------------------------------------------------------
// A página segue o sistema, a não ser que a pessoa ligue as animações pela
// chave do rodapé (computadores de escola e de empresa costumam vir com as
// animações do sistema desligadas). A escolha fica guardada neste navegador.
window.motion = (() => {
  const STORAGE_KEY = "linkwave.animacoes";
  const SYSTEM_QUERY = "(prefers-reduced-motion: no-preference)";
  const system = window.matchMedia(SYSTEM_QUERY);
  let forced = false;

  try {
    forced = localStorage.getItem(STORAGE_KEY) === "ligadas";
  } catch {
    // Sem armazenamento, a página só segue o sistema.
  }

  // A classe .motion libera o movimento na CSS e nos scripts.
  const apply = () => document.documentElement.classList.toggle("motion", forced || system.matches);
  apply();
  system.addEventListener("change", apply);

  // Na CSS, a transição entre páginas depende do sistema. Com as animações
  // ligadas pela chave, ela é ativada aqui.
  if (forced) {
    const style = document.createElement("style");
    style.textContent = "@view-transition { navigation: auto; }";
    document.head.append(style);
  }

  return {
    // Consulta de mídia para o gsap.matchMedia: vale quando a página pode animar.
    // Com as animações ligadas pela chave, é uma consulta que vale sempre.
    query: forced ? "(min-width: 0px)" : SYSTEM_QUERY,
    // O sistema pede movimento reduzido: é quando a chave do rodapé aparece.
    reducedBySystem: !system.matches,
    forced,
    // Guarda a escolha e recarrega do topo, para a abertura ser vista.
    // Devolve false quando o navegador não deixa guardar.
    force(on) {
      try {
        if (on) localStorage.setItem(STORAGE_KEY, "ligadas");
        else localStorage.removeItem(STORAGE_KEY);
      } catch {
        return false;
      }
      window.scrollTo({ top: 0, behavior: "instant" });
      window.location.reload();
      return true;
    },
  };
})();

window.addEventListener("pagereveal", (event) => {
  if (!event.viewTransition) return;
  document.documentElement.classList.add("vt");
  window.dispatchEvent(new Event("vt-arrival"));
});
