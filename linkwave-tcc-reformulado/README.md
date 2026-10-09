# LinkWave + LockMachine

Projeto feito com HTML, CSS e JavaScript, sem etapa de build.

A descrição completa do projeto está no [README da raiz do repositório](../README.md). Este arquivo traz só as instruções rápidas de uso.

## Como abrir

1. Abra esta pasta no VS Code.
2. Instale a extensão **Live Server**.
3. Clique com o botão direito em `index.html`.
4. Escolha **Open with Live Server**.

Não é necessário instalar Node.js, banco de dados, PHP ou TypeScript. Fontes e biblioteca de animação já estão na pasta `assets`, então o site funciona sem internet.

## Organização

```text
index.html                          entrada do projeto
assets/css/base.css                 sistema visual compartilhado
assets/js/head.js                   preparo da página antes de ela aparecer
assets/js/base.js                   menu e animações comuns aos dois sites
assets/fonts/                       fontes Archivo e Martian Mono
assets/vendor/gsap/                 biblioteca de animação GSAP e dois plugins
institucional/index.html            site da LinkWave
institucional/projetos.html         apresentação do projeto em destaque
institucional/style.css             o que é só da LinkWave
institucional/script.js             símbolos animados da LinkWave
lockmachine_app/sobre.html          apresentação e simulador do LockMachine
lockmachine_app/tela_de_login.html  login demonstrativo
lockmachine_app/dashboard.html      painel demonstrativo
lockmachine_app/style.css           o que é só do LockMachine
lockmachine_app/script.js           simulador, registro, login e painel
```

## Simulador do leitor

Na página do LockMachine, escolha um crachá e uma máquina e arraste o crachá até o leitor, ou clique em **Aproximar crachá**. A placa responde "Liberado" ou "Bloqueado" e mostra o motivo. Operadores, máquinas e datas são fictícios; as validades são calculadas a partir da data de hoje.

## Login de demonstração

Preencha os campos com qualquer e-mail válido e qualquer senha. Não existe autenticação real nesta fase: o formulário apenas encaminha para o painel de demonstração, que mostra dados ilustrativos e as tentativas feitas no simulador durante a mesma sessão do navegador.
