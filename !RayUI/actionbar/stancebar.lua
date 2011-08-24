local R, C, DB = unpack(select(2, ...))
    
  
local num = NUM_SHAPESHIFT_SLOTS

local bar = CreateFrame("Frame","rABS_StanceBar",UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(C["actionbar"].buttonsize*num+C["actionbar"].buttonspacing*(num-1))
bar:SetHeight(C["actionbar"].buttonsize)
bar:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 10, -50)
bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)

bar:SetScale(C["actionbar"].barscale)

R.CreateMover(bar, "StanceBarMover", "姿态条锚点", true)  

ShapeshiftBarFrame:SetParent(bar)
ShapeshiftBarFrame:EnableMouse(false)
    
    for i=1, num do
      local button = _G["ShapeshiftButton"..i]
      button:SetSize(C["actionbar"].buttonsize, C["actionbar"].buttonsize)
      button:ClearAllPoints()
      if i == 1 then
        button:SetPoint("BOTTOMLEFT", bar, 0,0)
      else
        local previous = _G["ShapeshiftButton"..i-1]      
        button:SetPoint("LEFT", previous, "RIGHT", C["actionbar"].buttonspacing, 0)
      end
    end
    
    local function rABS_MoveShapeshift()
      ShapeshiftButton1:SetPoint("BOTTOMLEFT", bar, 0,0)
    end
    hooksecurefunc("ShapeshiftBar_Update", rABS_MoveShapeshift);
    
    
    if C["actionbar"].stancebarmouseover then    
	  C["actionbar"].stancebarfade = false
      -- local function lighton(alpha)
        -- if ShapeshiftBarFrame:IsShown() then
          -- for i=1, num do
            -- local pb = _G["ShapeshiftButton"..i]
            -- pb:SetAlpha(alpha)
          -- end
        -- end
      -- end    
  	  bar:SetAlpha(0)
  	  bar:SetScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
      bar:SetScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)  
      for i=1, num do
        local pb = _G["ShapeshiftButton"..i]
        -- pb:SetAlpha(0)
        pb:HookScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
        pb:HookScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)
      end    
    end