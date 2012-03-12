local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local RA = R:GetModule("Raid")

local oUF = RayUF or oUF

local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
    return unpack(spellcache[a])
end

local GetTime = GetTime

local numberize = function(val)
    if (val >= 1e6) then
        return ("%.1fm"):format(val / 1e6)
    elseif (val >= 1e3) then
        return ("%.1fk"):format(val / 1e3)
    else
        return ("%d"):format(val)
    end
end
RA.numberize = numberize

local x = "M"

local getTime = function(expirationTime)
    local expire = (expirationTime-GetTime())
    local timeleft = numberize(expire)
    if expire > 0.5 then
        return ("|cffffff00"..timeleft.."|r")
    end
end

-- Magic
oUF.Tags['RayUIRaid:magic'] = function(u)
    local index = 1
    while true do
        local name,_,_,_, dtype = UnitAura(u, index, 'HARMFUL')
        if not name then break end
        
        if dtype == "Magic" then
            return RA.debuffColor[dtype]..x
        end

        index = index+1
    end
end
oUF.TagEvents['RayUIRaid:magic'] = "UNIT_AURA"

-- Disease
oUF.Tags['RayUIRaid:disease'] = function(u)
    local index = 1
    while true do
        local name,_,_,_, dtype = UnitAura(u, index, 'HARMFUL')
        if not name then break end
        
        if dtype == "Disease" then
            return RA.debuffColor[dtype]..x
        end

        index = index+1
    end
end
oUF.TagEvents['RayUIRaid:disease'] = "UNIT_AURA"

-- Curse
oUF.Tags['RayUIRaid:curse'] = function(u)
    local index = 1
    while true do
        local name,_,_,_, dtype = UnitAura(u, index, 'HARMFUL')
        if not name then break end
        
        if dtype == "Curse" then
            return RA.debuffColor[dtype]..x
        end

        index = index+1
    end
end
oUF.TagEvents['RayUIRaid:curse'] = "UNIT_AURA"

-- Poison
oUF.Tags['RayUIRaid:poison'] = function(u)
    local index = 1
    while true do
        local name,_,_,_, dtype = UnitAura(u, index, 'HARMFUL')
        if not name then break end
        
        if dtype == "Poison" then
            return RA.debuffColor[dtype]..x
        end

        index = index+1
    end
end
oUF.TagEvents['RayUIRaid:poison'] = "UNIT_AURA"

-- Priest
local pomCount = {"i","h","g","f","Z","Y"}
oUF.Tags['RayUIRaid:pom'] = function(u) 
    local name, _,_, c, _,_,_, fromwho = UnitAura(u, GetSpellInfo(41635)) 
    if fromwho == "player" then
        if(c) then return "|cff66FFFF"..pomCount[c].."|r" end 
    else
        if(c) then return "|cffFFCF7F"..pomCount[c].."|r" end 
    end
end
oUF.TagEvents['RayUIRaid:pom'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:rnw'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(139))
    if(fromwho == "player") then
        local spellTimer = GetTime()-expirationTime
        if spellTimer > -2 then
            return "|cffFF0000"..x.."|r"
        elseif spellTimer > -4 then
            return "|cffFF9900"..x.."|r"
        else
            return "|cff33FF33"..x.."|r"
        end
    end
end
oUF.TagEvents['RayUIRaid:rnw'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:rnwTime'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(139))
    if(fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['RayUIRaid:rnwTime'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:pws'] = function(u) if UnitAura(u, GetSpellInfo(17)) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['RayUIRaid:pws'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:ws'] = function(u) if UnitDebuff(u, GetSpellInfo(6788)) then return "|cffFF9900"..x.."|r" end end
oUF.TagEvents['RayUIRaid:ws'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:fw'] = function(u) if UnitAura(u, GetSpellInfo(6346)) then return "|cff8B4513"..x.."|r" end end
oUF.TagEvents['RayUIRaid:fw'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:sp'] = function(u) if not UnitAura(u, GetSpellInfo(79107)) then return "|cff9900FF"..x.."|r" end end
oUF.TagEvents['RayUIRaid:sp'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:fort'] = function(u) if not(UnitAura(u, GetSpellInfo(79105)) or UnitAura(u, GetSpellInfo(6307)) or UnitAura(u, GetSpellInfo(469))) then return "|cff00A1DE"..x.."|r" end end
oUF.TagEvents['RayUIRaid:fort'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:pwb'] = function(u) if UnitAura(u, GetSpellInfo(81782)) then return "|cffEEEE00"..x.."|r" end end
oUF.TagEvents['RayUIRaid:pwb'] = "UNIT_AURA"

-- Druid
local lbCount = { 4, 2, 3}
oUF.Tags['RayUIRaid:lb'] = function(u) 
    local name, _,_, c,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(33763))
    if(fromwho == "player") then
        local spellTimer = GetTime()-expirationTime
        if spellTimer > -2 then
            return "|cffFF0000"..lbCount[c].."|r"
        elseif spellTimer > -4 then
            return "|cffFF9900"..lbCount[c].."|r"
        else
            return "|cffA7FD0A"..lbCount[c].."|r"
        end
    end
end
oUF.TagEvents['RayUIRaid:lb'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:rejuv'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(774))
    if(fromwho == "player") then
        local spellTimer = GetTime()-expirationTime
        if spellTimer > -2 then
            return "|cffFF0000"..x.."|r"
        elseif spellTimer > -4 then
            return "|cffFF9900"..x.."|r"
        else
            return "|cff33FF33"..x.."|r"
        end
    end
end
oUF.TagEvents['RayUIRaid:rejuv'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:rejuvTime'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(774))
    if(fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['RayUIRaid:rejuvTime'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:regrow'] = function(u) if UnitAura(u, GetSpellInfo(8936)) then return "|cff00FF10"..x.."|r" end end
oUF.TagEvents['RayUIRaid:regrow'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:wg'] = function(u) if UnitAura(u, GetSpellInfo(48438)) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['RayUIRaid:wg'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:motw'] = function(u) if not(UnitAura(u, GetSpellInfo(79060)) or UnitAura(u,GetSpellInfo(79063))) then return "|cff00A1DE"..x.."|r" end end
oUF.TagEvents['RayUIRaid:motw'] = "UNIT_AURA"

-- Warrior
oUF.Tags['RayUIRaid:stragi'] = function(u) if not(UnitAura(u, GetSpellInfo(6673)) or UnitAura(u, GetSpellInfo(57330)) or UnitAura(u, GetSpellInfo(8076))) then return "|cffFF0000"..x.."|r" end end
oUF.TagEvents['RayUIRaid:stragi'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:vigil'] = function(u) if UnitAura(u, GetSpellInfo(50720)) then return "|cff8B4513"..x.."|r" end end
oUF.TagEvents['RayUIRaid:vigil'] = "UNIT_AURA"

-- Shaman
oUF.Tags['RayUIRaid:rip'] = function(u) 
    local name, _,_,_,_,_,_, fromwho = UnitAura(u, GetSpellInfo(61295))
    if(fromwho == 'player') then return "|cff00FEBF"..x.."|r" end
end
oUF.TagEvents['RayUIRaid:rip'] = 'UNIT_AURA'

oUF.Tags['RayUIRaid:ripTime'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(61295))
    if(fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['RayUIRaid:ripTime'] = 'UNIT_AURA'

local earthCount = {'i','h','g','f','p','q','Z','Z','Y'}
oUF.Tags['RayUIRaid:earth'] = function(u) 
    local c = select(4, UnitAura(u, GetSpellInfo(974))) if c then return '|cffFFCF7F'..earthCount[c]..'|r' end 
end
oUF.TagEvents['RayUIRaid:earth'] = 'UNIT_AURA'

-- Paladin
oUF.Tags['RayUIRaid:might'] = function(u) if not(UnitAura(u, GetSpellInfo(53138)) or UnitAura(u, GetSpellInfo(79102))) then return "|cffFF0000"..x.."|r" end end
oUF.TagEvents['RayUIRaid:might'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:beacon'] = function(u)
    local name, _,_,_,_,_, expirationTime, fromwho = UnitAura(u, GetSpellInfo(53563))
    if not name then return end
    if(fromwho == "player") then
        local spellTimer = GetTime()-expirationTime
        if spellTimer > -30 then
            return "|cffFF00004|r"
        else
            return "|cffFFCC003|r"
        end
    else
        return "|cff996600Y|r" -- other pally's beacon
    end
end
oUF.TagEvents['RayUIRaid:beacon'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:forbearance'] = function(u) if UnitDebuff(u, GetSpellInfo(25771)) then return "|cffFF9900"..x.."|r" end end
oUF.TagEvents['RayUIRaid:forbearance'] = "UNIT_AURA"

-- Warlock
oUF.Tags['RayUIRaid:di'] = function(u) 
    local name, _,_,_,_,_,_, fromwho = UnitAura(u, GetSpellInfo(85767)) 
    if fromwho == "player" then
        return "|cff6600FF"..x.."|r"
    elseif name then
        return "|cffCC00FF"..x.."|r"
    end
end
oUF.TagEvents['RayUIRaid:di'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:ss'] = function(u) 
    local name, _,_,_,_,_,_, fromwho = UnitAura(u, GetSpellInfo(20707)) 
    if fromwho == "player" then
        return "|cff6600FFY|r"
    elseif name then
        return "|cffCC00FFY|r"
    end
end
oUF.TagEvents['RayUIRaid:ss'] = "UNIT_AURA"

-- Mage
oUF.Tags['RayUIRaid:int'] = function(u) if not(UnitAura(u, GetSpellInfo(1459))) then return "|cff00A1DE"..x.."|r" end end
oUF.TagEvents['RayUIRaid:int'] = "UNIT_AURA"

oUF.Tags['RayUIRaid:fmagic'] = function(u) if UnitAura(u, GetSpellInfo(54648)) then return "|cffCC00FF"..x.."|r" end end
oUF.TagEvents['RayUIRaid:fmagic'] = "UNIT_AURA"

RA.classIndicators={
    ["DRUID"] = {
        ["TL"] = "",
        ["TR"] = "[RayUIRaid:motw]",
        ["BL"] = "[RayUIRaid:regrow][RayUIRaid:wg]",
        ["BR"] = "[RayUIRaid:lb]",
        ["Cen"] = "[RayUIRaid:rejuvTime]",
    },
    ["PRIEST"] = {
        ["TL"] = "[RayUIRaid:pws][RayUIRaid:ws]",
        ["TR"] = "[RayUIRaid:fw][RayUIRaid:sp][RayUIRaid:fort]",
        ["BL"] = "[RayUIRaid:rnw][RayUIRaid:pwb]",
        ["BR"] = "[RayUIRaid:pom]",
        ["Cen"] = "[RayUIRaid:rnwTime]",
    },
    ["PALADIN"] = {
        ["TL"] = "[RayUIRaid:forbearance]",
        ["TR"] = "[RayUIRaid:might][RayUIRaid:motw]",
        ["BL"] = "",
        ["BR"] = "[RayUIRaid:beacon]",
        ["Cen"] = "",
    },
    ["WARLOCK"] = {
        ["TL"] = "",
        ["TR"] = "[RayUIRaid:di]",
        ["BL"] = "",
        ["BR"] = "[RayUIRaid:ss]",
        ["Cen"] = "",
    },
    ["WARRIOR"] = {
        ["TL"] = "[RayUIRaid:vigil]",
        ["TR"] = "[RayUIRaid:stragi][RayUIRaid:fort]",
        ["BL"] = "",
        ["BR"] = "",
        ["Cen"] = "",
    },
    ["DEATHKNIGHT"] = {
        ["TL"] = "",
        ["TR"] = "",
        ["BL"] = "",
        ["BR"] = "",
        ["Cen"] = "",
    },
    ["SHAMAN"] = {
        ["TL"] = "[RayUIRaid:rip]",
        ["TR"] = "",
        ["BL"] = "",
        ["BR"] = "[RayUIRaid:earth]",
        ["Cen"] = "[RayUIRaid:ripTime]",
    },
    ["HUNTER"] = {
        ["TL"] = "",
        ["TR"] = "",
        ["BL"] = "",
        ["BR"] = "",
        ["Cen"] = "",
    },
    ["ROGUE"] = {
        ["TL"] = "",
        ["TR"] = "",
        ["BL"] = "",
        ["BR"] = "",
        ["Cen"] = "",
    },
    ["MAGE"] = {
        ["TL"] = "",
        ["TR"] = "[RayUIRaid:int]",
        ["BL"] = "",
        ["BR"] = "",
        ["Cen"] = "",
    }
}
