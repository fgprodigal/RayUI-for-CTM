local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(PVPFrame)
	R.SetBD(PVPBannerFrame)
	PVPFramePortrait:Hide()
	PVPHonorFrameBGTex:Hide()
	PVPBannerFramePortrait:Hide()
	select(2, PVPHonorFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
	select(3, PVPHonorFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
	select(4, PVPHonorFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
	PVPHonorFrameTypeScrollFrame:GetRegions():Hide()
	select(2, PVPHonorFrameTypeScrollFrame:GetRegions()):Hide()
	PVPFramePortraitFrame:Hide()
	PVPFrameTopBorder:Hide()
	PVPFrameTopRightCorner:Hide()
	PVPFrameLeftButton_RightSeparator:Hide()
	PVPFrameRightButton_LeftSeparator:Hide()
	PVPBannerFrameCustomizationBorder:Hide()
	PVPBannerFramePortraitFrame:Hide()
	PVPBannerFrameTopBorder:Hide()
	PVPBannerFrameTopRightCorner:Hide()
	PVPBannerFrameAcceptButton_RightSeparator:Hide()
	PVPBannerFrameCancelButton_LeftSeparator:Hide()
	PVPTeamManagementFrameWeeklyDisplay:SetPoint("RIGHT", PVPTeamManagementFrameWeeklyToggleRight, "LEFT", -2, 0)
	for i = 1, 4 do
		if _G["PVPFrameTab"..i] then R.CreateTab(_G["PVPFrameTab"..i]) end
	end

	PVPTeamManagementFrameFlag2Header:SetAlpha(0)
	PVPTeamManagementFrameFlag3Header:SetAlpha(0)
	PVPTeamManagementFrameFlag5Header:SetAlpha(0)
	PVPTeamManagementFrameFlag2HeaderSelected:SetAlpha(0)
	PVPTeamManagementFrameFlag3HeaderSelected:SetAlpha(0)
	PVPTeamManagementFrameFlag5HeaderSelected:SetAlpha(0)
	PVPTeamManagementFrameFlag2Title:SetTextColor(1, 1, 1)
	PVPTeamManagementFrameFlag3Title:SetTextColor(1, 1, 1)
	PVPTeamManagementFrameFlag5Title:SetTextColor(1, 1, 1)
	PVPTeamManagementFrameFlag2Title.SetTextColor = R.dummy
	PVPTeamManagementFrameFlag3Title.SetTextColor = R.dummy
	PVPTeamManagementFrameFlag5Title.SetTextColor = R.dummy

	local bglayers = {
		"PVPFrame",
		"PVPFrameInset",
		"PVPFrameTopInset",
		"PVPTeamManagementFrame",
		"PVPTeamManagementFrameHeader1",
		"PVPTeamManagementFrameHeader2",
		"PVPTeamManagementFrameHeader3",
		"PVPTeamManagementFrameHeader4",
		"PVPBannerFrame",
		"PVPBannerFrameInset"
	}
	for i = 1, #bglayers do
		_G[bglayers[i]]:DisableDrawLayer("BACKGROUND")
	end
	
	local borderlayers = {
		"PVPFrame",
		"PVPFrameInset",
		"PVPConquestFrameInfoButton",
		"PVPFrameTopInset",
		"PVPTeamManagementFrame",
		"PVPBannerFrame",
		"PVPBannerFrameInset"
	}
	for i = 1, #borderlayers do
		_G[borderlayers[i]]:DisableDrawLayer("BORDER")
	end
	PVPConquestFrame:DisableDrawLayer("ARTWORK")
	for i = 1, 3 do
		for j = 1, 2 do
			select(i, _G["PVPBannerFrameCustomization"..j]:GetRegions()):Hide()
		end
	end

	local buttons = {
		"PVPFrameLeftButton",
		"PVPFrameRightButton",
		"PVPBannerFrameAcceptButton",
		"PVPColorPickerButton1",
		"PVPColorPickerButton2",
		"PVPColorPickerButton3",
		"WarGameStartButton"
	}
	for i = 1, #buttons do
		local button = _G[buttons[i]]
		R.Reskin(button)
	end
	R.Reskin(select(6, PVPBannerFrame:GetChildren()))
	R.ReskinClose(PVPFrameCloseButton)
	R.ReskinClose(PVPBannerFrameCloseButton)
	R.ReskinScroll(PVPHonorFrameTypeScrollFrameScrollBar)
	R.ReskinScroll(PVPHonorFrameInfoScrollFrameScrollBar)
	R.ReskinInput(PVPBannerFrameEditBox, 20)
	R.ReskinInput(PVPTeamManagementFrameWeeklyDisplay)
	R.ReskinArrow(PVPTeamManagementFrameWeeklyToggleLeft, 1)
	R.ReskinArrow(PVPTeamManagementFrameWeeklyToggleRight, 2)
	R.ReskinArrow(PVPBannerFrameCustomization1LeftButton, 1)
	R.ReskinArrow(PVPBannerFrameCustomization1RightButton, 2)
	R.ReskinArrow(PVPBannerFrameCustomization2LeftButton, 1)
	R.ReskinArrow(PVPBannerFrameCustomization2RightButton, 2)

	local pvpbg = CreateFrame("Frame", nil, PVPTeamManagementFrame)
	pvpbg:SetPoint("TOPLEFT", PVPTeamManagementFrameFlag2)
	pvpbg:SetPoint("BOTTOMRIGHT", PVPTeamManagementFrameFlag5)
	R.CreateBD(pvpbg, .25)

	PVPFrameConquestBarLeft:Hide()
	PVPFrameConquestBarMiddle:Hide()
	PVPFrameConquestBarRight:Hide()
	PVPFrameConquestBarBG:Hide()
	PVPFrameConquestBarShadow:Hide()
	PVPFrameConquestBarCap1:SetAlpha(0)

	for i = 1, 4 do
		_G["PVPFrameConquestBarDivider"..i]:Hide()
	end

	PVPFrameConquestBarProgress:SetTexture(C.Aurora.backdrop)
	PVPFrameConquestBarProgress:SetGradient("VERTICAL", .7, 0, 0, .8, 0, 0)
	local qbg = CreateFrame("Frame", nil, PVPFrameConquestBar)
	qbg:SetPoint("TOPLEFT", -1, -2)
	qbg:SetPoint("BOTTOMRIGHT", 1, 2)
	qbg:SetFrameLevel(PVPFrameConquestBar:GetFrameLevel()-1)
	R.CreateBD(qbg, .25)
	
	local function CaptureBar()
		if not NUM_EXTENDED_UI_FRAMES then return end
		for i = 1, NUM_EXTENDED_UI_FRAMES do
			local barname = "WorldStateCaptureBar"..i
			local bar = _G[barname]

			if bar and bar:IsVisible() then
				bar:ClearAllPoints()
				bar:SetPoint("TOP", UIParent, "TOP", 0, -120)
				if not bar.skinned then
					local left = _G[barname.."LeftBar"]
					local right = _G[barname.."RightBar"]
					local middle = _G[barname.."MiddleBar"]

					left:SetTexture(C.Aurora.backdrop)
					right:SetTexture(C.Aurora.backdrop)
					middle:SetTexture(C.Aurora.backdrop)
					left:SetDrawLayer("BORDER")
					middle:SetDrawLayer("ARTWORK")
					right:SetDrawLayer("BORDER")

					left:SetGradient("VERTICAL", .1, .4, .9, .2, .6, 1)
					right:SetGradient("VERTICAL", .7, .1, .1, .9, .2, .2)
					middle:SetGradient("VERTICAL", .8, .8, .8, 1, 1, 1)

					_G[barname.."RightLine"]:SetAlpha(0)
					_G[barname.."LeftLine"]:SetAlpha(0)
					select(4, bar:GetRegions()):Hide()
					_G[barname.."LeftIconHighlight"]:SetAlpha(0)
					_G[barname.."RightIconHighlight"]:SetAlpha(0)

					bar.bg = bar:CreateTexture(nil, "BACKGROUND")
					bar.bg:SetPoint("TOPLEFT", left, -1, 1)
					bar.bg:SetPoint("BOTTOMRIGHT", right, 1, -1)
					bar.bg:SetTexture(C.Aurora.backdrop)
					bar.bg:SetVertexColor(0, 0, 0)

					bar.bgmiddle = CreateFrame("Frame", nil, bar)
					bar.bgmiddle:SetPoint("TOPLEFT", middle, -1, 1)
					bar.bgmiddle:SetPoint("BOTTOMRIGHT", middle, 1, -1)
					R.CreateBD(bar.bgmiddle, 0)

					bar.skinned = true
				end
			end
		end
	end

	hooksecurefunc("UIParent_ManageFramePositions", CaptureBar)

	select(2, WarGamesFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
	select(3, WarGamesFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
	select(4, WarGamesFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
	WarGamesFrameBGTex:Hide()
	WarGamesFrameBarLeft:Hide()
	select(3, WarGamesFrame:GetRegions()):Hide()
	WarGameStartButton_RightSeparator:Hide()	
	R.ReskinScroll(WarGamesFrameScrollFrameScrollBar)
	R.ReskinScroll(WarGamesFrameInfoScrollFrameScrollBar)
end

tinsert(R.SkinFuncs["RayUI"], LoadSkin)