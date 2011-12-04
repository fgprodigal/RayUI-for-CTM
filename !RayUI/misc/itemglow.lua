-- Based on oGlow by Haste

local R, C, L, DB = unpack(select(2, ...))
local Unusable
local tooltip = CreateFrame("GameTooltip", "ItemGlowTooltip", UIParent, "GameTooltipTemplate")
tooltip:SetOwner( UIParent, "ANCHOR_NONE" )

local function TooltipCanUse(tooltip)
	local l = { "TextLeft", "TextRight" }
	local n = tooltip:NumLines()
	if n > 5 then n = 5 end
	for i = 2, n do
		for _, v in pairs( l ) do
			local obj = _G[string.format( "%s%s%s", tooltip:GetName( ), v, i )]
			if obj and obj:IsShown( ) then
				local txt = obj:GetText( )
				local r, g, b = obj:GetTextColor( )
				local c = string.format( "%02x%02x%02x", r * 255, g * 255, b * 255 )
				if c == "fe1f1f" then
					if txt ~= ITEM_DISENCHANT_NOT_DISENCHANTABLE then
						return false
					end
				end
			end
		end
	end

	return true
end

local function UpdateGlow(button, id)
	local quality, texture, link, _
	local quest = _G[button:GetName().."IconQuestTexture"]
	local icontexture = _G[button:GetName().."IconTexture"]
	if(id) then
		_, link, quality, _, _, _, _, _, _, texture = GetItemInfo(id)
	end

	local glow = button.glow
	if(not glow) then
		button.glow = glow
		glow = CreateFrame("Frame", nil, button)
		glow:Point("TOPLEFT", -1, 1)
		glow:Point("BOTTOMRIGHT", 1, -1)
		glow:CreateBorder()
		button.glow = glow
	end

	if(texture) then
		local r, g, b
		ItemGlowTooltip:ClearLines()
		ItemGlowTooltip:SetHyperlink(link)
		
		-- if IsItemUnusable(link) then
		if not TooltipCanUse(ItemGlowTooltip) and not button:GetName():find("Inspect") then
			icontexture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		else
			icontexture:SetVertexColor(1, 1, 1)
		end	
		if quest and quest:IsShown() then
			r, g, b = 1, 0, 0
		else
			r, g, b = GetItemQualityColor(quality)
			if (quality <=1 ) then r, g, b = 0, 0, 0 end
		end
		glow:SetBackdropBorderColor(r, g, b)
		glow:Show()
	else
		glow:Hide()
	end
end

hooksecurefunc("BankFrameItemButton_Update", function(self)
	UpdateGlow(self, GetInventoryItemID("player", self:GetInventorySlot()))
end)

hooksecurefunc("BankFrame_UpdateCooldown", function(_, self)
	UpdateGlow(self, GetInventoryItemID("player", self:GetInventorySlot()))
end)


hooksecurefunc("ContainerFrame_Update", function(self)
	local name = self:GetName()
	local id = self:GetID()

	for i=1, self.size do
		local button = _G[name.."Item"..i]
		local itemID = GetContainerItemID(id, button:GetID())
		UpdateGlow(button, itemID)
	end
end)

hooksecurefunc("ContainerFrame_UpdateCooldowns", function(self)
	local name = self:GetName()
	local id = self:GetID()

	for i=1, self.size do
		local button = _G[name.."Item"..i]
		local itemID = GetContainerItemID(id, button:GetID())
		UpdateGlow(button, itemID)
	end
end)

local slots = {
	"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
	"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
	"SecondaryHand", "Ranged", "Tabard",
}

local updatechar = function(self)
	if CharacterFrame:IsShown() then
		for key, slotName in ipairs(slots) do
			local slotID = key % 20
			local slotFrame = _G['Character' .. slotName .. 'Slot']
			local slotLink = GetInventoryItemLink('player', slotID)
			UpdateGlow(slotFrame, slotLink)
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:SetScript("OnEvent", updatechar)
CharacterFrame:HookScript('OnShow', updatechar)

local updateinspect = function(self)
	local unit = InspectFrame.unit
	if InspectFrame:IsShown() and UnitExists(unit) then
		for key, slotName in ipairs(slots) do
			local slotID = key % 20
			local slotFrame = _G["Inspect"..slotName.."Slot"]
			local slotLink = GetInventoryItemLink(unit, slotID)
			UpdateGlow(slotFrame, slotLink)
		end
	end	
end

local g = CreateFrame("Frame")
g:RegisterEvent("ADDON_LOADED")
g:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_InspectUI" then
		g:RegisterEvent("PLAYER_TARGET_CHANGED")
		g:RegisterEvent("INSPECT_READY")
		g:SetScript("OnEvent", updateinspect)
		hooksecurefunc("InspectPaperDollItemSlotButton_Update", updateinspect)
		InspectFrame:HookScript("OnShow", function()
			updateinspect()
		end)
		g:UnregisterEvent("ADDON_LOADED")
	end
end)

hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
	local link = GetTradePlayerItemLink(id)
	local button = _G["TradePlayerItem"..id.."ItemButton"]
	local icontexture = _G["TradePlayerItem"..id.."ItemButtonIconTexture"]
	local glow = button.glow
	if(not glow) then
		button.glow = glow
		glow = CreateFrame("Frame", nil, button)
		glow:Point("TOPLEFT", -1, 1)
		glow:Point("BOTTOMRIGHT", 1, -1)
		glow:CreateBorder()
		button.glow = glow
	end
	if(link) then
		local r, g, b
		local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
		ItemGlowTooltip:ClearLines()
		ItemGlowTooltip:SetHyperlink(link)
		
		-- if IsItemUnusable(link) then
		if not TooltipCanUse(ItemGlowTooltip) then
			icontexture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		else
			icontexture:SetVertexColor(1, 1, 1)
		end		
		r, g, b = GetItemQualityColor(quality)
		if (quality <=1 ) then r, g, b = 0, 0, 0 end
		glow:SetBackdropBorderColor(r, g, b)
		glow:Show()
	else
		glow:Hide()
	end
end)

hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
	local link = GetTradeTargetItemLink(id)
	local button = _G["TradeRecipientItem"..id.."ItemButton"]
	local icontexture = _G["TradeRecipientItem"..id.."ItemButtonIconTexture"]
	local glow = button.glow
	if(not glow) then
		button.glow = glow
		glow = CreateFrame("Frame", nil, button)
		glow:Point("TOPLEFT", -1, 1)
		glow:Point("BOTTOMRIGHT", 1, -1)
		glow:CreateBorder()
		button.glow = glow
	end
	if(link) then
		local r, g, b
		local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
		ItemGlowTooltip:ClearLines()
		ItemGlowTooltip:SetHyperlink(link)
		
		-- if IsItemUnusable(link) then
		if not TooltipCanUse(ItemGlowTooltip) then
			icontexture:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		else
			icontexture:SetVertexColor(1, 1, 1)
		end		
		r, g, b = GetItemQualityColor(quality)
		if (quality <=1 ) then r, g, b = 0, 0, 0 end
		glow:SetBackdropBorderColor(r, g, b)
		glow:Show()
	else
		glow:Hide()
	end
end)