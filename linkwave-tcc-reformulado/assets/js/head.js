// Carregado no <head>, antes de a página aparecer.
// Marca que há JavaScript e avisa quando a página chega por uma transição
// entre páginas, para a abertura não competir com ela.
document.documentElement.classList.add("js");

window.addEventListener("pagereveal", (event) => {
  if (!event.viewTransition) return;
  document.documentElement.classList.add("vt");
  window.dispatchEvent(new Event("vt-arrival"));
});
