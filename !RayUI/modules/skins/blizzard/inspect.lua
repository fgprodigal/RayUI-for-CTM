local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(InspectFrame)
	InspectFrame:DisableDrawLayer("BACKGROUND")
	InspectFrame:DisableDrawLayer("BORDER")
	InspectFrameInset:DisableDrawLayer("BACKGROUND")
	InspectFrameInset:DisableDrawLayer("BORDER")
	InspectModelFrame:DisableDrawLayer("OVERLAY")

	InspectPVPTeam1:DisableDrawLayer("BACKGROUND")
	InspectPVPTeam2:DisableDrawLayer("BACKGROUND")
	InspectPVPTeam3:DisableDrawLayer("BACKGROUND")
	InspectFramePortrait:Hide()
	InspectGuildFrameBG:Hide()
	for i = 1, 5 do
		select(i, InspectModelFrame:GetRegions()):Hide()
	end
	for i = 1, 4 do
		select(i, InspectTalentFrame:GetRegions()):Hide()
		local tab = _G["InspectFrameTab"..i]
		R.CreateTab(tab)
		if i ~= 1 then
			tab:SetPoint("LEFT", _G["InspectFrameTab"..i-1], "RIGHT", -15, 0)
		end
	end
	for i = 1, 3 do
		for j = 1, 6 do
			select(j, _G["InspectTalentFrameTab"..i]:GetRegions()):Hide()
			select(j, _G["InspectTalentFrameTab"..i]:GetRegions()).Show = R.dummy
		end
	end
	if not R.HoT then
		InspectModelFrameRotateLeftButton:Hide()
		InspectModelFrameRotateRightButton:Hide()
	end
	InspectFramePortraitFrame:Hide()
	InspectFrameTopBorder:Hide()
	InspectFrameTopRightCorner:Hide()
	InspectPVPFrameBG:SetAlpha(0)
	InspectPVPFrameBottom:SetAlpha(0)
	InspectTalentFramePointsBarBorderLeft:Hide()
	InspectTalentFramePointsBarBorderMiddle:Hide()
	InspectTalentFramePointsBarBorderRight:Hide()

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Ranged", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Inspect"..slots[i].."Slot"]
		_G["Inspect"..slots[i].."SlotFrame"]:Hide()
		slot:SetNormalTexture("")
		slot:SetPushedTexture("")
		_G["Inspect"..slots[i].."SlotIconTexture"]:SetTexCoord(.08, .92, .08, .92)

	end
	if R.HoT then
		select(9, InspectMainHandSlot:GetRegions()):Hide()
		select(9, InspectRangedSlot:GetRegions()):Hide()
	else
		select(8, InspectMainHandSlot:GetRegions()):Hide()
		select(8, InspectRangedSlot:GetRegions()):Hide()
	end
	
	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function()
		if InspectFrame:IsShown() and UnitExists(InspectFrame.unit) then
			for i = 1, #slots do
				local ic = _G["Inspect"..slots[i].."SlotIconTexture"]

				if not GetInventoryItemLink(InspectFrame.unit, i) then
					ic:SetTexture(nil)
				end
			end
		end
	end)

	R.ReskinClose(InspectFrameCloseButton)
end

R.SkinFuncs["Blizzard_InspectUI"] = LoadSkin