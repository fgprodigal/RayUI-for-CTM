local R, C, L, DB = unpack(select(2, ...))

if not C["raid"].enable then return end

local ADDON_NAME, ns = ...
local oUF = RayUF or ns.oUF or oUF
assert(oUF, "unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local colors = setmetatable({
    power = setmetatable({
        ['MANA'] = {.31,.45,.63},
    }, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

function ns:hex(r, g, b)
    if(type(r) == 'table') then
        if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
    end
    return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

-- Unit Menu
local dropdown = CreateFrame('Frame', ADDON_NAME .. 'DropDown', UIParent, 'UIDropDownMenuTemplate')

local function menu(self)
    dropdown:SetParent(self)
    return ToggleDropDownMenu(1, nil, dropdown, 'cursor', 0, 0)
end

local function ColorGradient(perc, color1, color2, color3)
	local r1,g1,b1 = 1, 0, 0
	local r2,g2,b2 = .85, .8, .45
	local r3,g3,b3 = .12, .12, .12

	if perc >= 1 then
		return r3, g3, b3
	elseif perc <= 0 then
		return r1, g1, b1
	end

	local segment, relperc = math.modf(perc*(3-1))
	local offset = (segment*3)+1

	-- < 50% > 0%
	if(offset == 1) then
		return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
	end
	-- < 99% > 50%
	return r2 + (r3-r2)*relperc, g2 + (g3-g2)*relperc, b2 + (b3-b2)*relperc
end

local init = function(self)
    if (ns.db and C["raid"].hidemenu) and InCombatLockdown() then
        return
    end

    local unit = self:GetParent().unit
    local menu, name, id

    if(not unit) then
        return
    end

    if(UnitIsUnit(unit, "player")) then
        menu = "SELF"
    elseif(UnitIsUnit(unit, "vehicle")) then
        menu = "VEHICLE"
    elseif(UnitIsUnit(unit, "pet")) then
        menu = "PET"
    elseif(UnitIsPlayer(unit)) then
        id = UnitInRaid(unit)
        if(id) then
            menu = "RAID_PLAYER"
            name = GetRaidRosterInfo(id)
        elseif(UnitInParty(unit)) then
            menu = "PARTY"
        else
            menu = "PLAYER"
        end
    else
        menu = "TARGET"
        name = RAID_TARGET_ICON
    end

    if(menu) then
        UnitPopup_ShowMenu(self, menu, unit, name, id)
    end
end

UIDropDownMenu_Initialize(dropdown, init, 'MENU')

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local border = {
    bgFile = C["media"].blank,
    insets = {top = -R.Scale(2), left = -R.Scale(2), bottom = -R.Scale(2), right = -R.Scale(2)},
}

local border2 = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = -R.mult, left = -R.mult, bottom = -R.mult, right = -R.mult},
}

local glowBorder = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    edgeFile = C["media"].glow, edgeSize = R.Scale(5),
    insets = {left = R.Scale(3), right = R.Scale(3), top = R.Scale(3), bottom = R.Scale(3)}
}

-- Show Target Border
local ChangedTarget = function(self)
    if UnitIsUnit('target', self.unit) then
        self.TargetBorder:Show()
    else
		self.TargetBorder:Hide()
	end
end

-- Show Focus Border
local FocusTarget = function(self)
    if UnitIsUnit('focus', self.unit) then
        self.FocusHighlight:Show()
    else
		self.FocusHighlight:Hide()
	end
end

local updateThreat = function(self, event, unit)
    if(unit ~= self.unit) then return end

    local status = UnitThreatSituation(unit)

    if(status and status > 1) then
        local r, g, b = GetThreatStatusColor(status)
        self.Threat:SetBackdropBorderColor(r, g, b, 1)
        self.border:SetBackdropColor(r, g, b, 1)
    else
        self.Threat:SetBackdropBorderColor(0, 0, 0, 1)
        self.border:SetBackdropColor(0, 0, 0, 1)
    end
    self.Threat:Show()
end

oUF.Tags['freebgrid:name'] = function(u, r)
    local name = (u == 'vehicle' and UnitName(r or u)) or UnitName(u)

    if ns.nameCache[name] then
        return ns.nameCache[name]
    end
end
oUF.TagEvents['freebgrid:name'] = 'UNIT_NAME_UPDATE'

ns.nameCache = {}
ns.colorCache = {}
ns.debuffColor = {} -- hex debuff colors for tags

local function utf8sub(str, start, numChars) 
    local currentIndex = start 
    while numChars > 0 and currentIndex <= #str do 
        local char = string.byte(str, currentIndex) 
        if char >= 240 then 
            currentIndex = currentIndex + 4 
        elseif char >= 225 then 
            currentIndex = currentIndex + 3 
        elseif char >= 192 then 
            currentIndex = currentIndex + 2 
        else 
            currentIndex = currentIndex + 1 
        end 
        numChars = numChars - 1 
    end 
    return str:sub(start, currentIndex - 1) 
end 

function ns:UpdateName(name, unit) 
    if(unit) then
        local _NAME = UnitName(unit)
        local _, class = UnitClass(unit)
        if not _NAME or not class then return end

        local substring
        for length=#_NAME, 1, -1 do
            substring = utf8sub(_NAME, 1, length)
            name:SetText(substring)
            if name:GetStringWidth() <= C["raid"].width - 8 then name:SetText(nil); break end
        end
		
        local str = ns.colorCache[class]..substring
        ns.nameCache[_NAME] = str
        name:UpdateTag()
    end
end

local function PostHealth(hp, unit)
    local self = hp.__owner
    local name = UnitName(unit)

    if not ns.nameCache[name] then
        ns:UpdateName(self.Name, unit)
    end

    local suffix = self:GetAttribute'unitsuffix'
    if suffix == 'pet' or unit == 'vehicle' or unit == 'pet' then
        local r, g, b = .2, .9, .1
        hp:SetStatusBarColor(r*.2, g*.2, b*.2)
        hp.bg:SetVertexColor(r, g, b)
        return
    end
	
	if C["uf"].healthColorClass then
		hp.colorClass=true
		hp.bg.multiplier = .2
	else
		local curhealth, maxhealth = UnitHealth(unit), UnitHealthMax(unit)
		local r, g, b
		if C["uf"].smoothColor then
			r,g,b = ColorGradient(curhealth/maxhealth)
		else
			r,g,b = .12, .12, .12, 1
		end
		
		if(b) then
			hp:SetStatusBarColor(r, g, b, 1)
		elseif not UnitIsConnected(unit) then
			local color = colors.disconnected
			local power = hp.__owner.Power
			if power then
				power:SetValue(0)
				if power.value then
					power.value:SetText(nil)
				end
			end
		elseif UnitIsDeadOrGhost(unit) then
			local color = colors.disconnected
			local power = hp.__owner.Power
			if power then
				power:SetValue(0)
				if power.value then
					power.value:SetText(nil)
				end
			end
		end
		if C["uf"].smoothColor then
			if UnitIsDeadOrGhost(unit) or (not UnitIsConnected(unit)) then
				hp:SetStatusBarColor(0.5, 0.5, 0.5, 1)
				hp.bg:SetVertexColor(0.5, 0.5, 0.5, 1)
			else
				hp.bg:SetVertexColor(0.12, 0.12, 0.12, 1)
			end
		end
	end
end

function ns:UpdateHealth(hp)
    hp:SetStatusBarTexture(C["media"].normal)
    hp:SetOrientation("HORIZONTAL")
    hp.bg:SetTexture(C["media"].normal)
    hp.freebSmooth = C["uf"].smooth

	hp:ClearAllPoints()
	hp:SetPoint"TOP"
	hp:SetPoint"LEFT"
	hp:SetPoint"RIGHT"
end

local function PostPower(power, unit)
    local self = power.__owner
    local _, ptype = UnitPowerType(unit)
    local _, class = UnitClass(unit)

	power:Height(C["raid"].height*C["raid"].powerbarsize)
	self.Health:Height((0.98 - C["raid"].powerbarsize)*C["raid"].height-1)

    local perc = oUF.Tags['perpp'](unit)
    -- This kinda conflicts with the threat module, but I don't really care
    if (perc < 10 and UnitIsConnected(unit) and ptype == 'MANA' and not UnitIsDeadOrGhost(unit)) then
        self.Threat:SetBackdropBorderColor(0, 0, 1, 1)
        self.border:SetBackdropColor(0, 0, 1, 1)
    else
        -- pass the coloring back to the threat func
        updateThreat(self, nil, unit)
    end

    local r, g, b, t
    t = C["uf"].powerColorClass and colors.class[class] or colors.power[ptype]

	if C["uf"].powerColorClass then
		power.colorClass=true
		power.bg.multiplier = .2
	else
		power.colorPower=true
		power.bg.multiplier = .2
	end
end

function ns:UpdatePower(power)
	power:Show()
	power.PostUpdate = PostPower
    power:SetStatusBarTexture(C["media"].normal)
    power:SetOrientation("HORIZONTAL")
    power.bg:SetTexture(C["media"].normal)

    power:ClearAllPoints()
	power:SetPoint"LEFT"
	power:SetPoint"RIGHT"
	power:SetPoint"BOTTOM"
end

-- Show Mouseover highlight
local OnEnter = function(self)
    if C["raid"].tooltip then
        UnitFrame_OnEnter(self)
    else
        GameTooltip:Hide()
    end

    if C["raid"].highlight then
        self.Highlight:Show()
    end

    if C["raid"].arrow and C["raid"].arrowmouseover then
        ns:arrow(self, self.unit)
    end
end

local OnLeave = function(self)
    if C["raid"].tooltip then
        UnitFrame_OnLeave(self)
    end
    self.Highlight:Hide()

    if(self.freebarrow and self.freebarrow:IsShown()) and C["raid"].arrowmouseover then
        self.freebarrow:Hide()
    end
end

local style = function(self)
    self.menu = menu

	self:Height(C["raid"].height)
	self:Width(C["raid"].width)
    -- Backdrop
    self.BG = CreateFrame("Frame", nil, self)
    self.BG:SetPoint("TOPLEFT", self, "TOPLEFT")
    self.BG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    self.BG:SetFrameLevel(3)
    self.BG:SetBackdrop(backdrop)
    self.BG:SetBackdropColor(0, 0, 0)

    self.border = CreateFrame("Frame", nil, self)
    self.border:SetPoint("TOPLEFT", self, "TOPLEFT")
    self.border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    self.border:SetFrameLevel(2)
    self.border:SetBackdrop(border2)
    self.border:SetBackdropColor(0, 0, 0)

    -- Mouseover script
    self:SetScript("OnEnter", OnEnter)
    self:SetScript("OnLeave", OnLeave)
    self:RegisterForClicks"AnyUp"

    -- Health
    self.Health = CreateFrame"StatusBar"
    self.Health:SetParent(self)
    self.Health.frequentUpdates = true

    self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
    self.Health.bg:SetAllPoints(self.Health)

    self.Health.PostUpdate = PostHealth
    ns:UpdateHealth(self.Health)

    -- Threat
    local threat = CreateFrame("Frame", nil, self)
    threat:Point("TOPLEFT", self, "TOPLEFT", -5, 5)
    threat:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", 5, -5)
    threat:SetFrameLevel(0)
    threat:SetBackdrop(glowBorder)
    threat:SetBackdropColor(0, 0, 0, 0)
    threat:SetBackdropBorderColor(0, 0, 0, 1)
    threat.Override = updateThreat
    self.Threat = threat

    -- Name
    local name = self.Health:CreateFontString(nil, "OVERLAY", -8)
    name:SetPoint("CENTER")
    name:SetJustifyH("CENTER")
    name:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
    name:SetWidth(C["raid"].width)
    name.overrideUnit = true
    self.Name = name
    self:Tag(self.Name, '[freebgrid:name]')

    ns:UpdateName(self.Name)

    -- Power
    self.Power = CreateFrame"StatusBar"
    self.Power:SetParent(self)
    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints(self.Power)
    ns:UpdatePower(self.Power)

    -- Highlight tex
    local hl = self.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(self)
    hl:SetTexture(C["media"].blank)
    hl:SetVertexColor(1,1,1,.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    self.Highlight = hl

    -- Target tex
    local tBorder = CreateFrame("Frame", nil, self)
    tBorder:SetPoint("TOPLEFT", self, "TOPLEFT")
    tBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    tBorder:SetBackdrop(border)
    tBorder:SetBackdropColor(.8, .8, .8, 1)
    tBorder:SetFrameLevel(1)
    tBorder:Hide()
    self.TargetBorder = tBorder

    -- Focus tex
    local fBorder = CreateFrame("Frame", nil, self)
    fBorder:SetPoint("TOPLEFT", self, "TOPLEFT")
    fBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
    fBorder:SetBackdrop(border)
    fBorder:SetBackdropColor(.6, .8, 0, 1)
    fBorder:SetFrameLevel(1)
    fBorder:Hide()
    self.FocusHighlight = fBorder

    -- Raid Icons
    local ricon = self.Health:CreateTexture(nil, 'OVERLAY')
    ricon:SetPoint("TOP", self, 0, 5)
    ricon:SetSize(C["raid"].leadersize+2, C["raid"].leadersize+2)
    self.RaidIcon = ricon

    -- Leader Icon
    self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
    self.Leader:SetPoint("TOPLEFT", self, 0, 8)
    self.Leader:SetSize(C["raid"].leadersize, C["raid"].leadersize)

    -- Assistant Icon
    self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
    self.Assistant:SetPoint("TOPLEFT", self, 0, 8)
    self.Assistant:SetSize(C["raid"].leadersize, C["raid"].leadersize)

    local masterlooter = self.Health:CreateTexture(nil, 'OVERLAY')
    masterlooter:SetSize(C["raid"].leadersize, C["raid"].leadersize)
    masterlooter:SetPoint('LEFT', self.Leader, 'RIGHT')
    self.MasterLooter = masterlooter

    -- Role Icon
    if C["raid"].roleicon then
        self.LFDRole = self.Health:CreateTexture(nil, 'OVERLAY')
        self.LFDRole:SetSize(C["raid"].leadersize, C["raid"].leadersize)
        self.LFDRole:SetPoint('RIGHT', self, 'LEFT', C["raid"].leadersize/2, C["raid"].leadersize/2)
    end

    self.freebIndicators = true
    self.freebAfk = true
    self.freebHeals = true

    self.ResurrectIcon = self.Health:CreateTexture(nil, 'OVERLAY')
    self.ResurrectIcon:SetPoint("TOP", self, 0, -2)
    self.ResurrectIcon:SetSize(16, 16)

    -- Range
    local range = {
        insideAlpha = 1,
        outsideAlpha = C["raid"].outsideRange,
    }

    self.freebRange = C["raid"].arrow and range
    self.Range = C["raid"].arrow == false and range

    -- ReadyCheck
	local ReadyCheck = CreateFrame("Frame", nil, self.Health)
    ReadyCheck:SetPoint("CENTER")
    ReadyCheck:SetSize(C["raid"].leadersize + 4, C["raid"].leadersize + 4)
    self.ReadyCheck = ReadyCheck:CreateTexture(nil, "OVERLAY")
    self.ReadyCheck:SetPoint("TOP")
    self.ReadyCheck:SetSize(C["raid"].leadersize + 4, C["raid"].leadersize+ 4)

    -- Auras
    local auras = CreateFrame("Frame", nil, self)
    auras:SetSize(C["raid"].aurasize, C["raid"].aurasize)
    auras:SetPoint("CENTER", self.Health)
    auras.size = C["raid"].aurasize
    self.freebAuras = auras

    -- Add events
    self:RegisterEvent('PLAYER_FOCUS_CHANGED', FocusTarget)
    self:RegisterEvent('RAID_ROSTER_UPDATE', FocusTarget)
    self:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
    self:RegisterEvent('RAID_ROSTER_UPDATE', ChangedTarget)

    table.insert(ns._Objects, self)
end

oUF:RegisterStyle("Freebgrid", style)

function ns:Colors()
    for class, color in next, colors.class do
		ns.colorCache[class] = ns:hex(color)
    end

    for dtype, color in next, DebuffTypeColor do
        ns.debuffColor[dtype] = ns:hex(color)
    end
end

local pos, posRel, colX, colY
local function freebHeader(name, group, temp, pet, MT)
    local horiz, grow = C["raid"].horizontal, C["raid"].growth

    local initconfig = [[
    self:SetWidth(%d)
    self:SetHeight(%d)
    ]]

    local point, growth, xoff, yoff
    if horiz then
        point = "LEFT"
        xoff = C["raid"].spacing
        yoff = 0
        if grow == "UP" then
            growth = "BOTTOM"
            pos = "BOTTOMLEFT"
            posRel = "TOPLEFT"
            colY = C["raid"].spacing
        else
            growth = "TOP"
            pos = "TOPLEFT"
            posRel = "BOTTOMLEFT"
            colY = -C["raid"].spacing
        end
    else
        point = "TOP"
        xoff = 0
        yoff = -C["raid"].spacing
        if grow == "RIGHT" then
            growth = "LEFT"
            pos = "TOPLEFT"
            posRel = "TOPRIGHT"
            colX = C["raid"].spacing
        else
            growth = "RIGHT"
            pos = "TOPRIGHT"
            posRel = "TOPLEFT"
            colX = -C["raid"].spacing
        end
    end

    local template = temp or nil
    local header = oUF:SpawnHeader(name, template, 'raid,party,solo',
    -- 'oUF-initialConfigFunction', (initconfig):format(C["raid"].width, C["raid"].height),
    'showPlayer', C["raid"].showplayerinparty,
    'showSolo', C["raid"].showwhensolo,
    'showParty', C["raid"].showgridwhenparty,
    'showRaid', true,
    'xOffset', xoff,
    'yOffset', yoff,
    'point', point,
    'sortMethod', "INDEX",
    'groupFilter', group,
    'groupingOrder', "1,2,3,4,5,6,7,8",
    'groupBy', "GROUP",
    'maxColumns', C["raid"].numCol,
    'unitsPerColumn', 5,
    'columnSpacing', C["raid"].spacing,
    'columnAnchorPoint', growth)

    return header
end

oUF:Factory(function(self)
    -- ns:Anchors()
    ns:Colors()
	--隐藏自带团队
	-- CompactRaidFrameContainer:UnregisterAllEvents()
	-- CompactRaidFrameContainer:Hide() 
	-- CompactRaidFrameContainer.Show = function() end
	-- CompactRaidFrameManager:UnregisterAllEvents()
	-- CompactRaidFrameManager:Hide()
	-- CompactRaidFrameManager.Show = function() end
	
    self:SetActiveStyle"Freebgrid"
	local raid = {}
	for i=1, C["raid"].numCol do
		local group = freebHeader("Raid_Freebgrid"..i, i)
		if i == 1 then
			-- group:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", - C["raid"].width*5 -  C["raid"].spacing*4 - 50, C["raid"].height*5 +  C["raid"].spacing*4 + 230)
			group:Point("TOPLEFT", UIParent, "BOTTOMRIGHT", - C["raid"].width*5 -  C["raid"].spacing*4 - 50, 422)
		else
			group:Point(pos, raid[i-1], posRel, colX or 0, colY or 0)
		end
		raid[i] = group
		ns._Headers[group:GetName()] = group
	end
end)

ns:RegisterEvent("ADDON_LOADED")
function ns:ADDON_LOADED(event, addon)
    if addon ~= ADDON_NAME then return end

    self:UnregisterEvent("ADDON_LOADED")
    self.ADDON_LOADED = nil

    if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end

function ns:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")
    self.PLAYER_LOGIN = nil
end

function HideRaid()
	if InCombatLockdown() then return end
	CompactRaidFrameManager:Hide()
	local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then 
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

hooksecurefunc("CompactRaidFrameManager_UpdateShown",function()
	HideRaid()
end)
CompactRaidFrameManager:HookScript('OnShow', HideRaid)
CompactRaidFrameManager:SetScale(0.000001) --- BAHAHAHA FUCK YOU RAID FRAMES!