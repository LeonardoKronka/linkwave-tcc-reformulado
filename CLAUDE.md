# LinkWave + LockMachine (TCC SENAI 2026)

Guia do projeto para o Claude. Responda e escreva sempre em português do Brasil.

## O que é

- **LinkWave**: a equipe/empresa fictícia do TCC. Tem um site institucional.
- **LockMachine**: o produto do TCC. Controle de acesso a máquinas industriais: o operador aproxima o crachá RFID, o sistema confere se a capacitação dele é válida para aquela máquina e libera ou bloqueia.

Nesta fase o repositório contém só o front-end, feito com HTML, CSS e JavaScript puros. Não há Node, build, banco de dados nem back-end.

## Estrutura

```text
.vscode/settings.json                 porta do Live Server (5502)
linkwave-tcc-reformulado/
  index.html                          só redireciona para institucional/index.html
  README.md                           instruções rápidas de uso
  institucional/                      site da LinkWave (tema azul/navy)
    index.html                        página única: início, quem somos, projeto, equipe
    projetos.html                     vitrine do projeto em destaque
    style.css  script.js  img/
  lockmachine_app/                    LockMachine (tema vermelho/preto)
    sobre.html                        apresentação do produto
    tela_de_login.html                login demonstrativo
    dashboard.html                    dashboard demonstrativo
    style.css  script.js  img/
```

Cada parte tem **um** `style.css` e **um** `script.js`, compartilhados por todas as páginas daquela parte. As duas partes não compartilham arquivos entre si, com uma exceção: `institucional/style.css` usa a imagem `../lockmachine_app/img/lockmachine-hero.webp`.

## Como rodar

Abrir a pasta no VS Code e usar a extensão Live Server em `linkwave-tcc-reformulado/index.html`. Não há testes automatizados nem linter; a verificação é abrir no navegador e navegar institucional → LockMachine → login → dashboard.

## Convenções do código

- Sem frameworks e sem dependências externas. Não adicionar bibliotecas, npm ou etapa de build sem o Leonardo pedir.
- Textos da interface em pt-BR; `lang="pt-BR"` em toda página.
- O JavaScript encontra os elementos por atributos `data-*` (`data-navbar`, `data-menu-toggle`, `data-demo-login`, `data-dashboard-sidebar`...), nunca por classe. As classes são só para estilo.
- Todo o JS fica dentro de um único `DOMContentLoaded` por arquivo e usa `?.` para funcionar em páginas onde o elemento não existe.
- Animação de entrada: classe `.reveal` no HTML; o `IntersectionObserver` adiciona `.visible`. Respeita `prefers-reduced-motion`.
- CSS: cores e largura em variáveis no `:root` (`--navy`, `--blue`, `--cyan` no institucional; `--red`, `--charcoal`, `--green`, `--amber` no LockMachine). Regras relacionadas ficam na mesma linha, em estilo compacto. Breakpoints em 1000px, 760px e ~480px.
- Links entre páginas são sempre relativos (`../lockmachine_app/sobre.html`), para funcionar em qualquer servidor.

## O que é demonstração

- O login não autentica: com e-mail e senha preenchidos, `lockmachine_app/script.js` apenas redireciona para `dashboard.html`.
- Todos os números, operadores e máquinas do dashboard estão fixos no HTML e são ilustrativos. Só a data é gerada por JS.
- Os itens "Acessos", "Máquinas" e "Operadores" do menu estão marcados "Em breve" e não têm tela.
- Não existe integração com leitor RFID nem com banco de dados.

Ao documentar ou apresentar o projeto, não descrever essas partes como se já funcionassem de verdade.

## Equipe

Leonardo (Product Owner, dono deste repositório), Cauê (Scrum Master), João (Banco de Dados), Evelyn (Front-end), Gabriel (Documentação).

## Git

- Repositório: https://github.com/LeonardoKronka/linkwave-tcc-reformulado (branch `main`).
- O Leonardo trabalha em duas máquinas (PC de casa e notebook do SENAI). Antes de começar qualquer alteração, rodar `git pull`. Ao terminar, commit e `git push`.
- Mensagens de commit em português, curtas, dizendo o que mudou.
- Pedir confirmação ao Leonardo antes de qualquer `git push`.
