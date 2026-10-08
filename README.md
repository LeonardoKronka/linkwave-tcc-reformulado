# LinkWave + LockMachine

Projeto de TCC do SENAI (2026). A **LinkWave** é a nossa equipe, e o **LockMachine** é a solução que desenvolvemos: um controle de acesso para máquinas industriais baseado na capacitação do operador.

## O problema

Em uma fábrica, uma máquina pode acabar sendo operada por alguém que não tem o treinamento exigido para ela, ou cujo treinamento já venceu. Isso coloca pessoas e processos em risco.

## A proposta

O LockMachine verifica a capacitação **antes** de a máquina ser liberada:

1. **Identificação** — o operador aproxima o crachá RFID do leitor instalado na máquina.
2. **Verificação** — o sistema confere cadastro, autorização e validade da capacitação exigida.
3. **Liberação ou bloqueio** — a máquina é liberada ou permanece bloqueada, e a tentativa fica registrada para o supervisor.

## O que há neste repositório

O front-end do projeto, feito somente com HTML, CSS e JavaScript:

| Parte | Pasta | Páginas |
| --- | --- | --- |
| Site institucional da LinkWave | `linkwave-tcc-reformulado/institucional/` | `index.html`, `projetos.html` |
| Apresentação e demonstração do LockMachine | `linkwave-tcc-reformulado/lockmachine_app/` | `sobre.html`, `tela_de_login.html`, `dashboard.html` |

### Estado atual

Esta fase é uma **demonstração visual**:

- O login aceita qualquer e-mail válido e qualquer senha, e leva ao dashboard. Não há autenticação real.
- Os dados do dashboard (operadores, máquinas, acessos) são ilustrativos e estão fixos na página.
- As telas "Acessos", "Máquinas" e "Operadores" ainda não foram construídas.
- A integração com o leitor RFID e com o banco de dados ainda não faz parte deste repositório.

## Como abrir

1. Baixe ou clone o repositório:
   ```bash
   git clone https://github.com/LeonardoKronka/linkwave-tcc-reformulado
   ```
2. Abra a pasta no VS Code.
3. Instale a extensão **Live Server**.
4. Clique com o botão direito em `linkwave-tcc-reformulado/index.html` e escolha **Open with Live Server**.

Não é necessário instalar Node.js, banco de dados, PHP ou TypeScript.

## Estrutura

```text
linkwave-tcc-reformulado/
├── index.html                  entrada: redireciona para o site institucional
├── institucional/
│   ├── index.html              site da LinkWave
│   ├── projetos.html           projeto em destaque
│   ├── style.css               visual da LinkWave
│   ├── script.js               menu e animações
│   └── img/
└── lockmachine_app/
    ├── sobre.html              apresentação do LockMachine
    ├── tela_de_login.html      login demonstrativo
    ├── dashboard.html          dashboard demonstrativo
    ├── style.css               visual do LockMachine
    ├── script.js               menu, login e data do dashboard
    └── img/
```

## Equipe

| Integrante | Papel |
| --- | --- |
| Leonardo | Product Owner |
| Cauê | Scrum Master |
| João | Banco de Dados |
| Evelyn | Front-end |
| Gabriel | Documentação |

## Próximos passos

- Publicar o site com GitHub Pages
- Construir as telas de Acessos, Máquinas e Operadores
- Tornar o dashboard dinâmico, lendo os dados em vez de mantê-los fixos na página
- Integrar o leitor RFID e o banco de dados
