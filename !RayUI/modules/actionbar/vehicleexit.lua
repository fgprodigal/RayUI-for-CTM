local R, C, L, DB = unpack(select(2, ...))

local bar = CreateFrame("Frame","RayUIVehicleBar",UIParent, "SecureHandlerStateTemplate")
bar:SetHeight(C["actionbar"].buttonsize)
bar:SetWidth(C["actionbar"].buttonsize)
bar:SetPoint("BOTTOMLEFT", "RayUIActionBar2", "BOTTOMRIGHT", C["actionbar"].buttonspacing, 0)

bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)
bar:SetScale(C["actionbar"].barscale)

local veb = CreateFrame("BUTTON", nil, bar, "SecureActionButtonTemplate");
veb:Point("TOPLEFT", -3, 2)
veb:Point("BOTTOMRIGHT", 3, -2)
veb:CreateShadow("Background", -3)
veb:RegisterForClicks("AnyUp")
veb:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
veb:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
veb:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
veb:SetScript("OnClick", function(self) VehicleExit() end)
RegisterStateDriver(veb, "visibility", "[vehicleui] show;[target=vehicle,exists] show;hide")