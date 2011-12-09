local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	local r, g, b = C.Aurora.classcolours[R.myclass].r, C.Aurora.classcolours[R.myclass].g, C.Aurora.classcolours[R.myclass].b
	TimeManagerFrame:StripTextures()
	R.SetBD(TimeManagerFrame, 5, -10, -48, 10)
	R.ReskinClose(TimeManagerCloseButton, "TOPRIGHT", TimeManagerFrame, "TOPRIGHT", -51, -13)
	R.ReskinDropDown(TimeManagerAlarmHourDropDown)
	TimeManagerAlarmHourDropDown:SetWidth(80)
	R.ReskinDropDown(TimeManagerAlarmMinuteDropDown)
	TimeManagerAlarmMinuteDropDown:SetWidth(80)
	R.ReskinDropDown(TimeManagerAlarmAMPMDropDown)
	TimeManagerAlarmAMPMDropDown:SetWidth(90)
	R.ReskinCheck(TimeManagerMilitaryTimeCheck)
	R.ReskinCheck(TimeManagerLocalTimeCheck)
	R.ReskinInput(TimeManagerAlarmMessageEditBox)
	TimeManagerAlarmEnabledButton:SetNormalTexture(nil)
	TimeManagerAlarmEnabledButton.SetNormalTexture = R.dummy
	R.Reskin(TimeManagerAlarmEnabledButton)
	
	TimeManagerStopwatchFrame:StripTextures()
	TimeManagerStopwatchCheck:CreateBorder()
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
	TimeManagerStopwatchCheck:GetNormalTexture():ClearAllPoints()
	TimeManagerStopwatchCheck:GetNormalTexture():Point("TOPLEFT", 2, -2)
	TimeManagerStopwatchCheck:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
	local hover = TimeManagerStopwatchCheck:CreateTexture("frame", nil, TimeManagerStopwatchCheck) -- hover
	hover:SetTexture(1, 1, 1, 0.3)
	hover:Point("TOPLEFT", TimeManagerStopwatchCheck, 2, -2)
	hover:Point("BOTTOMRIGHT", TimeManagerStopwatchCheck, -2, 2)
	TimeManagerStopwatchCheck:SetHighlightTexture(hover)
	
	StopwatchFrame:StripTextures()
	R.SetBD(StopwatchFrame)
	
	StopwatchTabFrame:StripTextures()
	R.ReskinClose(StopwatchCloseButton)
	-- S:HandleNextPrevButton(StopwatchPlayPauseButton)
	-- S:HandleNextPrevButton(StopwatchResetButton)
	-- StopwatchPlayPauseButton:Point("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
	-- StopwatchResetButton:Point("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)
end

R.SkinFuncs["Blizzard_TimeManager"] = LoadSkin