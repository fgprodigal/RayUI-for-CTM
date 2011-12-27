local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(TransmogrifyFrame)
	TransmogrifyArtFrame:DisableDrawLayer("BACKGROUND")
	TransmogrifyArtFrame:DisableDrawLayer("BORDER")
	TransmogrifyArtFramePortraitFrame:Hide()
	TransmogrifyArtFramePortrait:Hide()
	TransmogrifyArtFrameTopBorder:Hide()
	TransmogrifyArtFrameTopRightCorner:Hide()
	TransmogrifyModelFrameMarbleBg:Hide()
	select(2, TransmogrifyModelFrame:GetRegions()):Hide()
	TransmogrifyModelFrameLines:Hide()
	TransmogrifyFrameButtonFrame:GetRegions():Hide()
	TransmogrifyFrameButtonFrameButtonBorder:Hide()
	TransmogrifyFrameButtonFrameButtonBottomBorder:Hide()
	TransmogrifyFrameButtonFrameMoneyLeft:Hide()
	TransmogrifyFrameButtonFrameMoneyRight:Hide()
	TransmogrifyFrameButtonFrameMoneyMiddle:Hide()
	TransmogrifyApplyButton_LeftSeparator:Hide()

	local slots = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Back", "MainHand", "SecondaryHand", "Ranged"}

	for i = 1, #slots do
		local slot = _G["TransmogrifyFrame"..slots[i].."Slot"]
		if slot then
			local ic = _G["TransmogrifyFrame"..slots[i].."SlotIconTexture"]
			_G["TransmogrifyFrame"..slots[i].."SlotBorder"]:Hide()
			_G["TransmogrifyFrame"..slots[i].."SlotGrabber"]:Hide()

			ic:SetTexCoord(.08, .92, .08, .92)
			R.CreateBD(slot, 0)
			
			slot:StyleButton()
			slot:GetHighlightTexture():Point("TOPLEFT", 1, -1)
			slot:GetHighlightTexture():Point("BOTTOMRIGHT", -1, 1)
			slot:GetPushedTexture():Point("TOPLEFT", 1, -1)
			slot:GetPushedTexture():Point("BOTTOMRIGHT", -1, 1)
		end
	end

	R.Reskin(TransmogrifyApplyButton)
	R.ReskinClose(TransmogrifyArtFrameCloseButton)
end

R.SkinFuncs["Blizzard_ItemAlterationUI"] = LoadSkin