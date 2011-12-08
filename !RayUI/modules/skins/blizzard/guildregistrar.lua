local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(GuildRegistrarFrame, 6, -15, -26, 64)
	R.CreateBD(GuildRegistrarFrameEditBox, .25)
	GuildRegistrarFrame:DisableDrawLayer("ARTWORK")
	GuildRegistrarFramePortrait:Hide()
	GuildRegistrarFrameEditBox:SetHeight(20)
	R.Reskin(GuildRegistrarFrameGoodbyeButton)
	R.Reskin(GuildRegistrarFramePurchaseButton)
	R.Reskin(GuildRegistrarFrameCancelButton)
	select(6, GuildRegistrarFrameEditBox:GetRegions()):Hide()
	select(7, GuildRegistrarFrameEditBox:GetRegions()):Hide()
	select(2, GuildRegistrarGreetingFrame:GetRegions()):Hide()
	R.ReskinClose(GuildRegistrarFrameCloseButton, "TOPRIGHT", GuildRegistrarFrame, "TOPRIGHT", -30, -20)
end

R.SkinFuncs["Blizzard_RaidUI"] = LoadSkin