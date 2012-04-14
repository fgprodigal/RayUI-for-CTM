local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local UF = R:GetModule("UnitFrames")
local oUF = RayUF or oUF

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

function UF:CreateBackdrop(parent, anchor) 
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameStrata("BACKGROUND")
    frame:SetFrameLevel(0)

	frame:Point("TOPLEFT", anchor, "TOPLEFT", -4, 4)
	frame:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
	frame:SetBackdrop({
		edgeFile = R["media"].glow, edgeSize = R:Scale(5),
		bgFile = R["media"].blank,
		insets = {left = R:Scale(3), right = R:Scale(3), top = R:Scale(3), bottom = R:Scale(3)}
	})

    frame:SetBackdropColor(0.1, 0.1, 0.1)
    frame:SetBackdropBorderColor(0, 0, 0)

    return frame
end

function UF:SpawnMenu()
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

function UF:ContructHealthBar(frame, bg, text)
	local health = CreateFrame('StatusBar', nil, frame)
	health:SetStatusBarTexture(R["media"].normal)
	health:SetFrameStrata("LOW")
	health.frequentUpdates = true
	health.PostUpdate = UF.PostUpdateHealth

	if self.db.smooth == true then
		health.Smooth = true
	end	
	
	if bg then
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints()
		health.bg:SetTexture(R["media"].normal)
		if self.db.smoothColor then
			health.bg:SetVertexColor(0.12, 0.12, 0.12, 1)
		else
			health.bg:SetVertexColor(0.33, 0.33, 0.33, 1)
		end
		health.bg.multiplier = .2
	end
	
	if text then
		health.value = frame.textframe:CreateFontString(nil, "OVERLAY")
		health.value:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
		health.value:SetJustifyH("LEFT")
		health.value:SetParent(frame.textframe)
	end
	
	if self.db.healthColorClass ~= true then
		health:SetStatusBarColor(.1, .1, .1)
	else
		health.colorTapping = true	
		health.colorClass = true
		health.colorReaction = true
	end
	health.colorDisconnected = true	
	
	return health
end

function UF:ConstructPowerBar(frame, bg, text)
	local power = CreateFrame('StatusBar', nil, frame)
	power:SetStatusBarTexture(R["media"].normal)
	power.frequentUpdates = true
	power:SetFrameStrata("LOW")
	power.PostUpdate = self.PostUpdatePower
	
	if self.db.smooth == true then
		power.Smooth = true
	end	
	
	if bg then
		power.bg = power:CreateTexture(nil, 'BORDER')
		power.bg:SetAllPoints()
		power.bg:SetTexture(R["media"].blank)
		power.bg.multiplier = 0.2
	end
	
	if text then
		local textframe = CreateFrame("Frame", nil, power)
		textframe:SetAllPoints(frame)
		textframe:SetFrameStrata(frame:GetFrameStrata())
		textframe:SetFrameLevel(frame:GetFrameLevel()+5)

		power.value = textframe:CreateFontString(nil, "OVERLAY")
		power.value:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
		power.value:SetJustifyH("LEFT")
		power.value:SetParent(textframe)
	end
	
	if self.db.powerColorClass == true then
		power.colorClass = true
		power.colorReaction = true
	else
		power.colorPower = true
	end
	
	power.colorDisconnected = true
	power.colorTapping = false

	return power
end

function UF:ConstructPortrait(frame)
	local portrait = CreateFrame("PlayerModel", nil, frame)
	portrait:SetFrameStrata("LOW")
	portrait:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
	portrait:SetPoint("TOPLEFT", frame.Health, "TOPLEFT", 0, 0)
	portrait:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", 0, 0)
	portrait.PostUpdate = function(frame)
		frame:SetAlpha(.2)
		if frame:GetModel() and frame:GetModel().find and frame:GetModel():find("worgenmale") then
			frame:SetCamera(1)
		end
		frame:SetCamDistanceScale(1 - 0.01) --Blizzard bug fix
		frame:SetCamDistanceScale(1)
	end
	
	portrait.overlay = CreateFrame("Frame", nil, frame)
	portrait.overlay:SetFrameLevel(frame:GetFrameLevel() - 5)
	
	frame.Health.bg:ClearAllPoints()
	frame.Health.bg:Point('BOTTOMLEFT', frame.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
	frame.Health.bg:Point('TOPRIGHT', frame.Health)
	frame.Health.bg:SetParent(portrait.overlay)
	
	return portrait
end

function UF:ConstructCastBar(frame)
	local castbar = CreateFrame("StatusBar", nil, frame)
	castbar:SetStatusBarTexture(R["media"].normal)
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

	castbar.shadow = UF:CreateBackdrop(castbar, castbar)
	castbar.bg = castbar:CreateTexture(nil, "BACKGROUND")
	castbar.bg:SetTexture(R["media"].normal)
	castbar.bg:SetAllPoints(true)
	castbar.bg:SetVertexColor(.12,.12,.12)
	castbar.Text = castbar:CreateFontString(nil, "OVERLAY")
	castbar.Text:SetFont(R["media"].font, 12, "THINOUTLINE")
	castbar.Text:SetPoint("BOTTOMLEFT", castbar, "TOPLEFT", 5, -2)
	castbar.Time = castbar:CreateFontString(nil, "OVERLAY")
	castbar.Time:SetFont(R["media"].font, 12, "THINOUTLINE")
	castbar.Time:SetJustifyH("RIGHT")
	castbar.Time:SetPoint("BOTTOMRIGHT", castbar, "TOPRIGHT", -5, -2)
	castbar.Iconbg = CreateFrame("Frame", nil ,castbar)
	castbar.Iconbg:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMLEFT", -5, 0)
	castbar.Iconbg:SetSize(21, 21)
	UF:CreateBackdrop(castbar.Iconbg, castbar.Iconbg)
	castbar.Icon = castbar:CreateTexture(nil, "OVERLAY")
	castbar.Icon:SetAllPoints(castbar.Iconbg)
	castbar.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	if frame.unit == "player" then
		castbar.SafeZone = castbar:CreateTexture(nil, "OVERLAY")
		castbar.SafeZone:SetDrawLayer("OVERLAY", 5)
		castbar.SafeZone:SetTexture(R["media"].normal)
		castbar.SafeZone:SetVertexColor(1, 0, 0, 0.75)
	end
	castbar.PostCastStart = UF.PostCastStart
	castbar.PostChannelStart = UF.PostCastStart
	castbar.CustomTimeText = UF.CustomCastTimeText
	castbar.CustomDelayText = UF.CustomCastDelayText
	castbar.PostCastInterruptible = UF.PostCastInterruptible
	castbar.PostCastNotInterruptible = UF.PostCastNotInterruptible
	castbar.PostCastFailed = UF.PostCastFailed
    castbar.PostCastInterrupted = UF.PostCastFailed

	castbar.OnUpdate = UF.OnCastbarUpdate

	return castbar
end

function UF:ConstructThreatBar()
	local aggroColors = {
		[1] = {0, 1, 0},
		[2] = {1, 1, 0},
		[3] = {1, 0, 0},
	}
	-- create the bar
	local RayUIThreatBar = CreateFrame("StatusBar", "RayUIThreatBar", RayUIBottomInfoBar)
	RayUIThreatBar:SetAllPoints(RayUIBottomInfoBar)
	RayUIThreatBar:SetFrameStrata("BACKGROUND")
	RayUIThreatBar:SetFrameLevel(1)

	RayUIThreatBar:SetStatusBarTexture(R["media"].normal)
	RayUIThreatBar:GetStatusBarTexture():SetHorizTile(false)
	RayUIThreatBar:SetMinMaxValues(0, 100)

	RayUIThreatBar.text = RayUIThreatBar:CreateFontString(nil, "OVERLAY")
	RayUIThreatBar.text:SetFont(R["media"].font, R["media"].fontsize, 'THINOUTLINE')
	RayUIThreatBar.text:SetPoint("CENTER", 0, -4)
	RayUIThreatBar.text:SetShadowOffset(R.mult, -R.mult)
	RayUIThreatBar.text:SetShadowColor(0, 0, 0)

	-- event func
	local function OnEvent(self, event, ...)
		local party = GetNumPartyMembers()
		local raid = GetNumRaidMembers()
		local pet = select(1, HasPetUI())
		
		if event == "PLAYER_ENTERING_WORLD" then
			self:Hide()
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		elseif event == "PLAYER_REGEN_ENABLED" then
			self:Hide()
		elseif event == "PLAYER_REGEN_DISABLED" then
			-- look if we have a pet, party or raid active
			-- having threat bar solo is totally useless
			if party > 0 or raid > 0 or pet == 1 then
				self:Show()
			else
				self:Hide()
			end
		else
			-- update when pet, party or raid change.
			if (InCombatLockdown()) and (party > 0 or raid > 0 or pet == 1) then
				self:Show()
			else
				self:Hide()
			end
		end
	end

	-- update status bar func
	local function OnUpdate(self, event, unit)
		if UnitAffectingCombat(self.unit) then
			local _, _, threatpct, rawthreatpct, _ = UnitDetailedThreatSituation(self.unit, self.tar)
			local threatval = threatpct or 0
			
			self:SetValue(threatval)
			self.text:SetFormattedText("%s%3.1f%%", L["当前仇恨"]..": ", threatval)
			
			if R.Role ~= "Tank" then
				if( threatval < 30 ) then
					self:SetStatusBarColor(unpack(self.Colors[1]))
				elseif( threatval >= 30 and threatval < 70 ) then
					self:SetStatusBarColor(unpack(self.Colors[2]))
				else
					self:SetStatusBarColor(unpack(self.Colors[3]))
				end
			else
				if( threatval < 30 ) then
					self:SetStatusBarColor(unpack(self.Colors[3]))
				elseif( threatval >= 30 and threatval < 70 ) then
					self:SetStatusBarColor(unpack(self.Colors[2]))
				else
					self:SetStatusBarColor(unpack(self.Colors[1]))
				end		
			end
					
			if threatval > 0 then
				self:SetAlpha(1)
			else
				self:SetAlpha(0)
			end		
		end
	end

	-- event handling
	RayUIThreatBar:RegisterEvent("PLAYER_ENTERING_WORLD")
	RayUIThreatBar:RegisterEvent("PLAYER_REGEN_ENABLED")
	RayUIThreatBar:RegisterEvent("PLAYER_REGEN_DISABLED")
	RayUIThreatBar:SetScript("OnEvent", OnEvent)
	RayUIThreatBar:SetScript("OnUpdate", OnUpdate)
	RayUIThreatBar.unit = "player"
	RayUIThreatBar.tar = RayUIThreatBar.unit.."target"
	RayUIThreatBar.Colors = aggroColors
	RayUIThreatBar:SetAlpha(0)
end

function UF:PostCastStart(unit, name, rank, castid)
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

function UF:CustomCastTimeText(duration)
	self.Time:SetText(("%.1f | %.1f"):format(self.channeling and duration or self.max - duration, self.max))
end

function UF:CustomCastDelayText(duration)
	self.Time:SetText(("%.1f |cffff0000%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
end

function UF:PostCastInterruptible(unit)
	if unit == "vehicle" then unit = "player" end
	if unit ~= "player" then
		local r, g, b
		if UnitIsPlayer(unit) and UnitIsFriend(unit, "player") and R.myname == "夏可" then
			r, g, b = 95/255, 182/255, 255/255
		elseif UnitIsPlayer(unit) and UnitIsFriend(unit, "player") then
			r, g, b = unpack(oUF.colors.class[select(2, UnitClass(unit))])
		else
			r, g, b = unpack(oUF.colors.reaction[6])
		end
		self:SetBackdropColor(r * 1, g * 1, b * 1)
		if unit:find("arena%d") or unit:find("boss%d") then
			self:SetStatusBarColor(r * 1, g * 1, b * 1, .2)
		else
			self:SetStatusBarColor(r * 1, g * 1, b * 1)
		end
	end
end

function UF:PostCastNotInterruptible(unit)
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

function UF:PostCastFailed(event, unit, name, rank, castid)
	self:SetStatusBarColor(unpack(oUF.colors.reaction[1]))
	self:SetValue(self.max)
	self:Show()
end

function UF:OnCastbarUpdate(elapsed)
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

function UF:PostUpdateHealth(unit, cur, max)
	local curhealth, maxhealth = UnitHealth(unit), UnitHealthMax(unit)
	local r, g, b = self:GetStatusBarColor()
	if UF.db.smoothColor then
		r,g,b = ColorGradient(curhealth/maxhealth)
	else
		r,g,b = .12, .12, .12
	end
	if not UF.db.healthColorClass then
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
		if UF.db.smoothColor then
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
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R:ShortValue(UnitHealth(unit)))
			else
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R:ShortValue(UnitHealth(unit) - UnitHealthMax(unit)))
			end
		elseif self.__owner.isMouseOver then
			self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R:ShortValue(UnitHealth(unit)))
		else
			self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.5))
		end
	elseif self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R:ShortValue(UnitHealthMax(unit)))
	else
		self.value:SetText(nil)
	end
end

function UF:PostUpdatePower(unit, cur, max)
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
			self.value:SetFormattedText("%s - |cff%02x%02x%02x%s|r", R:ShortValue(UnitPower(unit)), color[1] * 255, color[2] * 255, color[3] * 255, R:ShortValue(UnitPowerMax(unit)))
		elseif type == "MANA" then
			self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5))
		elseif cur > 0 then
			self.value:SetFormattedText("|cff%02x%02x%02x%d|r", color[1] * 255, color[2] * 255, color[3] * 255, UnitPower(unit))
		else
			self.value:SetText(nil)
		end
	elseif type == "MANA" and self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, R:ShortValue(UnitPowerMax(unit)))
	else
		self.value:SetText(nil)
	end
end

function UF:UpdateThreatStatus(event, unit)
	if (self.unit ~= unit) and (event~="PLAYER_TARGET_CHANGED") then return end
	unit = unit or self.unit
	local s = UnitThreatSituation(unit)
	if s and s > 1 then
		local r, g, b = GetThreatStatusColor(s)
		self.ThreatHlt:Show()
		self.ThreatHlt:SetVertexColor(r, g, b, 0.5)
	else
		self.ThreatHlt:Hide()
	end
end

function UF:PostAltUpdate(min, cur, max)
    local frame = self.__owner

    local tPath, r, g, b = UnitAlternatePowerTextureInfo(frame.unit, 2)

    if(r) then
        self:SetStatusBarColor(r, g, b, 1)
    else
        self:SetStatusBarColor(1, 1, 1, .8)
    end 
end

function UF:UpdateEclipse(unit)
    if self.hasSolarEclipse then
        self.border:SetBackdropBorderColor(1, .6, 0)
        self.shadow:SetBackdropBorderColor(1, .6, 0)
    elseif self.hasLunarEclipse then
        self.border:SetBackdropBorderColor(0, .4, 1)
        self.shadow:SetBackdropBorderColor(0, .4, 1)
    else
        self.border:SetBackdropBorderColor(0, 0, 0)
        self.shadow:SetBackdropBorderColor(0, 0, 0)
    end
	local direction = GetEclipseDirection()
	if direction == "sun" then
		self.Arrow:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-right-active")
		self.Spark:Hide()
	elseif direction == "moon" then
		self.Arrow:SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-left-active")
		self.Spark:Hide()
	else
		self.Arrow:SetTexture(nil)
		self.Spark:Show()
	end
end

function UF:ComboDisplay(event, unit)
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
		elseif UF.db.separateEnergy then
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

local function CreateAuraTimer(frame,elapsed)
    frame.elapsed = (frame.elapsed or 0) + elapsed

    if frame.elapsed < .2 then return end
    frame.elapsed = 0

    local timeLeft = frame.expires - GetTime()
    if timeLeft <= 0 then
        return
    else
        frame.remaining:SetText(formatTime(timeLeft))
    end
end

function UF:PostUpdateIcon(unit, icon, index, offset)
	local name, _, _, _, dtype, duration, expirationTime, unitCaster, canStealOrPurge = UnitAura(unit, index, icon.filter)

	local texture = icon.icon
	if icon.isDebuff then
		if icon.owner == "player" or icon.owner == "pet" or icon.owner == "vehicle" or UnitIsFriend('player', unit) then
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			icon.border:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			icon:GetHighlightTexture():Point("TOPLEFT", 1, -1)
			icon:GetHighlightTexture():Point("BOTTOMRIGHT", -1, 1)
			texture:Point("TOPLEFT", icon, 1, -1)
			texture:Point("BOTTOMRIGHT", icon, -1, 1)
			texture:SetDesaturated(false)
		else
			icon.border:SetBackdropBorderColor(unpack(R["media"].bordercolor))
			icon:GetHighlightTexture():SetAllPoints()
			texture:Point("TOPLEFT", icon)
			texture:Point("BOTTOMRIGHT", icon)
			texture:SetDesaturated(true)
		end
	else
		if (canStealOrPurge or ((R.myclass == "PRIEST" or R.myclass == "SHAMAN" or R.myclass == "MAGE") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
			icon.border:SetBackdropBorderColor(237/255, 234/255, 142/255)
			icon:GetHighlightTexture():Point("TOPLEFT", 1, -1)
			icon:GetHighlightTexture():Point("BOTTOMRIGHT", -1, 1)
			texture:Point("TOPLEFT", icon, 1, -1)
			texture:Point("BOTTOMRIGHT", icon, -1, 1)
		else
			icon:GetHighlightTexture():SetAllPoints()
			icon.border:SetBackdropBorderColor(unpack(R["media"].bordercolor))
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

function UF:PostCreateIcon(button)
	button:SetFrameStrata("BACKGROUND")
	local count = button.count
	count:ClearAllPoints()
	count:Point("CENTER", button, "BOTTOMRIGHT", 0, 5)
	count:SetFontObject(nil)
	count:SetFont(R["media"].font, 13, "THINOUTLINE")
	count:SetTextColor(.8, .8, .8)

	self.disableCooldown = true
	button.icon:SetTexCoord(.1, .9, .1, .9)
	button:CreateShadow()
	button.shadow:SetBackdropColor(0, 0, 0)
	button.overlay:Hide()

	button.remaining = button:CreateFontString(nil, "OVERLAY")
	button.remaining:SetFont(R["media"].font, 13, R["media"].fontflag)
	button.remaining:SetJustifyH("LEFT")
	button.remaining:SetTextColor(0.99, 0.99, 0.99)
	button.remaining:Point("CENTER", 0, 0)
	
	button:StyleButton(true)
	button:SetPushedTexture(nil)
end

function UF:CustomFilter(unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
	local isPlayer

	if(caster == 'player' or caster == 'vehicle') then
		isPlayer = true
	end

	if name then
		icon.isPlayer = isPlayer
		icon.owner = caster
	end
	
	if UnitCanAttack(unit, "player") and UnitLevel(unit) == -1 then
		if (R.Role == "Melee" and name and UF.PvEMeleeBossDebuffs[name]) or 
			(R.Role == "Caster" and name and UF.PvECasterBossDebuffs[name]) or
			(R.Role == "Tank" and name and UF.PvETankBossDebuffs[name]) or
			isPlayer then
			return true
		else
			return false
		end
	end
	
	return true
end

function UF:FocusText(frame)
	local focusdummy = CreateFrame("BUTTON", "focusdummy", frame, "SecureActionButtonTemplate")
	focusdummy:SetFrameStrata("HIGH")
	focusdummy:SetWidth(25)
	focusdummy:SetHeight(25)
	focusdummy:Point("CENTER", frame.Health, 0, 0)
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

	focusdummytext = focusdummy:CreateFontString(frame,"OVERLAY")
	focusdummytext:Point("CENTER", frame.Health, 0, 0)
	focusdummytext:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
	focusdummytext:SetText(L["焦点"])
	focusdummytext:SetVertexColor(1,0.2,0.1,0)

	focusdummy:SetScript("OnLeave", function(frame) focusdummytext:SetVertexColor(1,0.2,0.1,0) end)
	focusdummy:SetScript("OnEnter", function(frame) focusdummytext:SetTextColor(.6,.6,.6) end)	
end

function UF:ClearFocusText(frame)
	local clearfocus = CreateFrame("BUTTON", "focusdummy", frame, "SecureActionButtonTemplate")
	clearfocus:SetFrameStrata("HIGH")
	clearfocus:SetWidth(25)
	clearfocus:SetHeight(20)
	clearfocus:Point("TOP", frame,0, 0)
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

	clearfocustext = clearfocus:CreateFontString(frame,"OVERLAY")
	clearfocustext:Point("CENTER", frame.Health, 0, 0)
	clearfocustext:SetFont(R["media"].font, R["media"].fontsize, R["media"].fontflag)
	clearfocustext:SetText(L["取消焦点"])
	clearfocustext:SetVertexColor(1,0.2,0.1,0)

	clearfocus:SetScript("OnLeave", function(frame) clearfocustext:SetVertexColor(1,0.2,0.1,0) end)
	clearfocus:SetScript("OnEnter", function(frame) clearfocustext:SetTextColor(.6,.6,.6) end)
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
		if RayUF_player.Debuffs then RayUF_player.Debuffs.CustomFilter = nil end
		if RayUF_target.Buffs then RayUF_target.Buffs.CustomFilter = nil end
		if RayUF_target.Debuffs then RayUF_target.Debuffs.CustomFilter = nil end
		if RayUF_targettarget.Debuffs then RayUF_targettarget.Debuffs.CustomFilter = nil end
		if RayUF_targettarget.Buffs then RayUF_targettarget.Buffs.CustomFilter = nil end
		testuf()
		UnitAura = function()
			return 'penancelol', 'Rank 2', 'Interface\\Icons\\Spell_Holy_Penance', random(5), 'Magic', 0, 0, "player"
		end
		if(oUF) then
			for i, v in pairs(oUF.objects) do
				if(v.UNIT_AURA) then
					v:UNIT_AURA("UNIT_AURA", v.unit)
				end
			end
		end
	end
end
SlashCmdList.TestUF = TestUF
SLASH_TestUF1 = "/testuf"
