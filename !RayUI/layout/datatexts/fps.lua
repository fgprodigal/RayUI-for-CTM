local R, C, L, DB = unpack(select(2, ...))

local LastUpdate = 1

TopInfoBar1.Text:SetText("FPS: 0")
TopInfoBar1.Status:SetScript("OnUpdate", function(self, elapsed)
	LastUpdate = LastUpdate - elapsed
	
	if LastUpdate < 0 then
		self:SetMinMaxValues(0, 60)
		local value = floor(GetFramerate())
		local max = GetCVar("MaxFPS")
		self:SetValue(value)
		TopInfoBar1.Text:SetText("FPS: "..value)
		local r, g, b = R.ColorGradient(value/60, R.InfoBarStatusColor[1][1], R.InfoBarStatusColor[1][2], R.InfoBarStatusColor[1][3], 
																		R.InfoBarStatusColor[2][1], R.InfoBarStatusColor[2][2], R.InfoBarStatusColor[2][3],
																		R.InfoBarStatusColor[3][1], R.InfoBarStatusColor[3][2], R.InfoBarStatusColor[3][3])
		self:SetStatusBarColor(r, g, b)
		LastUpdate = 1
	end
end)