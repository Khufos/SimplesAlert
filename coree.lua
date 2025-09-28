-- FearAlertSimple Addon
local addonName = "FearAlertSimple"
local f = CreateFrame("Frame")
f.lastAlertTimes = {}
f.activeDebuffs = {}

-- Feitiços que queremos alertar ao iniciar cast
local trackedSpells = {
    ["Lava Burst"] = true,
    ["Lightning Bolt"] = true,
    ["Fireball"] = true,
}

-- DoTs que queremos alertar ao aplicar ou remover
local trackedDots = {
    ["Flame Shock"] = true,
}

-- Debuffs que queremos rastrear (lista reduzida para teste)
local trackedDebuffs = {
    [5782] = "Fear",                    -- Warlock Fear
    [5484] = "Howl of Terror",          -- Warlock Howl of Terror
    [8122] = "Psychic Scream",          -- Priest Psychic Scream
    [5246] = "Intimidating Shout",      -- Warrior Intimidating Shout
    [1513] = "Scare Beast",             -- Hunter Scare Beast
    [10326] = "Turn Evil",              -- Paladin Turn Evil
}

-- Função genérica para enviar alertas com controle de spam
local function SendAlert(key, message, cooldown)
    local now = GetTime()
    cooldown = cooldown or 5
    if not f.lastAlertTimes[key] or (now - f.lastAlertTimes[key]) > cooldown then
        SendChatMessage(message, "YELL")
        f.lastAlertTimes[key] = now
        print("ALERTA: " .. message) -- Debug no chat
    end
end

-- Evento principal
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:OnPlayerLogin()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:HandleCombatLog(...)
    end
end)

-- Mensagem de boas-vindas
function f:OnPlayerLogin()
    DEFAULT_CHAT_FRAME:AddMessage(addonName .. " carregado! Use /fs debug para informações.")
end

-- Lógica de combate - SIMPLIFICADA para debugging
function f:HandleCombatLog(...)
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
          destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType = select(1, ...)
    
    -- Debug: mostrar eventos importantes
    if trackedDebuffs[spellId] and destGUID == UnitGUID("player") then
        print(string.format("DEBUG: %s %s %d %s", eventType, spellName or "nil", spellId or 0, auraType or "nil"))
    end

    -- Eventos que você SOFREU (debuffs)
    if destGUID == UnitGUID("player") then
        -- Aplicação de debuff
        if eventType == "SPELL_AURA_APPLIED" and auraType == "DEBUFF" then
            self:HandleDebuffApplied(spellId, spellName, sourceName)
        
        -- Remoção de debuff (todas as variações possíveis)
        elseif (eventType == "SPELL_AURA_REMOVED" or 
                eventType == "SPELL_AURA_BROKEN" or 
                eventType == "SPELL_AURA_BROKEN_SPELL") and auraType == "DEBUFF" then
            self:HandleDebuffRemoved(spellId, spellName, sourceName)
        end
    end

    -- Eventos que você CAUSOU (opcional, para teste)
    if sourceGUID == UnitGUID("player") then
        if eventType == "SPELL_CAST_START" and trackedSpells[spellName] then
            self:HandleSpellCastStart(spellName)
        end
    end
end

-- Alerta de início de cast
function f:HandleSpellCastStart(spellName)
    local targetName = UnitName("target") or "???"
    SendAlert("cast_" .. spellName, "Castando " .. spellName .. " em " .. targetName, 3)
end

-- Alerta de debuff recebido - SIMPLIFICADO
function f:HandleDebuffApplied(spellId, spellName, sourceName)
    if trackedDebuffs[spellId] then
        local debuffName = trackedDebuffs[spellId]
        print(string.format("DEBUFF APLICADO: %s (%d) de %s", debuffName, spellId, sourceName or "???"))
        
        -- Registrar que este debuff está ativo
        f.activeDebuffs[spellId] = {
            name = debuffName,
            source = sourceName,
            appliedTime = GetTime()
        }
        
        SendAlert("debuff_" .. spellId, "Recebi " .. debuffName .. " de " .. (sourceName or "???"), 2)
    end
end

-- Alerta de debuff removido - SIMPLIFICADO
function f:HandleDebuffRemoved(spellId, spellName, sourceName)
    if trackedDebuffs[spellId] then
        local debuffName = trackedDebuffs[spellId]
        local debuffInfo = f.activeDebuffs[spellId]
        
        print(string.format("DEBUFF REMOVIDO: %s (%d)", debuffName, spellId))
        
        if debuffInfo then
            local duration = GetTime() - debuffInfo.appliedTime
            SendAlert("debuff_off_" .. spellId, debuffName .. " acabou! Durou " .. string.format("%.1f", duration) .. "s", 2)
            f.activeDebuffs[spellId] = nil
        else
            SendAlert("debuff_off_" .. spellId, debuffName .. " acabou!", 2)
        end
    end
end

-- Comando para debug
SLASH_FEARSIMPLE1 = "/fs"
SlashCmdList["FEARSIMPLE"] = function(msg)
    if msg == "debug" then
        print("=== FearAlertSimple Debug ===")
        print("Addon carregado: Sim")
        print("Eventos registrados: Sim")
        print("Unidade Player: " .. (UnitName("player") or "unknown"))
        print("GUID Player: " .. (UnitGUID("player") or "unknown"))
        
        print("=== Debuffs Ativos ===")
        local count = 0
        for spellId, info in pairs(f.activeDebuffs) do
            local duration = GetTime() - info.appliedTime
            print(string.format("%s (%d) - %.1fs - por %s", info.name, spellId, duration, info.source or "???"))
            count = count + 1
        end
        if count == 0 then
            print("Nenhum debuff ativo")
        end
        
        print("=== Tracked Debuffs ===")
        for spellId, name in pairs(trackedDebuffs) do
            print(string.format("%d: %s", spellId, name))
        end
        print("=====================")
        
    elseif msg == "test" then
        -- Teste manual
        SendAlert("test", "Teste do FearAlertSimple funcionando!", 1)
        
    elseif msg == "reset" then
        -- Resetar alertas
        f.lastAlertTimes = {}
        f.activeDebuffs = {}
        print("Alertas resetados")
        
    else
        print("FearAlertSimple Comandos:")
        print("/fs debug - Mostrar informações de debug")
        print("/fs test - Testar alerta")
        print("/fs reset - Resetar alertas ativos")
    end
end

-- Eventos registrados
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

print(addonName .. " carregado! Digite /fs para ver comandos.")