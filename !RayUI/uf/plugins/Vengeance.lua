local R, C, L, DB = unpack(select(2, ...))
local _, ns = ...
local oUF = RayUF or ns.oUF or oUF

-- local vengeance = GetSpellInfo(93098)
local vengeance = GetSpellInfo(76691)

local function valueChanged(self, event, unit)
	if unit ~= "player" then return end
	local bar = self.Vengeance
	
	if R.Role ~= "Tank" then
		bar:Hide()
		return
	end
	
	local name = UnitAura("player", vengeance, nil, "PLAYER|HELPFUL")
	
	if name then
		local value = select(14, UnitAura("player", vengeance, nil, "PLAYER|HELPFUL")) or -1
		if value > 0 then
			if value > bar.max then value = bar.max end
			if value == bar.value then return end
			
			bar:SetMinMaxValues(0, bar.max)
			bar:SetValue(value)
			bar.value = value
			bar:Show()
			
			if bar.Text then
				bar.Text:SetText(value)
			end
		end
	elseif bar.showInfight and InCombatLockdown() then
		bar:Show()
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(0)
		bar.value = 0
	else
		bar:Hide()
		bar.value = 0
	end
end

local function maxChanged(self, event, unit)
	if unit ~= "player" then return end
	local bar = self.Vengeance
	
	if R.Role ~= "Tank" then
		bar:Hide()
		return
	end
	
	local health = UnitHealthMax("player")
	local _, stamina = UnitStat("player", 3)
	
	if not health or not stamina then return end
	
	bar.max = 0.1 * (health - 15 * stamina) + stamina
	bar:SetMinMaxValues(0, bar.max)
	valueChanged(self, event, unit)
end

local function Enable(self, unit)
	local bar = self.Vengeance
	
	if bar and unit == "player" then
		bar.max = 0
		bar.value = 0
		maxChanged(self, nil, unit)
		self:RegisterEvent("UNIT_AURA", valueChanged)

		self:RegisterEvent("UNIT_MAXHEALTH", maxChanged)
		self:RegisterEvent("UNIT_LEVEL", maxChanged)
		
		bar:Hide()
		bar:SetScript("OnEnter", function(self)
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
			if self.value > 0 then
				GameTooltip:SetUnitBuff("player", vengeance)
			end
			GameTooltip:Show()
		end)
		bar:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		return true
	end
end

local function Disable(self)
	local bar = self.Vengeance
	
	if bar then
		self:UnregisterEvent("UNIT_AURA", valueChanged)		
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", maxChanged)
		self:UnregisterEvent("UNIT_MAXHEALTH", maxChanged)
		self:UnregisterEvent("UNIT_LEVEL", maxChanged)
	end
end

oUF:AddElement("Vengeance", nil, Enable, Disable)