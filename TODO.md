# TODO - Próximas Features para o SimpleAlert

Este arquivo descreve as próximas funcionalidades a serem implementadas para melhorar o addon.

## ✅ 1. Painel de Configuração (A mais importante)

**Objetivo:** Permitir que os usuários personalizem o comportamento do addon através de um menu na interface do jogo.

**Implementação:**
- Usar as bibliotecas `AceConfig-3.0` e `AceConfigDialog-3.0` para criar la interface de opções.
- A estrutura de opções deve ser uma tabela Lua que define cada opção (ex: `type = 'toggle'` para ligar/desligar, `type = 'group'` para agrupar).
- Criar um grupo de opções para cada classe (Mage, Warrior, etc.) e dentro de cada grupo, um toggle para cada magia.
- A tabela de opções será passada para `AceConfig:RegisterOptionsTable("SimpleAlert", options)`.
- O acesso aos valores salvos será feito através do banco de dados do `AceDB-3.0` (ex: `self.db.profile.spells[spellId]`).

**Exemplo de estrutura de opções:**
```lua
local options = {
    name = "SimpleAlert",
    type = "group",
    args = {
        spells = {
            name = "Magias",
            type = "group",
            args = {
                mage = {
                    name = "Mago",
                    type = "group",
                    args = {
                        [118] = { -- Polymorph
                            name = "Polymorph",
                            desc = "Ativar/Desativar alerta para Polymorph.",
                            type = "toggle",
                            get = function(info) return db.profile.spells[118] end,
                            set = function(info, val) db.profile.spells[118] = val end,
                        },
                        -- Outras magias de Mago
                    },
                },
                -- Outras classes
            },
        },
    },
}
```

## ✅ 2. Canais de Alerta Configuráveis

**Objetivo:** Permitir que o usuário escolha para onde as mensagens de alerta são enviadas.

**Implementação:**
- Adicionar uma opção do tipo `'select'` no painel de configuração (`AceConfig`).
- As opções seriam: "Party", "Raid", "Say", "Yell", "Self".
- Na função `SendAlert`, em vez de usar `SendChatMessage("message", "PARTY")` fixo, ler a opção do banco de dados e usar a escolha do usuário.

**Exemplo:**
```lua
local channel = db.profile.alertChannel -- Ex: "RAID"
SendChatMessage(message, channel)
```

## ⏳ 3. Mensagens Personalizáveis

**Objetivo:** Permitir que o usuário edite o texto dos alertas.

**Implementação:**
- Adicionar uma opção do tipo `'input'` (caixa de texto) para cada alerta no painel de configuração.
- A mensagem padrão seria o valor inicial.
- A função `SendAlert` usaria `string.format` ou `string.gsub` para substituir placeholders (ex: `{spell}`, `{source}`, `{dest}`) pela informação em tempo real.

**Exemplo:**
```lua
-- Mensagem do usuário: "{spell} em mim, vindo de {source}!"
local userMessage = db.profile.messages[spellId]
local formattedMessage = userMessage:gsub("{spell}", spellName):gsub("{source}", sourceName)
SendChatMessage(formattedMessage, channel)
```

## ✅ 4. Alertas Visuais e Sonoros

**Objetivo:** Fornecer feedback não textual para os eventos.

**Implementação:**
- **Visual:**
    - Criar um `Frame` que pode exibir uma textura (`CreateFrame("Frame", "SimpleAlert_IconFrame")`).
    - No painel de configuração, adicionar opções para ativar o alerta visual e escolher sua posição/tamanho.
    - Quando um alerta é disparado, usar `IconFrame:SetTexture(GetSpellTexture(spellId))` e mostrá-lo por alguns segundos.
- **Sonoro:**
    - Adicionar uma opção para escolher um som da lista de sons do jogo (`libs/LibSharedMedia-3.0` pode ajudar com isso).
    - Usar a função `PlaySoundFile()` para tocar o som escolhido quando o alerta é ativado.

## ✅ 5. Sistema de Perfis (Profiles)

**Objetivo:** Permitir que os usuários salvem e troquem entre diferentes conjuntos de configurações.

**Implementação:**
- Usar a biblioteca `AceDBOptions-3.0` que se integra com `AceDB-3.0` para fornecer uma interface de gerenciamento de perfis pronta.
- Isso adicionará automaticamente as opções de "Profiles" ao painel de configuração.
- Pode-se usar `LibDualSpec-1.0` para detectar a troca de talentos do jogador e trocar o perfil do addon automaticamente.

## ⏳ 6. Filtros por Zona/Contexto

**Objetivo:** Controlar onde e quando os alertas estão ativos.

**Implementação:**
- Adicionar opções de toggle no painel de configuração: "Ativar em Arenas", "Ativar em BGs", "Ativar em Raides".
- Antes de disparar um alerta na função `SendAlert`, verificar o contexto atual do jogador.
- Usar a função `GetZonePVPInfo()` para saber se está em BG ou Arena.
- Usar `GetInstanceInfo()` para verificar se está em uma instância de raide, grupo ou cenário.

**Exemplo:**
```lua
local _, instanceType = GetInstanceInfo()
if (db.profile.enableInRaids and instanceType == "raid") or (db.profile.enableInBGs and GetZonePVPInfo() == "battleground") then
    -- Enviar alerta
end
```
