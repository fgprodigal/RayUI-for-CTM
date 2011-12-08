local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	R.SetBD(TabardFrame, 10, -12, -34, 74)
	TabardFramePortrait:Hide()
	TabardFrame:DisableDrawLayer("BORDER")
	TabardFrame:DisableDrawLayer("ARTWORK")
	TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 1, 0)
	R.Reskin(TabardFrameAcceptButton)
	R.Reskin(TabardFrameCancelButton)
	R.ReskinClose(TabardFrameCloseButton, "TOPRIGHT", TabardFrame, "TOPRIGHT", -38, -16)
	for i = 7, 16 do
		select(i, TabardFrame:GetRegions()):Hide()
	end
	TabardFrameCustomizationBorder:Hide()
	for i = 1, 5 do
		_G["TabardFrameCustomization"..i.."Left"]:Hide()
		_G["TabardFrameCustomization"..i.."Middle"]:Hide()
		_G["TabardFrameCustomization"..i.."Right"]:Hide()
	end
	R.ReskinArrow(TabardCharacterModelRotateLeftButton, 1)
	R.ReskinArrow(TabardCharacterModelRotateRightButton, 2)
	for i = 1, 5 do
		R.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], 1)
		R.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], 2)
	end	
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)