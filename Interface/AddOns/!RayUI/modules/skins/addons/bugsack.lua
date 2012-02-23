local R, C, L, DB = unpack(select(2, ...))

if not IsAddOnLoaded("BugSack") or not BugSack then return end

local skinned = false

hooksecurefunc(BugSack, "OpenSack", function()
	if skinned then return end
	BugSackFrame:StripTextures()
	R.SetBD(BugSackFrame)
	R.Reskin(BugSackPrevButton)
	R.Reskin(BugSackNextButton)
	R.Reskin(BugSackSendButton)
	BugSackTabAll:ClearAllPoints()
	BugSackTabAll:SetPoint("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, 1)
	R.CreateTab(BugSackTabAll)
	R.CreateTab(BugSackTabSession)
	R.CreateTab(BugSackTabLast)
	skinned = true
end)