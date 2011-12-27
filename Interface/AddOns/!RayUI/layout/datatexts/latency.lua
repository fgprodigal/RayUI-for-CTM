local R, C, L, DB = unpack(select(2, ...))

local LastUpdate = 1

TopInfoBar2.Text:SetText("MS: 0")
TopInfoBar2.Status:SetScript("OnUpdate", function(self, elapsed)
	LastUpdate = LastUpdate - elapsed
	
	if LastUpdate < 0 then
		self:SetMinMaxValues(0, 1000)
		local value = (select(3, GetNetStats()))
		local max = 1000
		self:SetValue(value)
		TopInfoBar2.Text:SetText("MS: "..value)
		local r, g, b = R.ColorGradient(value/1000, R.InfoBarStatusColor[3][1], R.InfoBarStatusColor[3][2], R.InfoBarStatusColor[3][3], 
																		R.InfoBarStatusColor[2][1], R.InfoBarStatusColor[2][2], R.InfoBarStatusColor[2][3],
																		R.InfoBarStatusColor[1][1], R.InfoBarStatusColor[1][2], R.InfoBarStatusColor[1][3])
		self:SetStatusBarColor(r, g, b)
		LastUpdate = 1
	end
end)