local R, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

function R.LoadLayout(layout)
	for name, func in pairs(R.Layouts) do
		if name == layout then
			func() 
			R.LoadLayout = nil --only load 1 layout
			wipe(R.Layouts) --only load 1 layout
			break
		end
	end
end
-- R.LoadLayout(C["general"].layoutoverride)
R.LoadLayout("DPS")