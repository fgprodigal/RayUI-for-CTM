local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(HelpFrame)
	HelpFrameHeader:Hide()
	HelpFrameLeftInsetBg:Hide()
	select(4, HelpFrameTicket:GetChildren()):Hide()
	HelpFrameKnowledgebaseStoneTex:Hide()
	HelpFrameKnowledgebaseNavBarOverlay:Hide()
	select(5, HelpFrameGM_Response:GetChildren()):Hide()
	select(6, HelpFrameGM_Response:GetChildren()):Hide()
	HelpFrameKnowledgebaseNavBarHomeButtonLeft:Hide()
	HelpFrameKnowledgebaseTopTileStreaks:Hide()
	HelpFrameKnowledgebaseNavBar:GetRegions():Hide()
	HelpFrameTicketScrollFrameScrollBar:SetPoint("TOPLEFT", HelpFrameTicketScrollFrame, "TOPRIGHT", 1, -16)
	HelpFrameGM_ResponseScrollFrame1ScrollBar:SetPoint("TOPLEFT", HelpFrameGM_ResponseScrollFrame1, "TOPRIGHT", 1, -16)
	HelpFrameGM_ResponseScrollFrame2ScrollBar:SetPoint("TOPLEFT", HelpFrameGM_ResponseScrollFrame2, "TOPRIGHT", 1, -16)

	local buttons = {
		"HelpFrameButton1",
		"HelpFrameButton2",
		"HelpFrameButton3",
		"HelpFrameButton4",
		"HelpFrameButton5",
		"HelpFrameButton6",
		"HelpFrameAccountSecurityOpenTicket",
		"HelpFrameCharacterStuckStuck",
		"HelpFrameReportLagLoot",
		"HelpFrameReportLagAuctionHouse",
		"HelpFrameReportLagMail",
		"HelpFrameReportLagChat",
		"HelpFrameReportLagMovement",
		"HelpFrameReportLagSpell",
		"HelpFrameReportAbuseOpenTicket",
		"HelpFrameOpenTicketHelpTopIssues",
		"HelpFrameOpenTicketHelpOpenTicket",
		"HelpFrameKnowledgebaseSearchButton",
		"HelpFrameGM_ResponseNeedMoreHelp",
		"HelpFrameGM_ResponseCancel",
		"GMChatOpenLog",
		"HelpFrameKnowledgebaseNavBarHomeButton",
		"HelpFrameTicketSubmit",
		"HelpFrameTicketCancel"
	}
	for i = 1, #buttons do
		local button = _G[buttons[i]]
		R.Reskin(button)
	end
	
	R.ReskinClose(HelpFrameCloseButton)

	local layers = {
		"HelpFrameMainInset",
		"HelpFrame",
		"HelpFrameLeftInset"
	}
	for i = 1, #layers do
		_G[layers[i]]:DisableDrawLayer("BACKGROUND")
		_G[layers[i]]:DisableDrawLayer("BORDER")
	end

	local lightbds = {
		"HelpFrameTicketScrollFrame",
		"HelpFrameGM_ResponseScrollFrame1",
		"HelpFrameGM_ResponseScrollFrame2"
	}
	for i = 1, #lightbds do
		R.CreateBD(_G[lightbds[i]], .25)
	end

	local scrollbars = {
		"HelpFrameKnowledgebaseScrollFrameScrollBar",
		"HelpFrameTicketScrollFrameScrollBar",
		"HelpFrameGM_ResponseScrollFrame1ScrollBar",
		"HelpFrameGM_ResponseScrollFrame2ScrollBar",
		"HelpFrameKnowledgebaseScrollFrame2ScrollBar"
	}
	for i = 1, #scrollbars do
		bar = _G[scrollbars[i]]
		R.ReskinScroll(bar)
	end

	for i = 1, 15 do
		local bu = _G["HelpFrameKnowledgebaseScrollFrameButton"..i]
		bu:DisableDrawLayer("ARTWORK")
		R.CreateBD(bu, 0)

		local tex = bu:CreateTexture(nil, "BACKGROUND")
		tex:SetPoint("TOPLEFT")
		tex:SetPoint("BOTTOMRIGHT")
		tex:SetTexture(C.Aurora.backdrop)
		tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)
	end
	
	R.ReskinInput(HelpFrameKnowledgebaseSearchBox)

	for i = 1, 6 do
		_G["HelpFrameButton"..i.."Selected"]:SetAlpha(0)
	end

	-- Nav Bar
	local function navButtonFrameLevel(self)
		for i=1, #self.navList do
			local navButton = self.navList[i]
			local lastNav = self.navList[i-1]
			if navButton and lastNav then
				navButton:SetFrameLevel(lastNav:GetFrameLevel() - 2)
				navButton:ClearAllPoints()
				navButton:SetPoint("LEFT", lastNav, "RIGHT", 1, 0)
			end
		end			
	end

	hooksecurefunc("NavBar_AddButton", function(self, buttonData)
		local navButton = self.navList[#self.navList]


		if not navButton.skinned then
			R.Reskin(navButton)
			navButton:GetRegions():SetAlpha(0)
			select(2, navButton:GetRegions()):SetAlpha(0)
			select(3, navButton:GetRegions()):SetAlpha(0)

			navButton.skinned = true

			navButton:HookScript("OnClick", function()
				navButtonFrameLevel(self)
			end)
		end

		navButtonFrameLevel(self)
	end)
end

tinsert(R.SkinFuncs["RayUI"], LoadSkin)