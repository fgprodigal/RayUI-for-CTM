local R, C = unpack(RayUI)
local gcol = {.35, 1, .6}										-- Guild Color
local pgcol = {1, .12, .8} 									-- Player's Guild Color
local position = { "BOTTOMRIGHT", UIParent, "RIGHT", -25, 20 }	-- Static Tooltip position
local scale = 1												-- Tooltip scale
local cursor = true

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeSize = R.mult,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local tooltips = {
	GameTooltip, 
	ItemRefTooltip, 
	ShoppingTooltip1, 
	ShoppingTooltip2, 
	ShoppingTooltip3, 
	WorldMapTooltip, 
	DropDownList1MenuBackdrop, 
	DropDownList2MenuBackdrop, 
}

local types = {
	rare = " R ",
	elite = " + ",
	worldboss = " B ",
	rareelite = " R+ ",
}

for _, v in pairs(tooltips) do
	v:SetBackdrop(backdrop)
	v:SetBackdropColor(0, 0, 0, 0.6)
	v:SetBackdropBorderColor(0, 0, 0, 1)
	v:SetScale(scale)
	v:SetScript("OnShow", function(self)
		self:SetBackdropColor(0, 0, 0, 0.6)
		local item
		if self.GetItem then
			item = select(2, self:GetItem())
		end
		if item then
			local quality = select(3, GetItemInfo(item))
			if quality and quality > 1 then
				local r, g, b = GetItemQualityColor(quality)
				self:SetBackdropBorderColor(r, g, b)
			end
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end
		if v.NumLines then
			for index=1, v:NumLines() do
				_G[v:GetName()..'TextLeft'..index]:SetShadowOffset(R.mult, -R.mult)
			end
		end
	end)
	v:HookScript("OnHide", function(self)
		self:SetBackdropBorderColor(0, 0, 0, 1)
	end)
end

local hex = function(r, g, b)
	return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

local truncate = function(value)
	if value >= 1e6 then
		return string.format('%.2fm', value / 1e6)
	elseif value >= 1e4 then
		return string.format('%.1fk', value / 1e3)
	else
		return string.format('%.0f', value)
	end
end

function GameTooltip_UnitColor(unit)
	local r, g, b = 1, 1, 1
	if UnitPlayerControlled(unit) then
		if UnitCanAttack(unit, "player") then
			if UnitCanAttack("player", unit) then
				r = FACTION_BAR_COLORS[2].r
				g = FACTION_BAR_COLORS[2].g
				b = FACTION_BAR_COLORS[2].b
			end
		elseif UnitCanAttack("player", unit) then
			r = FACTION_BAR_COLORS[4].r
			g = FACTION_BAR_COLORS[4].g
			b = FACTION_BAR_COLORS[4].b
		elseif UnitIsPVP(unit) then
			r = FACTION_BAR_COLORS[6].r
			g = FACTION_BAR_COLORS[6].g
			b = FACTION_BAR_COLORS[6].b
		end
	else
		local reaction = UnitReaction(unit, "player")
		if reaction then
			r = FACTION_BAR_COLORS[reaction].r
			g = FACTION_BAR_COLORS[reaction].g
			b = FACTION_BAR_COLORS[reaction].b
		end
	end
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		if class then
			r = RAID_CLASS_COLORS[class].r
			g = RAID_CLASS_COLORS[class].g
			b = RAID_CLASS_COLORS[class].b
		end
	end
	return r, g, b
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local unit = select(2, self:GetUnit())
	if unit then
		local unitClassification = types[UnitClassification(unit)] or " "
		local diffColor = GetQuestDifficultyColor(UnitLevel(unit))
		local creatureType = UnitCreatureType(unit) or ""
		local unitName = UnitName(unit)
		local unitLevel = UnitLevel(unit)
		if unitLevel < 0 then unitLevel = '??' end
		if UnitIsPlayer(unit) then
			local unitRace = UnitRace(unit)
			local _, unitClass = UnitClass(unit)
			local guild, rank = GetGuildInfo(unit)
			local playerGuild = GetGuildInfo("player")
			GameTooltipStatusBar:SetStatusBarColor(unpack({GameTooltip_UnitColor(unit)}))
			if guild then
				GameTooltipTextLeft2:SetFormattedText("<%s>"..hex(1, 1, 1).." %s|r", guild, rank)
				if IsInGuild() and guild == playerGuild then
					GameTooltipTextLeft2:SetTextColor(pgcol[1], pgcol[2], pgcol[3])
				else
					GameTooltipTextLeft2:SetTextColor(gcol[1], gcol[2], gcol[3])
				end
			end
			for i=2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft" .. i]:GetText():find(PLAYER) then
					_G["GameTooltipTextLeft" .. i]:SetText(string.format(hex(diffColor.r, diffColor.g, diffColor.b).."%s|r ", unitLevel) .. unitRace)
					break
				end
			end
		else
			for i=2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft" .. i]:GetText():find(LEVEL) or _G["GameTooltipTextLeft" .. i]:GetText():find(creatureType) then
					_G["GameTooltipTextLeft" .. i]:SetText(string.format(hex(diffColor.r, diffColor.g, diffColor.b).."%s|r", unitLevel) .. unitClassification .. creatureType)
					break
				end
			end
		end
		if UnitIsPVP(unit) then
			for i = 2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft"..i]:GetText():find(PVP) then
					_G["GameTooltipTextLeft"..i]:SetText(nil)
					break
				end
			end
		end
		if UnitExists(unit.."target") then
			local r, g, b = GameTooltip_UnitColor(unit.."target")
			if UnitName(unit.."target") == UnitName("player") then
				text = hex(1, 0, 0)..">>你<<|r"
			else
				text = hex(r, g, b)..UnitName(unit.."target").."|r"
			end
			self:AddLine(TARGET..": "..text)
		end
	end
end)

GameTooltipStatusBar.bg = CreateFrame("Frame", nil, GameTooltipStatusBar)
GameTooltipStatusBar.bg:SetPoint("TOPLEFT", GameTooltipStatusBar, "TOPLEFT", -1, 1)
GameTooltipStatusBar.bg:SetPoint("BOTTOMRIGHT", GameTooltipStatusBar, "BOTTOMRIGHT", 1, -1)
GameTooltipStatusBar.bg:SetFrameStrata("LOW")
GameTooltipStatusBar.bg:SetBackdrop(backdrop)
GameTooltipStatusBar.bg:SetBackdropColor(0, 0, 0, 0.5)
GameTooltipStatusBar.bg:SetBackdropBorderColor(0, 0, 0, 1)
GameTooltipStatusBar:SetHeight(8)
GameTooltipStatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 1, -2)
GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -1, -2)
GameTooltipStatusBar:HookScript("OnValueChanged", function(self, value)
	if not value then
		return
	end
	local min, max = self:GetMinMaxValues()
	if value < min or value > max then
		return
	end
	local unit  = select(2, GameTooltip:GetUnit())
	if unit then
		min, max = UnitHealth(unit), UnitHealthMax(unit)
		if not self.text then
			self.text = self:CreateFontString(nil, "OVERLAY")
			self.text:SetPoint("CENTER", GameTooltipStatusBar)
			self.text:SetFont(GameFontNormal:GetFont(), 11, "THINOUTLINE")
			self.text:SetShadowOffset(R.mult, -R.mult)
		end
		self.text:Show()
		local hp = truncate(min).." / "..truncate(max)
		self.text:SetText(hp)
	else
		if self.text then
			self.text:Hide()
		end
	end
end)


local iconFrame = CreateFrame("Frame", nil, ItemRefTooltip)
iconFrame:SetWidth(30)
iconFrame:SetHeight(30)
iconFrame:SetPoint("TOPRIGHT", ItemRefTooltip, "TOPLEFT", -3, 0)
iconFrame:SetBackdrop(backdrop)
iconFrame:SetBackdropColor(0, 0, 0, 0.5)
iconFrame:SetBackdropBorderColor(0, 0, 0, 1)
iconFrame2 = CreateFrame("Frame", nil, iconFrame)
iconFrame2:SetAllPoints(iconFrame)
iconFrame2:SetFrameLevel(iconFrame:GetFrameLevel()+1)
iconFrame.icon = iconFrame2:CreateTexture(nil, "BACKGROUND")
iconFrame.icon:SetPoint("TOPLEFT", 1, -1)
iconFrame.icon:SetPoint("BOTTOMRIGHT", -1, 1)
iconFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

hooksecurefunc("SetItemRef", function(link, text, button)
	if iconFrame:IsShown() then
		iconFrame:Hide()
	end
	local type, id = string.match(link, "(%l+):(%d+)") 
	if type == "item" then
		iconFrame.icon:SetTexture(select(10, GetItemInfo(id)))
		iconFrame:Show()
	elseif type == "spell" then
		iconFrame.icon:SetTexture(select(3, GetSpellInfo(id)))
		iconFrame:Show()
	elseif type == "achievement" then
		iconFrame.icon:SetTexture(select(10, GetAchievementInfo(id)))
		iconFrame:Show()
	end
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	if cursor then
        tooltip:SetOwner(parent, "ANCHOR_CURSOR")
    else
        tooltip:SetOwner(parent, "ANCHOR_NONE")
		tooltip:SetPoint(unpack(position))
    end	
	tooltip.default = 1
end)

GameTooltip:HookScript("OnUpdate", function(self, ...)
   if self:GetAnchorType() == "ANCHOR_CURSOR" then
	  local x, y = GetCursorPosition()
	  local effScale = self:GetEffectiveScale()
	  local width = self:GetWidth() or 0
	  self:ClearAllPoints()
	  self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x / effScale - width / 2, y / effScale + 15)
   end
end)