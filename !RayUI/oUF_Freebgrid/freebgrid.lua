local R, C, DB = unpack(select(2, ...))

local ADDON_NAME, ns = ...
local oUF = oUF_Freeb or ns.oUF or oUF
assert(oUF, "oUF_Freebgrid was unable to locate oUF install.")

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

local init = function(self)
    if (ns.db and ns.db.hidemenu) and InCombatLockdown() then
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
    if ns.db.tborder and UnitIsUnit('target', self.unit) then
        self.TargetBorder:Show()
    else
        self.TargetBorder:Hide()
    end
end

-- Show Focus Border
local FocusTarget = function(self)
    if ns.db.fborder and UnitIsUnit('focus', self.unit) then
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
            if name:GetStringWidth() <= ns.db.width - 8 then name:SetText(nil); break end
        end
		
		if not UnitIsConnected(unit) then
			name:Hide()
		elseif not name:IsShown() then
			name:Show()
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

    if ns.db.definecolors and hp.colorSmooth then
        hp.bg:SetVertexColor(ns.db.hpbgcolor.r, ns.db.hpbgcolor.g, ns.db.hpbgcolor.b)
        return
    end

    local suffix = self:GetAttribute'unitsuffix'
    if suffix == 'pet' or unit == 'vehicle' or unit == 'pet' then
        local r, g, b = .2, .9, .1
        hp:SetStatusBarColor(r*.2, g*.2, b*.2)
        hp.bg:SetVertexColor(r, g, b)
        return
    elseif ns.db.definecolors then
        hp.bg:SetVertexColor(ns.db.hpbgcolor.r, ns.db.hpbgcolor.g, ns.db.hpbgcolor.b)
        hp:SetStatusBarColor(ns.db.hpcolor.r, ns.db.hpcolor.g, ns.db.hpcolor.b)
        return 
    end
	
	if C["ouf"].HealthcolorClass then
		hp.colorClass=true
		hp.bg.multiplier = .2
	else
		local r, g, b, t
		if(UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = colors.class[class]
		else		
			r, g, b = .2, .9, .1
		end

		if(t) then
			r, g, b = t[1], t[2], t[3]
		end

		if(b) then
			if ns.db.reversecolors then
				hp.bg:SetVertexColor(r*.2, g*.2, b*.2)
				hp:SetStatusBarColor(r, g, b)
			else
				hp.bg:SetVertexColor(1, 1, 1,.6)
				hp:SetStatusBarColor(.1, .1, .1)
			end
		end
	end
end

function ns:UpdateHealth(hp)
    hp:SetStatusBarTexture(ns.db.texturePath)
    hp:SetOrientation(ns.db.orientation)
    hp.bg:SetTexture(ns.db.texturePath)
    hp.freebSmooth = ns.db.smooth

    hp.colorSmooth = ns.db.colorSmooth
    hp.smoothGradient = { 
        ns.db.gradient.r, ns.db.gradient.g, ns.db.gradient.b,
        ns.db.hpcolor.r, ns.db.hpcolor.g, ns.db.hpcolor.b,
    }

    if not ns.db.powerbar then
        hp:SetHeight(ns.db.height)
        hp:SetWidth(ns.db.width)
    end

    hp:ClearAllPoints()
    hp:SetPoint"TOP"
    if ns.db.orientation == "VERTICAL" and ns.db.porientation == "VERTICAL" then
        hp:SetPoint"LEFT"
        hp:SetPoint"BOTTOM"
    elseif ns.db.orientation == "HORIZONTAL" and ns.db.porientation == "VERTICAL" then
        hp:SetPoint"RIGHT"
        hp:SetPoint"BOTTOM"
    else
        hp:SetPoint"LEFT"
        hp:SetPoint"RIGHT"
    end
end

local function PostPower(power, unit)
    local self = power.__owner
    local _, ptype = UnitPowerType(unit)
    local _, class = UnitClass(unit)

    -- if ptype == 'MANA' then
        -- power:Show()
        if(ns.db.porientation == "VERTICAL")then
            power:SetWidth(ns.db.width*ns.db.powerbarsize)
            self.Health:SetWidth((0.98 - ns.db.powerbarsize)*ns.db.width - 1)
        else
            power:SetHeight(ns.db.height*ns.db.powerbarsize)
            self.Health:SetHeight((0.98 - ns.db.powerbarsize)*ns.db.height - 1)
        end
    -- else
        -- power:Hide()
        -- if(ns.db.porientation == "VERTICAL")then
            -- self.Health:SetWidth(ns.db.width)
        -- else
            -- self.Health:SetHeight(ns.db.height)
        -- end
    -- end

    local perc = oUF.Tags['perpp'](unit)
    -- This kinda conflicts with the threat module, but I don't really care
    if (perc < 10 and UnitIsConnected(unit) and ptype == 'MANA' and not UnitIsDeadOrGhost(unit)) then
        self.Threat:SetBackdropBorderColor(0, 0, 1, 1)
        self.border:SetBackdropColor(0, 0, 1, 1)
    else
        -- pass the coloring back to the threat func
        updateThreat(self, nil, unit)
    end

    if ns.db.powerdefinecolors then
        power.bg:SetVertexColor(ns.db.powerbgcolor.r, ns.db.powerbgcolor.g, ns.db.powerbgcolor.b)
        power:SetStatusBarColor(ns.db.powercolor.r, ns.db.powercolor.g, ns.db.powercolor.b)
        return
    end

    local r, g, b, t
    t = ns.db.powerclass and colors.class[class] or colors.power[ptype]

    -- if(t) then
        -- r, g, b = t[1], t[2], t[3]
    -- else
        -- r, g, b = 1, 1, 1
    -- end

    -- if(b) then
        -- if ns.db.reversecolors or ns.db.powerclass then
            -- power.bg:SetVertexColor(r*.2, g*.2, b*.2)
            -- power:SetStatusBarColor(r, g, b)
        -- else
            -- power.bg:SetVertexColor(r, g, b)
            -- power:SetStatusBarColor(0, 0, 0, .8)
        -- end
    -- end
	if C["ouf"].Powercolor then
		power.colorClass=true
		power.bg.multiplier = .2
	else
		power.colorPower=true
		power.bg.multiplier = .2
	end
end

function ns:UpdatePower(power)
    if ns.db.powerbar then
        power:Show()
        power.PostUpdate = PostPower
    else
        power:Hide()
        power.PostUpdate = nil
        return
    end
    power:SetStatusBarTexture(ns.db.texturePath)
    power:SetOrientation(ns.db.porientation)
    power.bg:SetTexture(ns.db.texturePath)

    power:ClearAllPoints()
    if ns.db.orientation == "HORIZONTAL" and ns.db.porientation == "VERTICAL" then
        power:SetPoint"LEFT"
        power:SetPoint"TOP"
        power:SetPoint"BOTTOM"
    elseif ns.db.porientation == "VERTICAL" then
        power:SetPoint"TOP"
        power:SetPoint"RIGHT"
        power:SetPoint"BOTTOM"
    else
        power:SetPoint"LEFT"
        power:SetPoint"RIGHT"
        power:SetPoint"BOTTOM"
    end
end

-- Show Mouseover highlight
local OnEnter = function(self)
    if ns.db.tooltip then
        UnitFrame_OnEnter(self)
    else
        GameTooltip:Hide()
    end

    if ns.db.highlight then
        self.Highlight:Show()
    end

    if ns.db.arrow and ns.db.arrowmouseover then
        ns:arrow(self, self.unit)
    end
end

local OnLeave = function(self)
    if ns.db.tooltip then
        UnitFrame_OnLeave(self)
    end
    self.Highlight:Hide()

    if(self.freebarrow and self.freebarrow:IsShown()) and ns.db.arrowmouseover then
        self.freebarrow:Hide()
    end
end

local style = function(self)
    self.menu = menu

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
    local name = self.Health:CreateFontString(nil, "OVERLAY")
    name:SetPoint("CENTER")
    name:SetJustifyH("CENTER")
    name:SetFont(ns.db.fontPath, ns.db.fontsize, ns.db.outline)
    -- name:SetShadowOffset(1.25, -1.25)
    name:SetWidth(ns.db.width)
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
    ricon:SetSize(ns.db.leadersize+2, ns.db.leadersize+2)
    self.RaidIcon = ricon

    -- Leader Icon
    self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
    self.Leader:SetPoint("TOPLEFT", self, 0, 8)
    self.Leader:SetSize(ns.db.leadersize, ns.db.leadersize)

    -- Assistant Icon
    self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
    self.Assistant:SetPoint("TOPLEFT", self, 0, 8)
    self.Assistant:SetSize(ns.db.leadersize, ns.db.leadersize)

    local masterlooter = self.Health:CreateTexture(nil, 'OVERLAY')
    masterlooter:SetSize(ns.db.leadersize, ns.db.leadersize)
    masterlooter:SetPoint('LEFT', self.Leader, 'RIGHT')
    self.MasterLooter = masterlooter

    -- Role Icon
    if ns.db.roleicon then
        self.LFDRole = self.Health:CreateTexture(nil, 'OVERLAY')
        self.LFDRole:SetSize(ns.db.leadersize, ns.db.leadersize)
        self.LFDRole:SetPoint('RIGHT', self, 'LEFT', ns.db.leadersize/2, ns.db.leadersize/2)
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
        outsideAlpha = ns.db.outsideRange,
    }

    self.freebRange = ns.db.arrow and range
    self.Range = ns.db.arrow == false and range

    -- ReadyCheck
    self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
    self.ReadyCheck:SetPoint("TOP", self)
    self.ReadyCheck:SetSize(ns.db.leadersize, ns.db.leadersize)

    -- Auras
    local auras = CreateFrame("Frame", nil, self)
    auras:SetSize(ns.db.aurasize, ns.db.aurasize)
    auras:SetPoint("CENTER", self.Health)
    auras.size = ns.db.aurasize
    self.freebAuras = auras

    -- Add events
    self:RegisterEvent('PLAYER_FOCUS_CHANGED', FocusTarget)
    self:RegisterEvent('RAID_ROSTER_UPDATE', FocusTarget)
    self:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
    self:RegisterEvent('RAID_ROSTER_UPDATE', ChangedTarget)

    self:SetScale(ns.db.scale)

    table.insert(ns._Objects, self)
end

oUF:RegisterStyle("Freebgrid", style)

function ns:Colors()
    for class, color in next, colors.class do
        if ns.db.reversecolors then
            ns.colorCache[class] = "|cffFFFFFF"
        else
            ns.colorCache[class] = ns:hex(color)
        end
    end

    for dtype, color in next, DebuffTypeColor do
        ns.debuffColor[dtype] = ns:hex(color)
    end
end

local pos, posRel, colX, colY
local function freebHeader(name, group, temp, pet, MT)
    local horiz, grow = ns.db.horizontal, ns.db.growth
    local numUnits = ns.db.multi and 5 or ns.db.numUnits

    local initconfig = [[
    self:SetWidth(%d)
    self:SetHeight(%d)
    ]]

    if pet then
        horiz, grow = ns.db.pethorizontal, ns.db.petgrowth
        numUnits = ns.db.petUnits
        initconfig = [[ 
        self:SetWidth(%d)        
        self:SetHeight(%d)           
        self:SetAttribute('unitsuffix', 'pet')
        ]]
    elseif MT then
        horiz, grow = ns.db.MThorizontal, ns.db.MTgrowth
        numUnits = ns.db.MTUnits
    end

    local point, growth, xoff, yoff
    if horiz then
        point = "LEFT"
        xoff = ns.db.spacing
        yoff = 0
        if grow == "UP" then
            growth = "BOTTOM"
            pos = "BOTTOMLEFT"
            posRel = "TOPLEFT"
            colY = ns.db.spacing
        else
            growth = "TOP"
            pos = "TOPLEFT"
            posRel = "BOTTOMLEFT"
            colY = -ns.db.spacing
        end
    else
        point = "TOP"
        xoff = 0
        yoff = -ns.db.spacing
        if grow == "RIGHT" then
            growth = "LEFT"
            pos = "TOPLEFT"
            posRel = "TOPRIGHT"
            colX = ns.db.spacing
        else
            growth = "RIGHT"
            pos = "TOPRIGHT"
            posRel = "TOPLEFT"
            colX = -ns.db.spacing
        end
    end

    local sort, groupBy, groupOrder = "INDEX", "GROUP", "1,2,3,4,5,6,7,8"
    if not pet and not MT then
        if ns.db.sortName then
            sort = "NAME"
            groupBy = nil
        end

        if ns.db.sortClass then
            groupBy = "CLASS"
            groupOrder = ns.db.classOrder
            group = ns.db.classOrder
        end
    end

    local template = temp or nil
    local header = oUF:SpawnHeader(name, template, 'raid,party,solo',
    'oUF-initialConfigFunction', (initconfig):format(ns.db.width, ns.db.height),
    'showPlayer', ns.db.player,
    'showSolo', ns.db.solo,
    'showParty', ns.db.party,
    'showRaid', true,
    'xOffset', xoff,
    'yOffset', yoff,
    'point', point,
    'sortMethod', sort,
    'groupFilter', group,
    'groupingOrder', groupOrder,
    'groupBy', groupBy,
    'maxColumns', ns.db.numCol,
    'unitsPerColumn', numUnits,
    'columnSpacing', ns.db.spacing,
    'columnAnchorPoint', growth)

    return header
end

oUF:Factory(function(self)
    -- ns:Anchors()
    ns:Colors()
	--隐藏自带团队
	CompactRaidFrameContainer:UnregisterAllEvents()
	CompactRaidFrameContainer:Hide() 
	CompactRaidFrameContainer.Show = function() end
	CompactRaidFrameManager:UnregisterAllEvents()
	CompactRaidFrameManager:Hide()
	CompactRaidFrameManager.Show = function() end
	
    self:SetActiveStyle"Freebgrid"
    if ns.db.multi then
        local raid = {}
        for i=1, ns.db.numCol do
            local group = freebHeader("Raid_Freebgrid"..i, i)
            if i == 1 then
                group:SetPoint("TOPLEFT", UIParent, "BOTTOM", - ns.db.width*2.5 - ns.db.spacing*2, ns.db.height*5 + ns.db.spacing*4 + 40)
            else
                group:SetPoint(pos, raid[i-1], posRel, colX or 0, colY or 0)
            end
            raid[i] = group
            ns._Headers[group:GetName()] = group
        end
    else
        local raid = freebHeader("Raid_Freebgrid")
        raid:SetPoint(pos, "oUF_FreebgridRaidFrame", pos)
        ns._Headers[raid:GetName()] = raid
    end

    if ns.db.pets then
        local pet = freebHeader("Pet_Freebgrid", nil, 'SecureGroupPetHeaderTemplate', true)
        pet:SetPoint(pos, "oUF_FreebgridPetFrame", pos)
        pet:SetAttribute('useOwnerUnit', true)
        ns._Headers[pet:GetName()] = pet
    end

    if ns.db.MT then
        local tank = freebHeader("MT_Freebgrid", nil, nil, nil, true)
        tank:SetPoint(pos, "oUF_FreebgridMTFrame", pos)
        ns._Headers[tank:GetName()] = tank

        if oRA3 then
            tank:SetAttribute("initial-unitWatch", true)
            tank:SetAttribute("nameList", table.concat(oRA3:GetSortedTanks(), ","))

            local tankhandler = {}
            function tankhandler:OnTanksUpdated(event, tanks) 
                tank:SetAttribute("nameList", table.concat(tanks, ","))
            end
            oRA3.RegisterCallback(tankhandler, "OnTanksUpdated")
        else
            tank:SetAttribute('groupFilter', 'MAINTANK')
        end
    end
end)

ns.textures = {
    ["gradient"] = ns.mediapath.."gradient",
    ["Cabaret"] = ns.mediapath.."Cabaret",
}

ns.fonts = {
    ["calibri"] = ns.mediapath.."calibri.ttf",
    ["Accidental Presidency"] = ns.mediapath.."Accidental Presidency.ttf",
    ["Expressway"] = ns.mediapath.."expressway.ttf",
}

local SM = LibStub("LibSharedMedia-3.0", true)

if SM then
    for font, path in pairs(ns.fonts) do
        SM:Register("font", font, path)
    end

    for tex, path in pairs(ns.textures) do
        SM:Register("statusbar", tex, path)
    end
end

ns:RegisterEvent("ADDON_LOADED")
function ns:ADDON_LOADED(event, addon)
    if addon ~= ADDON_NAME then return end
    self:InitDB()

    self:UnregisterEvent("ADDON_LOADED")
    self.ADDON_LOADED = nil

    if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end

function ns:PLAYER_LOGIN()
    self:RegisterEvent("PLAYER_LOGOUT")

    local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
    f:SetScript('OnShow', function(self)
        self:SetScript('OnShow', nil)
        if not IsAddOnLoaded('oUF_Freebgrid_Config') then
            LoadAddOn('oUF_Freebgrid_Config')
        end
    end)

    self:UnregisterEvent("PLAYER_LOGIN")
    self.PLAYER_LOGIN = nil
end

function ns:PLAYER_LOGOUT()
    self:FlushDB()
end