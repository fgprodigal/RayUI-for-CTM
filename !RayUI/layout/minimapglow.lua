local R, C, DB = unpack(select(2, ...))
-----------------------------------------------------
-- MinimapBackground
-----------------------------------------------------
Minimap.bg = CreateFrame("Frame", nil, Minimap)
Minimap.bg:SetPoint("TOPLEFT", -2, 2)
Minimap.bg:SetPoint("BOTTOMRIGHT", 2, -2)
Minimap.bg:CreateShadow("Background")

--New Mail Check
local checkmail = CreateFrame("Frame")
checkmail:RegisterEvent("ADDON_LOADED")
checkmail:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
checkmail:RegisterEvent("UPDATE_PENDING_MAIL")
checkmail:RegisterEvent("PLAYER_ENTERING_WORLD")
checkmail:SetScript("OnEvent", function(self, event, addon)
	local inv = CalendarGetNumPendingInvites()
	local mail = HasNewMail()
	if inv > 0 and mail then -- New invites and mail
		Minimap.bg.glow:SetBackdropBorderColor(1, .5, 0)
		Minimap.bg:StartGlow()
	elseif inv > 0 and not mail then -- New invites and no mail
		Minimap.bg.glow:SetBackdropBorderColor(1, 30/255, 60/255)
		Minimap.bg:StartGlow()
	elseif inv==0 and mail then -- No invites and new mail
		Minimap.bg.glow:SetBackdropBorderColor(0, 1, 0)
		Minimap.bg:StartGlow()
	else -- None of the above
		Minimap.bg:StopGlow()
		Minimap.bg.glow:SetAlpha(1)
		Minimap.bg.glow:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end)