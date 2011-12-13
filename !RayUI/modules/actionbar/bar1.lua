local R, C, L, DB = unpack(select(2, ...))

local bar = CreateFrame("Frame","RayUIActionBar1",UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(C["actionbar"].buttonsize*12+C["actionbar"].buttonspacing*11)
bar:SetHeight(C["actionbar"].buttonsize)

bar:SetPoint("BOTTOM", "UIParent", "BOTTOM", -3 * C["actionbar"].buttonsize -3 * C["actionbar"].buttonspacing, 235)
bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)

bar:SetScale(C["actionbar"].barscale)

R.CreateMover(bar, "ActionBar1Mover", L["动作条1锚点"], true)

local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
	["WARLOCK"] = "[form:2] 7;",
	["DEFAULT"] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = R.myclass
	local page = Page[class]
	if page then
	  condition = condition.." "..page
	end
	condition = condition.." 1"
	return condition
end

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
bar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
bar:RegisterEvent("BAG_UPDATE")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button, buttons
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			button = _G["ActionButton"..i]
			self:SetFrameRef("ActionButton"..i, button)
		end

		self:Execute([[
		buttons = table.new()
		for i = 1, 12 do
		  table.insert(buttons, self:GetFrameRef("ActionButton"..i))
		end
		]])

		self:SetAttribute("_onstate-page", [[
		for i, button in ipairs(buttons) do
		  button:SetAttribute("actionpage", tonumber(newstate))
		end
		]])

		RegisterStateDriver(self, "page", GetBar())
	elseif event == "PLAYER_ENTERING_WORLD" then
		local button
		for i = 1, 12 do
			button = _G["ActionButton"..i]
			button:SetSize(C["actionbar"].buttonsize, C["actionbar"].buttonsize)
			button:ClearAllPoints()
			button:SetParent(self)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", bar, 0,0)
			else
				local previous = _G["ActionButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", C["actionbar"].buttonspacing, 0)
			end
		end
	else
	   MainMenuBar_OnEvent(self, event, ...)
	end
end)