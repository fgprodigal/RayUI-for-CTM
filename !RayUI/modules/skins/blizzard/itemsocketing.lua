local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(ItemSocketingFrame, 12, -8, -2, 24)
	select(2, ItemSocketingFrame:GetRegions()):Hide()
	ItemSocketingFramePortrait:Hide()
	ItemSocketingScrollFrameTop:SetAlpha(0)
	ItemSocketingScrollFrameBottom:SetAlpha(0)
	ItemSocketingSocket1Left:SetAlpha(0)
	ItemSocketingSocket1Right:SetAlpha(0)
	ItemSocketingSocket2Left:SetAlpha(0)
	ItemSocketingSocket2Right:SetAlpha(0)
	R.Reskin(ItemSocketingSocketButton)
	ItemSocketingSocketButton:ClearAllPoints()
	ItemSocketingSocketButton:SetPoint("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -10, 28)
	R.ReskinClose(ItemSocketingCloseButton, "TOPRIGHT", ItemSocketingFrame, "TOPRIGHT", -6, -12)
	R.ReskinScroll(ItemSocketingScrollFrameScrollBar)
end

R.SkinFuncs["Blizzard_ItemSocketingUI"] = LoadSkin