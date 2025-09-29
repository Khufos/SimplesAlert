# SimpleAlert

Um addon simples para World of Warcraft (WotLK 3.3.5a) que fornece alertas no chat do grupo sobre eventos de combate importantes.

## O que faz?

O SimpleAlert monitora o log de combate e envia mensagens para o chat do seu grupo (`/p`) quando ocorrem os seguintes eventos:

1.  **Casts Inimigos:** Alerta quando um inimigo começa a conjurar um feitiço importante (ex: `Lava Burst`, `Fireball`).
2.  **Seus DoTs:** Alerta quando você aplica ou quando seu DoT (Damage over Time) é removido de um alvo (ex: `Flame Shock`).
3.  **Debuffs em Você:** Alerta quando você recebe um debuff de controle de grupo (CC) ou outro efeito negativo importante de um jogador inimigo (ex: `Cyclone`, `Polymorph`, `Hammer of Justice`).

Todos os alertas são configuráveis e podem ser ativados ou desativados individualmente.

## Como usar?

Para abrir o painel de configurações, digite um dos seguintes comandos no chat:

-   `/sa`
-   `/simplealert`

No painel, você pode navegar pelas seções e marcar/desmarcar quais alertas deseja receber.

## Funcionalidades

### Alertas de Casts Inimigos

Receba um aviso assim que um inimigo começar a conjurar feitiços rastreados.

### Alertas de Seus DoTs

-   Aviso quando seu DoT for aplicado em um alvo.
-   Aviso quando seu DoT for removido (expirou ou foi dissipado).

### Alertas de Debuffs Recebidos

Seja notificado quando receber um debuff de uma classe inimiga. Os debuffs são organizados por classe no menu de opções, facilitando a personalização.

## Instalação

1.  Baixe o addon.
2.  Extraia a pasta `SimpleAlert` para dentro da sua pasta `Interface\AddOns` no diretório de instalação do World of Warcraft.
3.  Reinicie o jogo e ative o addon na tela de seleção de personagens.
