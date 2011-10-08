local R, C, L, DB = unpack(select(2, ...))
  

local bar = CreateFrame("Frame","rABS_VehicleBar",UIParent, "SecureHandlerStateTemplate")
bar:SetHeight(C["actionbar"].buttonsize)
bar:SetWidth(C["actionbar"].buttonsize)
if C.general.speciallayout then
	bar:SetPoint("BOTTOMLEFT", "rABS_MultiBarBottomLeft", "BOTTOMRIGHT", C["actionbar"].buttonspacing, 0)
else
	bar:SetPoint("LEFT", "rABS_MainMenuBar", "RIGHT", C["actionbar"].buttonspacing, 0)
end
bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)
bar:SetScale(C["actionbar"].barscale)

local veb = CreateFrame("BUTTON", nil, bar, "SecureActionButtonTemplate");
veb:Point("TOPLEFT", -3, 2)
veb:Point("BOTTOMRIGHT", 3, -2)
veb.bg = CreateFrame("Frame", nil, veb)
veb.bg:SetAllPoints(bar)
veb.bg:CreateShadow("Background")
veb:RegisterForClicks("AnyUp")
veb:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
veb:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
veb:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
veb:SetScript("OnClick", function(self) VehicleExit() end)
veb:RegisterEvent("UNIT_ENTERING_VEHICLE")
veb:RegisterEvent("UNIT_ENTERED_VEHICLE")
veb:RegisterEvent("UNIT_EXITING_VEHICLE")
veb:RegisterEvent("UNIT_EXITED_VEHICLE")
veb:SetScript("OnEvent", function(self,event,...)
local arg1 = ...;
if(((event=="UNIT_ENTERING_VEHICLE") or (event=="UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
	veb:SetAlpha(1)
elseif(((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and arg1 == "player") then
	veb:SetAlpha(0)
	-- veb:SetAlpha(1)
end
end)  
veb:SetAlpha(0)
-- veb:SetAlpha(1)