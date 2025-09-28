-- FearAlertSimple Addon
local addonName = "FearAlertSimple"
local f = CreateFrame("Frame")
f.lastAlertTimes = {}

-- Feitiços que queremos alertar ao iniciar cast
local trackedSpells = {
    ["Lava Burst"] = true,
    ["Lightning Bolt"] = true,
    ["Fireball"] = true,
}

-- DoTs que queremos alertar ao aplicar ou remover
local trackedDots = {
    ["Flame Shock"] = true,
    -- outros DoTs
}

-- Debuffs que queremos rastrear quando recebidos
local trackedDebuffs = {
   -- Death Knight
[47481] = "Gnaw",                    -- Gnaw (Ghoul)
[51209] = "Hungering Cold",          -- Hungering Cold
[47476] = "Strangulate",             -- Strangulate
[45524] = "Chains of Ice",           -- Chains of Ice
[55666] = "Desecration",             -- Desecration
[58617] = "Glyph of Heart Strike",   -- Glyph of Heart Strike
[50436] = "Icy Clutch",              -- Icy Clutch (Chilblains)

-- Druid
[5211]  = "Bash",                    -- Bash
[33786] = "Cyclone",                 -- Cyclone
[2637]  = "Hibernate",               -- Hibernate
[22570] = "Maim",                    -- Maim
[9005]  = "Pounce",                  -- Pounce
[339]   = "Entangling Roots",        -- Entangling Roots
[19675] = "Feral Charge Effect",     -- Feral Charge Effect
[58179] = "Infected Wounds",         -- Infected Wounds
[61391] = "Typhoon",                 -- Typhoon

-- Hunter
[60210] = "Freezing Arrow",          -- Freezing Arrow Effect
[3355]  = "Freezing Trap",           -- Freezing Trap Effect
[24394] = "Intimidation",            -- Intimidation
[1513]  = "Scare Beast",             -- Scare Beast
[19503] = "Scatter Shot",            -- Scatter Shot
[19386] = "Wyvern Sting",            -- Wyvern Sting
[34490] = "Silencing Shot",          -- Silencing Shot
[53359] = "Chimera Shot - Scorpid",  -- Chimera Shot - Scorpid
[19306] = "Counterattack",           -- Counterattack
[19185] = "Entrapment",              -- Entrapment
[35101] = "Concussive Barrage",      -- Concussive Barrage
[5116]  = "Concussive Shot",         -- Concussive Shot
[13810] = "Frost Trap Aura",         -- Frost Trap Aura
[61394] = "Glyph of Freezing Trap",  -- Glyph of Freezing Trap
[2974]  = "Wing Clip",               -- Wing Clip

-- Hunter Pets
[50519] = "Sonic Blast",             -- Sonic Blast (Bat)
[50541] = "Snatch",                  -- Snatch (Bird of Prey)
[54644] = "Froststorm Breath",       -- Froststorm Breath (Chimera)
[50245] = "Pin",                     -- Pin (Crab)
[50271] = "Tendon Rip",              -- Tendon Rip (Hyena)
[50518] = "Ravage",                  -- Ravage (Ravager)
[54706] = "Venom Web Spray",         -- Venom Web Spray (Silithid)
[4167]  = "Web",                     -- Web (Spider)

-- Mage
[44572] = "Deep Freeze",             -- Deep Freeze
[31661] = "Dragon's Breath",         -- Dragon's Breath
[12355] = "Impact",                  -- Impact
[118]   = "Polymorph",               -- Polymorph
[18469] = "Silenced - Improved Counterspell", -- Silenced - Improved Counterspell
[64346] = "Fiery Payback",           -- Fiery Payback
[33395] = "Freeze",                  -- Freeze (Water Elemental)
[122]   = "Frost Nova",              -- Frost Nova
[11071] = "Frostbite",               -- Frostbite
[55080] = "Shattered Barrier",       -- Shattered Barrier
[11113] = "Blast Wave",              -- Blast Wave
[6136]  = "Chilled",                 -- Chilled
[120]   = "Cone of Cold",            -- Cone of Cold
[116]   = "Frostbolt",               -- Frostbolt
[47610] = "Frostfire Bolt",          -- Frostfire Bolt
[31589] = "Slow",                    -- Slow

-- Paladin
[853]   = "Hammer of Justice",       -- Hammer of Justice
[2812]  = "Holy Wrath",              -- Holy Wrath
[20066] = "Repentance",              -- Repentance
[20170] = "Stun (Seal of Justice)",  -- Stun (Seal of Justice proc)
[10326] = "Turn Evil",               -- Turn Evil
[63529] = "Shield of the Templar",   -- Shield of the Templar
[20184] = "Judgement of Justice",    -- Judgement of Justice

-- Priest
[605]   = "Mind Control",            -- Mind Control
[64044] = "Psychic Horror",          -- Psychic Horror
[8122]  = "Psychic Scream",          -- Psychic Scream
[9484]  = "Shackle Undead",          -- Shackle Undead
[15487] = "Silence",                 -- Silence
[15407] = "Mind Flay",               -- Mind Flay

-- Rogue
[2094]  = "Blind",                   -- Blind
[1833]  = "Cheap Shot",              -- Cheap Shot
[1776]  = "Gouge",                   -- Gouge
[408]   = "Kidney Shot",             -- Kidney Shot
[6770]  = "Sap",                     -- Sap
[1330]  = "Garrote - Silence",       -- Garrote - Silence
[18425] = "Silenced - Improved Kick",-- Silenced - Improved Kick
[51722] = "Dismantle",               -- Dismantle
[31125] = "Blade Twisting",          -- Blade Twisting
[3409]  = "Crippling Poison",        -- Crippling Poison
[26679] = "Deadly Throw",            -- Deadly Throw

-- Shaman
[39796] = "Stoneclaw Stun",          -- Stoneclaw Stun
[51514] = "Hex",                     -- Hex
[64695] = "Earthgrab",               -- Earthgrab
[63685] = "Freeze (Frozen Power)",   -- Freeze (Frozen Power)
[3600]  = "Earthbind",               -- Earthbind
[8056]  = "Frost Shock",             -- Frost Shock
[8034]  = "Frostbrand Attack",       -- Frostbrand Attack

-- Warlock
[710]   = "Banish",                  -- Banish
[6789]  = "Death Coil",              -- Death Coil
[5782]  = "Fear",                    -- Fear
[5484]  = "Howl of Terror",          -- Howl of Terror
[6358]  = "Seduction",               -- Seduction
[30283] = "Shadowfury",              -- Shadowfury
[24259] = "Spell Lock",              -- Spell Lock
[18118] = "Aftermath",               -- Aftermath
[18223] = "Curse of Exhaustion",     -- Curse of Exhaustion

-- Warrior
[7922]  = "Charge Stun",             -- Charge Stun
[12809] = "Concussion Blow",         -- Concussion Blow
[20253] = "Intercept",               -- Intercept
[5246]  = "Intimidating Shout",      -- Intimidating Shout
[12798] = "Revenge Stun",            -- Revenge Stun
[46968] = "Shockwave",               -- Shockwave
[18498] = "Silenced - Gag Order",    -- Silenced - Gag Order
[676]   = "Disarm",                  -- Disarm
[58373] = "Glyph of Hamstring",      -- Glyph of Hamstring
[23694] = "Improved Hamstring",      -- Improved Hamstring
[1715]  = "Hamstring",               -- Hamstring
[12323] = "Piercing Howl",           -- Piercing Howl

-- Other
[30217] = "Adamantite Grenade",      -- Adamantite Grenade
[67769] = "Cobalt Frag Bomb",        -- Cobalt Frag Bomb
[30216] = "Fel Iron Bomb",           -- Fel Iron Bomb
[20549] = "War Stomp",               -- War Stomp
[25046] = "Arcane Torrent",          -- Arcane Torrent
[39965] = "Frost Grenade",           -- Frost Grenade
[55536] = "Frostweave Net",          -- Frostweave Net
[13099] = "Net-o-Matic",             -- Net-o-Matic
[29703] = "Dazed",                   -- Dazed

-- Immunities
[46924] = "Bladestorm",              -- Bladestorm (Warrior)
[642]   = "Divine Shield",           -- Divine Shield (Paladin)
[45438] = "Ice Block",               -- Ice Block (Mage)
[34692] = "The Beast Within",        -- The Beast Within (Hunter)

-- PvE
[28169] = "Mutating Injection",      -- Mutating Injection (Grobbulus)
[28059] = "Positive Charge",         -- Positive Charge (Thaddius)
[28084] = "Negative Charge",         -- Negative Charge (Thaddius)
[27819] = "Detonate Mana",           -- Detonate Mana (Kel'Thuzad)
[63024] = "Gravity Bomb",            -- Gravity Bomb (XT-002 Deconstructor)
[63018] = "Light Bomb",              -- Light Bomb (XT-002 Deconstructor)
[62589] = "Nature's Fury",           -- Nature's Fury (Freya)
[63276] = "Mark of the Faceless",    -- Mark of the Faceless (General Vezax)
[66770] = "Ferocious Butt",          -- Ferocious Butt (Icehowl)


    -- outros debuffs
}

-- Função genérica para enviar alertas com controle de spam
local function SendAlert(key, message, cooldown)
    local now = GetTime()
    cooldown = cooldown or 5
    if not f.lastAlertTimes[key] or (now - f.lastAlertTimes[key]) > cooldown then
        SendChatMessage(message, "YELL")
        f.lastAlertTimes[key] = now
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
    DEFAULT_CHAT_FRAME:AddMessage(addonName .. " carregado!")
end

-- Lógica de combate
function f:HandleCombatLog(...)
    local _, eventType, sourceGUID, sourceName, _, destGUID, destName, _, spellId, spellName = select(1, ...)

    -- Eventos que você causou
    if sourceGUID == UnitGUID("player") then
        if eventType == "SPELL_CAST_START" then
            self:HandleSpellCastStart(spellName)
        elseif eventType == "SPELL_AURA_APPLIED" then
            self:HandleDotApplied(spellName, destName, destGUID)
        elseif eventType == "SPELL_AURA_REMOVED" then
            self:HandleDotRemoved(spellName, destName, destGUID)
        end
    end

    -- Eventos que você sofreu
    if destGUID == UnitGUID("player") then
        if eventType == "SPELL_CAST_SUCCESS" then
            self:HandleDebuffApplied(spellId, spellName, sourceName)
        elseif eventType == "SPELL_AURA_REMOVED" then
            self:HandleDebuffRemoved(spellId, spellName, sourceName)
        end
    end
end

-- Alerta de início de cast
function f:HandleSpellCastStart(spellName)
    if trackedSpells[spellName] then
        local targetName = UnitName("target") or "???"
        SendAlert("cast_" .. spellName, "Castando " .. spellName .. " em " .. targetName)
    end
end

-- Alerta de aplicação de DoT
function f:HandleDotApplied(spellName, destName, destGUID)
    if trackedDots[spellName] then
        local name = destName or "???"
        SendAlert("dot_" .. spellName .. "_" .. destGUID, "Apliquei " .. spellName .. " em " .. name)
    end
end

-- Alerta de remoção de DoT
function f:HandleDotRemoved(spellName, destName, destGUID)
    if trackedDots[spellName] then
        local name = destName or "???"
        SendAlert("remove_" .. spellName .. "_" .. destGUID, "O debuff " .. spellName .. " saiu de " .. name)
    end
end

-- Alerta de debuff recebido
function f:HandleDebuffApplied(spellId, spellName, sourceName)
   
    if trackedDebuffs[spellId] then
        local debuffName = trackedDebuffs[spellId]
        SendAlert("debuff_" .. spellId, "Recebi " .. debuffName .. " de " .. (sourceName or "???"))
    end
end

-- Alerta de debuff removido
function f:HandleDebuffRemoved(spellId, spellName, sourceName)
    if trackedDebuffs[spellId] then
        local debuffName = trackedDebuffs[spellId]
        SendAlert("debuff_off_" .. spellId, debuffName .. " acabou! Foi aplicado por " .. (sourceName or "???"))
    end
end



-- Comando manual de teste
SLASH_FS1 = "/fs"
SlashCmdList["FS"] = function()
    SendChatMessage("Teste FearAlert!", "YELL")
end

-- Eventos registrados
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")