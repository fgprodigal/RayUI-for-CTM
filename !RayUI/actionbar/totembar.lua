local R, C, L, DB = unpack(select(2, ...))
  
  if R.myclass == "SHAMAN" then

    local bar = _G['MultiCastActionBarFrame']

    if bar then

      local holder = CreateFrame("Frame","rABS_TotemBar",UIParent, "SecureHandlerStateTemplate")
      holder:SetWidth(bar:GetWidth())
      holder:SetHeight(bar:GetHeight())
	            
      bar:SetParent(holder)
      bar:SetAllPoints(holder)
      bar:EnableMouse(false)
      
      bar.SetPoint = function() end
      
      local function moveTotem(self,a1,af,a2,x,y,...)
        if InCombatLockdown() then return end
      end
            
      --hooksecurefunc(bar, "SetPoint", moveTotem)  
      holder:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -134, 180)  
      holder:SetScale(C["actionbar"].barscale)
	  
	  R.CreateMover(holder, "TotemBarMover", L["图腾条锚点"], true)  


    end
  
  end --disable