local R, C, L, DB = unpack(select(2, ...))

local bar = CreateFrame("Frame","RayUIActionBar3",UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(C["actionbar"].buttonsize*12+C["actionbar"].buttonspacing*11)
bar:SetHeight(C["actionbar"].buttonsize)

bar:Point("BOTTOM", ActionBar1Mover, "TOP", 0, C["actionbar"].buttonspacing)
bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)

bar:SetScale(C["actionbar"].barscale)

R.CreateMover(bar, "ActionBar3Mover", L["动作条3锚点"], true)

MultiBarBottomRight:SetParent(bar)
  
  for i=1, 12 do
    local button = _G["MultiBarBottomRightButton"..i]
    button:SetSize(C["actionbar"].buttonsize, C["actionbar"].buttonsize)
    button:ClearAllPoints()
    if i == 1 then
      button:SetPoint("BOTTOMLEFT", bar, 0,0)
    else
      local previous = _G["MultiBarBottomRightButton"..i-1]      
        button:SetPoint("LEFT", previous, "RIGHT", C["actionbar"].buttonspacing, 0)
    end
  end
  
  if C["actionbar"].bar3mouseover then  
	C["actionbar"].bar3fade = false
    -- local function lighton(alpha)
      -- if MultiBarBottomRight:IsShown() then
        -- for i=1, 12 do
          -- local pb = _G["MultiBarBottomRightButton"..i]
          -- pb:SetAlpha(alpha)
        -- end
      -- end
    -- end    
    bar:SetAlpha(0)
	bar:SetScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
    bar:SetScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)  
    for i=1, 12 do
      local pb = _G["MultiBarBottomRightButton"..i]
      -- pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
      pb:HookScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)
    end    
  end