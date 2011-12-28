local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(DressUpFrame, 10, -12, -34, 74)
	DressUpFramePortrait:Hide()
	DressUpBackgroundTopLeft:Hide()
	DressUpBackgroundTopRight:Hide()
	DressUpBackgroundBotLeft:Hide()
	DressUpBackgroundBotRight:Hide()
	for i = 2, 5 do
		select(i, DressUpFrame:GetRegions()):Hide()
	end
	DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)
	R.Reskin(DressUpFrameCancelButton)
	R.Reskin(DressUpFrameResetButton)
	R.ReskinClose(DressUpFrameCloseButton, "TOPRIGHT", DressUpFrame, "TOPRIGHT", -38, -16)
end

tinsert(R.SkinFuncs["RayUI"], LoadSkin)