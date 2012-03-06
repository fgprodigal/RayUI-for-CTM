local R, C, L, DB = unpack(select(2, ...))
local _, ns = ...
local oUF = RayUF or ns.oUF or oUF

local PLAYER_WIDTH = 220
local PLAYER_HEIGHT = 32
local TARGET_WIDTH = 220
local TARGET_HEIGHT = 32
local SMALL_WIDTH = 140
local SMALL_HEIGHT = 8
local BOSS_WIDTH = 190
local BOSS_HEIGHT = 22
local PARTY_WIDTH = 170
local PARTY_HEIGHT = 32
local ENERGY_WIDTH = 200
local ENERGY_HEIGHT = 3

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

local function Fader(self)
	self.Fader = true
	self.FadeSmooth = 0.5
	self.FadeMinAlpha = 0
	self.FadeMaxAlpha = 1
end

local function Shared(self, unit)
--	self.FrameBackdrop = R.CreateBackdrop(self, self)
	
	-- Register Frames for Click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- Setup Menu
	self.menu = R.SpawnMenu
	
	-- Frame Level
	self:SetFrameLevel(5)
	
	self.textframe = CreateFrame("Frame", nil, self)
	self.textframe:SetAllPoints()
	self.textframe:SetFrameLevel(self:GetFrameLevel()+5)

	-- Health
	local health = R.ContructHealthBar(self, true, true)
	health:SetPoint("LEFT")
	health:SetPoint("RIGHT")
	health:SetPoint("TOP")
	health:CreateShadow("Background")
	self.Health = health
	
	-- Name
	local name = self.textframe:CreateFontString(nil, "OVERLAY")
	name:SetFont(C["media"].font, 15, C["media"].fontflag)
	self.Name = name
	
	-- mouseover highlight
    local mouseover = health:CreateTexture(nil, "OVERLAY")
	mouseover:SetAllPoints(health)
	mouseover:SetTexture("Interface\\AddOns\\!RayUI\\media\\mouseover")
	mouseover:SetVertexColor(1,1,1,.36)
	mouseover:SetBlendMode("ADD")
	mouseover:Hide()
	self.Mouseover = mouseover
	
	-- threat highlight
	local Thrt = health:CreateTexture(nil, "OVERLAY")
	Thrt:SetAllPoints(health)
	Thrt:SetTexture("Interface\\AddOns\\!RayUI\\media\\threat")
	Thrt:SetBlendMode("ADD")
	Thrt:Hide()
	self.ThreatHlt = Thrt	
	
	-- update threat
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", R.UpdateThreatStatus)
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", R.UpdateThreatStatus)
	
	-- SpellRange
	self.SpellRange = {
		  insideAlpha = 1,
		  outsideAlpha = 0.3}

	if unit == "player" then
		health:SetSize(PLAYER_WIDTH, PLAYER_HEIGHT * (1 - C["uf"].powerheight) - 10)
		health.value:Point("LEFT", health, "LEFT", 5, 0)
		name:Point("TOPLEFT", health, "BOTTOMLEFT", 0, 3)
		name:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, 3)
		name:SetJustifyH("LEFT")
		
		if C["uf"].healthColorClass then
			self:Tag(name, '[RayUF:name] [RayUF:info]')
		else
			self:Tag(name, '[RayUF:color][RayUF:name] [RayUF:info]')
		end
		
		-- Separated Energy Bar
		if C["uf"].separateEnergy and R.myclass == "ROGUE" then
			local EnergyBarHolder = CreateFrame("Frame", nil, self)
			EnergyBarHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 311)
			EnergyBarHolder:SetSize(ENERGY_WIDTH, ENERGY_HEIGHT + 13)
			local EnergyBar = CreateFrame("Statusbar", "RayUF_EnergyBar", EnergyBarHolder)
			EnergyBar:SetStatusBarTexture(C["media"].normal)
			EnergyBar:SetStatusBarColor(unpack(C["uf"].powerColorClass and oUF.colors.class[R.myclass] or oUF.colors.power['ENERGY']))
			EnergyBar:SetPoint("BOTTOM", 0, 3)
			EnergyBar:SetSize(ENERGY_WIDTH, ENERGY_HEIGHT)
			EnergyBar:CreateShadow("Background")
			EnergyBar.shadow:SetBackdropColor(.12, .12, .12, 1)
			EnergyBar.text = EnergyBar:CreateFontString(nil, "OVERLAY")
			EnergyBar.text:SetPoint("CENTER")
			EnergyBar.text:SetFont(C["media"].font, C["media"].fontsize + 2, C["media"].fontflag)
			EnergyBar:SetScript("OnUpdate", function(self)
				self:SetMinMaxValues(0, UnitPowerMax("player"))
				self:SetValue(UnitPower("player"))
				self.text:SetText(UnitPower("player"))
			end)
			R.CreateMover(EnergyBarHolder, "EnergyBarMover", L["能量条锚点"], true)
		else
			local power = R.ConstructPowerBar(self, true, true)
			power:SetPoint("LEFT")
			power:SetPoint("RIGHT")
			power:SetPoint("BOTTOM") 
			power.value:Point("RIGHT", health, "RIGHT", -5, 0)
			power:SetWidth(PLAYER_WIDTH)
			power:SetHeight(PLAYER_HEIGHT * C["uf"].powerheight)
			power:CreateShadow("Background")
			self.Power = power
		end
		
		self.Portrait = R.ConstructPortrait(self)
		
		-- Vengeance Bar
		if C["uf"].vengeance then
			local VengeanceBarHolder = CreateFrame("Frame", nil, self)
			VengeanceBarHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 317)
			VengeanceBarHolder:SetSize(ENERGY_WIDTH, ENERGY_HEIGHT)
			local VengeanceBar = CreateFrame("Statusbar", "RayUF_VengeanceBar", VengeanceBarHolder)
			VengeanceBar:SetStatusBarTexture(C["media"].normal)
			VengeanceBar:SetStatusBarColor(unpack(C["uf"].powerColorClass and oUF.colors.class[R.myclass] or oUF.colors.power['RAGE']))
			VengeanceBar:SetPoint("CENTER")
			VengeanceBar:SetSize(ENERGY_WIDTH, ENERGY_HEIGHT)
			VengeanceBar:CreateShadow("Background")
			VengeanceBar.shadow:SetBackdropColor(.12, .12, .12, 1)
			VengeanceBar.Text = VengeanceBar:CreateFontString(nil, "OVERLAY")
			VengeanceBar.Text:SetPoint("CENTER")
			VengeanceBar.Text:SetFont(C["media"].font, C["media"].fontsize + 2, C["media"].fontflag)
			R.CreateMover(VengeanceBarHolder, "VengeanceBarMover", L["复仇条锚点"], true)
			self.Vengeance = VengeanceBar
		end
		
		-- Alternative Power Bar
		local altpp = CreateFrame("StatusBar", nil, self)
		altpp:SetStatusBarTexture(C["media"].normal)
		altpp:GetStatusBarTexture():SetHorizTile(false)
		altpp:SetFrameStrata("LOW")
		altpp:SetHeight(4)
		altpp:Point('TOPLEFT', self, 'BOTTOMLEFT', 0, -2)
		altpp:Point('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -2)
		altpp.bg = altpp:CreateTexture(nil, 'BORDER')
		altpp.bg:SetAllPoints(altpp)
		altpp.bg:SetTexture(C["media"].normal)
		altpp.bg:SetVertexColor( 0,  0.76, 1)
		altpp.bd = R.CreateBackdrop(altpp, altpp)
		altpp.Text = altpp:CreateFontString(nil, "OVERLAY")
		altpp.Text:SetFont(C["media"].font, 12, C["media"].fontflag)
		altpp.Text:SetPoint("CENTER")
		self:Tag(altpp.Text, "[RayUF:altpower]")
		altpp.PostUpdate = R.PostAltUpdate
		self.AltPowerBar = altpp
		
		-- CastBar
		local castbar = R.ConstructCastBar(self)
		castbar:ClearAllPoints()
		castbar:Point("BOTTOM",UIParent,"BOTTOM",0,305)
		castbar:Width(350)
		castbar:Height(5)
		castbar.Text:ClearAllPoints()
		castbar.Text:SetPoint("BOTTOMLEFT", castbar, "TOPLEFT", 5, -2)
		castbar.Time:ClearAllPoints()
		castbar.Time:SetPoint("BOTTOMRIGHT", castbar, "TOPRIGHT", -5, -2)
		castbar.Icon:Hide()
		castbar.Iconbg:Hide()
		self.Castbar = castbar
		
		-- Debuffs
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(PLAYER_HEIGHT - 11)
		debuffs:SetWidth(PLAYER_WIDTH)
		debuffs:Point("BOTTOMRIGHT", self, "TOPRIGHT", 0, 8)
		debuffs.spacing = 3.8
		debuffs["growth-x"] = "LEFT"
		debuffs["growth-y"] = "UP"
		debuffs.size = PLAYER_HEIGHT - 11
		debuffs.initialAnchor = "BOTTOMRIGHT"
		debuffs.num = 9
		debuffs.PostCreateIcon = R.PostCreateIcon
		debuffs.PostUpdateIcon = R.PostUpdateIcon
		
		self.Debuffs = debuffs
		
		-- Fader
		Fader(self)
		
		-- ClassBar
		 if R.myclass == "DEATHKNIGHT" or R.myclass == "WARLOCK" or R.myclass == "PALADIN" then
            local count
            if R.myclass == "DEATHKNIGHT" then 
                count = 6 
            else 
                count = 3 
            end

            local bars = CreateFrame("Frame", nil, self)
			bars:SetSize(200/count - 5, 5)
			bars:SetFrameLevel(5)
			if count == 3 then
				bars:Point("BOTTOMRIGHT", self, "TOP", bars:GetWidth()*1.5 + 5, 1)
			else
				bars:Point("BOTTOMRIGHT", self, "TOP", bars:GetWidth()*3 + 12.5, 1)
			end

            local i = count
            for index = 1, count do
                bars[i] = CreateFrame("StatusBar", nil, bars)
				bars[i]:SetStatusBarTexture(C["media"].normal)
				bars[i]:SetWidth(200/count-5)
				bars[i]:SetHeight(5)
				bars[i]:GetStatusBarTexture():SetHorizTile(false)

                if R.myclass == "WARLOCK" then
                    local color = oUF.colors.class["WARLOCK"]
                    bars[i]:SetStatusBarColor(color[1], color[2], color[3])
                elseif R.myclass == "PALADIN" then
                    local color = oUF.colors.power["HOLY_POWER"]
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

				bars[i]:CreateShadow("Background")
				bars[i].shadow:SetFrameStrata("BACKGROUND")
				bars[i].shadow:SetFrameLevel(0)
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
            ebar:Point("BOTTOM", self, "TOP", 0, 1)
            ebar:SetSize(200, 5)
            ebar:CreateShadow("Background")
			ebar:SetFrameLevel(5)
			ebar.shadow:SetFrameStrata("BACKGROUND")
			ebar.shadow:SetFrameLevel(0)

			local lbar = CreateFrame("StatusBar", nil, ebar)
			lbar:SetStatusBarTexture(C["media"].normal)
			lbar:SetStatusBarColor(0, .4, 1)
			lbar:SetWidth(200)
			lbar:SetHeight(5)
			lbar:SetFrameLevel(5)
			lbar:GetStatusBarTexture():SetHorizTile(false)
            lbar:SetPoint("LEFT", ebar, "LEFT")
            ebar.LunarBar = lbar

			local sbar = CreateFrame("StatusBar", nil, ebar)
			sbar:SetStatusBarTexture(C["media"].normal)
			sbar:SetStatusBarColor(1, .6, 0)
			sbar:SetWidth(200)
			sbar:SetHeight(5)
			sbar:SetFrameLevel(5)
			sbar:GetStatusBarTexture():SetHorizTile(false)
            sbar:SetPoint("LEFT", lbar:GetStatusBarTexture(), "RIGHT")
            ebar.SolarBar = sbar

            ebar.Spark = sbar:CreateTexture(nil, "OVERLAY")
            ebar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
            ebar.Spark:SetBlendMode("ADD")
            ebar.Spark:SetAlpha(0.5)
            ebar.Spark:SetHeight(20)
            ebar.Spark:Point("LEFT", sbar:GetStatusBarTexture(), "LEFT", -15, 0)
			
            ebar.Arrow = sbar:CreateTexture(nil, "OVERLAY")
            ebar.Arrow:SetSize(8,8)
            ebar.Arrow:Point("CENTER", sbar:GetStatusBarTexture(), "LEFT", 0, 0)

            self.EclipseBar = ebar
            self.EclipseBar.PostUnitAura = R.UpdateEclipse
        end

        if  R.myclass == "SHAMAN" then
            self.TotemBar = {}
            self.TotemBar.Destroy = true
            for i = 1, 4 do
				self.TotemBar[i] = CreateFrame("StatusBar", nil, self)
				self.TotemBar[i]:SetStatusBarTexture(C["media"].normal)
				self.TotemBar[i]:SetWidth(200/4-5)
				self.TotemBar[i]:SetHeight(5)
				self.TotemBar[i]:GetStatusBarTexture():SetHorizTile(false)
				self.TotemBar[i]:SetFrameLevel(5)

                self.TotemBar[i]:SetBackdrop({bgFile = C["media"].blank})
                self.TotemBar[i]:SetBackdropColor(0.5, 0.5, 0.5)
                self.TotemBar[i]:SetMinMaxValues(0, 1)

                self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
                self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
                self.TotemBar[i].bg:SetTexture(C["media"].normal)
                self.TotemBar[i].bg.multiplier = 0.3

                self.TotemBar[i]:CreateShadow("Background")
				self.TotemBar[i].shadow:SetFrameStrata("BACKGROUND")
				self.TotemBar[i].shadow:SetFrameLevel(0)
            end
			self.TotemBar[2]:SetPoint("BOTTOM", self, "TOP", -75,1)
			self.TotemBar[1]:SetPoint("LEFT", self.TotemBar[2], "RIGHT", 5, 0)
			self.TotemBar[3]:SetPoint("LEFT", self.TotemBar[1], "RIGHT", 5, 0)
			self.TotemBar[4]:SetPoint("LEFT", self.TotemBar[3], "RIGHT", 5, 0)
        end
		
		-- Experienc & Reputation
		local experience = CreateFrame("StatusBar", nil, self)
		experience:SetStatusBarTexture(C["media"].normal)
		experience:SetStatusBarColor(0.58, 0.0, 0.55)
		experience:GetStatusBarTexture():SetHorizTile(false)
		
		experience:Point('TOPLEFT', BottomInfoBar, 'TOPLEFT', 0, 0)
		experience:Point('BOTTOMRIGHT', BottomInfoBar, 'BOTTOMRIGHT', 0, 0)
		experience:SetParent(BottomInfoBar)
		experience:SetFrameStrata("BACKGROUND")
		experience:SetFrameLevel(1)
		
		experience.Rested = CreateFrame("StatusBar", nil, experience)
		experience.Rested:SetStatusBarTexture(C["media"].normal)
		experience.Rested:SetStatusBarColor(0, 0.39, 0.88)
		experience.Rested:GetStatusBarTexture():SetHorizTile(false)
		experience.Rested:SetAllPoints(experience)
		experience.Rested:SetFrameStrata("BACKGROUND")
		experience.Rested:SetFrameLevel(0)
		
		experience.Tooltip = true		
		
		local reputation = CreateFrame("StatusBar", nil, self)
		reputation:SetStatusBarTexture(C["media"].normal)
		reputation:SetStatusBarColor(0, .7, 1)
		reputation:GetStatusBarTexture():SetHorizTile(false)
		
		reputation:Point('TOPLEFT', BottomInfoBar, 'TOPLEFT', 0, 0)
		reputation:Point('BOTTOMRIGHT', BottomInfoBar, 'BOTTOMRIGHT', 0, 0)
		reputation:SetParent(BottomInfoBar)
		reputation:SetFrameStrata("BACKGROUND")
		reputation:SetFrameLevel(1)
		
		reputation.PostUpdate = function(self, event, unit, bar)
															local name, id = GetWatchedFactionInfo()
															bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
														end
		reputation.Tooltip = true
		reputation.colorStanding = true
		
		self:SetScript("OnEnter", UnitFrame_OnEnter)
		self:SetScript("OnLeave", UnitFrame_OnLeave)
		
		RayUIThreatBar:HookScript("OnShow", function()
			if RayUIThreatBar:GetAlpha() > 0 then
				experience:SetAlpha(0)
				reputation:SetAlpha(0)
			end
		end)
		RayUIThreatBar:HookScript("OnHide", function()
			experience:SetAlpha(1)
			reputation:SetAlpha(1)
		end)
		hooksecurefunc(RayUIThreatBar, "SetAlpha", function()
			if RayUIThreatBar:GetAlpha() > 0 then
				experience:SetAlpha(0)
				reputation:SetAlpha(0)
			else
				experience:SetAlpha(1)
				reputation:SetAlpha(1)
			end
		end)
		
		self.Experience = experience
		self.Reputation = reputation
		
		-- Heal Prediction
		local mhpb = CreateFrame('StatusBar', nil, self)
		mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
		mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')	
		mhpb:SetWidth(health:GetWidth())
		mhpb:SetStatusBarTexture(C["media"].blank)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
		
		local ohpb = CreateFrame('StatusBar', nil, self)
		ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		ohpb:SetWidth(mhpb:GetWidth())
		ohpb:SetStatusBarTexture(C["media"].blank)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)
		
		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
			PostUpdate = function(self)
				if self.myBar:GetValue() == 0 then self.myBar:SetAlpha(0) else self.myBar:SetAlpha(1) end
				if self.otherBar:GetValue() == 0 then self.otherBar:SetAlpha(0) else self.otherBar:SetAlpha(1) end
			end
		}
		
		local Combat = self:CreateTexture(nil, 'OVERLAY')
		Combat:SetSize(20, 20)
		Combat:ClearAllPoints()
		Combat:Point("LEFT", health, "LEFT", -10, -5)
		self.Combat = Combat
		self.Combat:SetTexture("Interface\\AddOns\\!RayUI\\media\\combat")
		self.Combat:SetVertexColor(0.6, 0, 0)

		local Resting = self:CreateTexture(nil, 'OVERLAY')
		Resting:SetSize(20, 20)
		Resting:Point("BOTTOM", Combat, "BOTTOM", 0, 25)
		self.Resting = Resting
		self.Resting:SetTexture("Interface\\AddOns\\!RayUI\\media\\rested")
		self.Resting:SetVertexColor(0.8, 0.8, 0.8)
	end
	
	if unit == "target" then
		health:SetSize(TARGET_WIDTH, TARGET_HEIGHT * (1 - C["uf"].powerheight) - 10)
		health.value:Point("LEFT", health, "LEFT", 5, 0)
		name:Point("TOPLEFT", health, "BOTTOMLEFT", 0, 3)
		name:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, 3)
		name:SetJustifyH("RIGHT")		
		if C["uf"].healthColorClass then
			self:Tag(name, '[RayUF:name] [RayUF:info]')
		else
			self:Tag(name, '[RayUF:color][RayUF:name] [RayUF:info]')
		end
		R.FocusText(self)
		local power = R.ConstructPowerBar(self, true, true)
		power:SetPoint("LEFT")
		power:SetPoint("RIGHT")
		power:SetPoint("BOTTOM") 
		power.value:Point("RIGHT", health, "RIGHT", -5, 0)
		power:SetWidth(PLAYER_WIDTH)
		power:SetHeight(PLAYER_HEIGHT * C["uf"].powerheight)
		power:CreateShadow("Background")
		self.Power = power
		
		self.Portrait = R.ConstructPortrait(self)
		
		local castbar = R.ConstructCastBar(self)
		castbar:ClearAllPoints()
		castbar:Point("TOPRIGHT", self, "TOPRIGHT", 0, -65)
		castbar:Width(health:GetWidth()-27)
		castbar:Height(20)
		castbar.Text:ClearAllPoints()
		castbar.Text:SetPoint("LEFT", castbar, "LEFT", 5, 0)
		castbar.Time:ClearAllPoints()
		castbar.Time:SetPoint("RIGHT", castbar, "RIGHT", -5, 0)
		self.Castbar = castbar
		
		-- Auras
		local buffs = CreateFrame("Frame", nil, self)
		buffs:SetHeight(PLAYER_HEIGHT - 11)
		buffs:SetWidth(PLAYER_WIDTH)
		buffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
		buffs.spacing = 3.8
		buffs["growth-x"] = "RIGHT"
		buffs["growth-y"] = "DOWN"
		buffs.size = PLAYER_HEIGHT - 11
		buffs.initialAnchor = "TOPLEFT"
		buffs.num = 9
		buffs.PostCreateIcon = R.PostCreateIcon
		buffs.PostUpdateIcon = R.PostUpdateIcon
		
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(PLAYER_HEIGHT - 11)
		debuffs:SetWidth(PLAYER_WIDTH)
		debuffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 8)
		debuffs.spacing = 3.8
		debuffs["growth-x"] = "RIGHT"
		debuffs["growth-y"] = "UP"
		debuffs.size = PLAYER_HEIGHT - 11
		debuffs.initialAnchor = "BOTTOMLEFT"
		debuffs.num = 9
		debuffs.PostCreateIcon = R.PostCreateIcon
		debuffs.PostUpdateIcon = R.PostUpdateIcon
		debuffs.CustomFilter = R.CustomFilter

		self.Buffs = buffs
		self.Debuffs = debuffs
		
		-- Combo Bar
		local bars = CreateFrame("Frame", nil, self)
		bars:SetWidth(35)
		bars:SetHeight(5)
		bars:Point("BOTTOMLEFT", self, "TOP", - bars:GetWidth()*2.5 - 10, 1)
		
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

			bars[i]:CreateShadow("Background")
			bars[i].shadow:SetFrameStrata("BACKGROUND")
			bars[i].shadow:SetFrameLevel(0)
		end
			
		bars[1]:SetStatusBarColor(255/255, 0/255, 0)		
		bars[2]:SetStatusBarColor(255/255, 0/255, 0)
		bars[3]:SetStatusBarColor(255/255, 255/255, 0)
		bars[4]:SetStatusBarColor(255/255, 255/255, 0)
		bars[5]:SetStatusBarColor(0, 1, 0)
			
		self.CPoints = bars
		self.CPoints.Override = R.ComboDisplay
		
		if C["uf"].separateEnergy and R.myclass == "ROGUE" then
			bars:SetParent(RayUF_EnergyBar)
			bars:ClearAllPoints()
			bars:Point("BOTTOMLEFT", RayUF_EnergyBar, "TOPLEFT", 0, 3)
			for i = 1, 5 do
				bars[i]:SetHeight(3)
				bars[i]:SetWidth((ENERGY_WIDTH- 20)/5)
				bars[i]:SetAlpha(0)
			end
		end
		
		-- Heal Prediction
		local mhpb = CreateFrame('StatusBar', nil, self)
		mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
		mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')	
		mhpb:SetWidth(health:GetWidth())
		mhpb:SetStatusBarTexture(C["media"].blank)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
		
		local ohpb = CreateFrame('StatusBar', nil, self)
		ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		ohpb:SetWidth(mhpb:GetWidth())
		ohpb:SetStatusBarTexture(C["media"].blank)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)
		
		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
			PostUpdate = function(self)
				if self.myBar:GetValue() == 0 then self.myBar:SetAlpha(0) else self.myBar:SetAlpha(1) end
				if self.otherBar:GetValue() == 0 then self.otherBar:SetAlpha(0) else self.otherBar:SetAlpha(1) end
			end
		}
	end
	
	if unit == "party" or unit == "focus" then
		health:SetSize(PARTY_WIDTH, PARTY_HEIGHT * (1 - C["uf"].powerheight) - 10)
		health.value:Point("LEFT", health, "LEFT", 5, 0)
		name:Point("TOPLEFT", health, "BOTTOMLEFT", 0, 3)
		name:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, 3)
		name:SetJustifyH("LEFT")
		if C["uf"].healthColorClass then
			self:Tag(name, '[RayUF:name] [RayUF:info]')
		else
			self:Tag(name, '[RayUF:color][RayUF:name] [RayUF:info]')
		end
		local power = R.ConstructPowerBar(self, true, true)
		power:SetPoint("LEFT")
		power:SetPoint("RIGHT")
		power:SetPoint("BOTTOM") 
		power.value:Point("RIGHT", health, "RIGHT", -5, 0)
		power:SetWidth(PLAYER_WIDTH)
		power:SetHeight(PLAYER_HEIGHT * C["uf"].powerheight)
		power:CreateShadow("Background")
		self.Power = power
		
		self.Portrait = R.ConstructPortrait(self)
	end
	
	if unit == "party" then
		-- Heal Prediction
		local mhpb = CreateFrame('StatusBar', nil, self)
		mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
		mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')	
		mhpb:SetWidth(health:GetWidth())
		mhpb:SetStatusBarTexture(C["media"].blank)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
		
		local ohpb = CreateFrame('StatusBar', nil, self)
		ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		ohpb:SetWidth(mhpb:GetWidth())
		ohpb:SetStatusBarTexture(C["media"].blank)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)
		
		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
			PostUpdate = function(self)
				if self.myBar:GetValue() == 0 then self.myBar:SetAlpha(0) else self.myBar:SetAlpha(1) end
				if self.otherBar:GetValue() == 0 then self.otherBar:SetAlpha(0) else self.otherBar:SetAlpha(1) end
			end
		}
	end
	
	if unit == "focus" then
		-- CastBar
		local castbar = R.ConstructCastBar(self)
		castbar:ClearAllPoints()
		castbar:Point("CENTER", UIParent, "CENTER", 0, 100)
		castbar:Width(250)
		castbar:Height(5)
		castbar.Text:ClearAllPoints()
		castbar.Text:SetPoint("BOTTOMLEFT", castbar, "TOPLEFT", 5, -2)
		castbar.Time:ClearAllPoints()
		castbar.Time:SetPoint("BOTTOMRIGHT", castbar, "TOPRIGHT", -5, -2)
		castbar.Iconbg:SetSize(25, 25)
		castbar.Iconbg:ClearAllPoints()
		castbar.Iconbg:SetPoint("BOTTOM", castbar, "TOP", 0, 5)
		castbar:SetParent(UIParent)
		self.Castbar = castbar
		
		R.ClearFocusText(self)
		
		-- Debuffs
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(PARTY_HEIGHT - 10)
		debuffs:SetWidth(PARTY_WIDTH)
		debuffs:Point("BOTTOMRIGHT", self, "TOPRIGHT", 0, 7)
		debuffs.spacing = 3.8
		debuffs["growth-x"] = "LEFT"
		debuffs["growth-y"] = "UP"
		debuffs.size = PARTY_HEIGHT - 11
		debuffs.initialAnchor = "BOTTOMRIGHT"
		debuffs.num = 7
		debuffs.PostCreateIcon = R.PostCreateIcon
		debuffs.PostUpdateIcon = R.PostUpdateIcon
		debuffs.onlyShowPlayer = true
		
		self.Debuffs = debuffs
	end
	
	if unit == "targettarget" or unit == "pet" or unit == "pettarget" or unit == "focustarget" then
		health:SetSize(SMALL_WIDTH, SMALL_HEIGHT * 0.9)
		health.value:Point("LEFT", self, "LEFT", 5, 0)
		name:Point("TOP", health, 0, 12)
		name:SetFont(C["media"].font, 14, C["media"].fontflag)
		if C["uf"].healthColorClass then
			self:Tag(name, '[RayUF:name]')
		else
			self:Tag(name, '[RayUF:color][RayUF:name]')
		end		
	end
	
	if unit == "pet" then
		--Dummy Cast Bar, so we don't see an extra castbar while in vehicle
	--	local castbar = CreateFrame("StatusBar", nil, self)
	--	self.Castbar = castbar

		-- Fader
		Fader(self)
	end
	
	if unit == "targettarget" then
		-- Debuffs
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(PLAYER_HEIGHT - 11)
		debuffs:SetWidth(SMALL_WIDTH)
		debuffs:Point("TOPLEFT", self, "BOTTOMLEFT", 1, -5)
		debuffs.spacing = 5
		debuffs["growth-x"] = "RIGHT"
		debuffs["growth-y"] = "DOWN"
		debuffs.size = PLAYER_HEIGHT - 11
		debuffs.initialAnchor = "TOPLEFT"
		debuffs.num = 5
		debuffs.PostCreateIcon = R.PostCreateIcon
		debuffs.PostUpdateIcon = R.PostUpdateIcon
		debuffs.CustomFilter = function(_, unit) if UnitIsEnemy(unit, "player") then return false end return true end

		self.Debuffs = debuffs
		
		-- Buffs
		local buffs = CreateFrame("Frame", nil, self)
		buffs:SetHeight(PLAYER_HEIGHT - 11)
		buffs:SetWidth(SMALL_WIDTH)
		buffs:Point("TOPLEFT", self, "BOTTOMLEFT", 1, -5)
		buffs.spacing = 5
		buffs["growth-x"] = "RIGHT"
		buffs["growth-y"] = "DOWN"
		buffs.size = PLAYER_HEIGHT - 11
		buffs.initialAnchor = "TOPLEFT"
		buffs.num = 5
		buffs.PostCreateIcon = R.PostCreateIcon
		buffs.PostUpdateIcon = R.PostUpdateIcon
		buffs.CustomFilter = function(_, unit) if UnitIsFriend(unit, "player") then return false end return true end

		self.Buffs = buffs
	end
	
	if (unit and unit:find("arena%d") and C["uf"].showArenaFrames == true) or (unit and unit:find("boss%d") and C["uf"].showBossFrames == true) then
		health:SetSize(BOSS_WIDTH, BOSS_HEIGHT * (1 - C["uf"].powerheight)-2)
		health.value:Point("LEFT", self, "LEFT", 5, 0)
		name:Point("BOTTOM", health, -6, -15)
		name:Point("LEFT", health, 0, 0)
		name:SetJustifyH("LEFT")
		if C["uf"].healthColorClass then
			self:Tag(name, '[RayUF:name] [RayUF:info]')
		else
			self:Tag(name, '[RayUF:color][RayUF:name] [RayUF:info]')
		end
		local power = R.ConstructPowerBar(self, true, true)
		power:SetPoint("LEFT")
		power:SetPoint("RIGHT")
		power:SetPoint("BOTTOM") 
		power.value:Point("RIGHT", self, "RIGHT", -5, 0)
		power:SetWidth(PLAYER_WIDTH)
		power:SetHeight(PLAYER_HEIGHT * C["uf"].powerheight)
		power:CreateShadow("Background")
		self.Power = power
		
		self.Portrait = R.ConstructPortrait(self)
		
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(BOSS_HEIGHT)
		debuffs:SetWidth(BOSS_WIDTH)
		debuffs:Point("TOPRIGHT", self, "BOTTOMRIGHT", -1, -2)
		debuffs.spacing = 6
		debuffs["growth-x"] = "LEFT"
		debuffs["growth-y"] = "DOWN"
		debuffs.size = PLAYER_HEIGHT - 12
		debuffs.initialAnchor = "TOPRIGHT"
		debuffs.num = 7
		debuffs.PostCreateIcon = R.PostCreateIcon
		debuffs.PostUpdateIcon = R.PostUpdateIcon
		debuffs.onlyShowPlayer = true
		self.Debuffs = debuffs
		
		-- CastBar
		local castbar = R.ConstructCastBar(self)
		castbar:ClearAllPoints()
		castbar:SetAllPoints(self)
		castbar.Time:ClearAllPoints()
		castbar.Time:Point("RIGHT", self.Health, "RIGHT", -2, 0)
		castbar.Text:ClearAllPoints()
		castbar.Text:Point("LEFT", self.Health, "LEFT", 2, 0)
		castbar.Iconbg:ClearAllPoints()
		castbar.Iconbg:Point("RIGHT", self, "LEFT", -2, 1)
		castbar.shadow:Hide()
		castbar.bg:Hide()
		self.Castbar = castbar
	end

	if (unit and unit:find("arena%d") and C["uf"].showArenaFrames == true) then
		local trinkets = CreateFrame("Frame", nil, self)
		trinkets:SetHeight(BOSS_HEIGHT)
		trinkets:SetWidth(BOSS_HEIGHT)
		trinkets:SetPoint("LEFT", self, "RIGHT", 5, 0)
		trinkets:CreateShadow("Background")
		trinkets.shadow:SetFrameStrata("BACKGROUND")
		trinkets.trinketUseAnnounce = true
		trinkets.trinketUpAnnounce = true
		self.Trinket = trinkets
	end
	
    local leader = self:CreateTexture(nil, "OVERLAY")
    leader:SetSize(16, 16)
    leader:Point("TOPLEFT", self, "TOPLEFT", 7, 10)
    self.Leader = leader
	
	-- Assistant Icon
	local assistant = self:CreateTexture(nil, "OVERLAY")
    assistant:Point("TOPLEFT", self, "TOPLEFT", 7, 10)
    assistant:SetSize(16, 16)
    self.Assistant = assistant

    local masterlooter = self:CreateTexture(nil, 'OVERLAY')
    masterlooter:SetSize(16, 16)
    masterlooter:Point("TOPLEFT", self, "TOPLEFT", 20, 10)
    self.MasterLooter = masterlooter
	self.MasterLooter:SetTexture("Interface\\AddOns\\!RayUI\\media\\looter")
	self.MasterLooter:SetVertexColor(0.8, 0.8, 0.8)

    local LFDRole = self:CreateTexture(nil, 'OVERLAY')
    LFDRole:SetSize(16, 16)
    LFDRole:Point("TOPLEFT", self, -10, 10)
	self.LFDRole = LFDRole
	self.LFDRole:SetTexture("Interface\\AddOns\\!RayUI\\media\\lfd_role")
	
    local PvP = self:CreateTexture(nil, 'OVERLAY')
    PvP:SetSize(25, 25)
    PvP:Point('TOPRIGHT', self, 12, 8)
    self.PvP = PvP
	self.PvP.Override = function(self, event, unit)
		if(unit ~= self.unit) then return end

		if(self.PvP) then
			local factionGroup = UnitFactionGroup(unit)
			if(UnitIsPVPFreeForAll(unit)) then
				self.PvP:SetTexture[[Interface\TargetingFrame\UI-PVP-FFA]]
				self.PvP:Show()
			elseif(factionGroup and UnitIsPVP(unit)) then
				self.PvP:SetTexture([[Interface\AddOns\!RayUI\media\UI-PVP-]]..factionGroup)
				self.PvP:Show()
			else
				self.PvP:Hide()
			end
		end
	end

    local QuestIcon = self:CreateTexture(nil, 'OVERLAY')
    QuestIcon:SetSize(24, 24)
    QuestIcon:Point('BOTTOMRIGHT', self, 15, -2)
    self.QuestIcon = QuestIcon
	self.QuestIcon:SetTexture("Interface\\AddOns\\!RayUI\\media\\quest")
	self.QuestIcon:SetVertexColor(0.8, 0.8, 0.8)
	
    local ricon = self:CreateTexture(nil, 'OVERLAY')
    ricon:Point("BOTTOM", self, "TOP", 0, -7)
    ricon:SetSize(16,16)
    self.RaidIcon = ricon
	
	self.mouseovers = {}
	tinsert(self.mouseovers, self.Health)
	
	if self.Power then
		if self.Power.value then 
			tinsert(self.mouseovers, self.Power)
		end
	end
end

local function LoadDPSLayout()
	oUF:RegisterStyle('Ray', Shared)

	-- Player
	local player = oUF:Spawn('player', "RayUF_player")
	player:Point("BOTTOMRIGHT", UIParent, "BOTTOM", -80, 390)
	player:Size(PLAYER_WIDTH, PLAYER_HEIGHT)

	-- Target
	local target = oUF:Spawn('target', "RayUF_target")
	target:Point("BOTTOMLEFT", UIParent, "BOTTOM", 80, 390)
	target:Size(TARGET_WIDTH, TARGET_HEIGHT)

	-- Focus
	local focus = oUF:Spawn('focus', "RayUF_focus")
	focus:Point("BOTTOMRIGHT", RayUF_player, "TOPLEFT", -20, 20)
	focus:Size(PARTY_WIDTH, PARTY_HEIGHT)

	-- Target's Target
	local tot = oUF:Spawn('targettarget', "RayUF_targettarget")
	tot:Point("BOTTOMLEFT", RayUF_target, "TOPRIGHT", 5, 30)
	tot:Size(SMALL_WIDTH, SMALL_HEIGHT)

	-- Player's Pet
	local pet = oUF:Spawn('pet', "RayUF_pet")
	pet:Point("BOTTOM", RayUIPetBar, "TOP", 0, 3)
	pet:Size(SMALL_WIDTH, SMALL_HEIGHT)

	-- Focus's target
	local focustarget = oUF:Spawn('focustarget', "RayUF_focustarget")
	focustarget:Point("BOTTOMRIGHT", RayUF_focus, "BOTTOMLEFT", -10, 1)
	focustarget:Size(SMALL_WIDTH, SMALL_HEIGHT)

	if C["uf"].showArenaFrames and not IsAddOnLoaded("Gladius") then
		local arena = {}
		for i = 1, 5 do
			arena[i] = oUF:Spawn("arena"..i, "RayUFArena"..i)
			if i == 1 then
				arena[i]:Point("RIGHT", -80, 130)
			else
				arena[i]:Point("TOP", arena[i-1], "BOTTOM", 0, -25)
			end
			arena[i]:Size(BOSS_WIDTH, BOSS_HEIGHT)
		end
	end

	if C["uf"].showBossFrames then
		local boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "RayUFBoss"..i)
			if i == 1 then
				boss[i]:Point("RIGHT", -80, 130)
			else
				boss[i]:Point('TOP', boss[i-1], 'BOTTOM', 0, -25)             
			end
			boss[i]:Size(BOSS_WIDTH, BOSS_HEIGHT)
		end
	end
	
	if C["uf"].showParty and not C["raid"].showgridwhenparty then
		local party = oUF:SpawnHeader('RayUFParty', nil, 
		"custom [@raid6,exists] hide;show",
		-- "custom [group:party,nogroup:raid][@raid,noexists,group:raid] show;hide",
		-- "solo",
		"showParty", true,
		'showPlayer', false,
		-- 'showSolo',true,
		'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
		'initial-width', PARTY_WIDTH,
		'initial-height', PARTY_HEIGHT,
		"yOffset", - 20,
		"groupBy", "CLASS",
		"groupingOrder", "WARRIOR,PALADIN,DEATHKNIGHT,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,ROGUE,HUNTER"	-- Trying to put classes that can tank first
		)
		party:Point("TOPRIGHT", RayUF_player, "TOPLEFT", -20, 0)
		party:SetScale(1)
	end
end

R.Layouts["DPS"] = LoadDPSLayout