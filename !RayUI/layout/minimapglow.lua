local R, C, L, DB = unpack(select(2, ...))
-----------------------------------------------------
-- MinimapBackground
-----------------------------------------------------
Minimap:CreateShadow("Background", 2)

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
		Minimap.shadow:SetBackdropBorderColor(1, .5, 0)
		Minimap:StartGlow()
	elseif inv > 0 and not mail then -- New invites and no mail
		Minimap.shadow:SetBackdropBorderColor(1, 30/255, 60/255)
		Minimap:StartGlow()
	elseif inv==0 and mail then -- No invites and new mail
		Minimap.shadow:SetBackdropBorderColor(.5, 1, 1)
		Minimap:StartGlow()
	else -- None of the above
		Minimap:StopGlow()
		Minimap.shadow:SetAlpha(1)
		Minimap.shadow:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end)

-- GM
HelpOpenTicketButton:SetParent(Minimap)
HelpOpenTicketButton:ClearAllPoints()
HelpOpenTicketButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT")