local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local AB = R:GetModule("ActionBar")

function AB:CreateStanceBar()
	local num = NUM_SHAPESHIFT_SLOTS

	local bar = CreateFrame("Frame","RayUIStanceBar",UIParent, "SecureHandlerStateTemplate")
	bar:SetWidth(AB.db.buttonsize*num+AB.db.buttonspacing*(num-1))
	bar:SetHeight(AB.db.buttonsize)
	bar:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 15, 202)
	bar:SetScale(AB.db.barscale)

	R:CreateMover(bar, "StanceBarMover", L["职业条锚点"], true)  

	ShapeshiftBarFrame:SetParent(bar)
	ShapeshiftBarFrame:EnableMouse(false)

	for i=1, num do
		local button = _G["ShapeshiftButton"..i]
			button:SetSize(AB.db.buttonsize, AB.db.buttonsize)
			button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", bar, 0,0)
		else
			local previous = _G["ShapeshiftButton"..i-1]      
			button:SetPoint("LEFT", previous, "RIGHT", AB.db.buttonspacing, 0)
		end
	end
		
	local function RayUIMoveShapeshift()
		ShapeshiftButton1:SetPoint("BOTTOMLEFT", bar, 0,0)
	end
	hooksecurefunc("ShapeshiftBar_Update", RayUIMoveShapeshift);
		
		
	if AB.db.stancebarmouseover then    
		AB.db.stancebarfade = false  
		bar:SetAlpha(0)
		bar:SetScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
		bar:SetScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)  
		for i=1, num do
			local pb = _G["ShapeshiftButton"..i]
			pb:HookScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
			pb:HookScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)
		end    
	end

	local States = {
		["DRUID"] = "show",
		["WARRIOR"] = "show",
		["PALADIN"] = "show",
		["DEATHKNIGHT"] = "show",
		["ROGUE"] = "show,",
		["PRIEST"] = "show,",
		["HUNTER"] = "show,",
		["WARLOCK"] = "show,",
	}
end