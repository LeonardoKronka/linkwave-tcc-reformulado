# Estratégia do LockMachine

Rascunho de 08/10/2026 para a equipe validar. Segue o formato de decisão do CEO Advisor: conclusão, o que sabemos (com grau de confiança), por quê, como agir, e a decisão que cabe a vocês.

## Conclusão

O LockMachine não deve se apresentar como "controle de acesso com RFID". Essa categoria já existe e responde só "quem é você". O que o projeto tem de próprio é a **conferência de capacitação no ponto de uso**: a máquina só liga para quem está capacitado para ela, hoje.

O maior risco do projeto não está no site. Está em chegar à banca sem nenhuma prova de que a regra funciona fora do navegador.

## A estratégia em uma frase

> A máquina só liga para quem está capacitado para ela, hoje.

Se alguém da equipe não conseguir explicar o projeto com essa frase, o posicionamento ainda não está fechado.

## O que sabemos

| Afirmação | Confiança | De onde vem |
| --- | --- | --- |
| A NR-12 exige que a operação de máquinas seja feita por trabalhadores habilitados, qualificados ou capacitados, e autorizados (item 12.16.1) | Verificado em duas fontes jurídicas; falta conferir no texto oficial | guiatrabalhista.com.br e normaslegais.com.br |
| Hoje existe só o front-end, sem leitor, banco ou back-end | Verificado | Leonardo, 08/10/2026 |
| Em muitas fábricas a capacitação é conferida em papel ou planilha, longe da máquina | Provável, sem evidência própria | Senso comum do setor; falta ouvir alguém da área |
| Um gestor pagaria por essa conferência automática | Suposição | Ninguém foi entrevistado |
| Os dados de capacitação da empresa estão organizados o bastante para alimentar o sistema | Suposição | Depende de cada empresa |

## Para quem é

- **Quem decide a compra:** gestor de produção ou de segurança do trabalho. Quer reduzir risco de acidente e ter como provar que a regra foi cumprida.
- **Quem usa todo dia:** o operador. Quer que a conferência seja rápida e não atrapalhe o turno.
- **Quem acompanha:** o supervisor. Quer saber quem tentou operar o quê, e por que foi bloqueado.
- **Quem avalia agora:** a banca do TCC. Quer um problema real, uma solução clara e honestidade sobre o que foi construído.

## O que o diferencia

| | Confere a pessoa | Confere a capacitação para aquela máquina | Confere a validade | Registra a tentativa |
| --- | --- | --- | --- | --- |
| Catraca ou controle de acesso comum | Sim | Não | Não | Sim |
| Planilha de treinamentos | Não, no ponto de uso | Só se alguém consultar | Só se alguém consultar | Não |
| Chave ou senha na máquina | Não | Não | Não | Não |
| LockMachine (proposta) | Sim | Sim | Sim | Sim |

## O que pode derrubar o projeto

1. **Nenhuma prova física até a banca.** Sem um leitor de verdade, a pergunta "isso funciona?" fica sem resposta.
2. **Crachá emprestado.** O sistema confere o crachá, não a pessoa. É a primeira objeção que um técnico de segurança vai fazer. Vale ter a resposta pronta, por exemplo senha curta ou biometria como etapa futura.
3. **Cadastro desatualizado.** Se a base de capacitações estiver errada, o sistema bloqueia quem deveria liberar, e a fábrica desliga o sistema.
4. **O que acontece quando o sistema cai.** Bloquear tudo para a produção; liberar tudo anula a segurança. A equipe precisa escolher e justificar.

## Três caminhos para a próxima etapa

| Caminho | Ganho | Custo | Dá para voltar atrás? | Efeito colateral |
| --- | --- | --- | --- | --- |
| **A. Protótipo físico mínimo**: um leitor RFID, um microcontrolador e um LED ou relé | Prova o mecanismo e muda a conversa com a banca | Compra de peças e tempo de montagem | Sim | Obriga a decidir onde a regra roda: no dispositivo ou no servidor |
| **B. Back-end e banco primeiro**: cadastro e uma rota de verificação | O painel passa a mostrar dados de verdade | Sem leitor, continua sendo simulação | Sim | Define o modelo de dados cedo |
| **C. Polir a demonstração**: telas de Acessos, Máquinas e Operadores | Barato e rápido | Não reduz o maior risco | Sim | Aumenta a distância entre o que o site mostra e o que existe |

**Recomendação:** o caminho A no menor tamanho possível, com uma fatia fina do B. Um crachá, uma máquina, uma decisão de verdade. A regra já está escrita em JavaScript (`checkAccess`, em `lockmachine_app/script.js`) e pode servir de referência para a versão do servidor ou do dispositivo.

## Como isso entrou no site

- A abertura do LockMachine deixou de descrever o produto e passou a demonstrá-lo: o visitante aproxima um crachá fictício e vê a decisão e o motivo.
- O texto novo sobre o risco explica a diferença para um controle de acesso comum e cita a NR-12.
- "Como funciona" virou três conferências obrigatórias: identificar-se, ter a capacitação exigida, estar com a validade em dia.
- Todo trecho de demonstração está marcado como demonstração, em amarelo.

## Antes de apresentar

- Conferir o item 12.16.1 no texto oficial da NR-12 com o professor orientador.
- Conversar com um técnico de segurança ou instrutor do SENAI e perguntar como a capacitação é conferida hoje.
- Decidir a resposta para "e se emprestarem o crachá?" e para "e se o sistema cair?".

## A decisão é de vocês

Qual dos três caminhos a equipe segue até a banca, e quem fica responsável por cada parte.
