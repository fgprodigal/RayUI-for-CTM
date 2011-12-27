local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(BarberShopFrame, 44, -75, -40, 44)
	BarberShopFrameBackground:Hide()
	BarberShopFrameMoneyFrame:GetRegions():Hide()
	R.Reskin(BarberShopFrameOkayButton)
	R.Reskin(BarberShopFrameCancelButton)
	R.Reskin(BarberShopFrameResetButton)
	R.ReskinArrow(BarberShopFrameSelector1Prev, 1)
	R.ReskinArrow(BarberShopFrameSelector1Next, 2)
	R.ReskinArrow(BarberShopFrameSelector2Prev, 1)
	R.ReskinArrow(BarberShopFrameSelector2Next, 2)
	R.ReskinArrow(BarberShopFrameSelector3Prev, 1)
	R.ReskinArrow(BarberShopFrameSelector3Next, 2)
end

R.SkinFuncs["Blizzard_BarbershopUI"] = LoadSkin