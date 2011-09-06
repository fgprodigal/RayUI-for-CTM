local R, C, DB = unpack(select(2, ...))

local ADDON_NAME, ns = ...
local oUF = oUF_Freeb or ns.oUF or oUF

local mediaPath = "Interface\\AddOns\\!RayUI\\media\\"

local movtex = "Interface\\AddOns\\!RayUI\\media\\mouseover"
local thrtex = "Interface\\AddOns\\!RayUI\\media\\threat"
local buttonTex = "Interface\\AddOns\\!RayUI\\media\\buttontex"
local height, width = 22, 240
local scale = 1.0
local hpheight = .85 -- .70 - .90 

local overrideBlizzbuffs = false
local auras = true               -- disable all auras
local bossframes = true
local auraborders = false

local onlyShowPlayer = false -- only show player debuffs on target

local pixelborder = false

if overrideBlizzbuffs then
    BuffFrame:Hide()
    TemporaryEnchantFrame:Hide()
end

-- Unit Menu
local dropdown = CreateFrame('Frame', ADDON_NAME .. 'DropDown', UIParent, 'UIDropDownMenuTemplate')

local function menu(self)
    dropdown:SetParent(self)
    return ToggleDropDownMenu(1, nil, dropdown, 'cursor', 0, 0)
end

local init = function(self)
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

ns.backdrop = R.createBackdrop

local fixStatusbar = function(bar)
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:GetStatusBarTexture():SetVertTile(false)
end

local function ComboDisplay(self, event, unit)
	if(unit == 'pet') then return end
	
	local cpoints = self.CPoints
	local cp
	if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
		cp = GetComboPoints('vehicle', 'target')
	else
		cp = GetComboPoints('player', 'target')
	end

	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			cpoints[i]:SetAlpha(1)
		else
			cpoints[i]:SetAlpha(0.15)
		end
	end
	
	if cpoints[1]:GetAlpha() == 1 then
		for i=1, MAX_COMBO_POINTS do
			cpoints[i]:Show()
		end
		
	else
		for i=1, MAX_COMBO_POINTS do
			cpoints[i]:Hide()
		end
	end
end

local createStatusbar = function(parent, tex, layer, height, width, r, g, b, alpha)
    local bar = CreateFrame"StatusBar"
    bar:SetParent(parent)
    if height then
        bar:SetHeight(height)
    end
    if width then
        bar:SetWidth(width)
    end
    bar:SetStatusBarTexture(tex, layer)
    bar:SetStatusBarColor(r, g, b, alpha)
    fixStatusbar(bar)

    return bar
end

local createFont = function(parent, layer, font, fontsiz, thinoutline, r, g, b, justify)
    local string = parent:CreateFontString(nil, layer)
    string:SetFont(font, fontsiz, thinoutline)
    string:SetShadowOffset(R.mult, -R.mult)
    string:SetTextColor(r, g, b)
    if justify then
        string:SetJustifyH(justify)
    end

    return string
end

local updateEclipse = function(element, unit)
    if element.hasSolarEclipse then
        element.bd:SetBackdropBorderColor(1, .6, 0)
        element.bd:SetBackdropColor(1, .6, 0)
    elseif element.hasLunarEclipse then
        element.bd:SetBackdropBorderColor(0, .4, 1)
        element.bd:SetBackdropColor(0, .4, 1)
    else
        element.bd:SetBackdropBorderColor(0, 0, 0)
        element.bd:SetBackdropColor(0, 0, 0)
    end
end

local PostAltUpdate = function(altpp, min, cur, max)
    local self = altpp.__owner

    local tPath, r, g, b = UnitAlternatePowerTextureInfo(self.unit, 2)

    if(r) then
        altpp:SetStatusBarColor(r, g, b, 1)
    else
        altpp:SetStatusBarColor(1, 1, 1, .8)
    end 
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

local GetTime = GetTime
local floor, fmod = floor, math.fmod
local day, hour, minute = 86400, 3600, 60

local FormatTime = function(s)
    if s >= day then
        return format("%dd", floor(s/day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s/minute + 0.5))
    end

    return format("%d", fmod(s, minute))
end

local CreateAuraTimer = function(self,elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed

    if self.elapsed < .2 then return end
    self.elapsed = 0

    local timeLeft = self.expires - GetTime()
    if timeLeft <= 0 then
        return
    else
        self.remaining:SetText(FormatTime(timeLeft))
    end
end

local debuffFilter = {
    --Update this
}

local auraIcon = function(auras, button)
    local count = button.count
    count:ClearAllPoints()
    count:Point("TOPLEFT", -4, 2)
    count:SetFontObject(nil)
    count:SetFont(C["media"].font, 13, "THINOUTLINE")
    count:SetTextColor(.8, .8, .8)

    auras.disableCooldown = true

    button.icon:SetTexCoord(.1, .9, .1, .9)
    button.bg = R.createBackdrop(button, button)
	
    if auraborders then
        auras.showDebuffType = true
        button.overlay:SetTexture(buttonTex)
        button.overlay:Point("TOPLEFT", button, "TOPLEFT", -2, 2)
        button.overlay:Point("TOPLEFT", button, "TOPLEFT", 2, -2)
        button.overlay:SetTexCoord(0, 1, 0.02, 1)
    else
        button.overlay:Hide()
    end

    local remaining = createFont(button, "OVERLAY", C["media"].font, 13, "THINOUTLINE", 0.99, 0.99, 0.99)
    remaining:Point("BOTTOMRIGHT", 4, -4)
    button.remaining = remaining
end

local PostUpdateIcon
do
    local playerUnits = {
        player = true,
        pet = true,
        vehicle = true,
    }

    PostUpdateIcon = function(icons, unit, icon, index, offset)
        local name, _, _, _, dtype, duration, expirationTime, unitCaster = UnitAura(unit, index, icon.filter)

        local texture = icon.icon
        if playerUnits[icon.owner] or debuffFilter[name] or UnitIsFriend('player', unit) or not icon.debuff then
            texture:SetDesaturated(false)
        else
            texture:SetDesaturated(true)
        end

        if duration and duration > 0 then
            icon.remaining:Show()
        else
            icon.remaining:Hide()
        end

        --[[if icon.debuff then
        icon.bg:SetBackdropBorderColor(.4, 0, 0)
        else
        icon.bg:SetBackdropBorderColor(0, 0, 0)
        end]]

        icon.duration = duration
        icon.expires = expirationTime
        icon:SetScript("OnUpdate", CreateAuraTimer)
    end
end

local aurafilter = {
    ["Chill of the Throne"] = true,
}

 -- local CustomFilter = function(icons, ...)
    -- local _, icon, name, _, _, _, _, _, _, caster = ...

    -- if aurafilter[name] then
        -- return false
    -- end

    -- local isPlayer

    -- if R.multicheck(caster, 'player', 'vechicle') then
        -- isPlayer = true
    -- end

    -- if((icons.onlyShowPlayer and isPlayer) or (not icons.onlyShowPlayer and name)) then
        -- icon.isPlayer = isPlayer
        -- icon.owner = caster
        -- return true
    -- end
 -- end


local function PostUpdateHealth(self, unit, cur, max)
	local curhealth, maxhealth = UnitHealth(unit), UnitHealthMax(unit)
	local r, g, b
	r,g,b = ColorGradient(curhealth/maxhealth)
	
	if not C["ouf"].HealthcolorClass then
		if(b) then
			self:SetStatusBarColor(r, g, b, 1)
		elseif not UnitIsConnected(unit) then
			local color = colors.disconnected
			local power = self.__owner.Power
			if power then
				power:SetValue(0)
				if power.value then
					power.value:SetText(nil)
				end
			end
			return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, PLAYER_OFFLINE)
		elseif UnitIsDeadOrGhost(unit) then
			local color = colors.disconnected
			local power = self.__owner.Power
			if power then
				power:SetValue(0)
				if power.value then
					power.value:SetText(nil)
				end
			end
			return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, UnitIsGhost(unit) and GHOST or DEAD)
		end
	end
	
	local color
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = oUF.colors.class[class]
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = oUF.colors.tapped
	elseif UnitIsEnemy(unit, "player") then
		color = oUF.colors.reaction[1]
	else
		color = oUF.colors.reaction[UnitReaction(unit, "player") or 5]
	end
	if cur < max then
		if R.isHealer and UnitCanAssist("player", unit) then
			if self.__owner.isMouseOver and not unit:match("^party") then
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R.ShortValue(UnitHealth(unit)))
			else
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R.ShortValue(UnitHealth(unit) - UnitHealthMax(unit)))
			end
		elseif self.__owner.isMouseOver then
			self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R.ShortValue(UnitHealth(unit)))
		else
			self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.5))
		end
	elseif self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R.ShortValue(UnitHealthMax(unit)))
	else
		self.value:SetText(nil)
	end
end

local function PostUpdatePower(self, unit, cur, max)
	local shown = self:IsShown()
	if max == 0 then
		if shown then
			self:Hide()
		end
		return
	elseif not shown then
		self:Show()
	end

	if UnitIsDeadOrGhost(unit) then
		self:SetValue(0)
		if self.value then
			self.value:SetText(nil)
		end
		return
	end

	if not self.value then return end

	local _, type = UnitPowerType(unit)
	local color = oUF.colors.power[type] or oUF.colors.power.FUEL
	if cur < max then
		if self.__owner.isMouseOver then
			self.value:SetFormattedText("%s - |cff%02x%02x%02x%s|r", R.ShortValue(UnitPower(unit)), color[1] * 255, color[2] * 255, color[3] * 255, R.ShortValue(UnitPowerMax(unit)))
		elseif type == "MANA" then
			self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5))
		elseif cur > 0 then
			self.value:SetFormattedText("|cff%02x%02x%02x%d|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5))
		else
			self.value:SetText(nil)
		end
	elseif type == "MANA" and self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R.ShortValue(UnitPowerMax(unit)))
	else
		self.value:SetText(nil)
	end
end

-- mouseover highlight
local UnitFrame_OnEnter = function(self)
	if IsShiftKeyDown() or not UnitAffectingCombat("player") then
		UnitFrame_OnEnter(self)
	end
	self.Mouseover:Show()	
	self.isMouseOver = true
	for _, element in ipairs(self.mouseovers) do
		element:ForceUpdate()
	end
end

local UnitFrame_OnLeave = function(self)
	UnitFrame_OnLeave(self)
	self.Mouseover:Hide()
	self.isMouseOver = nil
	for _, element in ipairs(self.mouseovers) do
		element:ForceUpdate()
	end
end

-- threat highlight
local function updateThreatStatus(self, event, u)
	if (self.unit ~= u) then return end
	local s = UnitThreatSituation(u)
	if s and s > 1 then
		local r, g, b = GetThreatStatusColor(s)
		self.ThreatHlt:Show()
		self.ThreatHlt:SetVertexColor(r, g, b, 0.5)
	else
		self.ThreatHlt:Hide()
	end
end

--========================--
--  Shared
--========================--
local func = function(self, unit)
    self.menu = menu
	self.mouseovers = {}
	
    self:SetBackdrop(backdrop)
    self:SetBackdropColor(0, 0, 0)
	
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    self:RegisterForClicks"AnyUp"

    self.FrameBackdrop = R.createBackdrop(self, self)

    local hp = createStatusbar(self, C["media"].normal, nil, nil, nil, .1, .1, .1, 1)
    hp:SetPoint"TOP"
    hp:SetPoint"LEFT"
    hp:SetPoint"RIGHT"
	
	-- if unit == "player" or unit == "target" then
	hp.value = hp:CreateFontString(self, "OVERLAY")
	hp.value:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
	hp.value:Point("LEFT", self, "LEFT", 5, 0)
	-- end
		
	-- mouseover highlight
    local mov = hp:CreateTexture(nil, "OVERLAY")
	mov:SetAllPoints(hp)
	mov:SetTexture(movtex)
	mov:SetVertexColor(1,1,1,.36)
	mov:SetBlendMode("ADD")
	mov:Hide()
	self.Mouseover = mov
	
	-- threat highlight
	local Thrt = hp:CreateTexture(nil, "OVERLAY")
	Thrt:SetAllPoints(hp)
	Thrt:SetTexture(thrtex)
	--Thrt:SetVertexColor(1,1,1,.36)
	Thrt:SetBlendMode("ADD")
	Thrt:Hide()
	self.ThreatHlt = Thrt	
	
	-- update threat
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", updateThreatStatus)
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", updateThreatStatus)

    if(unit == "pet" or unit == "targettarget" or unit == "focustarget") then
        hp:SetHeight(0)
    else
        -- hp:SetHeight(height*hpheight)
        hp:SetHeight(height)
    end

    hp.frequentUpdates = true
    hp.Smooth = true

    local hpbg = hp:CreateTexture(nil, "BORDER")
    hpbg:SetAllPoints(hp)
    hpbg:SetTexture(C["media"].normal)

    if C["ouf"].HealthcolorClass then
        hp.colorClass = true
        hp.colorReaction = true
		hp.colorTapping = true
		hp.colorDisconnected = true
        hpbg.multiplier = .2
    else
        hpbg:SetVertexColor(1,1,1,.6)
    end

    -- if not (unit == "targettarget" or unit == "pet" or unit == "focustarget" or unit == "player" or unit == "target") then
        -- local hpp = createFont(hp, "OVERLAY", C["media"].font, C["media"].fontsize, C["media"].fontflag, 1, 1, 1)
		-- if (unit=="player" or unit == "focus" or unit == "boss" ) then
		-- hpp:Point("LEFT", hp, 2, 0)
        -- self:Tag(hpp, '[freeb:hp]')
		-- else
        -- hpp:Point("RIGHT", hp, -2, 0)
        -- self:Tag(hpp, '[freeb:hp]')
		-- end
    -- end

    hp.bg = hpbg
    self.Health = hp

    if not (unit == "pet" or unit == "targettarget" or unit == "focustarget") then
        local pp = createStatusbar(self, C["media"].normal, nil, height*-(hpheight-.95), nil, 1, 1, 1, 1)
        pp:SetPoint"LEFT"
        pp:SetPoint"RIGHT"
        pp:SetPoint"BOTTOM" 

        pp.frequentUpdates = true
        pp.Smooth = true
		pp.colorTapping = true
		pp.colorDisconnected = true
		pp.colorReaction = true
		
        local ppbg = pp:CreateTexture(nil, "BORDER")
        ppbg:SetAllPoints(pp)
        ppbg:SetTexture(C["media"].normal) 
		
		if C["ouf"].Powercolor then
			pp.colorClass = true
            ppbg.multiplier = .2
		else
			pp.colorPower = true
            ppbg.multiplier = .2
        end

        pp.bg = ppbg
		
		-- if unit == "player" or unit == "target" then
		pp.value = pp:CreateFontString(self, "OVERLAY")
		pp.value:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
		pp.value:Point("RIGHT", self, "RIGHT", -5, 0)
		-- end
		pp:SetFrameLevel(hp:GetFrameLevel()+1)
        self.Power = pp
    end

    local altpp = createStatusbar(self, C["media"].normal, nil, 4, nil, 1, 1, 1, .8)
    altpp:Point('TOPLEFT', self, 'BOTTOMLEFT', 0, -2)
    altpp:Point('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -2)
    altpp.bg = altpp:CreateTexture(nil, 'BORDER')
    altpp.bg:SetAllPoints(altpp)
    altpp.bg:SetTexture(C["media"].normal)
    altpp.bg:SetVertexColor( 0,  0.76, 1)
    altpp.bd = R.createBackdrop(altpp, altpp)

    altpp.Text =  createFont(altpp, "OVERLAY", C["media"].font, C["media"].fontsize, C["media"].fontflag, 1, 1, 1)
    altpp.Text:SetPoint("CENTER")
    self:Tag(altpp.Text, "[freeb:altpower]")

    altpp.PostUpdate = PostAltUpdate
    self.AltPowerBar = altpp

    local leader = hp:CreateTexture(nil, "OVERLAY")
    leader:SetSize(16, 16)
    leader:Point("TOPLEFT", hp, "TOPLEFT", 5, 10)
    self.Leader = leader

    local masterlooter = hp:CreateTexture(nil, 'OVERLAY')
    masterlooter:SetSize(16, 16)
    masterlooter:Point("TOPLEFT", hp, "TOPLEFT", 25, 10)
    self.MasterLooter = masterlooter

    local LFDRole = hp:CreateTexture(nil, 'OVERLAY')
    LFDRole:SetSize(16, 16)
    LFDRole:Point("TOPLEFT", hp, -10, 10)
	self.LFDRole = LFDRole
	self.LFDRole:SetTexture("Interface\\AddOns\\!RayUI\\media\\lfd_role")
	
    local PvP = hp:CreateTexture(nil, 'OVERLAY')
    PvP:SetSize(20, 20)
    PvP:Point('TOPRIGHT', hp, 12, 8)
    self.PvP = PvP

    local Combat = hp:CreateTexture(nil, 'OVERLAY')
    Combat:SetSize(20, 20)
    Combat:Point('BOTTOMLEFT', hp, -10, -10)
    self.Combat = Combat

    local Resting = hp:CreateTexture(nil, 'OVERLAY')
    Resting:SetSize(20, 20)
    Resting:Point('BOTTOM', Combat, 'BOTTOM', -9, 20)
    self.Resting = Resting

    local QuestIcon = hp:CreateTexture(nil, 'OVERLAY')
    QuestIcon:SetSize(24, 24)
    QuestIcon:Point('BOTTOMRIGHT', hp, 15, -20)
    self.QuestIcon = QuestIcon

    local PhaseIcon = hp:CreateTexture(nil, 'OVERLAY')
    PhaseIcon:SetSize(24, 24)
    PhaseIcon:SetPoint('RIGHT', QuestIcon, 'LEFT')
    self.PhaseIcon = PhaseIcon

    local name = createFont(hp, "OVERLAY", C["media"].font, 15, C["media"].fontflag, 1, 1, 1)	
	if(unit == "targettarget" or unit == "pet" or unit == "partypet" or unit == "partytarget" or unit == "focustarget") then
		name:Point("TOP", hp, 0, 12)
		name:SetFont(C["media"].font,14, C["media"].fontflag)
	elseif(unit == "target" ) then
		name:Point("BOTTOM", hp,  6, -15)
		name:Point("RIGHT", hp, 0, 0)
		name:SetJustifyH"LEFT"
	 elseif(unit == "focus" ) then
		name:Point("BOTTOM", hp, -4, -15)
		name:Point("LEFT", hp, 0, 0)
		name:SetFont(C["media"].font,14, C["media"].fontflag)
		name:SetJustifyH"RIGHT"		
	elseif( unit == "player" or unit =="party") then
		name:Point("BOTTOM", hp, -4, -15)
		name:Point("LEFT", hp, 0, 0)
		name:SetJustifyH"RIGHT"		
	else
		name:Point("TOP", hp, 0, 20)
		name:Point("LEFT", hp, 0, 0)
		name:SetJustifyH"RIGHT"		
	end
	self.Name = name
	
	if C["ouf"].HealthcolorClass then
		if(unit == "targettarget" or unit == "focustarget" or unit == "pet" or unit == "partypet" or unit == "partytarget" ) then
			self:Tag(name, '[freeb:name]')
		else
			self:Tag(name, '[freeb:name] [freeb:info]')
		end
	else
		if(unit == "targettarget" or unit == "focustarget" or unit == "pet" or unit == "partypet" or unit == "partytarget" ) then
			self:Tag(name, '[freeb:color][freeb:name]')
		else
			self:Tag(name, '[freeb:color][freeb:name] [freeb:info]')
		end
    end

    local ricon = hp:CreateTexture(nil, 'OVERLAY')
    ricon:Point("BOTTOM", hp, "TOP", 0, -7)
    ricon:SetSize(16,16)
    self.RaidIcon = ricon

    self:SetSize(width, height)
	if(unit and (unit == "targettarget")) then
        self:SetSize(140, 8)
    end
	
	if(unit and (unit == "boss")) then
        self:SetSize(200, height)
    end
	
    if(unit and (unit == "focustarget")) then
        self:SetSize(120, 8)
    end
	
    if(unit and (unit == "pet")) then
        self:SetSize(140,8)
    end

    self:SetScale(scale)
	
	tinsert(self.mouseovers, self.Health)
	self.Health.PostUpdate = PostUpdateHealth
	
	if self.Power then
		if self.Power.value then 
			tinsert(self.mouseovers, self.Power)
			self.Power.PostUpdate = PostUpdatePower	
		end
	end
end

local BarFader = function(self)
	self.BarFade = true
	self.BarFaderMinAlpha = "0"
end

local function Portrait(self)
	local portrait = CreateFrame("PlayerModel", nil, self)
	portrait.PostUpdate = function(self) 
											portrait:SetAlpha(0.15) 
											if self:GetModel() and self:GetModel().find and self:GetModel():find("worgenmale") then
												self:SetCamera(1)
											end	
										end
	portrait:SetAllPoints(self.Health)
	table.insert(self.__elements, HidePortrait)
	self.Portrait = portrait
end

local UnitSpecific = {

    --========================--
    --  Player
    --========================--
    player = function(self, ...)
        func(self, ...)
		
		R.CreateCastBar(self)
		-- self.Castbar.Icon:Hide()
		-- self.Castbar.Time:Hide()
		
		-- CreateCastBar(self)
		-- BarFader(self)
		R.CreateTrinketButton(self)
		
        -- Runes, Shards, HolyPower
        if R.multicheck(R.myclass, "DEATHKNIGHT", "WARLOCK", "PALADIN") then
            local count
            if R.myclass == "DEATHKNIGHT" then 
                count = 6 
            else 
                count = 3 
            end

            local bars = CreateFrame("Frame", nil, self)
			bars:SetSize(200/count - 5, 5)
			if count == 3 then
				bars:Point("BOTTOMRIGHT", self, "TOP", bars:GetWidth()*1.5 + 5,0)
			else
				bars:Point("BOTTOMRIGHT", self, "TOP", bars:GetWidth()*3 + 12.5,0)
			end

            local i = count
            for index = 1, count do
                bars[i] = createStatusbar(bars, C["media"].normal, nil, 5, 200/count-5, 1, 1, 1, 1)

                if R.myclass == "WARLOCK" then
                    local color = oUF.colors.class["WARLOCK"]
                    bars[i]:SetStatusBarColor(color[1], color[2], color[3])
                elseif R.myclass == "PALADIN" then
                    local color = self.colors.power["HOLY_POWER"]
                    bars[i]:SetStatusBarColor(color[1], color[2], color[3])
                end 

                if i == count then
                    bars[i]:SetPoint("TOPLEFT", bars, "TOPLEFT")
                else
                    bars[i]:Point("RIGHT", bars[i+1], "LEFT", -5, 0)
                end

                bars[i].bg = bars[i]:CreateTexture(nil, "BACKGROUND")
                bars[i].bg:SetAllPoints(bars[i])
                bars[i].bg:SetTexture(C["media"].normal)
                bars[i].bg.multiplier = .2

                bars[i].bd = R.createBackdrop(bars[i], bars[i])
                i=i-1
            end

            if R.myclass == "DEATHKNIGHT" then
                bars[3], bars[4], bars[5], bars[6] = bars[5], bars[6], bars[3], bars[4]
                self.Runes = bars
            elseif R.myclass == "WARLOCK" then
                self.SoulShards = bars
            elseif R.myclass == "PALADIN" then
                self.HolyPower = bars
            end
        end

        if R.myclass == "DRUID" then
            local ebar = CreateFrame("Frame", nil, self)
            ebar:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -8)
            ebar:SetSize(150, 16)
            ebar.bd = R.createBackdrop(ebar, ebar)

            local lbar = createStatusbar(ebar, C["media"].normal, nil, 16, 150, 0, .4, 1, 1)
            lbar:SetPoint("LEFT", ebar, "LEFT")
            ebar.LunarBar = lbar

            local sbar = createStatusbar(ebar, C["media"].normal, nil, 16, 150, 1, .6, 0, 1)
            sbar:SetPoint("LEFT", lbar:GetStatusBarTexture(), "RIGHT")
            ebar.SolarBar = sbar

            ebar.Spark = sbar:CreateTexture(nil, "OVERLAY")
            ebar.Spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
            ebar.Spark:SetBlendMode("ADD")
            ebar.Spark:SetAlpha(0.5)
            ebar.Spark:SetHeight(48)
            ebar.Spark:Point("LEFT", sbar:GetStatusBarTexture(), "LEFT", -15, 0)

            self.EclipseBar = ebar
            self.EclipseBar.PostUnitAura = updateEclipse

            --EclipseBarFrame:ClearAllPoints()
            --EclipseBarFrame:SetParent(self)
            --EclipseBarFrame:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -55)
        end

        if  R.myclass == "SHAMAN" then
            self.TotemBar = {}
            self.TotemBar.Destroy = true
            for i = 1, 4 do
                self.TotemBar[i] = createStatusbar(self, C["media"].normal, nil, 5, 200/4-5, 1, 1, 1, 1)

                if (i == 1) then
                    self.TotemBar[i]:SetPoint("BOTTOM", self, "TOP", 75,0)
                else
                    self.TotemBar[i]:SetPoint("RIGHT", self.TotemBar[i-1], "LEFT", -5, 0)
                end
                self.TotemBar[i]:SetBackdrop(backdrop)
                self.TotemBar[i]:SetBackdropColor(0.5, 0.5, 0.5)
                self.TotemBar[i]:SetMinMaxValues(0, 1)

                self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
                self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
                self.TotemBar[i].bg:SetTexture(C["media"].normal)
                self.TotemBar[i].bg.multiplier = 0.3

                self.TotemBar[i].bd = R.createBackdrop(self, self.TotemBar[i])
            end
        end

		self.Experience = createStatusbar(self, C["media"].normal, nil, 4, nil, 0.58, 0.0, 0.55, 1.0)
		self.Experience:Point('TOPLEFT', BottomInfoBar, 'TOPLEFT', 3, -3)
		self.Experience:Point('BOTTOMRIGHT', BottomInfoBar, 'BOTTOMRIGHT', -3, 3)
		self.Experience:SetFrameStrata("BACKGROUND")
		self.Experience:SetFrameLevel(1)
		
		self.Experience.Rested = createStatusbar(self.Experience, C["media"].normal, nil, nil, nil, 0.0, 0.39, 0.88, 1.0)
		self.Experience.Rested:SetAllPoints(self.Experience)
		self.Experience.Rested:SetFrameStrata("BACKGROUND")
		self.Experience.Rested:SetFrameLevel(0)

		-- self.Experience.bg = self.Experience.Rested:CreateTexture(nil, 'BORDER')
		-- self.Experience.bg:SetAllPoints(self.Experience)
		-- self.Experience.bg:SetTexture(C["media"].normal)
		-- self.Experience.bg:SetVertexColor(.1, .1, .1)

		-- self.Experience.bd = R.createBackdrop(self.Experience, self.Experience)

		-- self.Experience.text = createFont(self.Experience, "OVERLAY", C["media"].font, C["media"].fontsize, C["media"].fontflag, 1, 1, 1)
		-- self.Experience.text:SetPoint("CENTER")
		-- self.Experience.text:Hide()
		-- self:Tag(self.Experience.text, '[freeb:curxp] / [freeb:maxxp] - [freeb:perxp]%')
		
		self.Experience.Tooltip = true
		
		self.Reputation = createStatusbar(self, C["media"].normal, nil, 4, nil, 0, .7, 1, 1)
		self.Reputation:Point('TOPLEFT', BottomInfoBar, 'TOPLEFT', 3, -3)
		self.Reputation:Point('BOTTOMRIGHT', BottomInfoBar, 'BOTTOMRIGHT', -3, 3)
		self.Reputation:SetFrameStrata("BACKGROUND")
		self.Reputation:SetFrameLevel(0)
		
		self.Reputation.PostUpdate = function(self, event, unit, bar)
															local name, id = GetWatchedFactionInfo()
															bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
														end
		self.Reputation.Tooltip = true
		
		self:SetScript("OnEnter", UnitFrame_OnEnter)
		self:SetScript("OnLeave", UnitFrame_OnLeave)

		-- self:RegisterEvent('UNIT_POWER_BAR_SHOW', AltPower)
		-- self:RegisterEvent('UNIT_POWER_BAR_HIDE', AltPower)


        if overrideBlizzbuffs then
            local buffs = CreateFrame("Frame", nil, self)
            buffs:SetHeight(36)
            buffs:SetWidth(36*12)
            buffs.initialAnchor = "TOPRIGHT"
            buffs.spacing = 5
            buffs.num = 40
            buffs["growth-x"] = "LEFT"
            buffs["growth-y"] = "DOWN"
            buffs:Point("TOPRIGHT", UIParent, "TOPRIGHT", -10, -20)
            buffs.size = 36

            buffs.PostCreateIcon = R.postCreateIconSmall
            buffs.PostUpdateIcon = R.postUpdateIconSmall

            self.Buffs = buffs

            if (IsAddOnLoaded('oUF_WeaponEnchant')) then
                self.Enchant = CreateFrame('Frame', nil, self)
                self.Enchant.size = 32
                self.Enchant:SetHeight(32)
                self.Enchant:SetWidth(self.Enchant.size * 3)
                self.Enchant:Point("TOPRIGHT", UIParent, "TOPRIGHT", -390, -140)
                self.Enchant["growth-y"] = "DOWN"
                self.Enchant["growth-x"] = "LEFT"
                self.Enchant.spacing = 5
                self.PostCreateEnchantIcon = R.postCreateIconSmall
            end
        end
--[[
        if auras then 
            local debuffs = CreateFrame("Frame", nil, self)
            debuffs:SetHeight(height+2)
            debuffs:SetWidth(width)
            debuffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
            debuffs.spacing = 4
            debuffs.size = height+3.5
            debuffs.initialAnchor = "BOTTOMLEFT"

            debuffs.PostCreateIcon = R.postCreateIconSmall
            debuffs.PostUpdateIcon = R.postUpdateIconSmall
            debuffs.CustomFilter = CustomFilter

            self.Debuffs = debuffs
            self.Debuffs.num = 7
        end
		]]
		if C["ouf"].PlayerBuffFilter then
			local b = CreateFrame("Frame", nil, self)
			b.size = 30
			b.num = 14
			b.spacing = 4.8
			if R.multicheck(R.myclass, "DEATHKNIGHT", "WARLOCK", "PALADIN", "SHAMAN") then
				b:Point("BOTTOMRIGHT", self,  "TOPRIGHT", 0, 10)
			else
				b:Point("BOTTOMRIGHT", self,  "TOPRIGHT", 0, 5)
			end
			b.initialAnchor = "BOTTOMRIGHT"
			b["growth-x"] = "LEFT"
			b["growth-y"] = "UP"
			b:SetHeight((b.size+b.spacing)*4)
			b:SetWidth(self:GetWidth())
			b.CustomFilter = R.CustomBuffFilter
			b.PostCreateIcon = R.postCreateIcon
			b.PostUpdateIcon = R.postUpdateIcon

			self.Buffs = b
		end
		
		--======================--
		--     MirrorBar
		--======================--
		-- for _, bar in pairs({'MirrorTimer1','MirrorTimer2','MirrorTimer3',}) do   
			-- for i, region in pairs({_G[bar]:GetRegions()}) do
				-- if (region.GetTexture and region:GetTexture() == C["media"].normal) then
				-- region:Hide()
				-- end
			-- end
			-- _G[bar]:StripTextures()
			-- _G[bar]:SetParent(UIParent)
			-- _G[bar]:SetScale(1)
			-- _G[bar]:SetHeight(13)
			-- _G[bar]:SetWidth(250)
			-- _G[bar]:SetBackdropColor(.1,.1,.1)
			-- _G[bar..'Background'] = _G[bar]:CreateTexture(bar..'Background', 'BACKGROUND', _G[bar])
			-- _G[bar..'Background']:SetTexture(C["media"].normal)
			-- _G[bar..'Background']:SetAllPoints(bar)
			-- _G[bar..'Background']:SetVertexColor(.15,.15,.15,.75)
			-- _G[bar..'Text']:SetFont(C["media"].font, 13)
			-- _G[bar..'Text']:ClearAllPoints()
			-- _G[bar..'Text']:SetPoint('CENTER', MirrorTimer1StatusBar, 0, 1)
			-- _G[bar..'StatusBar']:SetAllPoints(_G[bar])
			-- _G[bar].bg = R.createBackdrop(_G[bar], _G[bar])
		-- end
	  
		-- tinsert(self.mouseovers, self.Health)
		-- self.Health.PostUpdate = PostUpdateHealth
		
		-- if self.Power.value then 
			-- tinsert(self.mouseovers, self.Power)
			-- self.Power.PostUpdate = PostUpdatePower	
		-- end
    end,

    --========================--
    --  Target
    --========================--
    target = function(self, ...)
        func(self, ...)
		-- CreateCastBar(self)
		R.CreateCastBar(self)
		SpellRange(self)
		R.FocusText(self)
		
		-- local tpp = createFont(self.Health, "OVERLAY", font, fontsize, fontflag, 1, 1, 1)
        -- tpp:Point("LEFT", 2, 0)
        -- tpp.frequentUpdates = true
        -- self:Tag(tpp, '[freeb:pp]')

		--================--
		-- Combo Bars
		--================--
		
		local bars = CreateFrame("Frame", nil, self)
		bars:SetWidth(35)
		bars:SetHeight(5)
		bars:Point("BOTTOMLEFT", self, "TOP", - bars:GetWidth()*2.5 - 10,0)
		
		bars:SetBackdropBorderColor(0,0,0,0)
		bars:SetBackdropColor(0,0,0,0)
			
		for i = 1, 5 do					
			bars[i] = CreateFrame("StatusBar", self:GetName().."_Combo"..i, bars)
			bars[i]:SetHeight(5)					
			bars[i]:SetStatusBarTexture(C["media"].normal)
			bars[i]:GetStatusBarTexture():SetHorizTile(false)
								
			if i == 1 then
				bars[i]:SetPoint("LEFT", bars)
			else
				bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", 5, 0)
			end
			bars[i]:SetAlpha(0.15)
			bars[i]:SetWidth(35)
			bars[i].bg = bars[i]:CreateTexture(nil, "BACKGROUND")
			bars[i].bg:SetAllPoints(bars[i])
			bars[i].bg:SetTexture(C["media"].normal)
			bars[i].bg.multiplier = .2

			bars[i].bd = R.createBackdrop(bars[i], bars[i])
		end
			
		bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
		bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
		bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
			
		self.CPoints = bars
		self.CPoints.Override = ComboDisplay
		
		-- tinsert(self.mouseovers, self.Health)
		-- self.Health.PostUpdate = PostUpdateHealth
		
		-- if self.Power.value then 
			-- tinsert(self.mouseovers, self.Power)
			-- self.Power.PostUpdate = PostUpdatePower	
		-- end
    end,

    --========================--
    --  Party
    --========================-- 
	party = function(self, ...)
		func(self, ...)
        self:SetWidth(200)
		--[[if auras then 
            local debuffs = CreateFrame("Frame", nil, self)
            debuffs:SetHeight(height+2)
            debuffs:SetWidth(width)
            debuffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -4)
            debuffs.spacing = 4
            debuffs.size = height+3.5
            debuffs.initialAnchor = "BOTTOMLEFT"

            debuffs.PostCreateIcon = R.postCreateIconSmall
            debuffs.PostUpdateIcon = R.postUpdateIconSmall

            self.Debuffs = debuffs
            self.Debuffs.num = 7
        end
		]]
    end,

    --========================--
    --  Arena
    --========================-- 
	Arena = function(self, ...)
		func(self, ...)
        
		--[[if C["ouf"].showPortrait then
            Portrait(self)
        end
		]]
		
		if auras then 
            local debuffs = CreateFrame("Frame", nil, self)
            debuffs:SetHeight(height+2)
            debuffs:SetWidth(width)
            debuffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
            debuffs.spacing = 4
            debuffs.size = height+3.5
            debuffs.initialAnchor = "BOTTOMLEFT"

            debuffs.PostCreateIcon = R.postCreateIconSmall
            debuffs.PostUpdateIcon = R.postUpdateIconSmall

            self.Debuffs = debuffs
            self.Debuffs.num = 7
        end
    end,

	--========================--
    --  Focus
    --========================--
    focus = function(self, ...)
        func(self, ...)
		-- CreateCastBar(self)
		R.CreateCastBar(self)
	    SpellRange(self)
		R.ClearFocusText(self)
	    self:SetWidth(width-40)
--[[
        if C["ouf"].showPortrait then
            Portrait(self)
        end
		]]
		-- local tpp = createFont(self.Health, "OVERLAY", C["media"].font, C["media"].fontsize, C["media"].fontflag, 1, 1, 1)
        -- tpp:Point("RIGHT", -2, 0)
        -- tpp.frequentUpdates = true
        -- self:Tag(tpp, '[freeb:pp]')

        if auras then 
		    -- local buffs = CreateFrame("Frame", nil, self)
            -- buffs:SetHeight(height)
            -- buffs:SetWidth(width-40)
            -- buffs.initialAnchor = "LEFT"
            -- buffs.spacing = 4
            -- buffs.num = 14
            -- buffs["growth-x"] = "LEFT"
            -- buffs["growth-y"] = "DOWN"
            -- buffs:Point("LEFT", self, "LEFT", -30, 0)
            -- buffs.size = height
			
            -- buffs.PostCreateIcon = R.postCreateIconSmall
            -- buffs.PostUpdateIcon = R.postUpdateIconSmall
			-- buffs.onlyShowPlayer = true

            -- self.Buffs = buffs

            local debuffs = CreateFrame("Frame", nil, self)
            debuffs:SetHeight(height)
            debuffs:SetWidth(width-40)
            debuffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
            debuffs.spacing = 5
            debuffs.size = height+2
			debuffs["growth-x"] = "RIGHT"
            debuffs["growth-y"] = "UP"
            debuffs.initialAnchor = "BOTTOMLEFT"
			debuffs.onlyShowPlayer = true
            -- debuffs.PostCreateIcon = R.postCreateIconSmall
            -- debuffs.PostUpdateIcon = R.postUpdateIconSmall
			debuffs.PostCreateIcon = R.postCreateIcon
			debuffs.PostUpdateIcon = R.postUpdateIcon

            self.Debuffs = debuffs
            self.Debuffs.num = 14
        end
		-- tinsert(self.mouseovers, self.Health)
		-- self.Health.PostUpdate = PostUpdateHealth
		
		-- if self.Power.value then 
			-- tinsert(self.mouseovers, self.Power)
			-- self.Power.PostUpdate = PostUpdatePower	
		-- end
    end,

    --========================--
    --  Focus Target
    --========================--
    focustarget = function(self, ...)
        func(self, ...)
		self:SetWidth(100)
    end,

    --========================--
    --  Pet
    --========================--
    pet = function(self, ...)
        func(self, ...)
		SpellRange(self)

        --[[if auras then 
            local debuffs = CreateFrame("Frame", nil, self)
            debuffs:SetHeight(height+2)
            debuffs:SetWidth(width)
            debuffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
            debuffs.spacing = 4
            debuffs.size = 21.5
            debuffs.initialAnchor = "BOTTOMLEFT"

            debuffs.PostCreateIcon = R.postCreateIconSmall
            debuffs.PostUpdateIcon = R.postUpdateIconSmall
            debuffs.CustomFilter = R.CustomFilter

            self.Debuffs = debuffs
            self.Debuffs.num = 6
        end
		]]
    end,

    --========================--
    --  Target Target
    --========================--
    targettarget = function(self, ...)
        func(self, ...)
		--self:SetHeight(height-4)
	    SpellRange(self)

		--[[
        if auras then 
            local debuffs = CreateFrame("Frame", nil, self)
            debuffs:SetHeight(height+2)
            debuffs:SetWidth(width)
            debuffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
            debuffs.spacing = 4
            debuffs.size = 21.5
            debuffs.initialAnchor = "BOTTOMLEFT"

            debuffs.PostCreateIcon = R.postCreateIconSmall
            debuffs.PostUpdateIcon = R.postUpdateIconSmall
            debuffs.CustomFilter = R.CustomFilter

            self.Debuffs = debuffs
            self.Debuffs.num = 6
        end
		]]
    end,

    --========================--
    --  Boss
    --========================--
    boss = function(self, ...)
        func(self, ...)
		SpellRange(self)
		
		local tpp = createFont(self.Health, "OVERLAY", C["media"].font, C["media"].fontsize, C["media"].fontflag, 1, 1, 1)
        tpp:Point("LEFT", 2, 0)
        tpp.frequentUpdates = true
        self:Tag(tpp, '[freeb:pp]')

        if auras then
            -- local buffs = CreateFrame("Frame", nil, self)
            -- buffs:SetHeight(height)
            -- buffs:SetWidth(170)
            -- buffs.spacing = 5
            -- buffs.num = 18
            -- buffs["growth-x"] = "RIGHT"
            -- buffs["growth-y"] = "DOWN"
			-- buffs.initialAnchor = "RIGHT"
            -- buffs:Point("RIGHT", self, "RIGHT", 30, 0)
            -- buffs.size = height

            -- buffs.PostCreateIcon = R.postCreateIconSmall
            -- buffs.PostUpdateIcon = R.postUpdateIconSmall

            -- self.Buffs = buffs

            local debuffs = CreateFrame("Frame", nil, self)
            debuffs:SetHeight(height)
            debuffs:SetWidth(200)		
            debuffs.spacing = 5
		    debuffs["growth-x"] = "RIGHT"
            debuffs["growth-y"] = "DOWN"
            debuffs.size = height+2
			debuffs.initialAnchor = "BOTTOMLEFT"
            debuffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
            debuffs.onlyShowPlayer = true
            debuffs.PostCreateIcon = R.postCreateIconSmall
            debuffs.PostUpdateIcon = R.postUpdateIconSmall
            debuffs.CustomFilter = R.CustomFilter

            self.Debuffs = debuffs
            self.Debuffs.num = 7
        end
	end,
}

oUF:RegisterStyle("Freeb", func)
for unit,layout in next, UnitSpecific do
    oUF:RegisterStyle('Freeb - ' .. unit:gsub("^%l", string.upper), layout)
end

local spawnHelper = function(self, unit, ...)
    if(UnitSpecific[unit]) then
        self:SetActiveStyle('Freeb - ' .. unit:gsub("^%l", string.upper))
    elseif(UnitSpecific[unit:match('[^%d]+')]) then -- boss1 -> boss
        self:SetActiveStyle('Freeb - ' .. unit:match('[^%d]+'):gsub("^%l", string.upper))
    else
        self:SetActiveStyle'Freeb'
    end

    local object = self:Spawn(unit)
    object:SetPoint(...)
    return object
end

oUF:Factory(function(self)
    local player = spawnHelper(self, "player", "BOTTOM", -300, 450)	
    local target = spawnHelper(self, "target", "BOTTOM", 0, 340)	
    local targettarget = spawnHelper(self, "targettarget", "BOTTOMLEFT", self.units.target, "BOTTOMRIGHT", 10, 1)	
    local focus = spawnHelper(self, "focus", "BOTTOMRIGHT", self.units.player, "TOPLEFT", -20, 36.5)	
    local focustarget = spawnHelper(self, "focustarget", "BOTTOMRIGHT", self.units.focus, "BOTTOMLEFT", -10, 1)
    local pet = spawnHelper(self, "pet", "BOTTOM", 0, 220)
	
	getmetatable(player).__index.UpdateLayout = R.UpdateSingle
	
	self:SetActiveStyle'Freeb - Party'
    local party = self:SpawnHeader('oUF_Party', nil, 
	"custom [@raid6,exists] hide;show",
	-- "custom [group:party,nogroup:raid][@raid,noexists,group:raid] show;hide",
	-- "solo",
	"showParty", true,
	'showPlayer', false,
	-- 'showSolo',true,
	"yOffset", -36.5,
	"groupBy", "CLASS",
    "groupingOrder", "WARRIOR,PALADIN,DEATHKNIGHT,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,ROGUE,HUNTER"	-- Trying to put classes that can tank first
	)
	party:Point("TOPRIGHT", oUF_FreebPlayer, "TOPLEFT", -20, 0)
	party:SetScale(1)

	getmetatable(party).__index.UpdateLayout = R.UpdateHeader
	
    self:SetActiveStyle'Freeb - Arena'
    local arena = {}
	--[[
    for i = 1, 5 do
      arena[i] = self:Spawn("arena"..i, "oUF_Arena"..i)
	  arena[i]:SetScale(0.85)
      if i == 1 then
        arena[i]:Point("RIGHT", UIParent, "RIGHT", -5, -180)
      else
        arena[i]:Point("BOTTOMRIGHT", arena[i-1], "TOPRIGHT", 0, 85)
      end
	  
    end
	]]

    if bossframes then
        for i = 1, MAX_BOSS_FRAMES do
            spawnHelper(self,'boss' .. i, "RIGHT", -80, 200 - (70 * i))
        end
    end
	
end)

SpellRange = function(self)
	if IsAddOnLoaded("oUF_SpellRange") then	
		self.SpellRange = {
		insideAlpha = 1, --范围内的透明度
		outsideAlpha = 0.3}	 --范围外的透明度
	end
end

local testui = TestUI or function() end
local TestUI = function(msg)
	if msg == "a" or msg == "arena" then
		oUF_FreebArena1:Show(); oUF_FreebArena1.Hide = function() end; oUF_FreebArena1.unit = "player"
		oUF_FreebArena2:Show(); oUF_FreebArena2.Hide = function() end; oUF_FreebArena2.unit = "target"
		oUF_FreebArena3:Show(); oUF_FreebArena3.Hide = function() end; oUF_FreebArena3.unit = "player"
		oUF_FreebArena4:Show(); oUF_FreebArena4.Hide = function() end; oUF_FreebArena4.unit = "target"
		oUF_FreebArena5:Show(); oUF_FreebArena5.Hide = function() end; oUF_FreebArena5.unit = "player"
	elseif msg == "boss" or msg == "b" then
		oUF_FreebBoss1:Show(); oUF_FreebBoss1.Hide = function() end; oUF_FreebBoss1.unit = "player"
		oUF_FreebBoss2:Show(); oUF_FreebBoss2.Hide = function() end; oUF_FreebBoss2.unit = "target"
		oUF_FreebBoss3:Show(); oUF_FreebBoss3.Hide = function() end; oUF_FreebBoss3.unit = "player"
	elseif msg == "buffs" then -- better dont test it ^^
		if oUF_FreebPlayer.Buffs then oUF_FreebPlayer.Buffs.CustomFilter = nil end
		if oUF_FreebTarget.Auras then oUF_FreebTarget.Auras.CustomFilter = nil end
		testui()
		UnitAura = function()
			-- name, rank, texture, count, dtype, duration, timeLeft, caster
			return 'penancelol', 'Rank 2', 'Interface\\Icons\\Spell_Holy_Penance', random(5), 'Magic', 0, 0, "player"
		end
		if(oUF) then
			for i, v in pairs(oUF.units) do
				if(v.UNIT_AURA) then
					v:UNIT_AURA("UNIT_AURA", v.unit)
				end
			end
		end
	end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"