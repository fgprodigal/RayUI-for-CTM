local R, C, L, DB = unpack(select(2, ...))

-- Edited from ElvUI
local aggroColors = {
	[1] = {0, 1, 0},
	[2] = {1, 1, 0},
	[3] = {0, 1, 0},
}

-- create the bar
local RayUIThreatBar = CreateFrame("StatusBar", "RayUIThreatBar", BottomInfoBar)
RayUIThreatBar:Point("TOPLEFT", 2, -2)
RayUIThreatBar:Point("BOTTOMRIGHT", -2, 2)
RayUIThreatBar:SetFrameStrata("BACKGROUND")
RayUIThreatBar:SetFrameLevel(1)

RayUIThreatBar:SetStatusBarTexture(C["media"].normal)
RayUIThreatBar:GetStatusBarTexture():SetHorizTile(false)
RayUIThreatBar:SetMinMaxValues(0, 100)

RayUIThreatBar.text = RayUIThreatBar:CreateFontString(nil, "OVERLAY")
RayUIThreatBar.text:SetFont(C["media"].font, C["media"].fontsize, 'THINOUTLINE')
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