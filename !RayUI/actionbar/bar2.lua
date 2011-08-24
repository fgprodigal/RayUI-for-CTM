local R, C, DB = unpack(select(2, ...))

  
local bar = CreateFrame("Frame","rABS_MultiBarBottomLeft",UIParent, "SecureHandlerStateTemplate")
bar:SetWidth(C["actionbar"].buttonsize*12+C["actionbar"].buttonspacing*11)
bar:SetHeight(C["actionbar"].buttonsize)

bar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 270)
bar:SetHitRectInsets(-C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset, -C["actionbar"].barinset)

bar:SetScale(C["actionbar"].barscale)

R.CreateMover(bar, "ActionBar2Mover", "动作条2锚点", true)  

MultiBarBottomLeft:SetParent(bar)
  
for i=1, 12 do
	local button = _G["MultiBarBottomLeftButton"..i]
	button:SetSize(C["actionbar"].buttonsize, C["actionbar"].buttonsize)
	button:ClearAllPoints()
	if i == 1 then
		button:SetPoint("BOTTOMLEFT", bar, 0,0)
	else
		local previous = _G["MultiBarBottomLeftButton"..i-1]      
		button:SetPoint("LEFT", previous, "RIGHT", C["actionbar"].buttonspacing, 0)
	end
end
  
  if C["actionbar"].bar2mouseover then
	C["actionbar"].bar2fade = false
    -- local function lighton(alpha)
      -- if MultiBarBottomLeft:IsShown() then
        -- for i=1, 12 do
          -- local pb = _G["MultiBarBottomLeftButton"..i]
          -- pb:SetAlpha(alpha)
        -- end
      -- end
    -- end    
    bar:SetAlpha(0)
	bar:SetScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
    bar:SetScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)  
    for i=1, 12 do
      local pb = _G["MultiBarBottomLeftButton"..i]
      -- pb:SetAlpha(0)
      pb:HookScript("OnEnter", function(self) UIFrameFadeIn(bar,0.5,bar:GetAlpha(),1) end)
      pb:HookScript("OnLeave", function(self) UIFrameFadeOut(bar,0.5,bar:GetAlpha(),0) end)
    end    
  end