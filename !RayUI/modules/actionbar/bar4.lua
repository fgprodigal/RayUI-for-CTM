local R, C, L, DB = unpack(select(2, ...))

  
local bar = CreateFrame("Frame","rABS_MultiBarRight",UIParent, "SecureHandlerStateTemplate")
bar:SetHeight(C["actionbar"].buttonsize*12+C["actionbar"].buttonspacing*11)
bar:SetWidth(C["actionbar"].buttonsize)
bar:SetPoint("RIGHT", "UIParent", "RIGHT", -10, 0)
bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)
  
bar:SetScale(C["actionbar"].barscale)

R.CreateMover(bar, "ActionBar4Mover", L["动作条4锚点"], true)  

  MultiBarRight:SetParent(bar)
  
  for i=1, 12 do
    local button = _G["MultiBarRightButton"..i]
    button:ClearAllPoints()
    button:SetSize(C["actionbar"].buttonsize, C["actionbar"].buttonsize)
    if i == 1 then
      button:SetPoint("TOPLEFT", bar, 0,0)
    else
      local previous = _G["MultiBarRightButton"..i-1]
      button:SetPoint("TOP", previous, "BOTTOM", 0, -C["actionbar"].buttonspacing)
    end
  end
  
  if C["actionbar"].bar4mouseover then    
	C["actionbar"].bar4fade = false
    -- local function lighton(alpha)
      -- if MultiBarRight:IsShown() then
        -- for i=1, 12 do
          -- local pb = _G["MultiBarRightButton"..i]
          -- pb:SetAlpha(alpha)
        -- end
      -- end
    -- end    
    bar:SetAlpha(0)
	bar:SetScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
    bar:SetScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)  
    for i=1, 12 do
      local pb = _G["MultiBarRightButton"..i]
      -- pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
      pb:HookScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)
    end    
  end