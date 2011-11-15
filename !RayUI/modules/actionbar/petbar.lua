local R, C, L, DB = unpack(select(2, ...))
  
local num = NUM_PET_ACTION_SLOTS

local bar = CreateFrame("Frame","rABS_PetBar",UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(C["actionbar"].buttonsize*num+C["actionbar"].buttonspacing*(num-1))
bar:SetHeight(C["actionbar"].buttonsize)
bar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 210)
bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)

bar:SetScale(C["actionbar"].petbarscale)

R.CreateMover(bar, "PetBarMover", L["宠物动作条锚点"], true)  

PetBarMover:SetScale(C["actionbar"].petbarscale)

PetActionBarFrame:SetParent(bar)
PetActionBarFrame:EnableMouse(false)

local function PetBarUpdate(self, event)
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton" .. i
		petActionButton = _G[buttonName]
		petActionIcon = _G[buttonName.."Icon"]
		petAutoCastableTexture = _G[buttonName.."AutoCastable"]
		petAutoCastShine = _G[buttonName.."Shine"]
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		
		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end
		
		petActionButton.isToken = isToken
		petActionButton.tooltipSubtext = subtext

		if isActive and name ~= "PET_ACTION_FOLLOW" then
			petActionButton:SetChecked(1)
			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(petActionButton)
			end
		else
			petActionButton:SetChecked(0)
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(petActionButton)
			end			
		end
		
		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end
		
		if autoCastEnabled then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end
		
		-- grid display
		-- if name then
			-- if not C["actionbar"].showgrid then
				-- petActionButton:SetAlpha(1)
			-- end			
		-- else
			-- if not C["actionbar"].showgrid then
				-- petActionButton:SetAlpha(0)
			-- end
		-- end
		
		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(petActionIcon, nil)
			else
				SetDesaturation(petActionIcon, 1)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end
		
		-- between level 1 and 10 on cata, we don't have any control on Pet. (I lol'ed so hard)
		-- Setting desaturation on button to true until you learn the control on class trainer.
		-- you can at least control "follow" button.
		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(petActionButton)
			SetDesaturation(petActionIcon, 1)
			petActionButton:SetChecked(0)
		end
	end
end

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_CONTROL_LOST")
bar:RegisterEvent("PLAYER_CONTROL_GAINED")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
bar:RegisterEvent("PET_BAR_UPDATE")
bar:RegisterEvent("PET_BAR_UPDATE_USABLE")
bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
bar:RegisterEvent("PET_BAR_HIDE")
bar:RegisterEvent("UNIT_PET")
bar:RegisterEvent("UNIT_FLAGS")
bar:RegisterEvent("UNIT_AURA")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then	
		-- bug reported by Affli on t12 BETA
		PetActionBarFrame.showgrid = 1 -- hack to never hide pet button. :X
	
		RegisterStateDriver(self, "visibility", "[pet,novehicleui,nobonusbar:5] show; hide")
		hooksecurefunc("PetActionBar_Update", PetBarUpdate)
	elseif event == "PET_BAR_UPDATE" or event == "UNIT_PET" and arg1 == "player" 
	or event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" or event == "UNIT_FLAGS"
	or arg1 == "pet" and (event == "UNIT_AURA") then
		PetBarUpdate()
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar_UpdateCooldowns()
	end
end)
    
    for i=1, num do
      local button = _G["PetActionButton"..i]
      local cd = _G["PetActionButton"..i.."Cooldown"]
      button:SetSize(C["actionbar"].buttonsize, C["actionbar"].buttonsize)
      button:ClearAllPoints()
	  button:SetParent(rABS_PetBar)
      if i == 1 then
        button:SetPoint("BOTTOMLEFT", bar, 0,0)
      else
        local previous = _G["PetActionButton"..i-1]      
        button:SetPoint("LEFT", previous, "RIGHT", C["actionbar"].buttonspacing, 0)
      end
      cd:SetAllPoints(button)
    end
    
    if C["actionbar"].petbarmouseover then    
	  C["actionbar"].petbarfade = false
      -- local function lighton(alpha)
        -- if PetActionBarFrame:IsShown() then
          -- for i=1, num do
            -- local pb = _G["PetActionButton"..i]
            -- pb:SetAlpha(alpha)
          -- end
        -- end
      -- end    
	  bar:SetAlpha(0)
	  bar:SetScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
      bar:SetScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)  
      for i=1, num do
        local pb = _G["PetActionButton"..i]
        -- pb:SetAlpha(0)
        pb:HookScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
        pb:HookScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)
      end   
	 end