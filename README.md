# LinkWave + LockMachine

Projeto de TCC do SENAI (2026). A **LinkWave** é a nossa equipe, e o **LockMachine** é a solução que desenvolvemos: um controle de acesso para máquinas industriais baseado na capacitação do operador.

## O problema

Um controle de acesso comum confere quem é a pessoa. Não confere se ela foi treinada para aquela máquina, nem se o treinamento ainda vale. A NR-12 determina que a operação de máquinas seja feita por trabalhadores habilitados, qualificados ou capacitados, e autorizados para isso (item 12.16.1).

## A proposta

O LockMachine faz três conferências **antes** de a máquina ligar:

1. **Identificação**: o operador aproxima o crachá RFID do leitor instalado na máquina.
2. **Capacitação exigida**: o sistema confere se a capacitação que aquela máquina exige consta no cadastro do operador.
3. **Validade**: treinamento vencido não libera.

Se as três passam, a máquina é liberada. Se falta uma, ela permanece bloqueada e a tentativa fica registrada para o supervisor.

## O que há neste repositório

O front-end do projeto, feito com HTML, CSS e JavaScript, sem etapa de build:

| Parte | Pasta | Páginas |
| --- | --- | --- |
| Site institucional da LinkWave | `linkwave-tcc-reformulado/institucional/` | `index.html`, `projetos.html` |
| Apresentação e demonstração do LockMachine | `linkwave-tcc-reformulado/lockmachine_app/` | `sobre.html`, `tela_de_login.html`, `dashboard.html` |
| Base compartilhada | `linkwave-tcc-reformulado/assets/` | estilos, scripts, fontes e a biblioteca GSAP |

### Estado atual

Esta fase é uma **demonstração**:

- A página do LockMachine tem um simulador do leitor: você escolhe um crachá e uma máquina fictícios, arrasta o crachá até o leitor (ou clica nele) e vê a decisão e o motivo. A regra de verificação é real e está em JavaScript; operadores, máquinas e datas são fictícios.
- O login aceita qualquer e-mail válido e qualquer senha. Não há autenticação.
- Os dados do painel, incluindo o gráfico de tentativas por hora, são ilustrativos. As tentativas que você faz no simulador aparecem nele durante a mesma sessão do navegador.
- As telas "Acessos", "Máquinas" e "Operadores" ainda não foram construídas.
- O leitor RFID físico, o banco de dados e o back-end ainda não existem.

## Como abrir

1. Baixe ou clone o repositório:
   ```bash
   git clone https://github.com/LeonardoKronka/linkwave-tcc-reformulado
   ```
2. Abra a pasta no VS Code.
3. Instale a extensão **Live Server**.
4. Clique com o botão direito em `linkwave-tcc-reformulado/index.html` e escolha **Open with Live Server**.

Não é necessário instalar Node.js, banco de dados, PHP ou TypeScript. O site funciona sem internet: fontes e biblioteca de animação estão dentro do projeto.

Se o site abrir parado, é porque o computador está configurado para reduzir animações (comum nos computadores do SENAI). No fim da página aparece o botão **Ligar animações**: a escolha fica guardada no navegador e vale para todas as páginas.

## Estrutura

```text
linkwave-tcc-reformulado/
├── index.html                  entrada: redireciona para o site institucional
├── assets/
│   ├── css/base.css            sistema visual: cores, tipos, placas, material
│   ├── js/head.js              preparo da página antes de ela aparecer
│   ├── js/base.js              menu e animações comuns aos dois sites
│   ├── fonts/                  Archivo e Martian Mono (com as licenças)
│   └── vendor/gsap/            GSAP, ScrollTrigger e SplitText
├── institucional/
│   ├── index.html              site da LinkWave
│   ├── projetos.html           projeto em destaque
│   ├── style.css               o que é só da LinkWave
│   ├── script.js               símbolos animados da LinkWave
│   └── img/
└── lockmachine_app/
    ├── sobre.html              apresentação e simulador do LockMachine
    ├── tela_de_login.html      login demonstrativo
    ├── dashboard.html          painel demonstrativo
    ├── style.css               o que é só do LockMachine
    ├── script.js               simulador, conferências, registro, login, painel e gráfico
    └── img/
```

## Documentos do projeto

- [PRODUCT.md](PRODUCT.md): o que é o produto, para quem, e o que existe de verdade hoje.
- [DESIGN.md](DESIGN.md): o sistema visual, baseado em placas de segurança industrial.
- [docs/estrategia.md](docs/estrategia.md): posicionamento, riscos e caminhos para a próxima etapa.

## Equipe

| Integrante | Papel |
| --- | --- |
| Leonardo | Product Owner e Full stack |
| Cauê | Scrum Master e Back-end |
| João | Banco de Dados |
| Evelyn | Front-end |
| Gabriel | Documentação |

## Créditos e licenças

- [GSAP](https://gsap.com) 3.15.0, sob a licença padrão gratuita da GreenSock.
- Fontes [Archivo](https://fonts.google.com/specimen/Archivo) e [Martian Mono](https://fonts.google.com/specimen/Martian+Mono), sob a SIL Open Font License. Os textos das licenças estão em `linkwave-tcc-reformulado/assets/fonts/`.

## Próximos passos

- Publicar o site com GitHub Pages
- Montar um protótipo físico mínimo: um leitor RFID, uma máquina, uma decisão de verdade
- Construir as telas de Acessos, Máquinas e Operadores
- Criar o back-end e o banco de dados, e ligar o painel a eles
