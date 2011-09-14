local R, C, DB = unpack(select(2, ...))

function R.Update_ActionBar()
	if R.SavePath["movers"] == nil then R.SavePath["movers"] = {} end
	if  R.TableIsEmpty(R.SavePath["movers"]["ActionBar1Mover"]) and R.TableIsEmpty(R.SavePath["movers"]["ActionBar2Mover"]) and R.TableIsEmpty(R.SavePath["movers"]["ActionBar3Mover"]) then
		if C["ouf"].HealFrames and R.isHealer then
			ActionBar1Mover:ClearAllPoints()
			ActionBar1Mover:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 40)
			ActionBar2Mover:ClearAllPoints()
			ActionBar2Mover:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 70)
			ActionBar3Mover:ClearAllPoints()
			ActionBar3Mover:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 100)
			PetBarMover:ClearAllPoints()
			PetBarMover:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 130)
		else
			ActionBar1Mover:ClearAllPoints()
			ActionBar1Mover:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 240)
			ActionBar2Mover:ClearAllPoints()
			ActionBar2Mover:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 270)
			ActionBar3Mover:ClearAllPoints()
			ActionBar3Mover:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 300)
			PetBarMover:ClearAllPoints()
			PetBarMover:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 210)
		end
	end
end