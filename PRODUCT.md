# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

- **Quem o site precisa convencer** (confirmado por Leonardo em 08/10/2026): gestores, supervisores e técnicos de segurança do trabalho da indústria, a quem o site fala como produto real; e a banca avaliadora do TCC do SENAI, que é quem lê primeiro.
- **Quem usaria o LockMachine:** o operador, que aproxima o crachá na máquina antes de começar o trabalho; e o supervisor ou administrador, que acompanha as tentativas de acesso e a situação das máquinas no painel.
- **Cena de apresentação:** ainda indefinida (projetor, notebook ou celular). O site precisa funcionar bem nos três.

## Product Purpose

O LockMachine impede que uma máquina industrial seja operada por quem não tem a capacitação exigida para ela, ou cuja capacitação venceu. A LinkWave é a equipe que o desenvolve, como TCC do SENAI (2026).

Sucesso nesta fase: quem visita o site entende em segundos o problema, a decisão que o sistema toma e o motivo dela; e a banca reconhece um projeto claro, honesto e bem executado.

## Positioning

Um controle de acesso comum responde "quem é você". O LockMachine responde "você está capacitado para esta máquina, hoje": cruza o crachá RFID com a capacitação exigida por aquela máquina e com a validade do treinamento, antes de liberar.

Formulação proposta em 08/10/2026, a validar com a equipe.

## Operating Context

Chão de fábrica: prensas, tornos e fresas; o operador diante da máquina; o supervisor acompanhando do escritório do galpão. O vocabulário é o da segurança do trabalho: capacitação, treinamento, validade, liberação, bloqueio, tentativa de acesso.

## Capabilities and Constraints

- O repositório contém só o front-end: HTML, CSS e JavaScript, sem build e sem back-end, aberto com Live Server.
- Login e dashboard são demonstrações: não há autenticação e os dados são ilustrativos.
- Hoje não existe protótipo físico, leitor RFID, banco de dados nem back-end (confirmado em 08/10/2026). Nada no site pode sugerir o contrário.
- As telas "Acessos", "Máquinas" e "Operadores" ainda não existem.
- Interface em português do Brasil.
- Decidido em 09/10/2026 para a apresentação (ver `docs/plano-apresentacao.md`): leitor com ESP32 e RFID, servidor em PHP + MySQL, painel com cadastro pelo administrador e app Flutter para Android. Nada disso existe ainda.
- Em aberto: a data exata e o formato da apresentação.

## Brand Commitments

- Nomes: LinkWave (equipe) e LockMachine (produto).
- Logos: o símbolo de três barras da LinkWave e o cadeado da LockMachine, ambos desenhados em CSS.
- Cores-base: azul para a LinkWave, vermelho para a LockMachine.
- Retratos desenhados dos cinco integrantes (`linkwave-tcc-reformulado/institucional/img/*-desenho.png`).

## Evidence on Hand

- Retratos da equipe e o papel de cada integrante.
- Duas imagens de fábrica geradas por computador (`linkwave-hero.webp` e `lockmachine-hero.webp`). São ilustrações, não fotos do projeto.
- Não há fotos de protótipo, clientes, depoimentos, métricas de uso nem resultados de teste. Trabalhos futuros não devem inventá-los.

## Product Principles

1. Prevenir antes de operar: a decisão acontece antes de a máquina ligar.
2. A decisão tem que ser legível: liberado ou bloqueado, e o motivo.
3. Honestidade sobre o estágio: proposta e demonstração são chamadas pelo nome.
4. Rastreabilidade: toda tentativa deixa registro para quem supervisiona.
