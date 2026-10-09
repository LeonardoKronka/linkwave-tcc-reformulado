# LinkWave + LockMachine (TCC SENAI 2026)

Guia do projeto para o Claude. Responda e escreva sempre em português do Brasil.

## O que é

- **LinkWave**: a equipe/empresa fictícia do TCC. Tem um site institucional.
- **LockMachine**: o produto do TCC. Controle de acesso a máquinas industriais: o operador aproxima o crachá RFID, o sistema confere se a capacitação dele é válida para aquela máquina e libera ou bloqueia.

O repositório contém só o front-end: HTML, CSS e JavaScript, sem Node, sem build, sem banco de dados e sem back-end.

Próxima etapa, decidida em 09/10/2026 para a apresentação (em 1 a 2 meses): leitor de verdade com ESP32 + RC522, servidor em PHP + MySQL no XAMPP (é o que o grupo aprendeu; sem framework), painel com login e cadastro de funcionários e máquinas pelo administrador, e app Flutter para Android (supervisor acompanha, operador consulta as capacitações). O plano, com o mínimo de cada peça, as semanas e quem faz o quê, está em [docs/plano-apresentacao.md](docs/plano-apresentacao.md).

Antes de mexer em produto ou visual, leia [PRODUCT.md](PRODUCT.md) (o que é verdade sobre o produto) e [DESIGN.md](DESIGN.md) (o sistema visual). O posicionamento está em [docs/estrategia.md](docs/estrategia.md).

## Estrutura

```text
PRODUCT.md  DESIGN.md  docs/estrategia.md  docs/plano-apresentacao.md
.claude/launch.json  .claude/serve.ps1   servidor local para pré-visualização (porta 4173)
.vscode/settings.json                    porta do Live Server (5502)
linkwave-tcc-reformulado/
  index.html                          só redireciona para institucional/index.html
  assets/
    css/base.css                      sistema visual: tokens, tipos, faixas, placas, material, fita
    js/head.js                        carregado no <head> de toda página: marca .js, decide o movimento (.motion) e avisa transição entre páginas
    js/base.js                        menu, chave das animações, abertura, entradas, fita, mouse (GSAP)
    fonts/                            Archivo e Martian Mono, com as licenças OFL
    vendor/gsap/                      gsap, ScrollTrigger e SplitText (3.15.0)
  institucional/                      site da LinkWave (marca azul)
    index.html  projetos.html  style.css  script.js  img/
  lockmachine_app/                    LockMachine (marca vermelha)
    sobre.html                        apresentação e simulador do leitor
    tela_de_login.html                login demonstrativo
    dashboard.html                    painel demonstrativo
    style.css  script.js  img/
```

`base.css` é a fonte da verdade do visual. Cada parte tem um `style.css` e um `script.js` só com o que é específico dela; o que serve aos dois sites fica em `assets/`.

## Como rodar

Abrir a pasta no VS Code e usar a extensão Live Server em `linkwave-tcc-reformulado/index.html`. Para o Claude pré-visualizar, `.claude/launch.json` sobe o servidor `site` na porta 4173.

Não há testes automatizados nem linter. A verificação é abrir no navegador, em tela de notebook (1366×625 de área útil, além de 1366×768) e de celular, e percorrer: institucional → LockMachine → levar o crachá ao leitor (liberado e bloqueado) → rolar pelas três conferências → login → painel.

Com o painel do navegador do Claude oculto, as animações ficam pausadas e as capturas falham. Nesse caso, avance o relógio com `gsap.updateRoot(...)` e confira os estados pelo DOM; diga ao Leonardo que o movimento não foi visto rodando.

Se o site abrir parado, confira primeiro o sistema: os computadores do SENAI costumam vir com os efeitos de animação do Windows desligados (Configurações → Acessibilidade → Efeitos visuais), e aí o navegador informa `prefers-reduced-motion: reduce`. Nesse caso o rodapé mostra a chave "Ligar animações" (ver Convenções do código).

## Sistema visual

O mundo é a placa de segurança industrial. A cor nunca decora, sempre significa: vermelho proíbe, amarelo alerta, azul obriga, verde libera. Botões e links comuns são pretos ou brancos.

- A palavra de sinal (`.sign-word`) é o título da seção; nunca use rótulo pequeno acima de título.
- Situação sempre traz cor, forma e palavra (`.status`).
- Todo trecho de demonstração leva um aviso amarelo (`.notice`).
- A placa é uma chapa esmaltada lisa: cantos arredondados, sombra curta (`--shadow-plate`) e brilho. Sem moldura, sem filete e sem parafusos: o grupo testou e preferiu o visual minimalista (09/10/2026). Nada de sombra dura, degradê em texto, vidro fosco ou foto escura de fábrica.
- Nenhuma seção troca de cor numa linha reta: as placas têm os cantos de fora arredondados e se sobrepõem. Quando uma placa (colorida ou branca) vem logo antes de outra, ela leva `.band--under`. O grupo pediu isso em 09/10/2026.
- Ícones são SVG desenhados (`.icon--*` em `base.css`); não use seta ou símbolo de teclado como ícone.
- Fonte monoespaçada (`.data`) só para dado medido: RFID, horário, data, código.

## Convenções do código

- Nomes de classe, variável e função em inglês; comentários e textos da interface em português. `lang="pt-BR"` em toda página.
- CSS legível: uma declaração por linha, seções com comentário, cores e medidas só por variáveis de `:root`. Cada superfície define `--bg` e `--fg`, e os componentes leem essas duas.
- O JavaScript encontra os elementos por atributos `data-*`, nunca por classe. Um único `DOMContentLoaded` por arquivo, com `?.` para funcionar em páginas onde o elemento não existe.
- Links entre páginas são sempre relativos.
- GSAP é a única biblioteca (núcleo, ScrollTrigger e SplitText), e fica em arquivo local. Não adicionar outros plugins, bibliotecas, npm ou etapa de build sem o Leonardo pedir.
- Movimento: o Leonardo pediu um site com vida (08/10/2026). Cada animação precisa vir da placa ou do produto: fixar, girar, carimbar, ler o crachá. A lista completa está na seção Motion do `DESIGN.md`.
- O site só anima com a classe `.motion` na raiz. Quem a põe é o `head.js`: quando o sistema permite (`prefers-reduced-motion`), ou quando a pessoa liga as animações pela chave do rodapé (`[data-motion-switch]`, que só aparece se o sistema pede movimento reduzido; a escolha fica em `localStorage` e vale para todas as páginas). O Leonardo pediu essa chave em 09/10/2026, por causa dos computadores do SENAI.
- Na CSS, movimento vai em seletor com `.motion` (use `:where(.motion)` quando o peso do seletor não pode mudar), nunca em `@media (prefers-reduced-motion: no-preference)`. No JavaScript, passe `motion.query` ao `gsap.matchMedia` no lugar dessa consulta, ou confira a classe `.motion`.
- ScrollTrigger só em tween ou timeline de nível superior, sem `markers`. Depois de criar uma seção presa (`pin`), chamar `ScrollTrigger.sort()` e `ScrollTrigger.refresh()`.
- Blocos que animam na abertura levam `data-intro`: a CSS os esconde até o script começar e os mostra sozinha depois de 3 segundos se o script falhar.
- Animação declarada no HTML por atributos: `data-sign` (entrada da placa), `data-follow`, `data-mount`, `data-roll`, `data-wipe`, `data-tilt`, `data-tape`, `data-draw` (traço com `pathLength="1"`), `data-vt` (placa que viaja entre páginas).
- A página precisa funcionar sem JavaScript: o menu fica aberto e o conteúdo aparece.

## O que é demonstração

- Hoje não existe protótipo físico, leitor RFID, banco de dados nem back-end. Nada no site ou na documentação pode sugerir o contrário.
- O simulador roda no navegador. A regra (`checkAccess` em `lockmachine_app/script.js`) é real; operadores, máquinas e datas são fictícios, e as validades são calculadas a partir de hoje.
- O login não autentica: com e-mail e senha preenchidos, só redireciona para `dashboard.html`.
- Os números, as linhas e o gráfico do painel são ilustrativos e fixos no HTML (o gráfico é desenhado a partir da tabela "Tentativas por hora"). O JavaScript acrescenta a data e as tentativas feitas no simulador (guardadas em `sessionStorage`).
- "Acessos", "Máquinas" e "Operadores" estão marcados "Em breve" e não têm tela.
- A citação da NR-12 (item 12.16.1) foi conferida em fontes jurídicas, não no texto oficial. A equipe ainda vai validar com o orientador.

## Equipe

Leonardo (Product Owner e full stack, dono deste repositório), Cauê (Scrum Master e back-end), João (banco de dados), Evelyn (front-end), Gabriel Miranda (documentação).

O Leonardo faz com o Claude as mudanças de visual e de funcionalidade do site, mas o trabalho é em equipe: ele precisa repassar demandas ao resto do grupo. Ao planejar algo maior (banco de dados, back-end, telas novas, documentação), separe o que cabe a cada área em vez de resolver tudo sozinho.

## Git

- Repositório: https://github.com/LeonardoKronka/linkwave-tcc-reformulado (branch principal `main`).
- O redesenho está na branch `redesign` e só entra na `main` quando o Leonardo aprovar.
- O Leonardo trabalha em duas máquinas (PC de casa e notebook do SENAI). Antes de começar qualquer alteração, rodar `git pull`. Ao terminar, commit e `git push`.
- Mensagens de commit em português, curtas, dizendo o que mudou.
- Pedir confirmação ao Leonardo antes de qualquer `git push`.
