---------------------
-- HatTrick
---------------------

local hcheck = CreateFrame("CheckButton", "HelmCheckBox", PaperDollFrame, "OptionsCheckButtonTemplate")
hcheck:SetSize(22, 22)
hcheck:SetPoint("TOPLEFT", CharacterHeadSlot, "BOTTOMRIGHT", 5, 15)
hcheck:SetScript("OnClick", function () ShowHelm(not ShowingHelm()) end)
hcheck:SetScript("OnEnter", function ()
 	GameTooltip:SetOwner(hcheck, "ANCHOR_RIGHT")
	GameTooltip:SetText(SHOW_HELM)
end)
hcheck:SetScript("OnLeave", function () GameTooltip:Hide() end)
hcheck:SetFrameStrata("HIGH")

local ccheck = CreateFrame("CheckButton", "CloakCheckBox", PaperDollFrame, "OptionsCheckButtonTemplate")
ccheck:SetSize(22, 22)
ccheck:SetPoint("TOPLEFT", CharacterBackSlot, "BOTTOMRIGHT", 5, 15)
ccheck:SetScript("OnClick", function () ShowCloak(not ShowingCloak()) end)
ccheck:SetScript("OnEnter", function ()
	GameTooltip:SetOwner(ccheck, "ANCHOR_RIGHT")
	GameTooltip:SetText(SHOW_CLOAK)
end)
ccheck:SetScript("OnLeave", function () GameTooltip:Hide() end)
ccheck:SetFrameStrata("HIGH")

hooksecurefunc("ShowHelm", function(v) hcheck:SetChecked(v) end)
hooksecurefunc("ShowCloak", function(v)	ccheck:SetChecked(v) end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	hcheck:SetChecked(ShowingHelm())
	ccheck:SetChecked(ShowingCloak())
end)