---
name: LinkWave + LockMachine
description: Placas de segurança industrial como sistema visual. A cor nunca decora, sempre significa.
colors:
  red: "#c81e27"
  yellow: "#ffc20e"
  blue: "#0b55c4"
  green: "#17714a"
  ink: "#131614"
  ink-soft: "#4d544f"
  wall: "#e3e6e2"
  white: "#fcfdfb"
  white-soft: "#c9cfca"
  line: "#bfc5bf"
  yellow-wash: "#fff8e0"
  steel: "#b4bab4"
typography:
  signal-word:
    fontFamily: "Archivo, Arial Narrow, Arial, sans-serif"
    fontSize: "clamp(3rem, 1.4rem + 6.6vw, 6rem)"
    fontWeight: 800
    lineHeight: 0.88
    letterSpacing: "-0.01em"
  signal-message:
    fontFamily: "Archivo, Arial Narrow, Arial, sans-serif"
    fontSize: "clamp(1.5rem, 1.05rem + 1.9vw, 2.5rem)"
    fontWeight: 700
    lineHeight: 1.06
    letterSpacing: "normal"
  body:
    fontFamily: "Archivo, Arial Narrow, Arial, sans-serif"
    fontSize: "1.0625rem"
    fontWeight: 400
    lineHeight: 1.55
    letterSpacing: "normal"
  label:
    fontFamily: "Archivo, Arial Narrow, Arial, sans-serif"
    fontSize: "0.8125rem"
    fontWeight: 700
    lineHeight: 1.55
    letterSpacing: "0.06em"
  data:
    fontFamily: "Martian Mono, ui-monospace, Cascadia Mono, Consolas, monospace"
    fontSize: "0.8em"
    fontWeight: 400
    lineHeight: 1.55
    letterSpacing: "0"
rounded:
  control: "0.625rem"
  plate: "clamp(0.75rem, 0.5rem + 0.8vw, 1.25rem)"
spacing:
  gutter: "clamp(1.25rem, 0.5rem + 3vw, 3rem)"
  band: "clamp(4rem, 2.5rem + 6vw, 7.5rem)"
  frame: "clamp(0.5rem, 0.2rem + 1vw, 1rem)"
components:
  button:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.white}"
    rounded: "{rounded.control}"
    padding: "0.65em 1.25em"
    height: "3rem"
  button-hover:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
  chip:
    backgroundColor: "{colors.white}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
  chip-checked:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.white}"
  status-ok:
    backgroundColor: "{colors.green}"
    textColor: "{colors.white}"
  status-blocked:
    backgroundColor: "{colors.red}"
    textColor: "{colors.white}"
  status-warn:
    backgroundColor: "{colors.yellow}"
    textColor: "{colors.ink}"
---

# Design System: LinkWave + LockMachine

## Overview

O site é uma placa de segurança que lê quem está na frente dela. Todo o sistema vem do código de cores da sinalização industrial, que o público do projeto conhece de cor: vermelho proíbe, amarelo alerta, azul obriga, verde libera. As cores das marcas já pertenciam a esse código (azul LinkWave, vermelho LockMachine), então a identidade foi mantida e ganhou significado.

O sistema recusa o padrão da categoria: foto escura de fábrica em tela cheia com um destaque em neon. Fundo claro foi escolhido pela cena de uso: sala de aula iluminada, projetor que lava as cores, celular no corredor.

A fonte da verdade é `linkwave-tcc-reformulado/assets/css/base.css`. Os dois sites só acrescentam o que é específico de cada um.

## Colors

### Primary

- **Vermelho `#c81e27`**: proibição e bloqueio. É também a cor da marca LockMachine.
- **Azul `#0b55c4`**: obrigação e instrução. É também a cor da marca LinkWave.

### Secondary

- **Verde `#17714a`**: condição segura. Liberado, caminho a seguir.
- **Amarelo `#ffc20e`**: atenção. Risco, e todo aviso de honestidade ("demonstração", "dados ilustrativos").

### Neutral

- **Tinta `#131614`** e **tinta suave `#4d544f`** para texto.
- **Parede `#e3e6e2`** como fundo da página, **branco de placa `#fcfdfb`** para painéis, **linha `#bfc5bf`** para divisórias. Todos puxados levemente para o cinza-esverdeado das paredes e quadros elétricos de fábrica.

### Named Rules

- **A cor nunca decora.** Uma cor de sinalização só aparece onde seu significado é verdadeiro. Ação comum (botão, link) é preta ou branca.
- **Cor em escala de página.** Uma seção inteira é um campo de cor; nada de detalhes coloridos espalhados sobre fundo neutro.
- **Texto sobre cor é branco puro de placa; sobre amarelo, tinta.** Todas as combinações passam de 4,5:1.
- **Cor nunca vai sozinha.** Situação sempre traz forma e palavra junto: quadrado para liberado, disco com barra para bloqueado, triângulo para atenção.

## Typography

Archivo (variável, com eixo de largura) faz todas as vozes. Martian Mono aparece só em dado medido: RFID, horário, data, código de máquina. As duas fontes são arquivos locais em `assets/fonts`.

### Hierarchy

- **Palavra de sinal**: caixa alta, peso 800, largura 68%, até 6rem (8rem só na abertura). É o título da seção.
- **Mensagem**: caixa alta, peso 700, largura 86%, logo abaixo da palavra de sinal.
- **Corpo**: 1,0625rem, peso 400, largura 100%, linha de no máximo 64 caracteres.
- **Rótulo**: 0,8125rem, peso 700, caixa alta, espaçamento 0,06em. Só para legendas de campo e cabeçalhos de tabela.

### Named Rules

- **A palavra de sinal é o título, nunca um rótulo pequeno acima dele.**
- **Largura é hierarquia.** Quanto maior o texto, mais condensado.

## Layout

Um contêiner de até 72rem com margem fluida. Cada seção é uma faixa de largura total. Placas com símbolo usam duas colunas (símbolo, texto) a partir de 52rem e empilham abaixo disso. A abertura ocupa a altura da tela e passa a duas colunas a partir de 60rem.

No celular, a abertura do LockMachine põe os controles antes do texto de apoio, para a placa e o leitor caberem na mesma tela.

O painel do supervisor segue a estrutura padrão da categoria: trilho lateral preto, barra de título, resumo, tabela e situação das máquinas. O trilho vira gaveta abaixo de 64rem.

## Elevation & Depth

A placa é uma chapa esmaltada presa à parede, não uma cor de tela. A profundidade vem de quatro coisas, todas discretas:

- **Esmalte**: toda superfície colorida leva uma luz vertical muito leve (mais clara em cima, mais escura embaixo) e um grão fino. As variáveis são `--enamel` e `--grain`.
- **Sombra de chapa** (`--shadow-plate`): curta, deslocada para baixo e suave, em painéis, chapas, crachá e placas da equipe.
- **Filete em relevo** (`--relief`): a linha da moldura projeta uma sombra de 1px.
- **Brilho**: uma faixa de luz atravessa a placa na abertura e a cada veredito, e um reflexo acompanha o cursor.

O painel do supervisor fica mais plano: só as placas de máquina têm sombra.

## Shapes

- Cantos de 0,625rem em controles e de 0,75 a 1,25rem em placas.
- **Filete interno**: toda faixa colorida e toda chapa têm uma linha na cor do texto, recuada da borda, como na moldura de uma placa real.
- **Parafusos**: quatro, um em cada canto das faixas coloridas e das chapas, em aço. São postos pelo `base.js`.
- Símbolos são geométricos e chapados, em SVG no próprio HTML: disco com barra, triângulo, disco azul com pictograma branco, quadrado verde.
- Ícones de interface são SVG de traço único de 2,6, aplicados como máscara em `.icon`.

## Components

### Buttons

Chapa preta com texto branco em caixa alta; sobre faixa colorida, inverte sozinha para branco com texto na cor da faixa. No hover fica vazada. O anel de foco usa a cor do texto da superfície.

### Chips

Escolhas do simulador são `radio` nativos com aparência de chapa: borda preta de 2px, preenchida de preto quando marcada.

### Cards / Containers

- **Faixa** (`.band`): seção de largura total em uma das cores do código.
- **Painel** (`.panel`): a área branca de mensagem de uma placa.
- **Chapa** (`.plate`): placa menor dentro de uma faixa.
- **Folha** (`.sheet`) no painel do supervisor: branca, borda preta de 2px, cabeçalho separado por linha.

### Inputs / Fields

Campo com borda preta de 2px, rótulo em caixa alta acima, foco com anel azul de 3px.

### Navigation

Barra preta fixa no topo, links em caixa alta, ação principal como chapa branca. Abaixo de 52rem os links recolhem em um botão de menu; sem JavaScript, ficam sempre visíveis.

### Signature Component

**A placa que confere o crachá** (`.signal`, na abertura do LockMachine). Estado inicial: regra, em vermelho, "Proibido operar sem capacitação válida". O visitante arrasta o crachá até o leitor, ou clica no leitor. O crachá encosta, o leitor dispara um pulso e o número do RFID embaralha por um instante. A cor do veredito se espalha a partir do leitor como um disco, a chapa branca muda de forma (disco para proibido, quadrado para liberado), as letras da palavra de sinal giram como plaquetas e o brilho atravessa a placa. Bloqueado: a placa balança de um lado para o outro. O motivo aparece logo abaixo e a tentativa cai no registro.

**As três conferências** (`.checks`): em tela larga a seção fica presa enquanto um crachá percorre um trilho; cada disco acende e recebe o selo de conferido, e as placas de decisão sobem no fim.

**Fita de isolamento** (`.tape`): tira listrada e levemente inclinada entre a abertura e a seção seguinte, com texto que corre e acelera com a rolagem. Amarela no LockMachine, azul na LinkWave.

**Gráfico de tentativas por hora** (painel): colunas finas empilhadas, verde para liberado e vermelho para bloqueado, com 2px de respiro, legenda com forma e palavra, rótulo só nos bloqueios, dica ao passar o mouse ou focar, e a mesma informação em tabela.

No painel do supervisor, a assinatura é a **situação das máquinas como um mural de placas**.

## Motion

O movimento conta que a placa é um objeto de verdade. Tudo é feito com GSAP e some com `prefers-reduced-motion`.

- **Fixação**: ao entrar, a moldura se desenha e os parafusos giram até apertar. Vale para a abertura e para cada faixa colorida.
- **Plaquetas**: as letras da palavra de sinal giram no eixo horizontal, uma a uma. A mensagem sobe linha por linha de trás de uma máscara.
- **Cada símbolo entra do seu jeito**: o disco de proibido assenta e a barra corta; o triângulo pisca como um sinalizador; o visto se desenha; a seta chega pela esquerda e continua apontando.
- **Vida própria**: as barras da LinkWave oscilam como um sinal, o olho pisca, a engrenagem gira com a rolagem, as ondas do leitor pulsam, o crachá balança no cordão. Laços param fora da tela.
- **Entre páginas**: o disco de proibido viaja da LinkWave para a abertura do LockMachine (View Transitions; sem suporte, a página troca normalmente).
- **Mouse**: símbolos balançam no parafuso, placas da equipe inclinam acompanhando o cursor, setas deslizam.
- **Tempos**: resposta em até 150ms, mudança de estado em até 300ms, sequência de veredito em cerca de 1 segundo. Curva de saída exponencial; o único excesso permitido é o do carimbo de conferido.

## Do's and Don'ts

### Do:

- Escolher a cor pelo que a seção significa, e só depois desenhar.
- Usar a palavra de sinal como título da seção.
- Chamar demonstração de demonstração, em plaquinha amarela.
- Dar a cada movimento um motivo vindo da placa ou do produto: fixar, girar, carimbar, ler o crachá.
- Deixar o conteúdo visível sem JavaScript e sem movimento: a animação parte do estado pronto, nunca o substitui.
- Respeitar `prefers-reduced-motion`: sem deslocamento, o estado muda na hora.

### Don't:

- Usar vermelho, amarelo, azul ou verde como enfeite.
- Trazer de volta foto escura de fábrica, brilho neon, vidro fosco ou texto em degradê.
- Animar por animar: surgir e subir igual em toda seção, paralaxe genérica, efeito que não saiu da placa.
- Fazer alguém esperar uma animação para usar o painel: lá a entrada dura menos de um segundo.
- Pôr rótulo pequeno acima de título, ou numerar seções sem que a ordem importe.
- Usar fonte monoespaçada para "parecer técnico".
- Usar seta ou símbolo de teclado como ícone; ícones são desenhados.
- Sugerir que o leitor físico, o banco de dados ou a autenticação já existem.
