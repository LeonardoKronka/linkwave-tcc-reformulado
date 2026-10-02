document.addEventListener("DOMContentLoaded", () => {
  const nav = document.querySelector("[data-project-nav]");
  const menu = document.querySelector("[data-project-menu]");
  const menuButton = document.querySelector("[data-project-menu-button]");

  const updateNav = () => nav?.classList.toggle("scrolled", window.scrollY > 24);
  updateNav();
  window.addEventListener("scroll", updateNav, { passive: true });

  menuButton?.addEventListener("click", () => {
    const open = menu.classList.toggle("open");
    menuButton.classList.toggle("open", open);
    menuButton.setAttribute("aria-expanded", String(open));
  });
  menu?.querySelectorAll("a").forEach((link) => link.addEventListener("click", () => menu.classList.remove("open")));

  const observer = "IntersectionObserver" in window ? new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 }) : null;
  document.querySelectorAll(".reveal").forEach((element) => observer ? observer.observe(element) : element.classList.add("visible"));

  const form = document.querySelector("[data-demo-login]");
  form?.addEventListener("submit", (event) => {
    event.preventDefault();
    const email = form.elements.email.value.trim();
    const password = form.elements.senha.value.trim();
    const message = document.querySelector("[data-form-message]");
    if (!email || !password) {
      message.textContent = "Preencha o e-mail e a senha para continuar.";
      return;
    }
    message.textContent = "";
    window.location.href = "dashboard.html";
  });

  const sidebar = document.querySelector("[data-dashboard-sidebar]");
  document.querySelector("[data-open-sidebar]")?.addEventListener("click", () => sidebar.classList.add("open"));
  document.querySelectorAll("[data-close-sidebar]").forEach((button) => button.addEventListener("click", () => sidebar.classList.remove("open")));

  const dateLabel = document.querySelector("[data-dashboard-date]");
  if (dateLabel) dateLabel.textContent = new Intl.DateTimeFormat("pt-BR", { dateStyle: "full" }).format(new Date());
});
