local R, C, L, DB = unpack(select(2, ...))

local _, ns = ...
local oUF = RayUF or ns.oUF or oUF

local siValue = function(val)
    if(val >= 1e6) then
        return ('%.1fm'):format(val / 1e6):gsub('%.?0+([km])$', '%1')
    elseif(val >= 1e4) then
        return ('%.1fk'):format(val / 1e3):gsub('%.?0+([km])$', '%1')
    else
        return val
    end
end

local utf8sub = function(string, i, dots)
	local bytes = string:len()
	if (bytes <= i) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if c > 240 then
				pos = pos + 4
			elseif c > 225 then
				pos = pos + 3
			elseif c > 192 then
				pos = pos + 2
			else
				pos = pos + 1
			end
			if (len == i) then break end
		end

		if (len == i and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

local function hex(r, g, b)
    if not r then return "|cffFFFFFF" end

    if(type(r) == 'table') then
        if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
    end
    return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

-- oUF.colors.power['MANA'] = { 78/255,  150/255,  222/255}
-- oUF.colors.power['RAGE'] = {.69,.31,.31}
-- oUF.colors.runes = {{0.87, 0.12, 0.23};{0.40, 0.95, 0.20};{0.14, 0.50, 1};{.70, .21, 0.94};}
-- oUF.colors.power['MANA'] = {.3,.45,.65}
-- oUF.colors.power['RAGE'] = {.7,.3,.3}
-- oUF.colors.power['FOCUS'] = {.7,.45,.25}
-- oUF.colors.power['ENERGY'] = {.65,.65,.35}
-- oUF.colors.power['RUNIC_POWER'] = {.45,.45,.75}
-- oUF.colors.power['AMMOSLOT'] = {.8,.6,0}
-- oUF.colors.power['FUEL'] = {0,.55,.5}
-- oUF.colors.power['POWER_TYPE_STEAM'] = {.55,.57,.61}
-- oUF.colors.power['POWER_TYPE_PYRITE'] = {.6,.09,.17}
-- oUF.colors.power['POWER_TYPE_HEAT'] = {.9,.45,.1}
-- oUF.colors.power['POWER_TYPE_OOZE'] = {.1,.1,.9}
-- oUF.colors.power['POWER_TYPE_BLOOD_POWER'] = {.9,.1,.1}

do
	local pcolor = oUF.colors.power
	pcolor.MANA[1], pcolor.MANA[2], pcolor.MANA[3] = 0, 0.8, 1
	pcolor.RUNIC_POWER[1], pcolor.RUNIC_POWER[2], pcolor.RUNIC_POWER[3] = 0.8, 0, 1
	local rcolor = oUF.colors.reaction
	rcolor[1][1], rcolor[1][2], rcolor[1][3] = 1,   0.2, 0.2 -- Hated
	rcolor[2][1], rcolor[2][2], rcolor[2][3] = 1,   0.2, 0.2 -- Hostile
	rcolor[3][1], rcolor[3][2], rcolor[3][3] = 1,   0.6, 0.2 -- Unfriendly
	rcolor[4][1], rcolor[4][2], rcolor[4][3] = 1,   1,   0.2 -- Neutral
	rcolor[5][1], rcolor[5][2], rcolor[5][3] = 0.2, 1,   0.2 -- Friendly
	rcolor[6][1], rcolor[6][2], rcolor[6][3] = 0.2, 1,   0.2 -- Honored
	rcolor[7][1], rcolor[7][2], rcolor[7][3] = 0.2, 1,   0.2 -- Revered
	rcolor[8][1], rcolor[8][2], rcolor[8][3] = 0.2, 1,   0.2 -- Exalted
end

oUF.Tags['freeb:lvl'] = function(u) 
    local level = UnitLevel(u)
    local typ = UnitClassification(u)
    local color = GetQuestDifficultyColor(level)

    if level <= 0 then
        level = "??" 
        color.r, color.g, color.b = 1, 0, 0
    end

    if typ=="rareelite" then
        return hex(color)..level..'r+|r'
    elseif typ=="elite" then
        return hex(color)..level..'+|r'
    elseif typ=="rare" then
        return hex(color)..level..'r|r'
    else
        return hex(color)..level..'|r'
    end
end

oUF.Tags['freeb:hp']  = function(u)
		local color
		if UnitIsPlayer(u) then
			local _, class = UnitClass(u)
			color = oUF.colors.class[class]
		elseif UnitIsTapped(u) and not UnitIsTappedByPlayer(u) then
			color = oUF.colors.tapped
		elseif UnitIsEnemy(u, "player") then
			color = oUF.colors.reaction[1]
		else
			color = oUF.colors.reaction[UnitReaction(u, "player") or 5]
		end
    local min, max = UnitHealth(u), UnitHealthMax(u)
    -- return siValue(min).." | "..math.floor(min/max*100+.5).."%"
    return format("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, siValue(min).." | "..math.floor(min/max*100+.5).."%")
end
oUF.TagEvents['freeb:hp'] = 'UNIT_HEALTH'

oUF.Tags['freeb:pp'] = function(u)
    local _, str = UnitPowerType(u)
    local power = UnitPower(u)

    if str and power > 0 then
	local min, max = UnitPower(u), UnitPowerMax(u)
        return hex(oUF.colors.power[str])..siValue(min).." | "..math.floor(min/max*100+.5).."%".."|r"
    end
end
oUF.TagEvents['freeb:pp'] = 'UNIT_POWER'

oUF.Tags['freeb:color'] = function(u, r)
    local _, class = UnitClass(u)
    local reaction = UnitReaction(u, "player")

    if (UnitIsTapped(u) and not UnitIsTappedByPlayer(u)) then
        return hex(oUF.colors.tapped)
    elseif (UnitIsPlayer(u)) then
        return hex(oUF.colors.class[class])
    elseif reaction then
        return hex(oUF.colors.reaction[reaction])
    else
        return hex(1, 1, 1)
    end
end
--oUF.TagEvents['freeb:color'] = 'UNIT_REACTION UNIT_HEALTH UNIT_HAPPINESS'

oUF.Tags['freeb:name'] = function(u, r)
    local name = UnitName(r or u)
    return name
end
oUF.TagEvents['freeb:name'] = 'UNIT_NAME_UPDATE'

oUF.Tags['raid:name'] = function(u, r)
    local name = UnitName(realUnit or u or r)
    return utf8sub(name, 4, false)
end
oUF.TagEvents['raid:name'] = 'UNIT_NAME_UPDATE'

oUF.Tags['freeb:info'] = function(u)
    if UnitIsDead(u) then
        return oUF.Tags['freeb:lvl'](u).."|cffCFCFCF 死亡|r"
    elseif UnitIsGhost(u) then
        return oUF.Tags['freeb:lvl'](u).."|cffCFCFCF 靈魂|r"
    elseif not UnitIsConnected(u) then
        return oUF.Tags['freeb:lvl'](u).."|cffCFCFCF 離線|r"
    else
        return oUF.Tags['freeb:lvl'](u)
    end
end
oUF.TagEvents['freeb:info'] = 'UNIT_HEALTH'

oUF.Tags['freebraid:info'] = function(u)
    local _, class = UnitClass(u)

    if class then
        if UnitIsDead(u) then
            return hex(oUF.colors.class[class]).."DEAD|r"
        elseif UnitIsGhost(u) then
            return hex(oUF.colors.class[class]).."GHO|r"
        elseif not UnitIsConnected(u) then
            return hex(oUF.colors.class[class]).."離線|r"
        end
    end
end
oUF.TagEvents['freebraid:info'] = 'UNIT_HEALTH UNIT_CONNECTION'

oUF.Tags['freeb:curxp'] = function(unit)
    return siValue(UnitXP(unit))
end

oUF.Tags['freeb:maxxp'] = function(unit)
    return siValue(UnitXPMax(unit))
end

oUF.Tags['freeb:perxp'] = function(unit)
    return math.floor(UnitXP(unit) / UnitXPMax(unit) * 100 + 0.5)
end

oUF.TagEvents['freeb:curxp'] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP'
oUF.TagEvents['freeb:maxxp'] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP'
oUF.TagEvents['freeb:perxp'] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP'

oUF.Tags['freeb:altpower'] = function(u)
	local cur = UnitPower(u, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(u, ALTERNATE_POWER_INDEX)
    local per = floor(cur/max*100)
    
    return format("%d", per > 0 and per or 0).."%"
end
oUF.TagEvents['freeb:altpower'] = "UNIT_POWER UNIT_MAXPOWER"
