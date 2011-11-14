local R, C, L, DB = unpack(select(2, ...))
  
if R.myclass ~= "SHAMAN" then return end

if MultiCastActionBarFrame then
	MultiCastActionBarFrame:SetScript("OnUpdate", nil)
	MultiCastActionBarFrame:SetScript("OnShow", nil)
	MultiCastActionBarFrame:SetScript("OnHide", nil)
	MultiCastActionBarFrame:SetParent(rABS_StanceBar)
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", rABS_StanceBar, "BOTTOMLEFT", -2, -2)

	hooksecurefunc("MultiCastActionButton_Update",function(actionbutton) if not InCombatLockdown() then actionbutton:SetAllPoints(actionbutton.slotButton) end end)
	
	MultiCastActionBarFrame.SetParent = R.dummy
	MultiCastActionBarFrame.SetPoint = R.dummy
	MultiCastRecallSpellButton.SetPoint = R.dummy -- bug fix, see http://www.tukui.org/v2/forums/topic.php?id=2405
end