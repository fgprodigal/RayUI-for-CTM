-- Based on oGlow by Haste

local R, C = unpack(select(2, ...))

local function UpdateGlow(button, id)
	local quality, texture, _
	local quest = _G[button:GetName().."IconQuestTexture"]
	if(id) then
		quality, _, _, _, _, _, _, texture = select(3, GetItemInfo(id))
	end

	local glow = button.glow
	if(not glow) then
		button.glow = glow
		glow = button:CreateTexture(nil, "BACKGROUND")
		glow:Point("TOPLEFT", -1, 1)
		glow:Point("BOTTOMRIGHT", 1, -1)
		glow:SetTexture(C.Aurora.backdrop)
		button.glow = glow
	end

	if(texture) then
		local r, g, b
		if quest and quest:IsShown() then
			r, g, b = 1, 0, 0
		else
			r, g, b = GetItemQualityColor(quality)
			if(r==1) then r, g, b = 0, 0, 0 end
		end
		glow:SetVertexColor(r, g, b)
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
	if InspectFrame:IsShown() and unit then
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