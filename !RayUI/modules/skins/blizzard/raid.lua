local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.ReskinCheck(RaidFrameAllAssistCheckButton)
	ReadyCheckFrame:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end)
	R.Reskin(RaidFrameReadyCheckButton)
	R.Reskin(ReadyCheckFrameYesButton)
	R.Reskin(ReadyCheckFrameNoButton)
	ReadyCheckPortrait:SetAlpha(0)
	select(2, ReadyCheckListenerFrame:GetRegions()):Hide()
end

R.SkinFuncs["Blizzard_RaidUI"] = LoadSkin