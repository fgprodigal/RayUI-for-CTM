local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	local r, g, b = C.Aurora.classcolours[R.myclass].r, C.Aurora.classcolours[R.myclass].g, C.Aurora.classcolours[R.myclass].b
	R.SetBD(QuestLogFrame, 6, -9, -2, 6)
	R.SetBD(QuestFrame, 6, -15, -26, 64)
	R.SetBD(QuestLogDetailFrame, 6, -9, 0, 0)
	QuestFramePortrait:Hide()

	NORMAL_QUEST_DISPLAY = "|cffffffff%s|r"
	TRIVIAL_QUEST_DISPLAY = string.gsub(TRIVIAL_QUEST_DISPLAY, "|cff000000", "|cffffffff")
	QuestFont:SetTextColor(1, 1, 1)
	QuestProgressRequiredItemsText:SetTextColor(1, 1, 1)
	QuestProgressRequiredItemsText:SetShadowColor(0, 0, 0)
	QuestInfoRewardsHeader:SetShadowColor(0, 0, 0)
	QuestProgressTitleText:SetShadowColor(0, 0, 0)
	QuestInfoTitleHeader:SetShadowColor(0, 0, 0)
	QuestInfoTitleHeader:SetTextColor(1, 1, 1)
	QuestInfoTitleHeader.SetTextColor = R.dummy
	QuestInfoDescriptionHeader:SetTextColor(1, 1, 1)
	QuestInfoDescriptionHeader.SetTextColor = R.dummy
	QuestInfoDescriptionHeader:SetShadowColor(0, 0, 0)
	QuestInfoObjectivesHeader:SetTextColor(1, 1, 1)
	QuestInfoObjectivesHeader.SetTextColor = R.dummy
	QuestInfoObjectivesHeader:SetShadowColor(0, 0, 0)
	QuestInfoRewardsHeader:SetTextColor(1, 1, 1)
	QuestInfoRewardsHeader.SetTextColor = R.dummy
	QuestInfoDescriptionText:SetTextColor(1, 1, 1)
	QuestInfoDescriptionText.SetTextColor = R.dummy
	QuestInfoObjectivesText:SetTextColor(1, 1, 1)
	QuestInfoObjectivesText.SetTextColor = R.dummy
	QuestInfoGroupSize:SetTextColor(1, 1, 1)
	QuestInfoGroupSize.SetTextColor = R.dummy
	QuestInfoRewardText:SetTextColor(1, 1, 1)
	QuestInfoRewardText.SetTextColor = R.dummy
	QuestInfoItemChooseText:SetTextColor(1, 1, 1)
	QuestInfoItemChooseText.SetTextColor = R.dummy
	QuestInfoItemReceiveText:SetTextColor(1, 1, 1)
	QuestInfoItemReceiveText.SetTextColor = R.dummy
	QuestInfoSpellLearnText:SetTextColor(1, 1, 1)
	QuestInfoSpellLearnText.SetTextColor = R.dummy
	QuestInfoXPFrameReceiveText:SetTextColor(1, 1, 1)
	QuestInfoXPFrameReceiveText.SetTextColor = R.dummy
	GossipGreetingText:SetTextColor(1, 1, 1)
	QuestProgressTitleText:SetTextColor(1, 1, 1)
	QuestProgressTitleText.SetTextColor = R.dummy
	QuestProgressText:SetTextColor(1, 1, 1)
	QuestProgressText.SetTextColor = R.dummy
	AvailableQuestsText:SetTextColor(1, 1, 1)
	AvailableQuestsText.SetTextColor = R.dummy
	AvailableQuestsText:SetShadowColor(0, 0, 0)
	QuestInfoSpellObjectiveLearnLabel:SetTextColor(1, 1, 1)
	QuestInfoSpellObjectiveLearnLabel.SetTextColor = R.dummy
	CurrentQuestsText:SetTextColor(1, 1, 1)
	CurrentQuestsText.SetTextColor = R.dummy
	CurrentQuestsText:SetShadowColor(0, 0, 0)
	for i = 1, MAX_OBJECTIVES do
		local objective = _G["QuestInfoObjective"..i]
		objective:SetTextColor(1, 1, 1)
		objective.SetTextColor = R.dummy
	end

	QuestInfoSkillPointFrameIconTexture:SetSize(40, 40)
	QuestInfoSkillPointFrameIconTexture:SetTexCoord(.08, .92, .08, .92)
	
	local scrollbars = {
		"QuestLogScrollFrameScrollBar",
		"QuestLogDetailScrollFrameScrollBar",
		"QuestProgressScrollFrameScrollBar",
		"QuestRewardScrollFrameScrollBar",
		"QuestDetailScrollFrameScrollBar",
		"QuestGreetingScrollFrameScrollBar",
		"QuestNPCModelTextScrollFrameScrollBar"
	}
	for i = 1, #scrollbars do
		bar = _G[scrollbars[i]]
		R.ReskinScroll(bar)
	end
	
	local layers = {
		"QuestFrameDetailPanel",
		"QuestFrameProgressPanel",
		"QuestFrameRewardPanel",
		"QuestFrameGreetingPanel",
		"EmptyQuestLogFrame"
	}
	for i = 1, #layers do
		_G[layers[i]]:DisableDrawLayer("BACKGROUND")
	end
	if R.HoT then
		QuestFrameDetailPanel:DisableDrawLayer("BORDER")
		QuestFrameRewardPanel:DisableDrawLayer("BORDER")
	end
	QuestLogDetailFrame:DisableDrawLayer("BORDER")
	QuestLogDetailFrame:DisableDrawLayer("ARTWORK")
	QuestLogDetailFrame:GetRegions():Hide()
	QuestNPCModelShadowOverlay:Hide()
	QuestNPCModelBg:Hide()
	QuestNPCModel:DisableDrawLayer("OVERLAY")
	QuestNPCModelNameText:SetDrawLayer("ARTWORK")
	QuestNPCModelTextFrameBg:Hide()
	QuestNPCModelTextFrame:DisableDrawLayer("OVERLAY")
	QuestNPCModelTextScrollFrameScrollBarThumbTexture.bg:Hide()
	QuestLogDetailTitleText:SetDrawLayer("OVERLAY")	
	QuestLogDetailScrollFrameScrollBackgroundTopLeft:SetAlpha(0)
	QuestLogDetailScrollFrameScrollBackgroundBottomRight:SetAlpha(0)
	QuestLogFrameCompleteButton_LeftSeparator:Hide()
	QuestLogFrameCompleteButton_RightSeparator:Hide()
	select(9, QuestFrameGreetingPanel:GetRegions()):Hide()
	QuestInfoItemHighlight:GetRegions():Hide()
	QuestInfoSpellObjectiveFrameNameFrame:Hide()

	QuestLogFrameShowMapButton:Hide()
	QuestLogFrameShowMapButton.Show = R.dummy

	for i = 1, 9 do
		select(i, QuestLogCount:GetRegions()):Hide()			
	end
	
	for i = 1, 3 do
		select(i, QuestLogFrame:GetRegions()):Hide()
	end
	
	NPCBD = CreateFrame("Frame", nil, QuestNPCModel)
	NPCBD:SetPoint("TOPLEFT", 0, 1)
	NPCBD:SetPoint("RIGHT", 1, 0)
	NPCBD:SetPoint("BOTTOM", QuestNPCModelTextScrollFrame)
	NPCBD:SetFrameLevel(QuestNPCModel:GetFrameLevel()-1)
	R.CreateBD(NPCBD)

	local line1 = CreateFrame("Frame", nil, QuestNPCModel)
	line1:SetPoint("BOTTOMLEFT", 0, -1)
	line1:SetPoint("BOTTOMRIGHT", 0, -1)
	line1:SetHeight(1)
	line1:SetFrameLevel(QuestNPCModel:GetFrameLevel()-1)
	R.CreateBD(line1, 0)

	local bg = CreateFrame("Frame", nil, QuestInfoSkillPointFrame)
	bg:SetPoint("TOPLEFT", -3, 0)
	bg:SetPoint("BOTTOMRIGHT", -3, 0)
	bg:Lower()
	R.CreateBD(bg, .25)

	R.CreateBD(QuestLogCount, .25)
	QuestInfoSkillPointFrameNameFrame:Hide()
	QuestInfoSkillPointFrameName:SetParent(bg)
	QuestInfoSkillPointFrameIconTexture:SetParent(bg)
	QuestInfoSkillPointFrameSkillPointBg:SetParent(bg)
	QuestInfoSkillPointFrameSkillPointBgGlow:SetParent(bg)
	QuestInfoSkillPointFramePoints:SetParent(bg)

	local line2 = QuestInfoSkillPointFrame:CreateTexture(nil, "BACKGROUND")
	line2:SetSize(1, 40)
	line2:SetPoint("RIGHT", QuestInfoSkillPointFrameIconTexture, 1, 0)
	line2:SetTexture(C.Aurora.backdrop)
	line2:SetVertexColor(0, 0, 0)

	local function clearhighlight()
		for i = 1, MAX_NUM_ITEMS do
			_G["QuestInfoItem"..i]:SetBackdropColor(0, 0, 0, .25)
		end
	end

	local function sethighlight(self)
		clearhighlight()

		local _, point = self:GetPoint()
		point:SetBackdropColor(r, g, b, .2)
	end

	hooksecurefunc(QuestInfoItemHighlight, "SetPoint", sethighlight)
	QuestInfoItemHighlight:HookScript("OnShow", sethighlight)
	QuestInfoItemHighlight:HookScript("OnHide", clearhighlight)

	for i = 1, MAX_REQUIRED_ITEMS do
		local bu = _G["QuestProgressItem"..i]
		local ic = _G["QuestProgressItem"..i.."IconTexture"]
		local na = _G["QuestProgressItem"..i.."NameFrame"]
		local co = _G["QuestProgressItem"..i.."Count"]

		ic:SetSize(40, 40)
		ic:SetTexCoord(.08, .92, .08, .92)

		R.CreateBD(bu, .25)

		na:Hide()
		co:SetDrawLayer("OVERLAY")

		local line = CreateFrame("Frame", nil, bu)
		line:SetSize(1, 40)
		line:SetPoint("RIGHT", ic, 1, 0)
		R.CreateBD(line)
	end

	for i = 1, MAX_NUM_ITEMS do
		local bu = _G["QuestInfoItem"..i]
		local ic = _G["QuestInfoItem"..i.."IconTexture"]
		local na = _G["QuestInfoItem"..i.."NameFrame"]
		local co = _G["QuestInfoItem"..i.."Count"]

		ic:SetPoint("TOPLEFT", 1, -1)
		ic:SetSize(39, 39)
		ic:SetTexCoord(.08, .92, .08, .92)
		ic:SetDrawLayer("OVERLAY")

		R.CreateBD(bu, .25)

		na:Hide()
		co:SetDrawLayer("OVERLAY")

		local line = CreateFrame("Frame", nil, bu)
		line:SetSize(1, 40)
		line:SetPoint("RIGHT", ic, 1, 0)
		R.CreateBD(line)
	end
	
	QuestLogFramePushQuestButton:ClearAllPoints()
	QuestLogFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", 1, 0)
	QuestLogFramePushQuestButton:SetWidth(100)
	QuestLogFrameTrackButton:ClearAllPoints()
	QuestLogFrameTrackButton:SetPoint("LEFT", QuestLogFramePushQuestButton, "RIGHT", 1, 0)
	
	hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, portrait, text, name, x, y)
		local parent = parentFrame:GetName()
		if parent == "QuestLogFrame" or parent == "QuestLogDetailFrame" then
			QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x+4, y)
		else
			QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x+8, y)
		end
	end)
	
	local questlogcontrolpanel = function()
		local parent
		if QuestLogFrame:IsShown() then
			parent = QuestLogFrame
			QuestLogControlPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 9, 6)
		elseif QuestLogDetailFrame:IsShown() then
			parent = QuestLogDetailFrame
			QuestLogControlPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 9, 0)
		end
	end
	hooksecurefunc("QuestLogControlPanel_UpdatePosition", questlogcontrolpanel)

	local buttons = {
		"QuestLogFrameAbandonButton",
		"QuestLogFramePushQuestButton",
		"QuestLogFrameTrackButton",
		"QuestLogFrameCancelButton",
		"QuestFrameAcceptButton",
		"QuestFrameDeclineButton",
		"QuestFrameCompleteQuestButton",
		"QuestFrameCompleteButton",
		"QuestFrameGoodbyeButton",
		"QuestFrameGreetingGoodbyeButton",
		"QuestLogFrameCompleteButton"
	}
	for i = 1, #buttons do
	local button = _G[buttons[i]]
		R.Reskin(button)
	end
	R.ReskinClose(QuestLogFrameCloseButton, "TOPRIGHT", QuestLogFrame, "TOPRIGHT", -7, -14)
	R.ReskinClose(QuestLogDetailFrameCloseButton, "TOPRIGHT", QuestLogDetailFrame, "TOPRIGHT", -5, -14)
	R.ReskinClose(QuestFrameCloseButton, "TOPRIGHT", QuestFrame, "TOPRIGHT", -30, -20)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)