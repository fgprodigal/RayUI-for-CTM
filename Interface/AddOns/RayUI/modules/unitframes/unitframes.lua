local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local UF = R:NewModule("UnitFrames", "AceEvent-3.0")
local oUF = RayUF or oUF

UF.modName = L["头像"]

UF.Layouts = {}

function UF:GetOptions()
	local options = {
		colors = {
			order = 5,
			type = "group",
			name = L["颜色"],
			guiInline = true,
			args = {
				healthColorClass = {
					order = 1,
					name = L["生命条按职业着色"],
					type = "toggle",
				},
				powerColorClass = {
					order = 2,
					name = L["法力条按职业着色"],
					type = "toggle",
				},
				smooth = {
					order = 3,
					name = L["平滑变化"],
					type = "toggle",
				},
				smoothColor = {
					order = 4,
					name = L["颜色随血量渐变"],
					type = "toggle",
				},
			},
		},		
		visible = {
			order = 6,
			type = "group",
			name = L["显示"],
			guiInline = true,
			args = {
				showParty = {
					order = 1,
					name = L["显示小队"],
					type = "toggle",
				},
				showBossFrames = {
					order = 2,
					name = L["显示BOSS"],
					type = "toggle",
				},
				showArenaFrames = {
					order = 3,
					name = L["显示竞技场头像"],
					type = "toggle",
				},
			},
		},
		others = {
			order = 7,
			type = "group",
			name = L["其他"],
			guiInline = true,
			args = {
				separateEnergy = {
					order = 1,
					name = L["独立能量条"],
					type = "toggle",
					disabled = function() return R.myclass ~= "ROGUE" end,
				},
				vengeance = {
					order = 2,
					name = L["坦克复仇条"],
					type = "toggle",
					disabled = function() return R.Role ~= "Tank" end,
				},
			},
		},
	}
	return options
end

function UF:Initialize()
	for layout, spawnFunc in pairs(UF.Layouts) do
		if spawnFunc then
			spawnFunc(self)
		end
	end
	wipe(UF.Layouts)
end

function UF:Info()
	return L["|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r头像模块."]
end

R:RegisterModule(UF:GetName())