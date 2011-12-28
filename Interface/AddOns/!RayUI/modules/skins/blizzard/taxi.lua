local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(TaxiFrame, 3, -23, -5, 3)
	TaxiFrame:DisableDrawLayer("BORDER")
	TaxiFrame:DisableDrawLayer("OVERLAY")
	TaxiFrameBg:Hide()
	TaxiFrameTitleBg:Hide()
	R.ReskinClose(TaxiFrameCloseButton, "TOPRIGHT", TaxiRouteMap, "TOPRIGHT", -1, -1)
end

tinsert(R.SkinFuncs["RayUI"], LoadSkin)