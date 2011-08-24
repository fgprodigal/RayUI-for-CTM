if not IsAddOnLoaded("!RayUI") then return end

local PostalSkin = CreateFrame("Frame")
PostalSkin:RegisterEvent("MAIL_SHOW")

PostalSkin:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("MAIL_SHOW")
	PostalSelectOpenButton:ReskinButton()
	PostalSelectReturnButton:ReskinButton()
	PostalOpenAllButton:ReskinButton()
end)