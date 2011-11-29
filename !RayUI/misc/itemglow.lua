-- Based on oGlow by Haste

local R, C, L, DB = unpack(select(2, ...))
local Unusable

if R.myclass == 'DEATHKNIGHT' then
	Unusable = {{3, 4, 10, 11, 13, 14, 15, 16}, {6}}
elseif R.myclass == 'DRUID' then
	Unusable = {{1, 2, 3, 4, 8, 9, 14, 15, 16}, {4, 5, 6}, true}
elseif R.myclass == 'HUNTER' then
	Unusable = {{5, 6, 16}, {5, 6, 7}}
elseif R.myclass == 'MAGE' then
	Unusable = {{1, 2, 3, 4, 5, 6, 7, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif R.myclass == 'PALADIN' then
	Unusable = {{3, 4, 10, 11, 13, 14, 15, 16}, {}, true}
elseif R.myclass == 'PRIEST' then
	Unusable = {{1, 2, 3, 4, 6, 7, 8, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif R.myclass == 'ROGUE' then
	Unusable = {{2, 6, 7, 9, 10, 16}, {4, 5, 6, 7}}
elseif R.myclass == 'SHAMAN' then
	Unusable = {{3, 4, 7, 8, 9, 14, 15, 16}, {5}}
elseif R.myclass == 'WARLOCK' then
	Unusable = {{1, 2, 3, 4, 5, 6, 7, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif R.myclass == 'WARRIOR' then
	Unusable = {{16}, {7}}
end

for class = 1, 2 do
	local subs = {GetAuctionItemSubClasses(class)}
	for i, subclass in ipairs(Unusable[class]) do
		Unusable[subs[subclass]] = true
	end
		
	Unusable[class] = nil
	subs = nil
end

local function IsClassUnusable(subclass, slot)
	if subclass then
		return Unusable[subclass] or slot == 'INVTYPE_WEAPONOFFHAND' and Unusable[3]
	end
end

local function IsItemUnusable(...)
	if ... then
		local subclass, _, slot = select(7, GetItemInfo(...))
		return IsClassUnusable(subclass, slot)
	end
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
		if IsItemUnusable(link) then
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

hooksecurefunc("ContainerFrame_Update", function(self)
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
			-- Ammo is located at 0.
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
		InspectFrame:HookScript("OnShow", function()
			g:RegisterEvent("PLAYER_TARGET_CHANGED")
			g:RegisterEvent("INSPECT_READY")
			g:SetScript("OnEvent", updateinspect)
			updateinspect()
		end)
		InspectFrame:HookScript("OnHide", function()
			g:UnregisterEvent("PLAYER_TARGET_CHANGED")
			g:UnregisterEvent("INSPECT_READY")
			g:SetScript("OnEvent", nil)
		end)
		g:UnregisterEvent("ADDON_LOADED")
	end
end)

hooksecurefunc("TradeFrame_UpdatePlayerItem", function(id)
	local link = GetTradePlayerItemLink(id)
	local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
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
	if(texture) then
		local r, g, b
		if IsItemUnusable(link) then
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
	local link = GetTradePlayerItemLink(id)
	local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
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
	if(texture) then
		local r, g, b
		if IsItemUnusable(link) then
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