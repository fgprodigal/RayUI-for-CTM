local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local S = R:GetModule("Skins")

local function LoadSkin()
	MacroFrameText:SetFont(R["media"].font, 14)
	S:SetBD(MacroFrame, 12, -10, -33, 68)
	S:CreateBD(MacroFrameScrollFrame, .25)
	S:CreateBD(MacroPopupFrame)
	S:CreateBD(MacroPopupEditBox, .25)
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
		ic:SetGradient("VERTICAL",.345,.345,.345,1,1,1)

		S:CreateBD(bu, .25)
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
		ic:SetGradient("VERTICAL",.345,.345,.345,1,1,1)

		S:CreateBD(bu, .25)
	end

	MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPLEFT", 12, -16)
	MacroFrameSelectedMacroButtonIcon:SetPoint("TOPLEFT", 1, -1)
	MacroFrameSelectedMacroButtonIcon:SetPoint("BOTTOMRIGHT", -1, 1)
	MacroFrameSelectedMacroButtonIcon:SetTexCoord(.08, .92, .08, .92)
	MacroFrameSelectedMacroButtonIcon:SetGradient("VERTICAL",.345,.345,.345,1,1,1)

	S:CreateBD(MacroFrameSelectedMacroButton, .25)

	S:Reskin(MacroDeleteButton)
	S:Reskin(MacroNewButton)
	S:Reskin(MacroExitButton)
	S:Reskin(MacroEditButton)
	S:Reskin(MacroSaveButton)
	S:Reskin(MacroCancelButton)
	S:Reskin(MacroPopupOkayButton)
	S:Reskin(MacroPopupCancelButton)
	MacroPopupFrame:ClearAllPoints()
	MacroPopupFrame:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", -32, -40)

	S:ReskinClose(MacroFrameCloseButton, "TOPRIGHT", MacroFrame, "TOPRIGHT", -38, -14)
	S:ReskinScroll(MacroButtonScrollFrameScrollBar)
	S:ReskinScroll(MacroFrameScrollFrameScrollBar)
	S:ReskinScroll(MacroPopupScrollFrameScrollBar)
end

S:RegisterSkin("Blizzard_MacroUI", LoadSkin)