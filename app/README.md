# LockMachine: aplicativo

Aplicativo do LockMachine para Android, feito em Flutter. Tem dois perfis: o **supervisor** acompanha as tentativas de acesso e a situação das máquinas, e o **operador** consulta as próprias capacitações. É uma das quatro peças do [plano da apresentação](../docs/plano-apresentacao.md).

## Estado atual

Esta fase é uma **demonstração**. Existe o projeto e a tela de login:

- O login **não fala com servidor nenhum**. Ele confere contas de teste fixas no código (`FakeAuthService`). O aviso amarelo da própria tela diz isso e oferece as contas.
- Depois do login aparece só uma placa dizendo quem entrou. As telas do supervisor e do operador ainda não foram feitas.
- O aplicativo foi visto rodando só no navegador. Ainda não foi instalado em um celular Android.
- O ícone ainda é o padrão do Flutter.

## Contas de teste

| Perfil | Nome | E-mail |
| --- | --- | --- |
| Supervisor | Leonardo Silva | `supervisor@empresa.test` |
| Operador | Marina Costa | `marina@empresa.test` |
| Operador | Carlos Souza | `carlos@empresa.test` |
| Operador | Pedro Alves | `pedro@empresa.test` |

São as mesmas pessoas fictícias do site: o supervisor do painel e os três operadores do simulador. A senha é a mesma para todas e aparece no aviso amarelo da tela de login, que também preenche os campos com um toque.

## Como rodar

É preciso ter o [Flutter](https://docs.flutter.dev/install) instalado (versão 3.47 ou mais nova). Dentro desta pasta (`app/`), baixe as dependências:

```bash
flutter pub get
```

Para ver as telas no navegador, sem celular e sem emulador:

```bash
flutter run -d chrome
```

Para rodar em um celular Android ou no emulador é preciso instalar também o Android Studio. O comando `flutter doctor` mostra o que falta. Com o celular ligado por USB (ou o emulador aberto):

```bash
flutter run
```

## Antes de enviar alterações

O analisador aponta erros e descuidos no código:

```bash
flutter analyze
```

Os testes abrem o aplicativo e conferem o login (campos vazios, senha errada, supervisor, operador, sair):

```bash
flutter test
```

## Organização

```text
lib/
  main.dart                 ponto de entrada: escolhe quem confere o login
  app.dart                  tema e troca entre o login e a tela inicial
  theme/
    tokens.dart             cores e medidas (as mesmas do site)
    type.dart               estilos de texto
    theme.dart              tema do Flutter, bordas de campo e aparência de botão
  auth/
    session.dart            quem entrou e com qual perfil
    auth_service.dart       contrato do login: o que a tela conhece
    fake_auth_service.dart  contas de teste, até a API existir
  login/login_screen.dart   a placa "Acesso restrito"
  home/home_screen.dart     tela provisória depois do login
  widgets/                  placa, palavra de sinal, botão, campo, aviso, marca e ícones
test/                       testes do login e das contas de teste
assets/fonts/               Archivo e Martian Mono, com as licenças
android/  web/              o que cada plataforma precisa (gerado pelo Flutter)
```

Nomes de classe, variável e função ficam em inglês; comentários e textos da tela, em português. O aplicativo usa só o que vem com o Flutter, sem pacotes de terceiros.

## Visual

O aplicativo segue o mesmo sistema do site, descrito no [DESIGN.md](../DESIGN.md): placas de segurança, em que a cor sempre significa alguma coisa (vermelho proíbe, amarelo alerta, azul obriga, verde libera) e a ação comum é preta ou branca.

- As cores e medidas de `lib/theme/tokens.dart` são as mesmas de `linkwave-tcc-reformulado/assets/css/base.css`. Mudou lá, mude aqui.
- A placa é lisa: borda preta, cantos arredondados e sombra curta. Sem filete e sem parafusos.
- Movimento: a placa cai e é fixada ao abrir, as letras da palavra de sinal giram como plaquetas, a cabeça da placa vira "Liberado" quando o login dá certo e a placa balança quando dá errado. Com as animações do sistema desligadas (Android: Acessibilidade → Remover animações), nada se move e o estado muda na hora.

## Quando a API existir

A tela de login só conhece um contrato, o `AuthService`. Para ligar o login de verdade, basta criar uma classe com esse contrato que chame a API e trocá-la pelo `FakeAuthService` em `lib/main.dart`. A tela e os testes continuam os mesmos.

O que o aplicativo espera do `POST /api/login`, como proposta inicial para o Cauê refinar:

| Situação | Resposta esperada |
| --- | --- |
| E-mail e senha conferem | nome, e-mail e perfil (`supervisor`, `operador` ou `administrador`) |
| E-mail ou senha não conferem | erro de credenciais inválidas |
| Conta desativada pelo administrador | erro de conta desativada |

Nessa etapa também vai ser preciso acrescentar o pacote `http`, a permissão de internet no `AndroidManifest.xml` e a liberação de HTTP sem criptografia para o servidor local, porque o XAMPP não usa HTTPS.

## Licenças

As fontes [Archivo](https://fonts.google.com/specimen/Archivo) e [Martian Mono](https://fonts.google.com/specimen/Martian+Mono) estão sob a SIL Open Font License. Os textos das licenças ficam em `assets/fonts/` e entram na lista de licenças do aplicativo.
