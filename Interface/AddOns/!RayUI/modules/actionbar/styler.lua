local R, C, L, DB = unpack(select(2, ...))

local _G = _G
local securehandler = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")

local function UpdateHotkey(self, actionButtonType)
	local hotkey = _G[self:GetName() .. 'HotKey']
	local text = hotkey:GetText()

	text = string.gsub(text, '(s%-)', 'S')
	text = string.gsub(text, '(a%-)', 'A')
	text = string.gsub(text, '(c%-)', 'C')
	text = string.gsub(text, '(Mouse Button )', 'M')
	text = string.gsub(text, '(滑鼠按鍵)', 'M')
	text = string.gsub(text, '(鼠标按键)', 'M')
	text = string.gsub(text, KEY_BUTTON3, 'M3')
	text = string.gsub(text, '(Num Pad )', 'N')
	text = string.gsub(text, KEY_PAGEUP, 'PU')
	text = string.gsub(text, KEY_PAGEDOWN, 'PD')
	text = string.gsub(text, KEY_SPACE, 'SpB')
	text = string.gsub(text, KEY_INSERT, 'Ins')
	text = string.gsub(text, KEY_HOME, 'Hm')
	text = string.gsub(text, KEY_DELETE, 'Del')
	text = string.gsub(text, KEY_MOUSEWHEELUP, 'MwU')
	text = string.gsub(text, KEY_MOUSEWHEELDOWN, 'MwD')

	if hotkey:GetText() == _G['RANGE_INDICATOR'] then
		hotkey:SetText('')
	else
		hotkey:SetText(text)
	end
end

function Style(self, totem, flyout)
	local name = self:GetName()
	
	if name:match("MultiCast") then return end 
	
	local action = self.action
	local Button = self
	local Icon = _G[name.."Icon"]
	local Count = _G[name.."Count"]
	local Flash	 = _G[name.."Flash"]
	local HotKey = _G[name.."HotKey"]
	local Border  = _G[name.."Border"]
	local Btname = _G[name.."Name"]
	local normal  = _G[name.."NormalTexture"]
	local normal2 = self:GetNormalTexture()
	
	if Flash then Flash:SetTexture(nil) end
	if normal then normal:SetTexture(nil) end
	if normal2 then normal2:SetTexture(nil) end
	if Border then Border:Kill() end
	
	if Count then
		Count:ClearAllPoints()
		Count:SetPoint("BOTTOMRIGHT", 0, R.Scale(2))
		-- Count:SetFont(C["media"].pxfont, R.Scale(10), "OUTLINE,MONOCHROME")
		Count:SetFont(C["media"].pxfont, R.mult*10, "OUTLINE,MONOCHROME")
	end
	
	if _G[name..'FloatingBG'] then
		_G[name..'FloatingBG']:Kill()
	end	

	if self.styled then return end	
	
	if Btname then
		if C["actionbar"].macroname ~= true then
			Btname:SetText("")
			Btname:Hide()
			Btname.Show = R.dummy
		end
	end
	
	if not self.shadow then
		if not totem then
			if not flyout then
				self:SetWidth(C["actionbar"].buttonsize)
				self:SetHeight(C["actionbar"].buttonsize)
			end
 
			self:CreateShadow("Background")
		end
		
		if Icon then
			Icon:SetTexCoord(.08, .92, .08, .92)
			Icon:SetAllPoints()
		end
	end
	
	if HotKey then
		HotKey:ClearAllPoints()
		HotKey:SetPoint("TOPRIGHT", 0, 0)
		-- HotKey:SetFont(C["media"].pxfont, R.Scale(10), "OUTLINE,MONOCHROME")
		HotKey:SetFont(C["media"].pxfont, R.mult*10, "OUTLINE,MONOCHROME")
		HotKey:SetShadowColor(0, 0, 0, 0.3)
		HotKey.ClearAllPoints = R.dummy
		HotKey.SetPoint = R.dummy
		if not C["actionbar"].hotkeys == true then
			HotKey:SetText("")
			HotKey:Hide()
			HotKey.Show = R.dummy
		end
	end
	
	if normal then
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT")
		normal:SetPoint("BOTTOMRIGHT")
	end
	
	self.styled = true
end

local function Stylesmallbutton(normal, button, icon, name, pet)
	local Flash	 = _G[name.."Flash"]
	-- button:SetWidth(C["actionbar"].buttonsize)
	-- button:SetHeight(C["actionbar"].buttonsize)

	button:SetNormalTexture("")
	button.SetNormalTexture = R.dummy
	
	Flash:SetTexture(1, 1, 1, 0.3)
	
	if not button.shadow then
		button:CreateShadow("Background")
	end

	icon:SetTexCoord(.08, .92, .08, .92)
	icon:ClearAllPoints()
	if pet then			
		if C["actionbar"].buttonsize < 30 then
			local autocast = _G[name.."AutoCastable"]
			autocast:SetAlpha(0)
		end
		local shine = _G[name.."Shine"]
		shine:Size(C["actionbar"].buttonsize, C["actionbar"].buttonsize)
		shine:ClearAllPoints()
		shine:SetPoint("CENTER", button, 0, 0)
		icon:SetAllPoints()
	else
		icon:SetAllPoints()
	end
	
	if normal then
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT")
		normal:SetPoint("BOTTOMRIGHT")
	end
end

local function StyleShift()
	for i=1, NUM_SHAPESHIFT_SLOTS do
		local name = "ShapeshiftButton"..i
		local button  = _G[name]
		local icon  = _G[name.."Icon"]
		local normal  = _G[name.."NormalTexture"]
		Stylesmallbutton(normal, button, icon, name)
	end
end

local function StylePet()
	for i=1, NUM_PET_ACTION_SLOTS do
		local name = "PetActionButton"..i
		local button  = _G[name]
		local icon  = _G[name.."Icon"]
		local normal  = _G[name.."NormalTexture2"]
		Stylesmallbutton(normal, button, icon, name, true)
	end
end

-- rescale cooldown spiral to fix texture.
local buttonNames = { "ActionButton",  "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarLeftButton", "MultiBarRightButton", "ShapeshiftButton", "PetActionButton"}
for _, name in ipairs( buttonNames ) do
	for index = 1, 12 do
		local buttonName = name .. tostring(index)
		local button = _G[buttonName]
		local cooldown = _G[buttonName .. "Cooldown"]
 
		if ( button == nil or cooldown == nil ) then
			break
		end
		
		cooldown:ClearAllPoints()
		cooldown:Point("TOPLEFT", button, "TOPLEFT", 2, -2)
		cooldown:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	end
end

local buttons = 0
local function SetupFlyoutButton()
	for i=1, buttons do
		--prevent error if you don't have max ammount of buttons
		if _G["SpellFlyoutButton"..i] and not _G["SpellFlyoutButton"..i].styled then
			Style(_G["SpellFlyoutButton"..i], nil, true)
			_G["SpellFlyoutButton"..i]:StyleButton(true)
			if C["actionbar"].rightbarmouseover == true then
				SpellFlyout:HookScript("OnEnter", function(self) RightBarMouseOver(1) end)
				SpellFlyout:HookScript("OnLeave", function(self) RightBarMouseOver(0) end)
				_G["SpellFlyoutButton"..i]:HookScript("OnEnter", function(self) RightBarMouseOver(1) end)
				_G["SpellFlyoutButton"..i]:HookScript("OnLeave", function(self) RightBarMouseOver(0) end)
			end
		end
	end
end
SpellFlyout:HookScript("OnShow", SetupFlyoutButton)

 
--Hide the Mouseover texture and attempt to find the ammount of buttons to be skinned
local function StyleFlyout(self)
	if not self.FlyoutBorder then return end
	self.FlyoutBorder:SetAlpha(0)
	self.FlyoutBorderShadow:SetAlpha(0)
	
	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)
	
	for i=1, GetNumFlyouts() do
		local x = GetFlyoutID(i)
		local _, _, numSlots, isKnown = GetFlyoutInfo(x)
		if isKnown then
			buttons = numSlots
			break
		end
	end
	
	--Change arrow direction depending on what bar the button is on
	local arrowDistance
	if ((SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self) or GetMouseFocus() == self) then
		arrowDistance = 5
	else
		arrowDistance = 2
	end
	
	if self:GetParent() and self:GetParent():GetParent() and self:GetParent():GetParent():GetName() and self:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame" then 
		return 
	end
	
	if self:GetAttribute("flyoutDirection") ~= nil then
		local point, _, _, _, _ = self:GetPoint()
		
		if strfind(point, "TOP") then
			self.FlyoutArrow:ClearAllPoints()
			self.FlyoutArrow:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(self.FlyoutArrow, 270)
			if not InCombatLockdown() then self:SetAttribute("flyoutDirection", "LEFT") end		
		else
			self.FlyoutArrow:ClearAllPoints()
			self.FlyoutArrow:SetPoint("TOP", self, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(self.FlyoutArrow, 0)
			if not InCombatLockdown() then self:SetAttribute("flyoutDirection", "UP") end
		end
	end
end

do	
	for i = 1, 12 do
		_G["MultiBarLeftButton"..i]:StyleButton(true)
		_G["MultiBarRightButton"..i]:StyleButton(true)
		_G["MultiBarBottomRightButton"..i]:StyleButton(true)
		_G["MultiBarBottomLeftButton"..i]:StyleButton(true)
		_G["ActionButton"..i]:StyleButton(true)
	end
	 
	for i=1, 10 do
		_G["ShapeshiftButton"..i]:StyleButton(true)
		_G["PetActionButton"..i]:StyleButton(true)
	end
	
	for i=1, 6 do
		_G["VehicleMenuBarActionButton"..i]:StyleButton(true)
		Style(_G["VehicleMenuBarActionButton"..i])
	end
end

local function UpdateOverlayGlow(self)
	if self.overlay then
		self.overlay:SetParent(self)
		self.overlay:ClearAllPoints()
		self.overlay:SetAllPoints(self.shadow)
		self.overlay.ants:ClearAllPoints()
		self.overlay.ants:SetAllPoints(self.shadow)
		-- self.overlay.ants:SetPoint("TOPLEFT", self.shadow, "TOPLEFT", -1, 1)
		-- self.overlay.ants:SetPoint("BOTTOMRIGHT", self.shadow, "BOTTOMRIGHT", 1, -1)
		self.overlay.outerGlow:SetPoint("TOPLEFT", self.shadow, "TOPLEFT", -4, 4)
		self.overlay.outerGlow:SetPoint("BOTTOMRIGHT", self.shadow, "BOTTOMRIGHT", 4, -4)
	end
end

hooksecurefunc("ActionButton_ShowOverlayGlow", UpdateOverlayGlow)

hooksecurefunc("ActionButton_Update", Style)
hooksecurefunc("ActionButton_UpdateHotkeys", UpdateHotkey)
hooksecurefunc("ActionButton_UpdateFlyout", StyleFlyout)

hooksecurefunc("ShapeshiftBar_Update", StyleShift)
hooksecurefunc("ShapeshiftBar_UpdateState", StyleShift)
hooksecurefunc("PetActionBar_Update", StylePet)

local RayUIOnLogon = CreateFrame("Frame")
RayUIOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
RayUIOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SetCVar("alwaysShowActionBars", 0)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
	if C["actionbar"].showgrid == true then
		ActionButton_HideGrid = R.dummy
		for i = 1, 12 do
			local button = _G[format("ActionButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("BonusActionButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
			
			button = _G[format("MultiBarRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarBottomRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
			
			button = _G[format("MultiBarLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
			
			button = _G[format("MultiBarBottomLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
		end
	end
end)