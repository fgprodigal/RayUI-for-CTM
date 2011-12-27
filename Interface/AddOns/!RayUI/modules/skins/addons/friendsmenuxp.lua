local R, C, L, DB = unpack(select(2, ...))

local Delay = CreateFrame("Frame")
Delay:RegisterEvent("PLAYER_ENTERING_WORLD")
Delay:SetScript("OnEvent", function()
	Delay:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if FriendsMenuXPSecure then
		FriendsMenuXPSecureMenuBackdrop:StripTextures()
		R.CreateBD(FriendsMenuXPSecureMenuBackdrop)
	end
end)