local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	MacroFrameText:SetFont(C.media.font, 14)
	R.SetBD(MacroFrame, 12, -10, -33, 68)
	R.CreateBD(MacroFrameScrollFrame, .25)
	R.CreateBD(MacroPopupFrame)
	R.CreateBD(MacroPopupEditBox, .25)
	for i = 1, 6 do
		select(i, MacroFrameTab1:GetRegions()):Hide()
		select(i, MacroFrameTab2:GetRegions()):Hide()
		select(i, MacroFrameTab1:GetRegions()).Show = R.dummy
		select(i, MacroFrameTab2:GetRegions()).Show = R.dummy
	end
	for i = 1, 8 do
		if i ~= 6 then select(i, MacroFrame:GetRegions()):Hide() end
	end
	for i = 1, 5 do
		select(i, MacroPopupFrame:GetRegions()):Hide()
	end
	MacroPopupScrollFrame:GetRegions():Hide()
	select(2, MacroPopupScrollFrame:GetRegions()):Hide()
	MacroPopupNameLeft:Hide()
	MacroPopupNameMiddle:Hide()
	MacroPopupNameRight:Hide()
	MacroFrameTextBackground:SetBackdrop(nil)
	select(2, MacroFrameSelectedMacroButton:GetRegions()):Hide()
	MacroFrameSelectedMacroBackground:SetAlpha(0)
	MacroButtonScrollFrameTop:Hide()
	MacroButtonScrollFrameBottom:Hide()

	for i = 1, MAX_ACCOUNT_MACROS do
		local bu = _G["MacroButton"..i]
		local ic = _G["MacroButton"..i.."Icon"]

		select(2, bu:GetRegions()):Hide()
		bu:StyleButton()
		bu:SetPushedTexture(nil)
		bu:GetHighlightTexture():Point("TOPLEFT", 1, -1)
		bu:GetHighlightTexture():Point("BOTTOMRIGHT", -1, 1)
		bu:GetCheckedTexture():Point("TOPLEFT", 1, -1)
		bu:GetCheckedTexture():Point("BOTTOMRIGHT", -1, 1)

		ic:Point("TOPLEFT", 1, -1)
		ic:Point("BOTTOMRIGHT", -1, 1)
		ic:SetTexCoord(.08, .92, .08, .92)

		R.CreateBD(bu, .25)
	end

	for i = 1, NUM_MACRO_ICONS_SHOWN do
		local bu = _G["MacroPopupButton"..i]
		local ic = _G["MacroPopupButton"..i.."Icon"]

		select(2, bu:GetRegions()):Hide()
		bu:StyleButton()
		bu:SetPushedTexture(nil)
		bu:GetHighlightTexture():Point("TOPLEFT", 1, -1)
		bu:GetHighlightTexture():Point("BOTTOMRIGHT", -1, 1)
		bu:GetCheckedTexture():Point("TOPLEFT", 1, -1)
		bu:GetCheckedTexture():Point("BOTTOMRIGHT", -1, 1)

		ic:SetPoint("TOPLEFT", 1, -1)
		ic:SetPoint("BOTTOMRIGHT", -1, 1)
		ic:SetTexCoord(.08, .92, .08, .92)

		R.CreateBD(bu, .25)
	end

	MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPLEFT", 12, -16)
	MacroFrameSelectedMacroButtonIcon:SetPoint("TOPLEFT", 1, -1)
	MacroFrameSelectedMacroButtonIcon:SetPoint("BOTTOMRIGHT", -1, 1)
	MacroFrameSelectedMacroButtonIcon:SetTexCoord(.08, .92, .08, .92)

	R.CreateBD(MacroFrameSelectedMacroButton, .25)

	R.Reskin(MacroDeleteButton)
	R.Reskin(MacroNewButton)
	R.Reskin(MacroExitButton)
	R.Reskin(MacroEditButton)
	R.Reskin(MacroSaveButton)
	R.Reskin(MacroCancelButton)
	R.Reskin(MacroPopupOkayButton)
	R.Reskin(MacroPopupCancelButton)
	MacroPopupFrame:ClearAllPoints()
	MacroPopupFrame:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", -32, -40)

	R.ReskinClose(MacroFrameCloseButton, "TOPRIGHT", MacroFrame, "TOPRIGHT", -38, -14)
	R.ReskinScroll(MacroButtonScrollFrameScrollBar)
	R.ReskinScroll(MacroFrameScrollFrameScrollBar)
	R.ReskinScroll(MacroPopupScrollFrameScrollBar)
end

R.SkinFuncs["Blizzard_MacroUI"] = LoadSkin