local addonName, addon = ...

local SimpleAlert = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

-- Feitiços que queremos alertar ao iniciar cast
local trackedSpells = {
    ["Lava Burst"] = true,
    ["Lightning Bolt"] = true,
    ["Fireball"] = true,
    ["Mortal Strike"] = true,
}

-- DoTs que queremos alertar ao aplicar ou remover
local trackedDots = {
    ["Flame Shock"] = true,
    ["Mortal Strike"] = true,
}

-- Debuffs que queremos rastrear quando recebidos
-- Organizado por [spellID] = {name = "Spell Name", class = "CLASS"}
local trackedDebuffs = {
   -- Death Knight
    [47481] = { name = "Gnaw", class = "DEATHKNIGHT" },
    [51209] = { name = "Hungering Cold", class = "DEATHKNIGHT" },
    [47476] = { name = "Strangulate", class = "DEATHKNIGHT" },
    [45524] = { name = "Chains of Ice", class = "DEATHKNIGHT" },
    [55666] = { name = "Desecration", class = "DEATHKNIGHT" },
    [58617] = { name = "Glyph of Heart Strike", class = "DEATHKNIGHT" },
    [50436] = { name = "Icy Clutch", class = "DEATHKNIGHT" },
    -- Druid
    [5211]  = { name = "Bash", class = "DRUID" },
    [33786] = { name = "Cyclone", class = "DRUID" },
    [2637]  = { name = "Hibernate", class = "DRUID" },
    [22570] = { name = "Maim", class = "DRUID" },
    [9005]  = { name = "Pounce", class = "DRUID" },
    [339]   = { name = "Entangling Roots", class = "DRUID" },
    [19675] = { name = "Feral Charge Effect", class = "DRUID" },
    [58179] = { name = "Infected Wounds", class = "DRUID" },
    [61391] = { name = "Typhoon", class = "DRUID" },
    -- Hunter
    [60210] = { name = "Freezing Arrow", class = "HUNTER" },
    [3355]  = { name = "Freezing Trap", class = "HUNTER" },
    [24394] = { name = "Intimidation", class = "HUNTER" },
    [1513]  = { name = "Scare Beast", class = "HUNTER" },
    [19503] = { name = "Scatter Shot", class = "HUNTER" },
    [19386] = { name = "Wyvern Sting", class = "HUNTER" },
    [34490] = { name = "Silencing Shot", class = "HUNTER" },
    [53359] = { name = "Chimera Shot - Scorpid", class = "HUNTER" },
    [19306] = { name = "Counterattack", class = "HUNTER" },
    [19185] = { name = "Entrapment", class = "HUNTER" },
    [35101] = { name = "Concussive Barrage", class = "HUNTER" },
    [5116]  = { name = "Concussive Shot", class = "HUNTER" },
    [13810] = { name = "Frost Trap Aura", class = "HUNTER" },
    [61394] = { name = "Glyph of Freezing Trap", class = "HUNTER" },
    [2974]  = { name = "Wing Clip", class = "HUNTER" },
    -- Hunter Pets
    [50519] = { name = "Sonic Blast (Bat)", class = "HUNTER" },
    [50541] = { name = "Snatch (Bird of Prey)", class = "HUNTER" },
    [54644] = { name = "Froststorm Breath (Chimera)", class = "HUNTER" },
    [50245] = { name = "Pin (Crab)", class = "HUNTER" },
    [50271] = { name = "Tendon Rip (Hyena)", class = "HUNTER" },
    [50518] = { name = "Ravage (Ravager)", class = "HUNTER" },
    [54706] = { name = "Venom Web Spray (Silithid)", class = "HUNTER" },
    [4167]  = { name = "Web (Spider)", class = "HUNTER" },
    -- Mage
    [44572] = { name = "Deep Freeze", class = "MAGE" },
    [31661] = { name = "Dragon's Breath", class = "MAGE" },
    [12355] = { name = "Impact", class = "MAGE" },
    [118]   = { name = "Polymorph", class = "MAGE" },
    [18469] = { name = "Silenced - Improved Counterspell", class = "MAGE" },
    [64346] = { name = "Fiery Payback", class = "MAGE" },
    [33395] = { name = "Freeze (Water Elemental)", class = "MAGE" },
    [122]   = { name = "Frost Nova", class = "MAGE" },
    [11071] = { name = "Frostbite", class = "MAGE" },
    [55080] = { name = "Shattered Barrier", class = "MAGE" },
    [11113] = { name = "Blast Wave", class = "MAGE" },
    [6136]  = { name = "Chilled", class = "MAGE" },
    [120]   = { name = "Cone of Cold", class = "MAGE" },
    [116]   = { name = "Frostbolt", class = "MAGE" },
    [47610] = { name = "Frostfire Bolt", class = "MAGE" },
    [31589] = { name = "Slow", class = "MAGE" },
    -- Paladin
    [853]   = { name = "Hammer of Justice", class = "PALADIN" },
    [2812]  = { name = "Holy Wrath", class = "PALADIN" },
    [20066] = { name = "Repentance", class = "PALADIN" },
    [20170] = { name = "Stun (Seal of Justice)", class = "PALADIN" },
    [10326] = { name = "Turn Evil", class = "PALADIN" },
    [63529] = { name = "Shield of the Templar", class = "PALADIN" },
    [20184] = { name = "Judgement of Justice", class = "PALADIN" },
    -- Priest
    [605]   = { name = "Mind Control", class = "PRIEST" },
    [64044] = { name = "Psychic Horror", class = "PRIEST" },
    [8122]  = { name = "Psychic Scream", class = "PRIEST" },
    [9484]  = { name = "Shackle Undead", class = "PRIEST" },
    [15487] = { name = "Silence", class = "PRIEST" },
    [15407] = { name = "Mind Flay", class = "PRIEST" },
    -- Rogue
    [2094]  = { name = "Blind", class = "ROGUE" },
    [1833]  = { name = "Cheap Shot", class = "ROGUE" },
    [1776]  = { name = "Gouge", class = "ROGUE" },
    [408]   = { name = "Kidney Shot", class = "ROGUE" },
    [6770]  = { name = "Sap", class = "ROGUE" },
    [1330]  = { name = "Garrote - Silence", class = "ROGUE" },
    [18425] = { name = "Silenced - Improved Kick", class = "ROGUE" },
    [51722] = { name = "Dismantle", class = "ROGUE" },
    [31125] = { name = "Blade Twisting", class = "ROGUE" },
    [3409]  = { name = "Crippling Poison", class = "ROGUE" },
    [26679] = { name = "Deadly Throw", class = "ROGUE" },
    -- Shaman
    [39796] = { name = "Stoneclaw Stun", class = "SHAMAN" },
    [51514] = { name = "Hex", class = "SHAMAN" },
    [64695] = { name = "Earthgrab", class = "SHAMAN" },
    [63685] = { name = "Freeze (Frozen Power)", class = "SHAMAN" },
    [3600]  = { name = "Earthbind", class = "SHAMAN" },
    [8056]  = { name = "Frost Shock", class = "SHAMAN" },
    [8034]  = { name = "Frostbrand Attack", class = "SHAMAN" },
    -- Warlock
    [710]   = { name = "Banish", class = "WARLOCK" },
    [6789]  = { name = "Death Coil", class = "WARLOCK" },
    [5782]  = { name = "Fear", class = "WARLOCK" },
    [5484]  = { name = "Howl of Terror", class = "WARLOCK" },
    [6358]  = { name = "Seduction", class = "WARLOCK" },
    [30283] = { name = "Shadowfury", class = "WARLOCK" },
    [24259] = { name = "Spell Lock", class = "WARLOCK" },
    [18118] = { name = "Aftermath", class = "WARLOCK" },
    [18223] = { name = "Curse of Exhaustion", class = "WARLOCK" },
    -- Warrior
    [7922]  = { name = "Charge Stun", class = "WARRIOR" },
    [12809] = { name = "Concussion Blow", class = "WARRIOR" },
    [20253] = { name = "Intercept", class = "WARRIOR" },
    [5246]  = { name = "Intimidating Shout", class = "WARRIOR" },
    [12798] = { name = "Revenge Stun", class = "WARRIOR" },
    [46968] = { name = "Shockwave", class = "WARRIOR" },
    [18498] = { name = "Silenced - Gag Order", class = "WARRIOR" },
    [676]   = { name = "Disarm", class = "WARRIOR" },
    [58373] = { name = "Glyph of Hamstring", class = "WARRIOR" },
    [23694] = { name = "Improved Hamstring", class = "WARRIOR" },
    [1715]  = { name = "Hamstring", class = "WARRIOR" },
    [12323] = { name = "Piercing Howl", class = "WARRIOR" },
    -- Other
    [30217] = { name = "Adamantite Grenade", class = "OTHER" },
    [67769] = { name = "Cobalt Frag Bomb", class = "OTHER" },
    [30216] = { name = "Fel Iron Bomb", class = "OTHER" },
    [20549] = { name = "War Stomp", class = "OTHER" },
    [25046] = { name = "Arcane Torrent", class = "OTHER" },
    [39965] = { name = "Frost Grenade", class = "OTHER" },
    [55536] = { name = "Frostweave Net", class = "OTHER" },
    [13099] = { name = "Net-o-Matic", class = "OTHER" },
    [29703] = { name = "Dazed", class = "OTHER" },
    -- Immunities
    [46924] = { name = "Bladestorm", class = "IMMUNITY" },
    [642]   = { name = "Divine Shield", class = "IMMUNITY" },
    [45438] = { name = "Ice Block", class = "IMMUNITY" },
    [34692] = { name = "The Beast Within", class = "IMMUNITY" },
    -- PvE
    [28169] = { name = "Mutating Injection", class = "PVE" },
    [28059] = { name = "Positive Charge", class = "PVE" },
    [28084] = { name = "Negative Charge", class = "PVE" },
    [27819] = { name = "Detonate Mana", class = "PVE" },
    [63024] = { name = "Gravity Bomb", class = "PVE" },
    [63018] = { name = "Light Bomb", class = "PVE" },
    [62589] = { name = "Nature's Fury", class = "PVE" },
    [63276] = { name = "Mark of the Faceless", class = "PVE" },
    [66770] = { name = "Ferocious Butt", class = "PVE" },
    [5416]  = { name = "Leeching Swarm", class = "PVE" },
    [47486] = { name = "Mortal Striker", class = "PVE" },
}

local defaults = {
    profile = {
        channel = "PARTY",
        spells = {},
        dots = {},
        debuffs = {},
    }
}

local function getToggle(info)
    local category = info[1]
    local key = info[#info]
    return SimpleAlert.db.profile[category][key]
end

local function setToggle(info, value)
    local category = info[1]
    local key = info[#info]
    SimpleAlert.db.profile[category][key] = value
end

function SimpleAlert:OnInitialize()
    -- Populando os defaults
    for spellName in pairs(trackedSpells) do
        defaults.profile.spells[spellName] = true
    end
    for dotName in pairs(trackedDots) do
        defaults.profile.dots[dotName] = true
    end
    for spellId in pairs(trackedDebuffs) do
        defaults.profile.debuffs[spellId] = true
    end

    self.db = AceDB:New("SimpleAlertDB", defaults, true)
    self:RegisterChatCommand("salert", "ChatCommand")
    self:RegisterChatCommand("salert_test", "TestAlertCommand")

    local options = {
        name = addonName,
        handler = self,
        type = "group",
        args = {
            general = {
                type = "group",
                name = "Geral",
                args = {
                    channel = {
                        type = "select",
                        name = "Canal do Chat",
                        desc = "Escolha para onde as mensagens de alerta serão enviadas.",
                        values = {
                            ["SAY"] = "Dizer",
                            ["PARTY"] = "Grupo",
                            ["YELL"] = "Gritar",
                            ["BG"] = "Campo de Batalha",
                        },
                        get = function(info) return SimpleAlert.db.profile.channel end,
                        set = function(info, value) 
                            SimpleAlert.db.profile.channel = value 
                            SimpleAlert:Print("Canal de alerta definido para: " .. value)
                        end,
                    },
                },
            },
            spells = {
                type = "group",
                name = "Casts Inimigos",
                args = {},
            },
            dots = {
                type = "group",
                name = "Seus DoTs",
                args = {},
            },
            debuffs = {
                type = "group",
                name = "Debuffs Recebidos",
                args = {},
            },
        },
    }

    -- Populando as opções dinamicamente
    for spellName in pairs(trackedSpells) do
        options.args.spells.args[spellName] = {
            type = "toggle",
            name = spellName,
            desc = "Ativar/desativar alerta para " .. spellName,
            get = getToggle,
            set = function(info, val) 
                setToggle(info, val)
                local status = val and "ativado" or "desativado"
                local message = spellName .. " " .. status
                SimpleAlert:Print(message)
            end,
        }
    end

    for dotName in pairs(trackedDots) do
        options.args.dots.args[dotName] = {
            type = "toggle",
            name = dotName,
            desc = "Ativar/desativar alerta para " .. dotName,
            get = getToggle,
            set = function(info, val) 
                setToggle(info, val)
                local status = val and "ativado" or "desativado"
                local message = dotName .. " " .. status
                SimpleAlert:Print(message)
            end,
        }
    end

    local customCategoryNames = {
        OTHER = "Outros",
        IMMUNITY = "Imunidades",
        PVE = "PvE",
    }

    local function createDebuffGet(id)
        return function() return SimpleAlert.db.profile.debuffs[id] end
    end
    local function createDebuffSet(id)
        return function(info, val) 
            SimpleAlert.db.profile.debuffs[id] = val 
            local status = val and "ativado" or "desativado"
            local message = trackedDebuffs[id].name .. " " .. status
            SimpleAlert:Print(message)
        end
    end

    for spellId, data in pairs(trackedDebuffs) do
        local class = data.class
        if not options.args.debuffs.args[class] then
            local groupName = customCategoryNames[class] or LOCALIZED_CLASS_NAMES_MALE[class]
            options.args.debuffs.args[class] = {
                type = "group",
                name = groupName,
                args = {},
            }
        end
        options.args.debuffs.args[class].args[tostring(spellId)] = {
            type = "toggle",
            name = data.name,
            desc = "Ativar/desativar alerta para " .. data.name,
            get = createDebuffGet(spellId),
            set = createDebuffSet(spellId),
        }
    end

    options.args.profiles = AceDBOptions:GetOptionsTable(self.db)

    AceConfig:RegisterOptionsTable(addonName, options)
    AceConfigDialog:AddToBlizOptions(addonName, addonName)

    self:Print("Carregado! Use /salert para configurar.")
end

function SimpleAlert:OnEnable()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function SimpleAlert:ChatCommand(input)
    if not input or input:trim() == "" then
        AceConfigDialog:Open(addonName)
    end
end

function SimpleAlert:TestAlertCommand(input)
    local spellId = 5782 -- Fear
    local spellName = trackedDebuffs[spellId].name
    local sourceName = "Fake Warlock"
    
    self:Print("Sending fake alert for " .. spellName)
    
    if self.db.profile.debuffs[spellId] then
        self:SendAlert("debuff_" .. spellId, "Recebi " .. spellName .. " de " .. sourceName .. "!")
        self:Print("Fake alert sent.")
    else
        self:Print(spellName .. " alert is disabled in the options.")
    end
end

function SimpleAlert:SendAlert(key, message, cooldown)
    cooldown = cooldown or 5
    if not self.lastAlertTimes then self.lastAlertTimes = {} end
    local now = GetTime()
    if not self.lastAlertTimes[key] or (now - self.lastAlertTimes[key]) > cooldown then
        SendChatMessage(message, self.db.profile.channel)
        self.lastAlertTimes[key] = now
    end
end

function SimpleAlert:COMBAT_LOG_EVENT_UNFILTERED(...)
    local _, timestamp, eventType, sourceGUID, sourceName, _, destGUID, destName, _, spellId, spellName, spellSchool, auraType = ...

    if eventType == "SPELL_CAST_START" and trackedSpells[spellName] and self.db.profile.spells[spellName] then
        if sourceGUID ~= UnitGUID("player") then
            self:SendAlert("cast_" .. spellName, spellName .. " sendo conjurado por " .. (sourceName or "???") .. "!")
        end
    end

    if sourceGUID == UnitGUID("player") then
        if eventType == "SPELL_AURA_APPLIED" and trackedDots[spellName] and self.db.profile.dots[spellName] then
            self:SendAlert("dot_" .. spellName .. "_" .. destGUID, spellName .. " aplicado em " .. (destName or "???") .. "!")
        elseif eventType == "SPELL_AURA_REMOVED" and trackedDots[spellName] and self.db.profile.dots[spellName] then
            self:SendAlert("remove_" .. spellName .. "_" .. destGUID, spellName .. " REMOVIDO de " .. (destName or "???") .. "!")
        end
    end

    if destGUID == UnitGUID("player") then
        if eventType == "SPELL_AURA_APPLIED" and trackedDebuffs[spellId] and self.db.profile.debuffs[spellId] then
            local debuffInfo = trackedDebuffs[spellId]
            local debuffName = debuffInfo.name
            if debuffName == "Mortal Strike" then
                self:SendAlert("debuff_" .. spellId, " Recebi " .. debuffName .. " de " .. (sourceName or "???") .. "! Cura reduzida em 50%!")
            else
                self:SendAlert("debuff_" .. spellId, "Recebi " .. debuffName .. " de " .. (sourceName or "???") .. "!")
            end
        elseif eventType == "SPELL_AURA_REMOVED" and trackedDebuffs[spellId] and self.db.profile.debuffs[spellId] then
            local debuffInfo = trackedDebuffs[spellId]
            local debuffName = debuffInfo.name
            self:SendAlert("debuff_off_" .. spellId, debuffName .. " FINALIZADO! (Aplicado por " .. (sourceName or "???") .. ")")
        end
    end
end
