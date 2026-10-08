# LinkWave + LockMachine (TCC SENAI 2026)

Guia do projeto para o Claude. Responda e escreva sempre em português do Brasil.

## O que é

- **LinkWave**: a equipe/empresa fictícia do TCC. Tem um site institucional.
- **LockMachine**: o produto do TCC. Controle de acesso a máquinas industriais: o operador aproxima o crachá RFID, o sistema confere se a capacitação dele é válida para aquela máquina e libera ou bloqueia.

O repositório contém só o front-end: HTML, CSS e JavaScript, sem Node, sem build, sem banco de dados e sem back-end.

Antes de mexer em produto ou visual, leia [PRODUCT.md](PRODUCT.md) (o que é verdade sobre o produto) e [DESIGN.md](DESIGN.md) (o sistema visual). O posicionamento está em [docs/estrategia.md](docs/estrategia.md).

## Estrutura

```text
PRODUCT.md  DESIGN.md  docs/estrategia.md
.claude/launch.json  .claude/serve.ps1   servidor local para pré-visualização (porta 4173)
.vscode/settings.json                    porta do Live Server (5502)
linkwave-tcc-reformulado/
  index.html                          só redireciona para institucional/index.html
  assets/
    css/base.css                      sistema visual: tokens, tipos, faixas, placas, botões
    js/base.js                        menu e entrada das listas (GSAP)
    fonts/                            Archivo e Martian Mono, com as licenças OFL
    vendor/gsap/                      gsap.min.js e ScrollTrigger.min.js (3.15.0)
  institucional/                      site da LinkWave (marca azul)
    index.html  projetos.html  style.css  img/
  lockmachine_app/                    LockMachine (marca vermelha)
    sobre.html                        apresentação e simulador do leitor
    tela_de_login.html                login demonstrativo
    dashboard.html                    painel demonstrativo
    style.css  script.js  img/
```

`base.css` é a fonte da verdade do visual. Cada parte tem um `style.css` só com o que é específico dela. Só o LockMachine tem `script.js` próprio.

## Como rodar

Abrir a pasta no VS Code e usar a extensão Live Server em `linkwave-tcc-reformulado/index.html`. Para o Claude pré-visualizar, `.claude/launch.json` sobe o servidor `site` na porta 4173.

Não há testes automatizados nem linter. A verificação é abrir no navegador, em largura de notebook (1366×768) e de celular, e percorrer: institucional → LockMachine → aproximar crachá (liberado e bloqueado) → login → painel.

## Sistema visual

O mundo é a placa de segurança industrial. A cor nunca decora, sempre significa: vermelho proíbe, amarelo alerta, azul obriga, verde libera. Botões e links comuns são pretos ou brancos.

- A palavra de sinal (`.sign-word`) é o título da seção; nunca use rótulo pequeno acima de título.
- Situação sempre traz cor, forma e palavra (`.status`).
- Todo trecho de demonstração leva um aviso amarelo (`.notice`).
- Sem sombras, sem degradê em texto, sem vidro fosco, sem foto escura de fábrica.
- Ícones são SVG desenhados (`.icon--*` em `base.css`); não use seta ou símbolo de teclado como ícone.
- Fonte monoespaçada (`.data`) só para dado medido: RFID, horário, data, código.

## Convenções do código

- Nomes de classe, variável e função em inglês; comentários e textos da interface em português. `lang="pt-BR"` em toda página.
- CSS legível: uma declaração por linha, seções com comentário, cores e medidas só por variáveis de `:root`. Cada superfície define `--bg` e `--fg`, e os componentes leem essas duas.
- O JavaScript encontra os elementos por atributos `data-*`, nunca por classe. Um único `DOMContentLoaded` por arquivo, com `?.` para funcionar em páginas onde o elemento não existe.
- Links entre páginas são sempre relativos.
- GSAP é a única biblioteca, e fica em arquivo local. Não adicionar outras bibliotecas, npm ou etapa de build sem o Leonardo pedir.
- Movimento: o conteúdo é visível por padrão; o GSAP só anima quando `prefers-reduced-motion` permite (`gsap.matchMedia`). O único momento autoral é o veredito do simulador. ScrollTrigger só em tween ou timeline de nível superior, sem `markers`.
- A página precisa funcionar sem JavaScript: o menu fica aberto e o conteúdo aparece.

## O que é demonstração

- Hoje não existe protótipo físico, leitor RFID, banco de dados nem back-end. Nada no site ou na documentação pode sugerir o contrário.
- O simulador roda no navegador. A regra (`checkAccess` em `lockmachine_app/script.js`) é real; operadores, máquinas e datas são fictícios, e as validades são calculadas a partir de hoje.
- O login não autentica: com e-mail e senha preenchidos, só redireciona para `dashboard.html`.
- Os números e as linhas do painel são ilustrativos e fixos no HTML. O JavaScript acrescenta a data e as tentativas feitas no simulador (guardadas em `sessionStorage`).
- "Acessos", "Máquinas" e "Operadores" estão marcados "Em breve" e não têm tela.
- A citação da NR-12 (item 12.16.1) foi conferida em fontes jurídicas, não no texto oficial. A equipe ainda vai validar com o orientador.

## Equipe

Leonardo (Product Owner, dono deste repositório), Cauê (Scrum Master), João (Banco de Dados), Evelyn (Front-end), Gabriel (Documentação).

## Git

- Repositório: https://github.com/LeonardoKronka/linkwave-tcc-reformulado (branch principal `main`).
- O redesenho está na branch `redesign` e só entra na `main` quando o Leonardo aprovar.
- O Leonardo trabalha em duas máquinas (PC de casa e notebook do SENAI). Antes de começar qualquer alteração, rodar `git pull`. Ao terminar, commit e `git push`.
- Mensagens de commit em português, curtas, dizendo o que mudou.
- Pedir confirmação ao Leonardo antes de qualquer `git push`.
