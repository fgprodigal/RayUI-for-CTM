local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(BattlefieldMinimap, -1, 1, -5, 3)
	BattlefieldMinimapCorner:Hide()
	BattlefieldMinimapBackground:Hide()
	BattlefieldMinimapCloseButton:Hide()
end

R.SkinFuncs["Blizzard_BattlefieldMinimap"] = LoadSkin