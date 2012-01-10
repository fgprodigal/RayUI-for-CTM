local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.CreateBD(AchievementFrame)
	R.CreateSD(AchievementFrame)
	AchievementFrameCategories:SetBackdrop(nil)
	AchievementFrameSummary:SetBackdrop(nil)
	for i = 1, 17 do
		select(i, AchievementFrame:GetRegions()):Hide()
	end
	AchievementFrameSummaryBackground:Hide()
	AchievementFrameSummary:GetChildren():Hide()
	AchievementFrameCategoriesContainerScrollBarBG:SetAlpha(0)
	for i = 1, 4 do
		select(i, AchievementFrameHeader:GetRegions()):Hide()
	end
	AchievementFrameHeaderRightDDLInset:SetAlpha(0)
	select(2, AchievementFrameAchievements:GetChildren()):Hide()
	AchievementFrameAchievementsBackground:Hide()
	select(3, AchievementFrameAchievements:GetRegions()):Hide()
	AchievementFrameStatsBG:Hide()
	AchievementFrameSummaryAchievementsHeaderHeader:Hide()
	AchievementFrameSummaryCategoriesHeaderTexture:Hide()
	select(3, AchievementFrameStats:GetChildren()):Hide()

	local first = 1
	hooksecurefunc("AchievementFrameCategories_Update", function()
		if first == 1 then
			for i = 1, 19 do
				_G["AchievementFrameCategoriesContainerButton"..i.."Background"]:Hide()
			end
			first = 0
		end
	end)

	AchievementFrameHeaderPoints:SetPoint("TOP", AchievementFrame, "TOP", 0, -6)
	AchievementFrameFilterDropDown:SetPoint("TOPRIGHT", AchievementFrame, "TOPRIGHT", -98, 1)
	AchievementFrameFilterDropDownText:ClearAllPoints()
	AchievementFrameFilterDropDownText:SetPoint("CENTER", -10, 1)

	for i = 1, 3 do
		local tab = _G["AchievementFrameTab"..i]
		if tab then
			R.CreateTab(tab)
		end
	end

	AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(C.Aurora.backdrop)
	AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
	AchievementFrameSummaryCategoriesStatusBarLeft:Hide()
	AchievementFrameSummaryCategoriesStatusBarMiddle:Hide()
	AchievementFrameSummaryCategoriesStatusBarRight:Hide()
	AchievementFrameSummaryCategoriesStatusBarFillBar:Hide()
	AchievementFrameSummaryCategoriesStatusBarTitle:SetTextColor(1, 1, 1)
	AchievementFrameSummaryCategoriesStatusBarTitle:SetPoint("LEFT", AchievementFrameSummaryCategoriesStatusBar, "LEFT", 6, 0)
	AchievementFrameSummaryCategoriesStatusBarText:SetPoint("RIGHT", AchievementFrameSummaryCategoriesStatusBar, "RIGHT", -5, 0)

	local bg = CreateFrame("Frame", nil, AchievementFrameSummaryCategoriesStatusBar)
	bg:Point("TOPLEFT", -1, 1)
	bg:Point("BOTTOMRIGHT", 1, -1)
	bg:SetFrameLevel(AchievementFrameSummaryCategoriesStatusBar:GetFrameLevel()-1)
	R.CreateBD(bg, .25)

	for i = 1, 7 do
		local bu = _G["AchievementFrameAchievementsContainerButton"..i]
		bu:DisableDrawLayer("BORDER")

		local bd = _G["AchievementFrameAchievementsContainerButton"..i.."Background"]

		bd:SetTexture(C.Aurora.backdrop)
		bd:SetVertexColor(0, 0, 0, .25)

		local text = _G["AchievementFrameAchievementsContainerButton"..i.."Description"]
		text:SetTextColor(.9, .9, .9)
		text.SetTextColor = R.dummy
		text:SetShadowOffset(1, -1)
		text.SetShadowOffset = R.dummy

		_G["AchievementFrameAchievementsContainerButton"..i.."TitleBackground"]:Hide()
		_G["AchievementFrameAchievementsContainerButton"..i.."Glow"]:Hide()
		_G["AchievementFrameAchievementsContainerButton"..i.."RewardBackground"]:SetAlpha(0)
		_G["AchievementFrameAchievementsContainerButton"..i.."PlusMinus"]:SetAlpha(0)
		_G["AchievementFrameAchievementsContainerButton"..i.."Highlight"]:SetAlpha(0)
		_G["AchievementFrameAchievementsContainerButton"..i.."IconOverlay"]:Hide()
		_G["AchievementFrameAchievementsContainerButton"..i.."GuildCornerL"]:SetAlpha(0)
		_G["AchievementFrameAchievementsContainerButton"..i.."GuildCornerR"]:SetAlpha(0)

		local bg = CreateFrame("Frame", nil, bu)
		bg:Point("TOPLEFT", 2, -2)
		bg:Point("BOTTOMRIGHT", -2, 2)
		R.CreateBD(bg, 0)

		local ic = _G["AchievementFrameAchievementsContainerButton"..i.."IconTexture"]
		ic:SetTexCoord(.08, .92, .08, .92)
		R.CreateBG(ic)
	end

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function()
		for i = 1, 16 do
			local name = _G["AchievementFrameCriteria"..i.."Name"]
			if name and select(2, name:GetTextColor()) == 0 then
				name:SetTextColor(1, 1, 1)
			end
		end

		for i = 1, 25 do
			local bu = _G["AchievementFrameMeta"..i]
			if bu and select(2, bu.label:GetTextColor()) == 0 then
				bu.label:SetTextColor(1, 1, 1)
			end
		end
	end)

	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local bar = _G["AchievementFrameProgressBar"..index]
		if not bar.reskinned then
			bar:SetStatusBarTexture(C.Aurora.backdrop)

			_G["AchievementFrameProgressBar"..index.."BG"]:SetTexture(0, 0, 0, .25)
			_G["AchievementFrameProgressBar"..index.."BorderLeft"]:Hide()
			_G["AchievementFrameProgressBar"..index.."BorderCenter"]:Hide()
			_G["AchievementFrameProgressBar"..index.."BorderRight"]:Hide()

			local bg = CreateFrame("Frame", nil, bar)
			bg:Point("TOPLEFT", -1, 1)
			bg:Point("BOTTOMRIGHT", 1, -1)
			R.CreateBD(bg, 0)

			bar.reskinned = true
		end
	end)

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local bu = _G["AchievementFrameSummaryAchievement"..i]
			if not bu.reskinned then
				bu:DisableDrawLayer("BORDER")

				local bd = _G["AchievementFrameSummaryAchievement"..i.."Background"]

				bd:SetTexture(C.Aurora.backdrop)
				bd:SetVertexColor(0, 0, 0, .25)

				_G["AchievementFrameSummaryAchievement"..i.."TitleBackground"]:Hide()
				_G["AchievementFrameSummaryAchievement"..i.."Glow"]:Hide()
				_G["AchievementFrameSummaryAchievement"..i.."Highlight"]:SetAlpha(0)
				_G["AchievementFrameSummaryAchievement"..i.."IconOverlay"]:Hide()

				local text = _G["AchievementFrameSummaryAchievement"..i.."Description"]
				text:SetTextColor(.9, .9, .9)
				text.SetTextColor = R.dummy
				text:SetShadowOffset(1, -1)
				text.SetShadowOffset = R.dummy

				local bg = CreateFrame("Frame", nil, bu)
				bg:Point("TOPLEFT", 2, -2)
				bg:Point("BOTTOMRIGHT", -2, 2)
				R.CreateBD(bg, 0)

				local ic = _G["AchievementFrameSummaryAchievement"..i.."IconTexture"]
				ic:SetTexCoord(.08, .92, .08, .92)
				R.CreateBG(ic)

				bu.reskinned = true
			end
		end
	end)
	
	AchievementFrame:HookScript("OnShow", function()
		for i=1, 20 do
			local frame = _G["AchievementFrameCategoriesContainerButton"..i]

			frame:StyleButton()
			frame:GetHighlightTexture():Point("TOPLEFT", 0, -4)
			frame:GetHighlightTexture():Point("BOTTOMRiGHT", 0, -3)
			frame:GetPushedTexture():Point("TOPLEFT", 0, -4)
			frame:GetPushedTexture():Point("BOTTOMRiGHT", 0, -3)
		end	
	end)

	for i = 1, 8 do
		local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local bar = bu:GetStatusBarTexture()
		local label = _G["AchievementFrameSummaryCategoriesCategory"..i.."Label"]

		bu:SetStatusBarTexture(C.Aurora.backdrop)
		bar:SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		label:SetTextColor(1, 1, 1)
		label:Point("LEFT", bu, "LEFT", 6, 0)

		local bg = CreateFrame("Frame", nil, bu)
		bg:Point("TOPLEFT", -1, 1)
		bg:Point("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)
		R.CreateBD(bg, .25)
		
		_G["AchievementFrameSummaryCategoriesCategory"..i.."Left"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."Middle"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."Right"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."FillBar"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]:SetAlpha(0)
		_G["AchievementFrameSummaryCategoriesCategory"..i.."Text"]:SetPoint("RIGHT", bu, "RIGHT", -5, 0)
	end

	for i = 1, 20 do
		_G["AchievementFrameStatsContainerButton"..i.."BG"]:Hide()
		_G["AchievementFrameStatsContainerButton"..i.."BG"].Show = R.dummy
		_G["AchievementFrameStatsContainerButton"..i.."HeaderLeft"]:SetAlpha(0)
		_G["AchievementFrameStatsContainerButton"..i.."HeaderMiddle"]:SetAlpha(0)
		_G["AchievementFrameStatsContainerButton"..i.."HeaderRight"]:SetAlpha(0)
	end

	R.ReskinClose(AchievementFrameCloseButton)
	R.ReskinScroll(AchievementFrameAchievementsContainerScrollBar)
	R.ReskinScroll(AchievementFrameStatsContainerScrollBar)
	R.ReskinScroll(AchievementFrameCategoriesContainerScrollBar)
	R.ReskinDropDown(AchievementFrameFilterDropDown)
end

R.SkinFuncs["Blizzard_AchievementUI"] = LoadSkin