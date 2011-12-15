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
	InspectFramePortraitFrame:Hide()
	InspectFrameTopBorder:Hide()
	InspectFrameTopRightCorner:Hide()
	InspectPVPFrameBG:SetAlpha(0)
	InspectPVPFrameBottom:SetAlpha(0)
	InspectTalentFramePointsBarBorderLeft:Hide()
	InspectTalentFramePointsBarBorderMiddle:Hide()
	InspectTalentFramePointsBarBorderRight:Hide()

	local slots = {
		"Head",
		"Neck",
		"Shoulder",
		"Shirt",
		"Chest",
		"Waist",
		"Legs",
		"Feet",
		"Wrist",
		"Hands",
		"Finger0",
		"Finger1",
		"Trinket0",
		"Trinket1",
		"Back",
		"MainHand",
		"SecondaryHand",
		"Ranged",
		"Tabard"
	}

	for i = 1, #slots do
		local slot = _G["Inspect"..slots[i].."Slot"]
		_G["Inspect"..slots[i].."SlotFrame"]:Hide()
		slot:SetNormalTexture("")
		slot.backgroundTextureName = ""
		slot.checkRelic = nil
		slot:SetNormalTexture("")
		slot:StyleButton()
		slot:GetHighlightTexture():SetAllPoints()
		slot:GetPushedTexture():SetAllPoints()
		_G["Inspect"..slots[i].."SlotIconTexture"]:SetTexCoord(.08, .92, .08, .92)
		slot:SetBackdrop({
					bgFile = C["media"].blank, 
					insets = { left = -R.mult, right = -R.mult, top = -R.mult, bottom = -R.mult }
				})
	end
	select(7, InspectMainHandSlot:GetRegions()):Kill()
	select(7, InspectRangedSlot:GetRegions()):Kill()
	-- select(9, InspectMainHandSlot:GetRegions()):Kill()
	-- select(9, InspectRangedSlot:GetRegions()):Kill()

	R.ReskinClose(InspectFrameCloseButton)
	
	local CheckItemBorderColor = CreateFrame("Frame")
	local function ScanSlots()
		local unit = InspectFrame.unit
		if not (InspectFrame:IsShown() and UnitExists(unit) and UnitIsPlayer(unit)) then return end
		local notFound
		for i = 1, #slots do
			-- Colour the equipment slots by rarity
			local target = _G["Inspect"..slots[i].."Slot"]
			local icon = _G["Inspect"..slots[i].."SlotIconTexture"]
			local slotId, _, _ = GetInventorySlotInfo(slots[i].."Slot")
			local itemId = GetInventoryItemID("target", slotId)
			
			local glow = target.glow
			if(not glow) then
				target.glow = glow
				glow = CreateFrame("Frame", nil, target)
				glow:Point("TOPLEFT", -1, 1)
				glow:Point("BOTTOMRIGHT", 1, -1)
				glow:CreateBorder()
				target.glow = glow
			end

			if itemId then
				local _, _, rarity, _, _, _, _, _, _, _, _ = GetItemInfo(itemId)
				if not rarity then notFound = true end
				if rarity and rarity > 1 then
					glow:SetBackdropBorderColor(GetItemQualityColor(rarity))
					icon:Point("TOPLEFT", 1, -1)
					icon:Point("BOTTOMRIGHT", -1, 1)
					target:SetBackdrop({
						bgFile = C["media"].blank, 
						insets = { left = -R.mult, right = -R.mult, top = -R.mult, bottom = -R.mult }
					})
					target:SetBackdropColor(0, 0, 0)
				else
					glow:SetBackdropBorderColor(0, 0, 0, 0)
					icon:SetAllPoints()
					target:SetBackdropColor(0, 0, 0, 0)
				end
			else
				glow:SetBackdropBorderColor(0, 0, 0, 0)
				target:SetBackdropColor(0, 0, 0, 0)
			end
		end	
		
		if notFound == true then
			return false
		else
			CheckItemBorderColor:SetScript('OnUpdate', nil) --Stop updating
			return true
		end		
	end
	
	local function ColorItemBorder(self)
		if self and not ScanSlots() then
			self:SetScript("OnUpdate", ScanSlots) --Run function until all items borders are colored, sometimes when you have never seen an item before GetItemInfo will return nil, when this happens we have to wait for the server to send information.
		end 
	end

	CheckItemBorderColor:RegisterEvent("PLAYER_TARGET_CHANGED")
	CheckItemBorderColor:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	CheckItemBorderColor:RegisterEvent("PARTY_MEMBERS_CHANGED")
	CheckItemBorderColor:SetScript("OnEvent", ColorItemBorder)	
	InspectFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder(CheckItemBorderColor)
end

R.SkinFuncs["Blizzard_InspectUI"] = LoadSkin