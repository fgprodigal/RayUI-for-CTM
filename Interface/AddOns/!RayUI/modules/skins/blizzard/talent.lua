local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(PlayerTalentFrame)
	R.Reskin(PlayerTalentFrameToggleSummariesButton)
	R.Reskin(PlayerTalentFrameLearnButton)
	R.Reskin(PlayerTalentFrameResetButton)
	R.Reskin(PlayerTalentFrameActivateButton)
	-- PlayerTalentFrame:DisableDrawLayer("BACKGROUND")
	-- PlayerTalentFrame:DisableDrawLayer("BORDER")
	-- PlayerTalentFrameInset:DisableDrawLayer("BACKGROUND")
	-- PlayerTalentFrameInset:DisableDrawLayer("BORDER")
	PlayerTalentFramePortrait:Hide()
	PlayerTalentFramePortraitFrame:Hide()
	PlayerTalentFrameTopBorder:Hide()
	PlayerTalentFrameTopRightCorner:Hide()
	PlayerTalentFrameToggleSummariesButton_LeftSeparator:Hide()
	PlayerTalentFrameToggleSummariesButton_RightSeparator:Hide()
	PlayerTalentFrameLearnButton_LeftSeparator:Hide()
	PlayerTalentFrameResetButton_LeftSeparator:Hide()

	local StripAllTextures = {
		"PlayerTalentFrame",
		"PlayerTalentFrameInset",
		"PlayerTalentFrameTalents",
		"PlayerTalentFramePanel1HeaderIcon",
		"PlayerTalentFramePanel2HeaderIcon",
		"PlayerTalentFramePanel3HeaderIcon",
		"PlayerTalentFramePetTalents",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local function StripTalentFramePanelTextures(object)
		for i=1, object:GetNumRegions() do
			local region = select(i, object:GetRegions())
			if region:GetObjectType() == "Texture" then
				if region:GetName():find("Branch") then
					region:SetDrawLayer("OVERLAY")
				else
					region:SetTexture(nil)
				end
			end
		end
	end

	StripTalentFramePanelTextures(PlayerTalentFramePanel1)
	StripTalentFramePanelTextures(PlayerTalentFramePanel2)
	StripTalentFramePanelTextures(PlayerTalentFramePanel3)
	StripTalentFramePanelTextures(PlayerTalentFramePetPanel)
	
	local KillTextures = {
		"PlayerTalentFramePanel1InactiveShadow",
		"PlayerTalentFramePanel2InactiveShadow",
		"PlayerTalentFramePanel3InactiveShadow",
		"PlayerTalentFramePanel1SummaryRoleIcon",
		"PlayerTalentFramePanel2SummaryRoleIcon",
		"PlayerTalentFramePanel3SummaryRoleIcon",
		"PlayerTalentFramePetShadowOverlay",
	}

	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end
	
	local function TalentSummaryButtons(self, first, active, i, j)
		if active then
			button = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1"]
			icon = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1Icon"]
		else
			button = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j]
			icon = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j.."Icon"]
		end

		if first then
			button:StripTextures()
		end

		if icon then
			icon:SetTexCoord(.08, .92, .08, .92)
			button:SetFrameLevel(button:GetFrameLevel() +1)
			local frame = CreateFrame("Frame",nil, button)
			R.CreateBD(frame)
			frame:SetFrameLevel(button:GetFrameLevel() -1)
			frame:ClearAllPoints()
			frame:SetAllPoints(icon)
		end
	end

	for i=1, 3 do
		for j=1, 3 do
			TalentSummaryButtons(nil, true, true, i, j)
			TalentSummaryButtons(nil, true, false, i, j)
		end
		local tex1, tex2, _, _, textl, textr, texbl, texbr, _, _, _, _, border = _G["PlayerTalentFramePanel"..i.."Summary"]:GetRegions()
		tex1:ClearAllPoints()
		tex1:Point("TOPLEFT", _G["PlayerTalentFramePanel"..i.."Summary"], 0, 3)
		tex1:Point("BOTTOMRIGHT", _G["PlayerTalentFramePanel"..i.."Summary"], 0, 0)
		tex2:ClearAllPoints()
		tex2:Point("TOPLEFT", _G["PlayerTalentFramePanel"..i.."Summary"], 1, 2)
		tex2:Point("BOTTOMRIGHT", _G["PlayerTalentFramePanel"..i.."Summary"], -1, 1)
		
		local bg = _G["PlayerTalentFramePanel"..i.."Summary"]:CreateTexture(nil, "BACKGROUND")
		bg:Point("TOPLEFT", _G["PlayerTalentFramePanel"..i.."Summary"], -1, 4)
		bg:Point("BOTTOMRIGHT", _G["PlayerTalentFramePanel"..i.."Summary"], 1, -1)
		bg:SetTexture(0, 0, 0)
		
		textl:Point("TOPLEFT", 0, 2)
		textr:Point("TOPRIGHT", 0, 2)
		texbl:Point("BOTTOMLEFT", 0, 0)
		texbr:Point("BOTTOMRIGHT", 0, 0)

		border:Kill()
	end

	if R.myclass == "HUNTER" then
		PlayerTalentFramePetPanel:DisableDrawLayer("BORDER")
		PlayerTalentFramePetModelBg:Hide()
		PlayerTalentFramePetShadowOverlay:Hide()
		PlayerTalentFramePetModelRotateLeftButton:Hide()
		PlayerTalentFramePetModelRotateRightButton:Hide()
		PlayerTalentFramePetIconBorder:Hide()
		PlayerTalentFramePetPanelHeaderIconBorder:Hide()
		PlayerTalentFramePetPanelHeaderBackground:Hide()
		PlayerTalentFramePetPanelHeaderBorder:Hide()

		PlayerTalentFramePetIcon:SetTexCoord(.08, .92, .08, .92)
		R.CreateBG(PlayerTalentFramePetIcon)

		PlayerTalentFramePetPanelHeaderIconIcon:SetTexCoord(.08, .92, .08, .92)
		R.CreateBG(PlayerTalentFramePetPanelHeaderIcon)

		PlayerTalentFramePetPanelHeaderIcon:Point("TOPLEFT", PlayerTalentFramePetPanelHeaderBackground, "TOPLEFT", -2, 3)
		PlayerTalentFramePetPanelName:Point("LEFT", PlayerTalentFramePetPanelHeaderBackground, "LEFT", 62, 8)

		local bg = CreateFrame("Frame", nil, PlayerTalentFramePetPanel)
		bg:Point("TOPLEFT", 4, -6)
		bg:Point("BOTTOMRIGHT", -4, 4)
		bg:SetFrameLevel(0)
		R.CreateBD(bg, .25)

		local line = PlayerTalentFramePetPanel:CreateTexture(nil, "BACKGROUND")
		line:SetHeight(1)
		line:Point("TOPLEFT", 4, -52)
		line:Point("TOPRIGHT", -4, -52)
		line:SetTexture(C.Aurora.backdrop)
		line:SetVertexColor(0, 0, 0)
		
		for i=1,GetNumTalents(1,false,true) do
			local bu = _G["PlayerTalentFramePetPanelTalent"..i]
			local ic = _G["PlayerTalentFramePetPanelTalent"..i.."IconTexture"]

			_G["PlayerTalentFramePetPanelTalent"..i.."Slot"]:SetAlpha(0)
			_G["PlayerTalentFramePetPanelTalent"..i.."SlotShadow"]:SetAlpha(0)
			_G["PlayerTalentFramePetPanelTalent"..i.."GoldBorder"]:SetAlpha(0)
			_G["PlayerTalentFramePetPanelTalent"..i.."GlowBorder"]:SetAlpha(0)
			bu:StyleButton()
			bu:GetHighlightTexture():Point("TOPLEFT", 1, -1)
			bu:GetHighlightTexture():Point("BOTTOMRIGHT", -1, 1)
			bu:GetPushedTexture():Point("TOPLEFT", 1, -1)
			bu:GetPushedTexture():Point("BOTTOMRIGHT", -1, 1)
			bu.SetHighlightTexture = R.dummy
			bu.SetPushedTexture = R.dummy
			
			ic:SetTexCoord(.08, .92, .08, .92)
			ic:Point("TOPLEFT", 1, -1)
			ic:Point("BOTTOMRIGHT", -1, 1)

			R.CreateBD(bu)
		end
	end

	for i = 1, 3 do
		local tab = _G["PlayerTalentFrameTab"..i]
		if tab then
			R.CreateTab(tab)
		end

		local panel = _G["PlayerTalentFramePanel"..i]
		local icon = _G["PlayerTalentFramePanel"..i.."HeaderIcon"]
		local num = _G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpent"]
		local icontexture = _G["PlayerTalentFramePanel"..i.."HeaderIconIcon"]

		for j = 1, 8 do
			select(j, panel:GetRegions()):Hide()
		end
		for j = 14, 21 do
			select(j, panel:GetRegions()):SetAlpha(0)
		end

		_G["PlayerTalentFramePanel"..i.."HeaderBackground"]:SetAlpha(0)
		_G["PlayerTalentFramePanel"..i.."HeaderBorder"]:Hide()
		_G["PlayerTalentFramePanel"..i.."BgHighlight"]:Hide()
		_G["PlayerTalentFramePanel"..i.."HeaderIconPrimaryBorder"]:SetAlpha(0)
		_G["PlayerTalentFramePanel"..i.."HeaderIconSecondaryBorder"]:SetAlpha(0)
		_G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpentBgGold"]:SetAlpha(0)
		_G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpentBgSilver"]:SetAlpha(0)

		icontexture:SetTexCoord(.08, .92, .08, .92)
		icontexture:Point("TOPLEFT", 1, -1)
		icontexture:Point("BOTTOMRIGHT", -1, 1)

		R.CreateBD(icon)

		icon:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -1)

		num:ClearAllPoints()
		num:Point("RIGHT", _G["PlayerTalentFramePanel"..i.."HeaderBackground"], "RIGHT", -40, 0)
		num:SetFont("FONTS\\FRIZQT__.TTF", 12)
		num:SetJustifyH("RIGHT")

		panel.bg = CreateFrame("Frame", nil, panel)
		panel.bg:SetPoint("TOPLEFT", 4, -39)
		panel.bg:SetPoint("BOTTOMRIGHT", -4, 4)
		panel.bg:SetFrameLevel(panel:GetFrameLevel()+1)
		R.CreateBD(panel.bg, 0)

		panel.bg2 = CreateFrame("Frame", nil, panel)
		panel.bg2:SetSize(200, 36)
		panel.bg2:SetPoint("TOPLEFT", 4, -1)
		panel.bg2:SetFrameLevel(0)
		R.CreateBD(panel.bg2, .25)

		R.Reskin(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"])

		for j = 1, 28 do
			local bu = _G["PlayerTalentFramePanel"..i.."Talent"..j]
			local ic = _G["PlayerTalentFramePanel"..i.."Talent"..j.."IconTexture"]

			_G["PlayerTalentFramePanel"..i.."Talent"..j.."Slot"]:SetAlpha(0)
			_G["PlayerTalentFramePanel"..i.."Talent"..j.."SlotShadow"]:SetAlpha(0)
			_G["PlayerTalentFramePanel"..i.."Talent"..j.."GoldBorder"]:SetAlpha(0)
			_G["PlayerTalentFramePanel"..i.."Talent"..j.."GlowBorder"]:SetAlpha(0)

			bu:StyleButton()
			bu:GetHighlightTexture():Point("TOPLEFT", 1, -1)
			bu:GetHighlightTexture():Point("BOTTOMRIGHT", -1, 1)
			bu:GetPushedTexture():Point("TOPLEFT", 1, -1)
			bu:GetPushedTexture():Point("BOTTOMRIGHT", -1, 1)
			bu.SetHighlightTexture = R.dummy
			bu.SetPushedTexture = R.dummy

			ic:SetTexCoord(.08, .92, .08, .92)
			ic:Point("TOPLEFT", 1, -1)
			ic:Point("BOTTOMRIGHT", -1, 1)

			R.CreateBD(bu)
		end
	end
	for i = 1, 2 do
		_G["PlayerSpecTab"..i.."Background"]:Hide()
		local tab = _G["PlayerSpecTab"..i]
		tab:StyleButton(true)
		tab:SetPushedTexture(nil)
		local a1, p, a2, x, y = PlayerSpecTab1:GetPoint()
		local bg = CreateFrame("Frame", nil, tab)
		bg:Point("TOPLEFT", -1, 1)
		bg:Point("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(tab:GetFrameLevel()-1)
		hooksecurefunc("PlayerTalentFrame_UpdateTabs", function()
			PlayerSpecTab1:Point(a1, p, a2, x + 11, y + 10)
			PlayerSpecTab2:Point("TOP", PlayerSpecTab1, "BOTTOM")
		end)
		R.CreateSD(tab, 5, 0, 0, 0, 1, 1)
		R.CreateBD(bg, 1)
		select(2, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
	end

	R.ReskinClose(PlayerTalentFrameCloseButton)
end

R.SkinFuncs["Blizzard_TalentUI"] = LoadSkin