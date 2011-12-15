local R, C, L, DB = unpack(select(2, ...))
local _, ns = ...
local oUF = RayUF or ns.oUF or oUF

R.Layouts = {}

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

function R.CreateBackdrop(parent, anchor) 
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetFrameLevel(0)

	frame:Point("TOPLEFT", anchor, "TOPLEFT", -4, 4)
	frame:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
	frame:SetBackdrop({
		edgeFile = C["media"].glow, edgeSize = R.Scale(5),
		bgFile = C["media"].blank,
		insets = {left = R.Scale(3), right = R.Scale(3), top = R.Scale(3), bottom = R.Scale(3)}
	})

    frame:SetBackdropColor(0.1, 0.1, 0.1)
    frame:SetBackdropBorderColor(0, 0, 0)

    return frame
end

function R.SpawnMenu(self)
	local unit = self.unit:gsub("(.)", string.upper, 1)
	if self.unit == "targettarget" then return end
	if _G[unit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
	elseif (self.unit:match("party")) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

function R.ContructHealthBar(self, bg, text)
	local health = CreateFrame('StatusBar', nil, self)
	health:SetStatusBarTexture(C["media"].normal)
	health:SetFrameStrata("LOW")
	health.frequentUpdates = 0.2
	health.PostUpdate = R.PostUpdateHealth
	
	if C["uf"].smooth == true then
		health.Smooth = true
	end	
	
	if bg then
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints()
		health.bg:SetTexture(C["media"].normal)
		if C["uf"].smoothColor then
			health.bg:SetVertexColor(0.12, 0.12, 0.12, 1)
		else
			health.bg:SetVertexColor(0.33, 0.33, 0.33, 1)
		end
		health.bg.multiplier = .2
	end
	
	if text then
		health.value = health:CreateFontString(nil, "OVERLAY")
		health.value:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
		health.value:SetJustifyH("LEFT")
		health.value:SetParent(health)
	end
	
	if C["uf"].healthColorClass ~= true then
		health:SetStatusBarColor(.1, .1, .1)
	else
		health.colorTapping = true	
		health.colorClass = true
		health.colorReaction = true
	end
	health.colorDisconnected = true	
	
	return health
end

function R.ConstructPowerBar(self, bg, text)
	local power = CreateFrame('StatusBar', nil, self)
	power:SetStatusBarTexture(C["media"].normal)
	power.frequentUpdates = 0.2
	power:SetFrameStrata("LOW")
	power.PostUpdate = R.PostUpdatePower
	
	if C["uf"].smooth == true then
		power.Smooth = true
	end	
	
	if bg then
		power.bg = power:CreateTexture(nil, 'BORDER')
		power.bg:SetAllPoints()
		power.bg:SetTexture(C["media"].blank)
		power.bg.multiplier = 0.2
	end
	
	if text then
		power.value = power:CreateFontString(nil, "OVERLAY")
		power.value:SetFont(C["media"].font, C["media"].fontsize, C["media"].fontflag)
		power.value:SetJustifyH("LEFT")
		power.value:SetParent(power)
	end
	
	if C["uf"].powerColorClass == true then
		power.colorClass = true
		power.colorReaction = true
	else
		power.colorPower = true
	end
	
	power.colorDisconnected = true
	power.colorTapping = false

	return power
end

function R.ConstructCastBar(self)
	local castbar = CreateFrame("StatusBar", nil, self)
	castbar:SetStatusBarTexture(C["media"].normal)
	castbar:GetStatusBarTexture():SetDrawLayer("BORDER")
	castbar:GetStatusBarTexture():SetHorizTile(false)
	castbar:GetStatusBarTexture():SetVertTile(false)
	castbar:SetFrameStrata("HIGH")
	castbar:SetHeight(4)
	
	local spark = castbar:CreateTexture(nil, "OVERLAY")
	spark:SetDrawLayer("OVERLAY", 7)
	spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
	spark:SetBlendMode("ADD")
	spark:SetAlpha(.8)
	spark:Point("TOPLEFT", castbar:GetStatusBarTexture(), "TOPRIGHT", -10, 13)
	spark:Point("BOTTOMRIGHT", castbar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -13)
	castbar.Spark = spark

	castbar.shadow = R.CreateBackdrop(castbar, castbar)
	castbar.bg = castbar:CreateTexture(nil, "BACKGROUND")
	castbar.bg:SetTexture(C["media"].normal)
	castbar.bg:SetAllPoints(true)
	castbar.bg:SetVertexColor(.12,.12,.12)
	castbar.Text = castbar:CreateFontString(nil, "OVERLAY")
	castbar.Text:SetFont(C.media.font, 12, "THINOUTLINE")
	castbar.Text:SetPoint("BOTTOMLEFT", castbar, "TOPLEFT", 5, -2)
	castbar.Time = castbar:CreateFontString(nil, "OVERLAY")
	castbar.Time:SetFont(C.media.font, 12, "THINOUTLINE")
	castbar.Time:SetJustifyH("RIGHT")
	castbar.Time:SetPoint("BOTTOMRIGHT", castbar, "TOPRIGHT", -5, -2)
	castbar.Iconbg = CreateFrame("Frame", nil ,castbar)
	castbar.Iconbg:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMLEFT", -5, 0)
	castbar.Iconbg:SetSize(21, 21)
	R.CreateBackdrop(castbar.Iconbg, castbar.Iconbg)
	castbar.Icon = castbar:CreateTexture(nil, "OVERLAY")
	castbar.Icon:SetAllPoints(castbar.Iconbg)
	castbar.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	if self.unit == "player" then
		castbar.SafeZone = castbar:CreateTexture(nil, "OVERLAY")
		castbar.SafeZone:SetDrawLayer("OVERLAY", 5)
		castbar.SafeZone:SetTexture(C["media"].normal)
		castbar.SafeZone:SetVertexColor(1, 0, 0, 0.75)
	end
	castbar.PostCastStart = R.PostCastStart
	castbar.PostChannelStart = R.PostCastStart
	castbar.CustomTimeText = R.CustomCastTimeText
	castbar.CustomDelayText = R.CustomCastDelayText
	castbar.PostCastInterruptible = R.PostCastInterruptible
	castbar.PostCastNotInterruptible = R.PostCastNotInterruptible
	castbar.PostCastFailed = R.PostCastFailed
    castbar.PostCastInterrupted = R.PostCastFailed

	castbar.OnUpdate = R.OnCastbarUpdate

	return castbar
end

function R.PostCastStart(self, unit, name, rank, castid)
	if unit == "vehicle" then unit = "player" end
	local r, g, b
	if UnitIsPlayer(unit) and UnitIsFriend(unit, "player") and R.myname == "夏可" then
		r, g, b = 95/255, 182/255, 255/255
	elseif UnitIsPlayer(unit) and UnitIsFriend(unit, "player") then
		r, g, b = unpack(oUF.colors.class[select(2, UnitClass(unit))])
	elseif self.interrupt then
		r, g, b = unpack(oUF.colors.reaction[1])
	else
		r, g, b = unpack(oUF.colors.reaction[5])
	end
	self:SetBackdropColor(r * 1, g * 1, b * 1)
	if unit:find("arena%d") or unit:find("boss%d") then
		self:SetStatusBarColor(r * 1, g * 1, b * 1, .2)
	else
		self:SetStatusBarColor(r * 1, g * 1, b * 1)
	end
end

function R.CustomCastTimeText(self, duration)
	self.Time:SetText(("%.1f | %.1f"):format(self.channeling and duration or self.max - duration, self.max))
end

function R.CustomCastDelayText(self, duration)
	self.Time:SetText(("%.1f |cffff0000%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
end

function R.PostCastInterruptible(self, unit)
	if unit == "vehicle" then unit = "player" end
	if unit ~= "player" then
		local r, g, b
		if UnitIsPlayer(unit) and UnitIsFriend(unit, "player") and R.myname == "夏可" then
			r, g, b = 95/255, 182/255, 255/255
		elseif UnitIsPlayer(unit) and UnitIsFriend(unit, "player") then
			r, g, b = unpack(oUF.colors.class[select(2, UnitClass(unit))])
		else
			r, g, b = unpack(oUF.colors.reaction[1])
		end
		self:SetBackdropColor(r * 1, g * 1, b * 1)
		if unit:find("arena%d") or unit:find("boss%d") then
			self:SetStatusBarColor(r * 1, g * 1, b * 1, .2)
		else
			self:SetStatusBarColor(r * 1, g * 1, b * 1)
		end
	end
end

function R.PostCastNotInterruptible(self, unit)
	local r, g, b
	if UnitIsPlayer(unit) and UnitIsFriend(unit, "player") and R.myname == "夏可" then
		r, g, b = 95/255, 182/255, 255/255
	elseif UnitIsPlayer(unit) and UnitIsFriend(unit, "player") then
		r, g, b = unpack(oUF.colors.class[select(2, UnitClass(unit))])
	else
		r, g, b = unpack(oUF.colors.reaction[5])
	end
	self:SetBackdropColor(r * 1, g * 1, b * 1)
	if unit:find("arena%d") or unit:find("boss%d") then
		self:SetStatusBarColor(r * 1, g * 1, b * 1, .2)
	else
		self:SetStatusBarColor(r * 1, g * 1, b * 1)
	end
end

function R.PostCastFailed(self, event, unit, name, rank, castid)
	self:SetStatusBarColor(unpack(oUF.colors.reaction[1]))
	self:SetValue(self.max)
	self:Show()
end

function R.OnCastbarUpdate(self, elapsed)
	if(self.casting) then
		self.Spark:Show()
		self:SetAlpha(1)
		local duration = self.duration + elapsed
		if(duration >= self.max) then
			self.casting = nil
			self:Hide()

			if(self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
			return
		end

		if(self.SafeZone) then
			local width = self:GetWidth()
			local _, _, _, ms = GetNetStats()
			local safeZonePercent = (width / self.max) * (ms / 1e5)
			if(safeZonePercent > 1) then safeZonePercent = 1 end
			self.SafeZone:SetWidth(width * safeZonePercent)
			self.SafeZone:Show()
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText("%.1f", duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)

		if(self.Spark) then
			self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
			self.Spark:Show()
		end
	elseif(self.channeling) then
		self:SetAlpha(1)
		local duration = self.duration - elapsed

		if(duration <= 0) then
			self.channeling = nil
			self:Hide()

			if(self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
			return
		end

		if(self.SafeZone) then
			local width = self:GetWidth()
			local _, _, _, ms = GetNetStats()
			local safeZonePercent = (width / self.max) * (ms / 1e5)
			if(safeZonePercent > 1) then safeZonePercent = 1 end
			self.SafeZone:SetWidth(width * safeZonePercent)
			self.SafeZone:Show()
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText("%.1f", duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)
		if(self.Spark) then
			self.Spark:Show()
			self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
		end	
	else
		if(self.SafeZone) then
			self.SafeZone:Hide()
		end
		if(self.Spark) then
			self.Spark:Hide()
		end
		local alpha = self:GetAlpha() - 0.02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self:Hide()
		end
		if(self.Time) then
			self.Time:SetText(INTERRUPT)
		end
	end
end

function R.PostUpdateHealth(self, unit, cur, max)
	local curhealth, maxhealth = UnitHealth(unit), UnitHealthMax(unit)
	local r, g, b
	if C["uf"].smoothColor then
		r,g,b = ColorGradient(curhealth/maxhealth)
	else
		r,g,b = .12, .12, .12
	end
	if not C["uf"].healthColorClass then
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
	if not C["uf"].healthColorClass then
		if C["uf"].smoothColor then
			if UnitIsDeadOrGhost(unit) or (not UnitIsConnected(unit)) then
				self:SetStatusBarColor(0.5, 0.5, 0.5, 1)
				self.bg:SetVertexColor(0.5, 0.5, 0.5, 1)
			else
				self.bg:SetVertexColor(0.12, 0.12, 0.12, 1)
			end
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

function R.PostUpdatePower(self, unit, cur, max)
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

function R.UpdateThreatStatus(self, event, unit)
	if (self.unit ~= unit) then return end
	local s = UnitThreatSituation(unit)
	if s and s > 1 then
		local r, g, b = GetThreatStatusColor(s)
		self.ThreatHlt:Show()
		self.ThreatHlt:SetVertexColor(r, g, b, 0.5)
	else
		self.ThreatHlt:Hide()
	end
end

function R.PostAltUpdate(altpp, min, cur, max)
    local self = altpp.__owner

    local tPath, r, g, b = UnitAlternatePowerTextureInfo(self.unit, 2)

    if(r) then
        altpp:SetStatusBarColor(r, g, b, 1)
    else
        altpp:SetStatusBarColor(1, 1, 1, .8)
    end 
end

function R.UpdateEclipse(element, unit)
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

function R.ComboDisplay(self, event, unit)
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
		elseif C["uf"].separateEnergy then
			cpoints[i]:SetAlpha(0)
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

local  function formatTime(s)
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

local function CreateAuraTimer(self,elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed

    if self.elapsed < .2 then return end
    self.elapsed = 0

    local timeLeft = self.expires - GetTime()
    if timeLeft <= 0 then
        return
    else
        self.remaining:SetText(formatTime(timeLeft))
    end
end

function R.PostUpdateIcon(icons, unit, icon, index, offset)
	local name, _, _, _, dtype, duration, expirationTime, unitCaster, isStealable = UnitAura(unit, index, icon.filter)

	local texture = icon.icon
	if icon.debuff then
		if icon.owner == "player" or icon.owner == "pet" or icon.owner == "vehicle" or UnitIsFriend('player', unit) then
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			icon.border:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			icon.border:Show()
			texture:Point("TOPLEFT", icon, 1, -1)
			texture:Point("BOTTOMRIGHT", icon, -1, 1)
			texture:SetDesaturated(false)
		else
			icon.border:SetBackdropBorderColor(unpack(C["media"].bordercolor))
			icon.border:Hide()
			texture:Point("TOPLEFT", icon)
			texture:Point("BOTTOMRIGHT", icon)
			texture:SetDesaturated(true)
		end
	else
		if (isStealable or ((R.myclass == "PRIEST" or R.myclass == "SHAMAN" or R.myclass == "MAGE") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
			icon.border:SetBackdropBorderColor(237/255, 234/255, 142/255)
			icon.border:Show()
			texture:Point("TOPLEFT", icon, 1, -1)
			texture:Point("BOTTOMRIGHT", icon, -1, 1)
		else
			icon.border:SetBackdropBorderColor(unpack(C["media"].bordercolor))
			icon.border:Hide()
			texture:Point("TOPLEFT", icon)
			texture:Point("BOTTOMRIGHT", icon)
		end
	end

	if duration and duration > 0 then
		icon.remaining:Show()
	else
		icon.remaining:Hide()
	end
	
	icon.duration = duration
	icon.expires = expirationTime
	icon:SetScript("OnUpdate", CreateAuraTimer)
end

function R.PostCreateIcon(auras, button)
	button:SetFrameStrata("BACKGROUND")
	local count = button.count
	count:ClearAllPoints()
	count:Point("CENTER", button, "BOTTOMRIGHT", 0, 5)
	count:SetFontObject(nil)
	count:SetFont(C["media"].font, 13, "THINOUTLINE")
	count:SetTextColor(.8, .8, .8)

	auras.disableCooldown = true
	button.icon:SetTexCoord(.1, .9, .1, .9)
	button.border = CreateFrame("Frame", nil, button)
	button.border:Point("TOPLEFT", -1, 1)
	button.border:Point("BOTTOMRIGHT", 1, -1)
	button.border:CreateBorder()
	button.border:SetFrameLevel(1)
	button:CreateShadow("Default", 2)
	button.shadow:SetFrameLevel(0)
	button.shadow:SetBackdropColor(0, 0, 0)
	button.overlay:Hide()

	button.remaining = button:CreateFontString(nil, "OVERLAY")
	button.remaining:SetFont(C["media"].font, 13, C["media"].fontflag)
	button.remaining:SetJustifyH("LEFT")
	button.remaining:SetTextColor(0.99, 0.99, 0.99)
	button.remaining:Point("CENTER", 0, 0)
	
	button:StyleButton()
	button:SetPushedTexture(nil)
	button:GetHighlightTexture():SetAllPoints()
end

function R.CustomFilter(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
	local isPlayer

	if(caster == 'player' or caster == 'vehicle') then
		isPlayer = true
	end

	if name then
		icon.isPlayer = isPlayer
		icon.owner = caster
	end
	
	if UnitCanAttack(unit, "player") and UnitLevel(unit) == -1 then
		if (R.Role == "Melee" and name and R.PvEMeleeBossDebuffs[name]) or 
			(R.Role == "Caster" and name and R.PvECasterBossDebuffs[name]) or
			(R.Role == "Tank" and name and R.PvETankBossDebuffs[name]) or
			isPlayer then
			return true
		else
			return false
		end
	end
	
	return true
end

function R.FocusText(self)
	local focusdummy = CreateFrame("BUTTON", "focusdummy", self, "SecureActionButtonTemplate")
	focusdummy:SetFrameStrata("HIGH")
	focusdummy:SetWidth(25)
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
	focusdummytext:SetText(L["焦点"])
	focusdummytext:SetVertexColor(1,0.2,0.1,0)

	focusdummy:SetScript("OnLeave", function(self) focusdummytext:SetVertexColor(1,0.2,0.1,0) end)
	focusdummy:SetScript("OnEnter", function(self) focusdummytext:SetTextColor(.6,.6,.6) end)	
end

function R.ClearFocusText(self)
	local clearfocus = CreateFrame("BUTTON", "focusdummy", self, "SecureActionButtonTemplate")
	clearfocus:SetFrameStrata("HIGH")
	clearfocus:SetWidth(25)
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
	clearfocustext:SetText(L["取消焦点"])
	clearfocustext:SetVertexColor(1,0.2,0.1,0)

	clearfocus:SetScript("OnLeave", function(self) clearfocustext:SetVertexColor(1,0.2,0.1,0) end)
	clearfocus:SetScript("OnEnter", function(self) clearfocustext:SetTextColor(.6,.6,.6) end)
end

local testuf = TestUF or function() end
local function TestUF(msg)
	if msg == "a" or msg == "arena" then
		RayUFArena1:Show(); RayUFArena1.Hide = function() end; RayUFArena1.unit = "player"
		RayUFArena2:Show(); RayUFArena2.Hide = function() end; RayUFArena2.unit = "target"
		RayUFArena3:Show(); RayUFArena3.Hide = function() end; RayUFArena3.unit = "player"
		RayUFArena4:Show(); RayUFArena4.Hide = function() end; RayUFArena4.unit = "target"
		RayUFArena5:Show(); RayUFArena5.Hide = function() end; RayUFArena5.unit = "player"
	elseif msg == "boss" or msg == "b" then
		RayUFBoss1:Show(); RayUFBoss1.Hide = function() end; RayUFBoss1.unit = "player"
		RayUFBoss2:Show(); RayUFBoss2.Hide = function() end; RayUFBoss2.unit = "target"
		RayUFBoss3:Show(); RayUFBoss3.Hide = function() end; RayUFBoss3.unit = "target"
		RayUFBoss4:Show(); RayUFBoss4.Hide = function() end; RayUFBoss4.unit = "player"
	elseif msg == "buffs" then
		if RayUF_player.Buffs then RayUF_player.Buffs.CustomFilter = nil end
		if RayUF_target.Auras then RayUF_target.Auras.CustomFilter = nil end
		testuf()
		UnitAura = function()
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
SlashCmdList.TestUF = TestUF
SLASH_TestUF1 = "/testuf"