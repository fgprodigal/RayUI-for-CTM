local R, C, L, DB = unpack(select(2, ...))
local AddOnName = ...

local function LoadSkin()
	R.SetBD(WorldStateScoreFrame)
	R.ReskinScroll(WorldStateScoreScrollFrameScrollBar)
	WorldStateScoreFrame:DisableDrawLayer("BACKGROUND")
	WorldStateScoreFrameInset:DisableDrawLayer("BACKGROUND")
	WorldStateScoreFrame:DisableDrawLayer("BORDER")
	WorldStateScoreFrameInset:DisableDrawLayer("BORDER")
	WorldStateScoreFrameTopLeftCorner:Hide()
	WorldStateScoreFrameTopBorder:Hide()
	WorldStateScoreFrameTopRightCorner:Hide()
	select(2, WorldStateScoreScrollFrame:GetRegions()):Hide()
	select(3, WorldStateScoreScrollFrame:GetRegions()):Hide()
	WorldStateScoreFrameTab2:SetPoint("LEFT", WorldStateScoreFrameTab1, "RIGHT", -15, 0)
	WorldStateScoreFrameTab3:SetPoint("LEFT", WorldStateScoreFrameTab2, "RIGHT", -15, 0)
	for i = 1, 3 do
		R.CreateTab(_G["WorldStateScoreFrameTab"..i])
	end
	R.Reskin(WorldStateScoreFrameLeaveButton)
	R.ReskinClose(WorldStateScoreFrameCloseButton)
end

tinsert(R.SkinFuncs[AddOnName], LoadSkin)