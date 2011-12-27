local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.CreateBD(TradeSkillFrame)
	R.CreateSD(TradeSkillFrame)
	R.CreateBD(TradeSkillGuildFrame)
	R.CreateSD(TradeSkillGuildFrame)
	R.CreateBD(TradeSkillGuildFrameContainer, .25)

	TradeSkillFrame:DisableDrawLayer("BORDER")
	TradeSkillFrameInset:DisableDrawLayer("BORDER")
	TradeSkillFramePortrait:Hide()
	TradeSkillFramePortrait.Show = R.dummy
	for i = 18, 20 do
		select(i, TradeSkillFrame:GetRegions()):Hide()
		select(i, TradeSkillFrame:GetRegions()).Show = R.dummy
	end
	TradeSkillHorizontalBarLeft:Hide()
	select(22, TradeSkillFrame:GetRegions()):Hide()
	for i = 1, 3 do
		select(i, TradeSkillExpandButtonFrame:GetRegions()):Hide()
		select(i, TradeSkillFilterButton:GetRegions()):Hide()
	end
	for i = 1, 9 do
		select(i, TradeSkillGuildFrame:GetRegions()):Hide()
	end
	TradeSkillListScrollFrame:GetRegions():Hide()
	select(2, TradeSkillListScrollFrame:GetRegions()):Hide()
	TradeSkillDetailHeaderLeft:Hide()
	TradeSkillDetailScrollFrameTop:SetAlpha(0)
	TradeSkillDetailScrollFrameBottom:SetAlpha(0)
	TradeSkillFrameBg:Hide()
	TradeSkillFrameInsetBg:Hide()
	TradeSkillFrameTitleBg:Hide()
	TradeSkillFramePortraitFrame:Hide()
	TradeSkillFrameTopBorder:Hide()
	TradeSkillFrameTopRightCorner:Hide()
	TradeSkillCreateAllButton_RightSeparator:Hide()
	TradeSkillCreateButton_LeftSeparator:Hide()
	TradeSkillCancelButton_LeftSeparator:Hide()
	TradeSkillViewGuildCraftersButton_RightSeparator:Hide()
	TradeSkillGuildCraftersFrameTrack:Hide()
	TradeSkillRankFrameBorder:Hide()
	TradeSkillRankFrameBackground:Hide()

	TradeSkillDetailScrollFrame:SetHeight(176)

	local a1, p, a2, x, y = TradeSkillGuildFrame:GetPoint()
	TradeSkillGuildFrame:ClearAllPoints()
	TradeSkillGuildFrame:SetPoint(a1, p, a2, x + 16, y)

	TradeSkillLinkButton:SetPoint("LEFT", 0, -1)

	R.Reskin(TradeSkillCreateButton)
	R.Reskin(TradeSkillCreateAllButton)
	R.Reskin(TradeSkillCancelButton)
	R.Reskin(TradeSkillViewGuildCraftersButton)
	R.Reskin(TradeSkillFilterButton)

	TradeSkillRankFrame:SetStatusBarTexture(C.Aurora.backdrop)
	TradeSkillRankFrame.SetStatusBarColor = R.dummy
	TradeSkillRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
	
	local bg = CreateFrame("Frame", nil, TradeSkillRankFrame)
	bg:SetPoint("TOPLEFT", -1, 1)
	bg:SetPoint("BOTTOMRIGHT", 1, -1)
	bg:SetFrameLevel(TradeSkillRankFrame:GetFrameLevel()-1)
	R.CreateBD(bg, .25)

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local bu = _G["TradeSkillReagent"..i]
		local na = _G["TradeSkillReagent"..i.."NameFrame"]
		local ic = _G["TradeSkillReagent"..i.."IconTexture"]

		na:Hide()

		ic:SetTexCoord(.08, .92, .08, .92)
		ic:SetDrawLayer("ARTWORK")
		R.CreateBG(ic)

		local bd = CreateFrame("Frame", nil, bu)
		bd:SetPoint("TOPLEFT", na, 14, -25)
		bd:SetPoint("BOTTOMRIGHT", na, -53, 24)
		bd:SetFrameLevel(0)
		R.CreateBD(bd, .25)

		_G["TradeSkillReagent"..i.."Name"]:SetParent(bd)
	end

	local reskinned = false
	hooksecurefunc("TradeSkillFrame_SetSelection", function()
		if not reskinned == true then
			local ic = select(2, TradeSkillSkillIcon:GetRegions())
			TradeSkillSkillIcon:StyleButton()
			TradeSkillSkillIcon:SetPushedTexture(nil)
			TradeSkillSkillIcon:GetHighlightTexture():Point("TOPLEFT", 1, -1)
			TradeSkillSkillIcon:GetHighlightTexture():Point("BOTTOMRIGHT", -1, 1)
			if ic then
				ic:SetTexCoord(.08, .92, .08, .92)
				ic:SetPoint("TOPLEFT", 1, -1)
				ic:SetPoint("BOTTOMRIGHT", -1, 1)
				R.CreateBD(TradeSkillSkillIcon)
				reskinned = true
			end
		end
	end)

	TradeSkillIncrementButton:SetPoint("RIGHT", TradeSkillCreateButton, "LEFT", -9, 0)

	R.ReskinClose(TradeSkillFrameCloseButton)
	R.ReskinClose(TradeSkillGuildFrameCloseButton)
	R.ReskinScroll(TradeSkillDetailScrollFrameScrollBar)
	R.ReskinScroll(TradeSkillListScrollFrameScrollBar)
	R.ReskinScroll(TradeSkillGuildCraftersFrameScrollBar)
	R.ReskinInput(TradeSkillInputBox)
	R.ReskinInput(TradeSkillFrameSearchBox)
	R.ReskinArrow(TradeSkillDecrementButton, 1)
	R.ReskinArrow(TradeSkillIncrementButton, 2)
	R.ReskinArrow(TradeSkillLinkButton, 2)
end

R.SkinFuncs["Blizzard_TradeSkillUI"] = LoadSkin