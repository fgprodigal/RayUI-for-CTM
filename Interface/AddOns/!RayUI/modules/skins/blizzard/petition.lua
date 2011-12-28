local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(PetitionFrame, 6, -15, -26, 64)
	PetitionFramePortrait:Hide()
	PetitionFrameCharterTitle:SetTextColor(1, 1, 1)
	PetitionFrameCharterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMasterTitle:SetTextColor(1, 1, 1)
	PetitionFrameMasterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMemberTitle:SetTextColor(1, 1, 1)
	PetitionFrameMemberTitle:SetShadowColor(0, 0, 0)
	for i = 2, 5 do
		select(i, PetitionFrame:GetRegions()):Hide()
	end
	R.Reskin(PetitionFrameSignButton)
	R.Reskin(PetitionFrameRequestButton)
	R.Reskin(PetitionFrameRenameButton)
	R.Reskin(PetitionFrameCancelButton)
	R.ReskinClose(PetitionFrameCloseButton, "TOPRIGHT", PetitionFrame, "TOPRIGHT", -30, -20)
end

tinsert(R.SkinFuncs["RayUI"], LoadSkin)