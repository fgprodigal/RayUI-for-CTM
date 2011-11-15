local R, C, L, DB = unpack(select(2, ...))
  
  local _G = _G

  local nomoreplay = function() return end
  
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
  --initial style func
  local function rActionButtonStyler_AB_style(self, totem, flyout)
  
    local name = self:GetName()
	
	if name:match("MultiCast") then return end 
      
      local action = self.action
      local name = self:GetName()
      local bu  = _G[name]
      local ic  = _G[name.."Icon"]
      local co  = _G[name.."Count"]
      local bo  = _G[name.."Border"]
      local ho  = _G[name.."HotKey"]
      local cd  = _G[name.."Cooldown"]
      local na  = _G[name.."Name"]
      local fl  = _G[name.."Flash"]
      local nt  = _G[name.."NormalTexture"]
      
      if fl then
		fl:SetTexture("")
	  end
	  
	  if bo then
		  bo:Hide()
		  bo.Show = nomoreplay
	  end
	  
	  if nt then
		nt:SetTexture(nil)
      end
	  
	  if self.rABS_Styled then return end	
	  
      if C["actionbar"].hotkeys then
        ho:SetFont(C["media"].pxfont, 11, "OUTLINE,MONOCHROME")
		ho:SetShadowColor(0, 0, 0)
		ho:SetShadowOffset(R.mult, -R.mult)
        ho:ClearAllPoints()
        ho:SetPoint("TOPRIGHT", 0, 0)
        ho:SetPoint("TOPLEFT", 0, 0)
      else
        ho:Hide()
        ho.Show = nomoreplay
      end
      
      if C["actionbar"].macroname then
        na:SetFont(C["media"].font, 12, "OUTLINE")
        na:ClearAllPoints()
        na:SetPoint("BOTTOMLEFT", bu, 0, 0)
        na:SetPoint("BOTTOMRIGHT", bu, 0, 0)
      else
        na:Hide()
      end

      if C["actionbar"].itemcount then
        co:SetFont(C["media"].pxfont, 11, "OUTLINE,MONOCHROME")
		co:SetShadowColor(0, 0, 0)
		co:SetShadowOffset(R.mult, -R.mult)
        co:ClearAllPoints()
        co:SetPoint("BOTTOMRIGHT", bu, 0, 0)        
      else
        co:Hide()
      end
	  
	  if nt then
		nt:ClearAllPoints()
		nt:SetPoint("TOPLEFT")
		nt:SetPoint("BOTTOMRIGHT")
	  end
    
      --applying the textures

	  bu:CreateShadow("Background")
	  

      --cut the default border of the icons and make them shiny
      ic:SetTexCoord(0.1,0.9,0.1,0.9)
      ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
      ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
  
      --adjust the cooldown frame
      cd:SetPoint("TOPLEFT", bu, "TOPLEFT", 0, -0)
      cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -0, 0)
    
      self.rABS_Styled = true
  end
  
  --style pet buttons
  local function rActionButtonStyler_AB_stylepet()
    
    for i=1, NUM_PET_ACTION_SLOTS do
      local name = "PetActionButton"..i
      local bu  = _G[name]
      local ic  = _G[name.."Icon"]
      local fl  = _G[name.."Flash"]
      local nt  = _G[name.."NormalTexture2"]
	  local shine = _G[name.."Shine"]
	  local autocast = _G[name.."AutoCastable"]
      if fl then
		fl:SetTexture("")
	  end

	  if nt then
		nt:SetTexture(nil)
      end
      nt:SetAllPoints(bu)
      
      bu:CreateShadow("Background")
      --cut the default border of the icons and make them shiny
      ic:SetTexCoord(0.1,0.9,0.1,0.9)
      ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
      ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	  
	  shine:SetSize(bu:GetHeight()-5, bu:GetWidth()-5)
	  shine:ClearAllPoints()
	  shine:SetPoint("CENTER", bu, 0, 0)
	  
	  autocast:SetAlpha(0)
    end  
  end
  
  --style shapeshift buttons
  local function rActionButtonStyler_AB_styleshapeshift()    
    for i=1, NUM_SHAPESHIFT_SLOTS do
      local name = "ShapeshiftButton"..i
      local bu  = _G[name]
      local ic  = _G[name.."Icon"]
      local fl  = _G[name.."Flash"]
      local nt  = _G[name.."NormalTexture2"]
  
      if fl then
		fl:SetTexture("")
	  end

	  if nt then
		nt:SetTexture(nil)
      end
      nt:SetAllPoints(bu)
      
      bu:CreateShadow("Background")

      --cut the default border of the icons and make them shiny
      ic:SetTexCoord(0.1,0.9,0.1,0.9)
      ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
      ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
      
    end    
  end
  
  local buttons = 0
local function SetupFlyoutButton()
	for i=1, buttons do
		--prevent error if you don't have max ammount of buttons
		if _G["SpellFlyoutButton"..i] and not _G["SpellFlyoutButton"..i].rABS_Styled then
			rActionButtonStyler_AB_style(_G["SpellFlyoutButton"..i], nil, true)
			_G["SpellFlyoutButton"..i]:StyleButton(true)
		end
	end
end
SpellFlyout:HookScript("OnShow", SetupFlyoutButton)

 
--Hide the Mouseover texture and attempt to find the ammount of buttons to be skinned
local function ActionButtonStyler_AB_styleflyout(self)
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
		rActionButtonStyler_AB_style(_G["VehicleMenuBarActionButton"..i])
	end
end
  
  ---------------------------------------
  -- CALLS // HOOKS
  ---------------------------------------
  
  hooksecurefunc("ActionButton_Update",         rActionButtonStyler_AB_style)
  hooksecurefunc("ShapeshiftBar_Update",        rActionButtonStyler_AB_styleshapeshift)
  hooksecurefunc("ShapeshiftBar_UpdateState",   rActionButtonStyler_AB_styleshapeshift)
  hooksecurefunc("PetActionBar_Update",         rActionButtonStyler_AB_stylepet)
  hooksecurefunc("ActionButton_UpdateFlyout", ActionButtonStyler_AB_styleflyout)
  hooksecurefunc("ActionButton_UpdateHotkeys", UpdateHotkey)
  
---------------------------------------------------------------
-- Totem Style, they need a lot more work than "normal" buttons
-- Because of this, we skin it via separate styling codes
-- Special thank's to DarthAndroid
---------------------------------------------------------------

-- don't continue executing code in this file is not playing a shaman.
if not UnitClass("player") == "SHAMAN" then return end

-- Tex Coords for empty buttons
SLOT_EMPTY_TCOORDS = {
	[EARTH_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 3 / 256,
		bottom	= 33 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 67 / 128,
		right	= 97 / 128,
		top		= 100 / 256,
		bottom	= 130 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 39 / 128,
		right	= 69 / 128,
		top		= 209 / 256,
		bottom	= 239 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 36 / 256,
		bottom	= 66 / 256,
	},
}

local function StyleTotemFlyout(flyout)
	-- remove blizzard flyout texture
	flyout.top:SetTexture(nil)
	flyout.middle:SetTexture(nil)
	flyout:SetFrameStrata('MEDIUM')
	
	-- Skin buttons
	local last = nil
	
	for _,button in ipairs(flyout.buttons) do
		button:CreateShadow()
		local icon = select(1,button:GetRegions())
		icon:SetTexCoord(.09,.91,.09,.91)
		icon:SetDrawLayer("ARTWORK")
		icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
		icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)		
		if not InCombatLockdown() then
			button:Size(C["actionbar"].buttonsize)
			button:ClearAllPoints()
			button:Point("BOTTOM",last,"TOP",0,4)
		end
		if button:IsVisible() then last = button end
		button:SetBackdropBorderColor(flyout.parent:GetBackdropBorderColor())
		button:StyleButton()
		
		-- if C["actionbar"].shapeshiftmouseover == true then
			-- button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
			-- button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
		-- end			
	end
	
	flyout.buttons[1]:SetPoint("BOTTOM",flyout,"BOTTOM")
	
	if flyout.type == "slot" then
		local tcoords = SLOT_EMPTY_TCOORDS[flyout.parent:GetID()]
		flyout.buttons[1].icon:SetTexCoord(tcoords.left,tcoords.right,tcoords.top,tcoords.bottom)
	end
	
	-- Skin Close button
	local close = MultiCastFlyoutFrameCloseButton
	close:CreateShadow("Background")	
	close:GetHighlightTexture():SetTexture([[Interface\Buttons\ButtonHilight-Square]])
	close:GetHighlightTexture():Point("TOPLEFT",close,"TOPLEFT",1,-1)
	close:GetHighlightTexture():Point("BOTTOMRIGHT",close,"BOTTOMRIGHT",-1,1)
	close:GetNormalTexture():SetTexture(nil)
	close:ClearAllPoints()
	close:Point("BOTTOMLEFT",last,"TOPLEFT",0,4)
	close:Point("BOTTOMRIGHT",last,"TOPRIGHT",0,4)	
	close:SetBackdropBorderColor(last:GetBackdropBorderColor())
	close:Height(8)
	
	flyout:ClearAllPoints()
	flyout:Point("BOTTOM",flyout.parent,"TOP",0,4)
	
	-- if C["actionbar"].shapeshiftmouseover == true then
		-- flyout:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		-- flyout:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
		-- close:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		-- close:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	-- end
end
hooksecurefunc("MultiCastFlyoutFrame_ToggleFlyout",function(self) StyleTotemFlyout(self) end)
	
local function StyleTotemOpenButton(button, parent)
	button:GetHighlightTexture():SetAlpha(0)
	button:GetNormalTexture():SetAlpha(0)

	button:Height(20)
	button:ClearAllPoints()
	button:Point("BOTTOMLEFT", parent, "TOPLEFT", 0, -3)
	button:Point("BOTTOMRIGHT", parent, "TOPRIGHT", 0, -3)
	if not button.visibleBut then
		button.visibleBut = CreateFrame("Frame",nil,button)
		button.visibleBut:Height(8)
		button.visibleBut:Width(C["actionbar"].buttonsize)
		button.visibleBut:SetPoint("CENTER")
		button.visibleBut.highlight = button.visibleBut:CreateTexture(nil,"HIGHLIGHT")
		button.visibleBut.highlight:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
		button.visibleBut.highlight:Point("TOPLEFT",button.visibleBut,"TOPLEFT",1,-1)
		button.visibleBut.highlight:Point("BOTTOMRIGHT",button.visibleBut,"BOTTOMRIGHT",-1,1)
		button.visibleBut:CreateShadow("Background")
	end	
	
	-- if C["actionbar"].shapeshiftmouseover == true then
		-- button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		-- button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	-- end	
	button.visibleBut:SetBackdropBorderColor(parent:GetBackdropBorderColor())
end
hooksecurefunc("MultiCastFlyoutFrameOpenButton_Show",function(button,_, parent) StyleTotemOpenButton(button, parent) end)

-- the color we use for border
local bordercolors = {
	{.23,.45,.13},   -- Earth
	{.58,.23,.10},   -- Fire
	{.19,.48,.60},   -- Water
	{.42,.18,.74},   -- Air
}

local function StyleTotemSlotButton(button, index)
	button:CreateShadow()
	button.overlayTex:SetTexture(nil)
	button.background:SetDrawLayer("ARTWORK")
	button.background:ClearAllPoints()
	button.background:Point("TOPLEFT",button,"TOPLEFT",2, -2)
	button.background:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2, 2)
	if not InCombatLockdown() then button:Size(C["actionbar"].buttonsize) end
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 4) + 1]))
	button:StyleButton()
	-- if C["actionbar"].shapeshiftmouseover == true then
		-- button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		-- button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	-- end	
end
hooksecurefunc("MultiCastSlotButton_Update",function(self, slot) StyleTotemSlotButton(self,tonumber( string.match(self:GetName(),"MultiCastSlotButton(%d)"))) end)

-- Skin the actual totem buttons
local function StyleTotemActionButton(button, index)
	local icon = select(1,button:GetRegions())
	icon:SetTexCoord(.09,.91,.09,.91)
	icon:SetDrawLayer("ARTWORK")
	icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
	icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)
	button.overlayTex:SetTexture(nil)
	button.overlayTex:Hide()
	button:GetNormalTexture():SetAlpha(0)
	if button.slotButton and not InCombatLockdown() then
		button:ClearAllPoints()
		button:SetAllPoints(button.slotButton)
		button:SetFrameLevel(button.slotButton:GetFrameLevel()+1)
	end
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 4) + 1]))
	button:SetBackdropColor(0,0,0,0)
	button:StyleButton(true)
	-- if C["actionbar"].shapeshiftmouseover == true then
		-- button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		-- button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	-- end	
end
hooksecurefunc("MultiCastActionButton_Update",function(actionButton, actionId, actionIndex, slot) StyleTotemActionButton(actionButton,actionIndex) end)

local function FixBackdrop(button)
	if button:GetName() and button:GetName():find("MultiCast") and button:GetNormalTexture() then
		button:GetNormalTexture():SetAlpha(0)
	end
end
hooksecurefunc("ActionButton_ShowGrid", FixBackdrop)

-- Skin the summon and recall buttons
local function StyleTotemSpellButton(button, index)
	if not button then return end
	local icon = select(1,button:GetRegions())
	icon:SetTexCoord(.09,.91,.09,.91)
	icon:SetDrawLayer("ARTWORK")
	icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
	icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)
	button:CreateShadow()
	button:GetNormalTexture():SetTexture(nil)
	if not InCombatLockdown() then button:Size(C["actionbar"].buttonsize) end
	_G[button:GetName().."Highlight"]:SetTexture(nil)
	_G[button:GetName().."NormalTexture"]:SetTexture(nil)
	button:StyleButton()
	-- if C["actionbar"].shapeshiftmouseover == true then
		-- button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		-- button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	-- end	
end
hooksecurefunc("MultiCastSummonSpellButton_Update", function(self) StyleTotemSpellButton(self,0) end)
hooksecurefunc("MultiCastRecallSpellButton_Update", function(self) StyleTotemSpellButton(self,5) end)

local RayUIOnLogon = CreateFrame("Frame")
RayUIOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
RayUIOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SetCVar("alwaysShowActionBars", 0)	
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
	else
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
	end
end)