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

local PlayerBuffFilter = true
local DebuffOnyshowPlayer = true

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

local function multicheck(check, ...)
    for i=1, select('#', ...) do
        if check == select(i, ...) then return true end
    end
    return false
end

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local backdrop2 = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = -R.mult, left = -R.mult, bottom = -R.mult, right = -R.mult},
}

local frameBD = {
    edgeFile = C["media"].glow, edgeSize = R.Scale(5),
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {left = R.Scale(3), right = R.Scale(3), top = R.Scale(3), bottom = R.Scale(3)}
}

local createBackdrop = function(parent, anchor) 
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("LOW")

    if pixelborder then
        frame:SetAllPoints(anchor)
        frame:SetBackdrop(backdrop2)
    else
        frame:Point("TOPLEFT", anchor, "TOPLEFT", -4, 4)
        frame:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
        frame:SetBackdrop(frameBD)
    end

    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(0, 0, 0)

    return frame
end

local function FocusText(self)
	local focusdummy = CreateFrame("BUTTON", "focusdummy", self, "SecureActionButtonTemplate")
	focusdummy:SetFrameStrata("HIGH")
	focusdummy:SetWidth(50)
	focusdummy:SetHeight(25)
	focusdummy:Point("TOP", self,0,0)
	focusdummy:EnableMouse(true)
	focusdummy:RegisterForClicks("AnyUp")
	focusdummy:SetAttribute("type", "macro")
	focusdummy:SetAttribute("macrotext", "/focus")
	focusdummy:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		}
	})
	focusdummy:SetBackdropColor(.1,.1,.1,0)
	focusdummy:SetBackdropBorderColor(0,0,0,0)

	focusdummytext = focusdummy:CreateFontString(self,"OVERLAY")
	focusdummytext:Point("CENTER", self,0,0)
	focusdummytext:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
	focusdummytext:SetText("焦点")
	focusdummytext:SetVertexColor(1,0.2,0.1,0)

	focusdummy:SetScript("OnLeave", function(self) focusdummytext:SetVertexColor(1,0.2,0.1,0) end)
	focusdummy:SetScript("OnEnter", function(self) focusdummytext:SetTextColor(.6,.6,.6) end)	
end

local function ClearFocusText(self)
	local clearfocus = CreateFrame("BUTTON", "focusdummy", self, "SecureActionButtonTemplate")
	clearfocus:SetFrameStrata("HIGH")
	clearfocus:SetWidth(30)
	clearfocus:SetHeight(20)
	clearfocus:Point("TOP", self,0, 0)
	clearfocus:EnableMouse(true)
	clearfocus:RegisterForClicks("AnyUp")
	clearfocus:SetAttribute("type", "macro")
	clearfocus:SetAttribute("macrotext", "/clearfocus")
	
	clearfocus:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		}
	})
	clearfocus:SetBackdropColor(.1,.1,.1,0)
	clearfocus:SetBackdropBorderColor(0,0,0,0)

	clearfocustext = clearfocus:CreateFontString(self,"OVERLAY")
	clearfocustext:Point("CENTER", self,0,0)
	clearfocustext:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
	clearfocustext:SetText("取消焦点")
	clearfocustext:SetVertexColor(1,0.2,0.1,0)

	clearfocus:SetScript("OnLeave", function(self) clearfocustext:SetVertexColor(1,0.2,0.1,0) end)
	clearfocus:SetScript("OnEnter", function(self) clearfocustext:SetTextColor(.6,.6,.6) end)
end

local formatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	-- return format("%.1f", s), (s * 100 - floor(s * 100))/100
	return format("%d", s), (s * 100 - floor(s * 100))/100
end

local setTimer = function (self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = formatTime(self.timeLeft)
					self.time:SetText(time)
				if self.timeLeft < 5 then
					self.time:SetTextColor(1, 0, 0)
				elseif self.timeLeft<60 then
					self.time:SetTextColor(1, 1, 0)
				else
					self.time:SetTextColor(1, 1, 1)
				end
			else
				self.time:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

local postCreateIcon = function(element, button)
	local unit = button:GetParent():GetParent().unit
	element.disableCooldown = true
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	
	-- local h = CreateFrame("Frame", nil, button)
	-- h:SetFrameLevel(0)
	-- h:Point("TOPLEFT",-2,2)
	-- h:Point("BOTTOMRIGHT",2,-2)
	-- h:CreateShadow()
	button.bg = createBackdrop(button, button)
	local time = button:CreateFontString(nil, "OVERLAY")
	if unit == "focus" then
		time:SetFont(C["media"].font, 16, "OUTLINE")
	else
		time:SetFont(C["media"].font, 22, "OUTLINE")
	end
    time:SetShadowColor(0,0,0,1)
    time:SetShadowOffset(0.5,-0.5)
	local count = button:CreateFontString(nil, "OVERLAY")
	if unit == "focus" then
		count:SetFont(C["media"].font, 12, "OUTLINE")
	else
		count:SetFont(C["media"].font, 18, "OUTLINE")
    end
	count:SetShadowColor(0,0,0,1)
    count:SetShadowOffset(0.5,-0.5)
	time:Point("CENTER", button, "CENTER", 2, 0)
	time:SetJustifyH("CENTER")
	time:SetVertexColor(1,1,1)
	button.time = time
	count:Point("CENTER", button, "BOTTOMRIGHT", 0, 3)
	count:SetJustifyH("RIGHT")
	button.count = count
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer("ARTWORK")
end

local postUpdateIcon = function(element, unit, button, index)
	local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, button.filter)
	
	if duration and duration > 0 then
		button.time:Show()
		button.timeLeft = expirationTime	
		button:SetScript("OnUpdate", setTimer)			
	else
		button.time:Hide()
		button.timeLeft = math.huge
		button:SetScript("OnUpdate", nil)
	end

	if(button.debuff) then
		if(unit == "target") then	
			if (unitCaster == "player" or unitCaster == "vehicle") then
				button.icon:SetDesaturated(false)                 
			elseif(not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don"t desaturate debuffs
				button:SetBackdropColor(0, 0, 0)
				button.overlay:SetVertexColor(0.3, 0.3, 0.3)      
				button.icon:SetDesaturated(true)  
			end
		end
	end
	button:SetScript('OnMouseUp', function(self, mouseButton)
		if mouseButton == 'RightButton' then
			CancelUnitBuff('player', index)
	end end)
	button.first = true
end

local CustomFilter = function(icons, ...)
    local unit, icon, name, _, _, _, _, _, _, caster = ...
	local buffexist, _, _, _, _, _, _, _, isStealable = UnitBuff(unit, name)
	
	if buffexist and not UnitCanAttack("player",unit) then
		return true
	end
	
	--Only Show Stealable
	if buffexist and UnitCanAttack("player",unit) and isStealable then
		return true
	end
	
    if R.DebuffBlackList[name] then
        return false
    end	
	
    local isPlayer

    if multicheck(caster, 'player', 'vechicle', 'pet') then
        isPlayer = true
    end

    if((icons.onlyShowPlayer and isPlayer) or (not icons.onlyShowPlayer and name)) then
        icon.isPlayer = isPlayer
        icon.owner = caster
        return true
    end
	
end

local CustomBuffFilter = function(icons, ...)
    local unit, icon, name, _, _, _, _, _, _, caster = ...
	if R.BuffWhiteList[R.myclass][name] then
		return true
	else
		return false
	end
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

ns.backdrop = createBackdrop

local fixStatusbar = function(bar)
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:GetStatusBarTexture():SetVertTile(false)
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
    string:SetShadowOffset(0.625, -0.625)
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
    button.bg = createBackdrop(button, button)
	
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

    -- if multicheck(caster, 'player', 'vechicle') then
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

	if cur < max then
		if UnitCanAssist("player", unit) then
			if self.__owner.isMouseOver and not unit:match("^party") then
				self.value:SetFormattedText("%s", UnitHealth(unit))
			else
				self.value:SetFormattedText("%s", UnitHealth(unit) - UnitHealthMax(unit))
			end
		elseif self.__owner.isMouseOver then
			self.value:SetFormattedText("%s", UnitHealth(unit))
		else
			self.value:SetFormattedText("%d%%", floor(UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.5))
		end
	elseif self.__owner.isMouseOver then
		self.value:SetFormattedText("%s", UnitHealthMax(unit))
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
			self.value:SetFormattedText("%s - |cff%02x%02x%02x%s|r", UnitPower(unit), color[1] * 255, color[2] * 255, color[3] * 255, UnitPowerMax(unit))
		elseif type == "MANA" then
			self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5))
		elseif cur > 0 then
			self.value:SetFormattedText("|cff%02x%02x%02x%d|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5))
		else
			self.value:SetText(nil)
		end
	elseif type == "MANA" and self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, UnitPowerMax(unit))
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

    self.FrameBackdrop = createBackdrop(self, self)

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
        hp:SetHeight(height*hpheight)
    end

    hp.frequentUpdates = true
    hp.Smooth = false

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

    if not (unit == "targettarget" or unit == "pet" or unit == "focustarget" or unit == "player" or unit == "target") then
        local hpp = createFont(hp, "OVERLAY", C["media"].font, C["media"].fontsize, C["media"].fontflag, 1, 1, 1)
		if (unit=="player" or unit == "focus" or unit == "boss" ) then
		hpp:Point("LEFT", hp, 2, 0)
        self:Tag(hpp, '[freeb:hp]')
		else
        hpp:Point("RIGHT", hp, -2, 0)
        self:Tag(hpp, '[freeb:hp]')
		end
    end

    hp.bg = hpbg
    self.Health = hp

    if not (unit == "pet" or unit == "targettarget" or unit == "focustarget") then
        local pp = createStatusbar(self, C["media"].normal, nil, height*-(hpheight-.95), nil, 1, 1, 1, 1)
        pp:SetPoint"LEFT"
        pp:SetPoint"RIGHT"
        pp:SetPoint"BOTTOM" 

        pp.frequentUpdates = true
        pp.Smooth = false
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
        self.Power = pp
    end

    local altpp = createStatusbar(self, C["media"].normal, nil, 4, nil, 1, 1, 1, .8)
    altpp:Point('TOPLEFT', self, 'BOTTOMLEFT', 0, -2)
    altpp:Point('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -2)
    altpp.bg = altpp:CreateTexture(nil, 'BORDER')
    altpp.bg:SetAllPoints(altpp)
    altpp.bg:SetTexture(C["media"].normal)
    altpp.bg:SetVertexColor( 0,  0.76, 1)
    altpp.bd = createBackdrop(altpp, altpp)

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
            name:Point("BOTTOM", hp,  6, -27)
            name:Point("RIGHT", hp, 0, 0)
            name:SetJustifyH"LEFT"
		 elseif(unit == "focus" ) then
            name:Point("BOTTOM", hp, -4, -27)
            name:Point("LEFT", hp, 0, 0)
			name:SetFont(C["media"].font,14, C["media"].fontflag)
            name:SetJustifyH"RIGHT"		
		elseif( unit == "player" or unit =="party") then
            name:Point("BOTTOM", hp, -4, -27)
            name:Point("LEFT", hp, 0, 0)
            name:SetJustifyH"RIGHT"		
		else
            name:Point("TOP", hp, 0, 20)
            name:Point("LEFT", hp, 0, 0)
            name:SetJustifyH"RIGHT"		
        end

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
		CreateCastBar(self)
		-- BarFader(self)

        if C["ouf"].showPortrait then
            Portrait(self)
        end
				
		-- local ppp = createFont(self.Health, "OVERLAY", font, fontsize, fontflag, 1, 1, 1)
        -- ppp:Point("RIGHT", -2, 0)
        -- ppp.frequentUpdates = true
        -- self:Tag(ppp, '[freeb:pp]')

        local _, class = UnitClass("player")
        -- Runes, Shards, HolyPower
        if multicheck(class, "DEATHKNIGHT", "WARLOCK", "PALADIN") then
            local count
            if class == "DEATHKNIGHT" then 
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

                if class == "WARLOCK" then
                    local color = oUF.colors.class["WARLOCK"]
                    bars[i]:SetStatusBarColor(color[1], color[2], color[3])
                elseif class == "PALADIN" then
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

                bars[i].bd = createBackdrop(bars[i], bars[i])
                i=i-1
            end

            if class == "DEATHKNIGHT" then
                bars[3], bars[4], bars[5], bars[6] = bars[5], bars[6], bars[3], bars[4]
                self.Runes = bars
            elseif class == "WARLOCK" then
                self.SoulShards = bars
            elseif class == "PALADIN" then
                self.HolyPower = bars
            end
        end

        if class == "DRUID" then
            local ebar = CreateFrame("Frame", nil, self)
            ebar:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -8)
            ebar:SetSize(150, 16)
            ebar.bd = createBackdrop(ebar, ebar)

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

        if  class == "SHAMAN" then
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

                self.TotemBar[i].bd = createBackdrop(self, self.TotemBar[i])
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

		-- self.Experience.bd = createBackdrop(self.Experience, self.Experience)

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

            buffs.PostCreateIcon = auraIcon
            buffs.PostUpdateIcon = PostUpdateIcon

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
                self.PostCreateEnchantIcon = auraIcon
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

            debuffs.PostCreateIcon = auraIcon
            debuffs.PostUpdateIcon = PostUpdateIcon
            debuffs.CustomFilter = CustomFilter

            self.Debuffs = debuffs
            self.Debuffs.num = 7
        end
		]]
		if C["ouf"].PlayerBuffFilter then
			b = CreateFrame("Frame", nil, self)
			b.size = 30
			b.num = 14
			b.spacing = 4.8
			if multicheck(class, "DEATHKNIGHT", "WARLOCK", "PALADIN", "SHAMAN") then
				b:Point("BOTTOMRIGHT", self,  "TOPRIGHT", 0, 10)
			else
				b:Point("BOTTOMRIGHT", self,  "TOPRIGHT", 0, 5)
			end
			b.initialAnchor = "BOTTOMRIGHT"
			b["growth-x"] = "LEFT"
			b["growth-y"] = "UP"
			b:SetHeight((b.size+b.spacing)*4)
			b:SetWidth(self:GetWidth())
			b.CustomFilter = CustomBuffFilter
			b.PostCreateIcon = postCreateIcon
			b.PostUpdateIcon = postUpdateIcon

			self.Buffs = b
		end
		
		tinsert(self.mouseovers, self.Health)
		self.Health.PostUpdate = PostUpdateHealth
		
		if self.Power.value then 
			tinsert(self.mouseovers, self.Power)
			self.Power.PostUpdate = PostUpdatePower	
		end
    end,

    --========================--
    --  Target
    --========================--
    target = function(self, ...)
        func(self, ...)
		CreateCastBar(self)
		SpellRange(self)
		FocusText(self)
		
        if C["ouf"].showPortrait then
            Portrait(self)
        end
		
		-- local tpp = createFont(self.Health, "OVERLAY", font, fontsize, fontflag, 1, 1, 1)
        -- tpp:Point("LEFT", 2, 0)
        -- tpp.frequentUpdates = true
        -- self:Tag(tpp, '[freeb:pp]')

        if auras and not C["ouf"].DebuffOnyshowPlayer then
            local buffs = CreateFrame("Frame", nil, self)
            buffs:SetHeight(height)
            buffs:SetWidth(245)
            buffs.initialAnchor = "BOTTOMLEFT"
            buffs.spacing = 5
            buffs.num = 9
            buffs["growth-x"] = "RIGHT"
            buffs["growth-y"] = "DOWN"
            buffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, 50)
            buffs.size = height

            buffs.PostCreateIcon = auraIcon
            buffs.PostUpdateIcon = PostUpdateIcon

            self.Buffs = buffs

            local debuffs = CreateFrame("Frame", nil, self)
            debuffs:SetHeight(height+1)
            debuffs:SetWidth(140)
            debuffs:Point("LEFT", self, "RIGHT", 5, 0)
            debuffs.spacing = 4
			debuffs["growth-x"] = "RIGHT"
            debuffs["growth-y"] = "DOWN"
            debuffs.size = height
            debuffs.initialAnchor = "TOPLEFT"
            debuffs.onlyShowPlayer = onlyShowPlayer

            debuffs.PostCreateIcon = auraIcon
            debuffs.PostUpdateIcon = PostUpdateIcon
            debuffs.CustomFilter = CustomFilter

            self.Debuffs = debuffs
            self.Debuffs.num = 18

            local Auras = CreateFrame("Frame", nil, self)
            Auras:SetHeight(height+2)
            Auras:SetWidth(width)
            Auras:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
            Auras.spacing = 4
            Auras.gap = true
            Auras.size = height+2
            Auras.initialAnchor = "BOTTOMLEFT"

            Auras.PostCreateIcon = auraIcon
            Auras.PostUpdateIcon = PostUpdateIcon
            Auras.CustomFilter = CustomFilter

            --self.Auras = Auras
            --self.Auras.numDebuffs = 14
            --self.Auras.numBuffs = 14
        end
		
		if C["ouf"].DebuffOnyshowPlayer then 
			Auras = CreateFrame("Frame", nil, self)
			Auras:SetHeight(42)
			Auras:SetWidth(self:GetWidth())
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"		
			Auras["growth-y"] = "DOWN"
			Auras.numBuffs = 24
			Auras.numDebuffs = 10
			Auras.size = 18
			Auras.spacing = 4.8
			Auras["growth-y"] = "UP"
			Auras.size = 30
			Auras.onlyShowPlayer = true
			Auras.CustomFilter = CustomFilter			
			Auras:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
			Auras.gap = true
			Auras.PostCreateIcon = postCreateIcon
			Auras.PostUpdateIcon = postUpdateIcon
			self.Auras = Auras
		end
	
        local cpoints = createFont(self, "OVERLAY", C["media"].font, 24, "THINOUTLINE", 1, 0, 0)
        cpoints:Point('RIGHT', self, 'LEFT', -4, 0)
        self:Tag(cpoints, '[cpoints]')
		
		tinsert(self.mouseovers, self.Health)
		self.Health.PostUpdate = PostUpdateHealth
		
		if self.Power.value then 
			tinsert(self.mouseovers, self.Power)
			self.Power.PostUpdate = PostUpdatePower	
		end
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

            debuffs.PostCreateIcon = auraIcon
            debuffs.PostUpdateIcon = PostUpdateIcon

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

            debuffs.PostCreateIcon = auraIcon
            debuffs.PostUpdateIcon = PostUpdateIcon

            self.Debuffs = debuffs
            self.Debuffs.num = 7
        end
    end,

	--========================--
    --  Focus
    --========================--
    focus = function(self, ...)
        func(self, ...)
		CreateCastBar(self)
	    SpellRange(self)
		ClearFocusText(self)
	    self:SetWidth(width-40)
--[[
        if C["ouf"].showPortrait then
            Portrait(self)
        end
		]]
		local tpp = createFont(self.Health, "OVERLAY", C["media"].font, C["media"].fontsize, C["media"].fontflag, 1, 1, 1)
        tpp:Point("RIGHT", -2, 0)
        tpp.frequentUpdates = true
        self:Tag(tpp, '[freeb:pp]')

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
			
            -- buffs.PostCreateIcon = auraIcon
            -- buffs.PostUpdateIcon = PostUpdateIcon
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
            -- debuffs.PostCreateIcon = auraIcon
            -- debuffs.PostUpdateIcon = PostUpdateIcon
			debuffs.PostCreateIcon = postCreateIcon
			debuffs.PostUpdateIcon = postUpdateIcon

            self.Debuffs = debuffs
            self.Debuffs.num = 14
        end
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

            debuffs.PostCreateIcon = auraIcon
            debuffs.PostUpdateIcon = PostUpdateIcon
            debuffs.CustomFilter = CustomFilter

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

            debuffs.PostCreateIcon = auraIcon
            debuffs.PostUpdateIcon = PostUpdateIcon
            debuffs.CustomFilter = CustomFilter

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

            -- buffs.PostCreateIcon = auraIcon
            -- buffs.PostUpdateIcon = PostUpdateIcon

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
            debuffs.PostCreateIcon = auraIcon
            debuffs.PostUpdateIcon = PostUpdateIcon
            debuffs.CustomFilter = CustomFilter

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
    spawnHelper(self, "player", "BOTTOM", -300, 450)
    spawnHelper(self, "target", "BOTTOM", 0, 340)
    spawnHelper(self, "targettarget", "BOTTOMLEFT", self.units.target, "BOTTOMRIGHT", 10, 1)
    spawnHelper(self, "focus", "BOTTOMRIGHT", self.units.player, "TOPLEFT", -20, 36.5)
    spawnHelper(self, "focustarget", "BOTTOMRIGHT", self.units.focus, "BOTTOMLEFT", -10, 1)
    spawnHelper(self, "pet", "BOTTOM", 0, 220)
	
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
            spawnHelper(self,'boss' .. i, "RIGHT", -5, 200 - (70 * i))
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
TestUI = function(msg)
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
		if C["ouf"].PlayerBuffFilter then oUF_FreebPlayer.Buffs.CustomFilter = nil end
		if C["ouf"].DebuffOnyshowPlayer then oUF_FreebTarget.Auras.CustomFilter = nil end
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