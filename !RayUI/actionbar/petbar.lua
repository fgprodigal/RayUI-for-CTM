local R, C, DB = unpack(select(2, ...))
  
local num = NUM_PET_ACTION_SLOTS

local bar = CreateFrame("Frame","rABS_PetBar",UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(C["actionbar"].buttonsize*num+C["actionbar"].buttonspacing*(num-1))
bar:SetHeight(C["actionbar"].buttonsize)
bar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 190)
bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)

bar:SetScale(C["actionbar"].petbarscale)

R.CreateMover(bar, "PetBarMover", "宠物动作条锚点", true)  

PetActionBarFrame:SetParent(bar)
PetActionBarFrame:EnableMouse(false)
    
    for i=1, num do
      local button = _G["PetActionButton"..i]
      local cd = _G["PetActionButton"..i.."Cooldown"]
      button:SetSize(C["actionbar"].buttonsize, C["actionbar"].buttonsize)
      button:ClearAllPoints()
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