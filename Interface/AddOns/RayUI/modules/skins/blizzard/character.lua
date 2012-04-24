local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local S = R:GetModule("Skins")

local function LoadSkin()
	local r, g, b = S["media"].classcolours[R.myclass].r, S["media"].classcolours[R.myclass].g, S["media"].classcolours[R.myclass].b
	S:SetBD(CharacterFrame)
	S:SetBD(PetStableFrame)
	local frames = {
		"CharacterFrame",
		"CharacterFrameInset",
		"CharacterFrameInsetRight",
		"CharacterModelFrame",		
	}
	for i = 1, #frames do
		_G[frames[i]]:DisableDrawLayer("BACKGROUND")
		_G[frames[i]]:DisableDrawLayer("BORDER")
	end
	CharacterModelFrame:DisableDrawLayer("OVERLAY")
	CharacterFramePortrait:Hide()
	CharacterFrameExpandButton:GetNormalTexture():SetAlpha(0)
	CharacterFrameExpandButton:GetPushedTexture():SetAlpha(0)
	CharacterStatsPaneTop:Hide()
	CharacterStatsPaneBottom:Hide()
	CharacterFramePortraitFrame:Hide()
	CharacterFrameTopRightCorner:Hide()
	CharacterFrameTopBorder:Hide()
	CharacterFrameExpandButton:SetPoint("BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT", -14, 6)
	ReputationListScrollFrame:GetRegions():Hide()
	ReputationDetailCorner:Hide()
	ReputationDetailDivider:Hide()
	select(2, ReputationListScrollFrame:GetRegions()):Hide()
	select(3, ReputationDetailFrame:GetRegions()):Hide()
	for i = 1, 4 do
		select(i, GearManagerDialogPopup:GetRegions()):Hide()
	end
	GearManagerDialogPopupScrollFrame:GetRegions():Hide()
	select(2, GearManagerDialogPopupScrollFrame:GetRegions()):Hide()
	ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 1, -28)
	PaperDollEquipmentManagerPaneEquipSet:SetWidth(PaperDollEquipmentManagerPaneEquipSet:GetWidth()-1)
	PaperDollEquipmentManagerPaneSaveSet:SetPoint("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 1, 0)
	GearManagerDialogPopup:SetPoint("LEFT", PaperDollFrame, "RIGHT", 1, 0)
	PaperDollSidebarTabs:GetRegions():Hide()
	select(2, PaperDollSidebarTabs:GetRegions()):Hide()
	select(6, PaperDollEquipmentManagerPaneEquipSet:GetRegions()):Hide()

	S:ReskinClose(CharacterFrameCloseButton)
	S:ReskinScroll(CharacterStatsPaneScrollBar)
	S:ReskinScroll(PaperDollTitlesPaneScrollBar)
	S:ReskinScroll(PaperDollEquipmentManagerPaneScrollBar)
	S:ReskinScroll(ReputationListScrollFrameScrollBar)
	S:ReskinScroll(GearManagerDialogPopupScrollFrameScrollBar)
	S:ReskinArrow(CharacterFrameExpandButton, 1)
	S:Reskin(PaperDollEquipmentManagerPaneEquipSet)
	S:Reskin(PaperDollEquipmentManagerPaneSaveSet)
	S:Reskin(GearManagerDialogPopupOkay)
	S:Reskin(GearManagerDialogPopupCancel)
	S:ReskinClose(ReputationDetailCloseButton)
	S:ReskinCheck(ReputationDetailAtWarCheckBox)
	S:ReskinCheck(ReputationDetailInactiveCheckBox)
	S:ReskinCheck(ReputationDetailMainScreenCheckBox)
	S:ReskinInput(GearManagerDialogPopupEditBox)
	
	hooksecurefunc("CharacterFrame_Expand", function()
		select(15, CharacterFrameExpandButton:GetRegions()):SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-left-active")
	end)

	hooksecurefunc("CharacterFrame_Collapse", function()
		select(15, CharacterFrameExpandButton:GetRegions()):SetTexture("Interface\\AddOns\\RayUI\\media\\arrow-right-active")
	end)
	
	hooksecurefunc("PaperDollFrame_CollapseStatCategory", function(categoryFrame)
			categoryFrame.BgMinimized:Hide()
		end)

	hooksecurefunc("PaperDollFrame_ExpandStatCategory", function(categoryFrame)
		categoryFrame.BgTop:Hide()
		categoryFrame.BgMiddle:Hide()
		categoryFrame.BgBottom:Hide()
	end)

	local titles = false
	hooksecurefunc("PaperDollTitlesPane_Update", function()
		if titles == false then
			for i = 1, 17 do
				_G["PaperDollTitlesPaneButton"..i]:DisableDrawLayer("BACKGROUND")
			end
			titles = true
		end
	end)

	for i = 1, 4 do
		S:CreateTab(_G["CharacterFrameTab"..i])
	end

	function PaperDollFrame_SetLevel()
		local primaryTalentTree = GetPrimaryTalentTree()
		local classDisplayName, class = UnitClass("player")
		local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or S["media"].classcolours[class]
		local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
		local specName

		if (primaryTalentTree) then
			_, specName = GetTalentTabInfo(primaryTalentTree);
		end

		if (specName and specName ~= "") then
			CharacterLevelText:SetFormattedText(PLAYER_LEVEL, UnitLevel("player"), classColorString, specName, classDisplayName);
		else
			CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, UnitLevel("player"), classColorString, classDisplayName);
		end
	end

	EquipmentFlyoutFrameButtons:DisableDrawLayer("BACKGROUND")
	EquipmentFlyoutFrameButtons:DisableDrawLayer("ARTWORK")

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
		local slot = _G["Character"..slots[i].."Slot"]
		local ic = _G["Character"..slots[i].."SlotIconTexture"]
		_G["Character"..slots[i].."SlotFrame"]:Hide()

		slot.backgroundTextureName = ""
		slot.checkRelic = nil
		slot:SetNormalTexture("")
		slot:StyleButton()
		slot:SetBackdrop({
					bgFile = R["media"].blank, 
					insets = { left = -R.mult, right = -R.mult, top = -R.mult, bottom = -R.mult }
				})
		ic:SetTexCoord(.08, .92, .08, .92)
		ic:Point("TOPLEFT", 2, -2)
		ic:Point("BOTTOMRIGHT", -2, 2)
		ic.SetVertexColor = R.dummy
		ic:SetGradient("VERTICAL",.345,.345,.345,1,1,1)
		slot.glow = CreateFrame("Frame", nil, slot)
		slot.glow:SetAllPoints()
		slot.glow:CreateBorder()
	end

	select(8, CharacterMainHandSlot:GetRegions()):Kill()
	select(8, CharacterRangedSlot:GetRegions()):Kill()

	local function SkinItemFlyouts()
		for i = 1, 10 do
			local bu = _G["EquipmentFlyoutFrameButton"..i]
			local icon = _G["EquipmentFlyoutFrameButton"..i.."IconTexture"]
			if bu and not bu.reskinned then
				bu:SetNormalTexture("")
				bu:StyleButton()
				_G["EquipmentFlyoutFrameButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
				icon:Point("TOPLEFT", 2, -2)
				icon:Point("BOTTOMRIGHT", -2, 2)
				icon.SetVertexColor = R.dummy
				icon:SetGradient("VERTICAL",.345,.345,.345,1,1,1)
				bu.reskinned = true
			end
		end
	end
	EquipmentFlyoutFrameButtons:HookScript("OnShow", SkinItemFlyouts)
	hooksecurefunc("EquipmentFlyout_Show", SkinItemFlyouts)
	
	local function ColorItemBorder()
		for i = 1, #slots do
			-- Colour the equipment slots by rarity
			local target = _G["Character"..slots[i].."Slot"]
			local icon = _G["Character"..slots[i].."SlotIconTexture"]
			local slotId, _, _ = GetInventorySlotInfo(slots[i].."Slot")
			local itemId = GetInventoryItemID("player", slotId)
			
			local glow = target.glow

			if itemId then
				local _, _, rarity, _, _, _, _, _, _, _, _ = GetItemInfo(itemId)
				if rarity and rarity > 1 then
					glow:SetAllPoints()
					glow:SetBackdropBorderColor(GetItemQualityColor(rarity))
					target:SetBackdropColor(0, 0, 0)
				else
					glow:Point("TOPLEFT", 1, -1)
					glow:Point("BOTTOMRIGHT", -1, 1)
					glow:SetBackdropBorderColor(0, 0, 0)
					target:SetBackdropColor(0, 0, 0, 0)
				end
			else
				glow:SetBackdropBorderColor(0, 0, 0, 0)
				target:SetBackdropColor(0, 0, 0, 0)
			end
		end
	end

	local CheckItemBorderColor = CreateFrame("Frame")
	CheckItemBorderColor:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	CheckItemBorderColor:SetScript("OnEvent", ColorItemBorder)	
	CharacterFrame:HookScript("OnShow", ColorItemBorder)
	ColorItemBorder()
	
	local function ColorFlyOutItemBorder(self)
		local location = self.location
		local glow = self.glow
		if(not glow) then
			self.glow = glow
			glow = CreateFrame("Frame", nil, self)
			glow:SetAllPoints()
			glow:CreateBorder()
			self.glow = glow			
			self:SetBackdrop({
					bgFile = R["media"].blank, 
					insets = { left = -R.mult, right = -R.mult, top = -R.mult, bottom = -R.mult }
				})
		end
		if (not location) or (location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION) then
			self.glow:Point("TOPLEFT", 1, -1)
			self.glow:Point("BOTTOMRIGHT", -1, 1)
			self.glow:SetBackdropBorderColor(0, 0, 0)
			self:SetBackdropColor(0, 0, 0, 0)
			return
		end
		local id = EquipmentManager_GetItemInfoByLocation(location)
		local icon = _G[self:GetName().."IconTexture"]
		if id then
			local _, _, rarity, _, _, _, _, _, _, _, _ = GetItemInfo(id)
			if rarity and rarity > 1 then
				glow:SetAllPoints()
				glow:SetBackdropBorderColor(GetItemQualityColor(rarity))
				self:SetBackdropColor(0, 0, 0)
			else
				glow:Point("TOPLEFT", 1, -1)
				glow:Point("BOTTOMRIGHT", -1, 1)
				glow:SetBackdropBorderColor(0, 0, 0)
				self:SetBackdropColor(0, 0, 0, 0)
			end
		else
			glow:Point("TOPLEFT", 1, -1)
			glow:Point("BOTTOMRIGHT", -1, 1)
			glow:SetBackdropBorderColor(0, 0, 0)
			self:SetBackdropColor(0, 0, 0, 0)
		end
	end

	hooksecurefunc("EquipmentFlyout_DisplayButton", ColorFlyOutItemBorder)
	hooksecurefunc("EquipmentFlyout_Show", function()
		local flyout = EquipmentFlyoutFrame
		local buttonAnchor = flyout.buttonFrame
		local p1, parent, p2, x, y = buttonAnchor:GetPoint()
		if p2 == "TOPRIGHT" then
			buttonAnchor:ClearAllPoints()
			buttonAnchor:Point(p1, parent, p2, x, 2)
		elseif p2 == "BOTTOMLEFT" then
			buttonAnchor:ClearAllPoints()
			buttonAnchor:Point(p1, parent, p2, -2, y)
		end
	end)

	for i = 1, #PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i]

		if i == 1 then
			for i = 1, 4 do
				local region = select(i, tab:GetRegions())
				region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
				region.SetTexCoord = R.dummy
			end
		end

		tab.Highlight:SetTexture(r, g, b, .2)
		tab.Highlight:Point("TOPLEFT", 3, -4)
		tab.Highlight:Point("BOTTOMRIGHT", -1, 0)
		tab.Hider:SetTexture(.3, .3, .3, .4)
		tab.TabBg:SetAlpha(0)

		select(2, tab:GetRegions()):ClearAllPoints()
		if i == 1 then
			select(2, tab:GetRegions()):Point("TOPLEFT", 3, -4)
			select(2, tab:GetRegions()):Point("BOTTOMRIGHT", -1, 0)
		else
			select(2, tab:GetRegions()):Point("TOPLEFT", 2, -4)
			select(2, tab:GetRegions()):Point("BOTTOMRIGHT", -1, -1)
		end

		tab.bg = CreateFrame("Frame", nil, tab)
		tab.bg:Point("TOPLEFT", 2, -3)
		tab.bg:Point("BOTTOMRIGHT", 0, -1)
		tab.bg:SetFrameLevel(0)
		S:CreateBD(tab.bg)

		tab.Hider:Point("TOPLEFT", tab.bg, 1, -1)
		tab.Hider:Point("BOTTOMRIGHT", tab.bg, -1, 1)
	end

	for i = 1, NUM_GEARSET_ICONS_SHOWN do
		local bu = _G["GearManagerDialogPopupButton"..i]
		local ic = _G["GearManagerDialogPopupButton"..i.."Icon"]

		bu:SetCheckedTexture(S["media"].checked)
		select(2, bu:GetRegions()):Hide()
		ic:Point("TOPLEFT", 1, -1)
		ic:Point("BOTTOMRIGHT", -1, 1)
		ic:SetTexCoord(.08, .92, .08, .92)

		S:CreateBD(bu, .25)
	end

	local sets = false
	PaperDollSidebarTab3:HookScript("OnClick", function()
		if sets == false then
			for i = 1, 8 do
				local bu = _G["PaperDollEquipmentManagerPaneButton"..i]
				local bd = _G["PaperDollEquipmentManagerPaneButton"..i.."Stripe"]
				local ic = _G["PaperDollEquipmentManagerPaneButton"..i.."Icon"]
				_G["PaperDollEquipmentManagerPaneButton"..i.."BgTop"]:SetAlpha(0)
				_G["PaperDollEquipmentManagerPaneButton"..i.."BgMiddle"]:Hide()
				_G["PaperDollEquipmentManagerPaneButton"..i.."BgBottom"]:SetAlpha(0)

				bd:Hide()
				bd.Show = R.dummy
				ic:SetTexCoord(.08, .92, .08, .92)

				S:CreateBG(ic)
			end
			sets = true
		end
	end)
	
	-- Reputation frame
	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local statusbar = _G["ReputationBar"..i.."ReputationBar"]

			if statusbar then
				statusbar:SetStatusBarTexture(S["media"].backdrop)

				if not statusbar.reskinned then
				--	S:CreateBD(statusbar, .25)
					local frame = CreateFrame("Frame",nil, statusbar)
					S:CreateBD(frame, .25)
					frame:SetFrameLevel(statusbar:GetFrameLevel() -1)
					frame:Point("TOPLEFT", -1, 1)
					frame:Point("BOTTOMRIGHT", 1, -1)
					statusbar.reskinned = true
				end

				_G["ReputationBar"..i.."Background"]:SetTexture(nil)
				_G["ReputationBar"..i.."LeftLine"]:SetAlpha(0)
				_G["ReputationBar"..i.."BottomLine"]:SetAlpha(0)
				_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)	
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)
			end		
		end		
	end

	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	hooksecurefunc("ReputationFrame_OnEvent", UpdateFactionSkins)
	
	-- Pet stuff
	if R.myclass == "HUNTER" or R.myclass == "MAGE" or R.myclass == "DEATHKNIGHT" or R.myclass == "WARLOCK" then
		if R.myclass == "HUNTER" then
			PetStableFrame:DisableDrawLayer("BACKGROUND")
			PetStableFrame:DisableDrawLayer("BORDER")
			PetStableFrameInset:DisableDrawLayer("BACKGROUND")
			PetStableFrameInset:DisableDrawLayer("BORDER")
			PetStableBottomInset:DisableDrawLayer("BACKGROUND")
			PetStableBottomInset:DisableDrawLayer("BORDER")
			PetStableLeftInset:DisableDrawLayer("BACKGROUND")
			PetStableLeftInset:DisableDrawLayer("BORDER")
			PetStableFramePortrait:Hide()
			PetStableModelShadow:Hide()
			PetStableFramePortraitFrame:Hide()
			PetStableFrameTopBorder:Hide()
			PetStableFrameTopRightCorner:Hide()
			PetStableModelRotateLeftButton:Hide()
			PetStableModelRotateRightButton:Hide()
			
			PetStableSelectedPetIcon:SetTexCoord(.08, .92, .08, .92)
			local bd = CreateFrame("Frame", nil, PetStableFrame)
			bd:Point("TOPLEFT", PetStableSelectedPetIcon, -1, 1)
			bd:Point("BOTTOMRIGHT", PetStableSelectedPetIcon, 1, -1)
			S:CreateBD(bd, .25)

			S:ReskinClose(PetStableFrameCloseButton)
			S:ReskinArrow(PetStablePrevPageButton, 1)
			S:ReskinArrow(PetStableNextPageButton, 2)

			for i = 1, 10 do
				local bu = _G["PetStableStabledPet"..i]
				local bd = CreateFrame("Frame", nil, bu)
				bd:Point("TOPLEFT", -1, 1)
				bd:Point("BOTTOMRIGHT", 1, -1)
				bd:SetFrameLevel(0)
				S:CreateBD(bd, .25)
				bu:StripTextures()
				bu:StyleButton(true)
				_G["PetStableStabledPet"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
			end
			
			for i = 1, 5 do
				local bu = _G["PetStableActivePet"..i]
				local bd = CreateFrame("Frame", nil, bu)
				bd:Point("TOPLEFT", -1, 1)
				bd:Point("BOTTOMRIGHT", 1, -1)
				bd:SetFrameLevel(0)
				S:CreateBD(bd, .25)
				bu:StripTextures()
				bu:StyleButton(true)
				_G["PetStableActivePet"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
			end
		end

		local function FixTab()
			if CharacterFrameTab2:IsShown() then
				CharacterFrameTab3:SetPoint("LEFT", CharacterFrameTab2, "RIGHT", -15, 0)
			else
				CharacterFrameTab3:SetPoint("LEFT", CharacterFrameTab1, "RIGHT", -15, 0)
			end
		end
		CharacterFrame:HookScript("OnEvent", FixTab)
		CharacterFrame:HookScript("OnShow", FixTab)

		PetModelFrameRotateLeftButton:Hide()
		PetModelFrameRotateRightButton:Hide()
		PetModelFrameShadowOverlay:Hide()
		PetPaperDollXPBar1:Hide()
		select(2, PetPaperDollFrameExpBar:GetRegions()):Hide()
		PetPaperDollPetModelBg:SetAlpha(0)
		PetPaperDollFrameExpBar:SetStatusBarTexture(R["media"].normal)

		local bbg = CreateFrame("Frame", nil, PetPaperDollFrameExpBar)
		bbg:Point("TOPLEFT", -1, 1)
		bbg:Point("BOTTOMRIGHT", 1, -1)
		bbg:SetFrameLevel(PetPaperDollFrameExpBar:GetFrameLevel()-1)
		S:CreateBD(bbg, .25)
	end
end

S:RegisterSkin("RayUI", LoadSkin)