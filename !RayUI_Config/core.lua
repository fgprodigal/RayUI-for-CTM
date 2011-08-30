local RayUIConfig = LibStub("AceAddon-3.0"):NewAddon("RayUIConfig", "AceConsole-3.0", "AceEvent-3.0")
local R, C, DB
local LSM = LibStub("LibSharedMedia-3.0")
local db = {}
local defaults
local DEFAULT_WIDTH = 700
local DEFAULT_HEIGHT = 500
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")

function RayUIConfig:LoadDefaults()
	R, C, DB = unpack(RayUI)
	--Defaults
	defaults = {
		profile = {
			general = DB["general"],
			media = DB["media"],
			ouf = DB["ouf"],
			actionbar = DB["actionbar"],
		},
	}
end	

function RayUIConfig:OnInitialize()	
	RayUIConfig:RegisterChatCommand("rc", "ShowConfig")
	
	self.OnInitialize = nil
end

function RayUIConfig:ShowConfig() 
	ACD[ACD.OpenFrames.RayUIConfig and "Close" or "Open"](ACD,"RayUIConfig") 
end

function RayUIConfig:Load()
	self:LoadDefaults()

	-- Create savedvariables
	self.db = LibStub("AceDB-3.0"):New("RayConfig", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	db = self.db.profile
	
	self:SetupOptions()
end

function RayUIConfig:OnProfileChanged(event, database, newProfileKey)
	StaticPopup_Show("CFG_RELOAD")
end


function RayUIConfig:SetupOptions()
	AC:RegisterOptionsTable("RayUIConfig", self.GenerateOptions)
	ACD:SetDefaultSize("RayUIConfig", DEFAULT_WIDTH, DEFAULT_HEIGHT)

	--Create Profiles Table
	self.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db);
	AC:RegisterOptionsTable("RayProfiles", self.profile)
	self.profile.order = -10
	
	self.SetupOptions = nil
end

function RayUIConfig.GenerateOptions()
	if RayUIConfig.noconfig then assert(false, RayUIConfig.noconfig) end
	if not RayUIConfig.Options then
		RayUIConfig.GenerateOptionsInternal()
		RayUIConfig.GenerateOptionsInternal = nil
	end
	return RayUIConfig.Options
end

function RayUIConfig.GenerateOptionsInternal()
	local R, C, DB = unpack(RayUI)

	StaticPopupDialogs["CFG_RELOAD"] = {
		text = "改变参数需重载应用设置",
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept = function() ReloadUI() end,
		timeout = 0,
		whileDead = 1,
	}
	
	RayUIConfig.Options = {
		type = "group",
		name = "RayUI",
		args = {
			RayUI_Header = {
				order = 1,
				type = "header",
				name = "版本"..R.version,
				width = "full",		
			},
			ToggleAnchors = {
				order = 2,
				type = "execute",
				name = "解锁锚点",
				desc = "解锁并移动头像和动作条",
				func = function() R.ToggleMovers() end,
			},
			general = {
				order = 4,
				type = "group",
				name = "一般",
				get = function(info) return db.general[ info[#info] ] end,
				set = function(info, value) db.general[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					uiscale = {
						order = 1,
						name = "UI缩放",
						desc = "UI界面缩放",
						type = "range",
						min = 0.64, max = 1, step = 0.01,
						isPercent = true,
					},
				},
			},
			ouf = {
				order = 5,
				type = "group",
				name = "头像",
				get = function(info) return db.ouf[ info[#info] ] end,
				set = function(info, value) db.ouf[ info[#info] ] = value; C.ouf[ info[#info] ] = value; R.Update_All(); end,
				args = {
					scale = {
						order = 1,
						name = "头像缩放",
						desc = "头像整体缩放",
						type = "range",
						min = 0.5, max = 1.5, step = 0.01,
						isPercent = true,
					},
					spacer = {
						type = 'description',
						name = '',
						desc = '',
						order = 2,
					},	
					PlayerBuffFilter = {
						order = 3,
						name = "玩家头像BUFF过滤",
						desc = "玩家头像上的BUFF将只显示白名单中存在的",
						type = "toggle",
					},
					DebuffOnyshowPlayer = {
						order = 4,
						name = "目标DEBUFF过滤",
						desc = "目标头像上的DEBUFF将只显示玩家、宠物、载具释放的，敌方BUFF将只显示可偷取的，右方BUFF显示全部",
						type = "toggle",
					},
					HealthcolorClass = {
						order = 5,
						name = "生命条按职业着色",
						type = "toggle",
					},
					Powercolor = {
						order = 6,
						name = "法力条按职业着色",
						type = "toggle",
					},
					showPortrait = {
						order = 7,
						name = "显示3D头像",
						type = "toggle",
					},
				},
			},
			actionbar = {
				order = 6,
				type = "group",
				name = "动作条",
				get = function(info) return db.actionbar[ info[#info] ] end,
				set = function(info, value) db.actionbar[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					barscale = {
						order = 1,
						name = "动作条缩放",
						type = "range",
						min = 0.5, max = 1.5, step = 0.01,
						isPercent = true,
					},
					petbarscale = {
						order = 2,
						name = "宠物动作条缩放",
						type = "range",
						min = 0.5, max = 1.5, step = 0.01,
						isPercent = true,
					},
					buttonsize = {
						order = 3,
						name = "按键大小",
						type = "range",
						min = 20, max = 35, step = 1,
					},
					buttonspacing = {
						order = 4,
						name = "按键间距",
						type = "range",
						min = 1, max = 10, step = 1,
					},
					macroname = {
						order = 5,
						name = "显示宏名称",
						type = "toggle",
					},
					itemcount = {
						order = 6,
						name = "显示物品数量",
						type = "toggle",
					},
					hotkeys = {
						order = 7,
						name = "显示快捷键",
						type = "toggle",
					},
					spacer = {
						type = 'description',
						name = '',
						desc = '',
						order = 8,
					},
					Bar1Group = {
						order = 11,
						type = "group",
						name = "动作条1",
						guiInline = true,
						args = {
							bar1fade = {
								type = "toggle",
								name = "自动隐藏",
								order = 1,								
							},
							spacer = {
								type = 'description',
								name = '',
								desc = '',
								order = 2,
							},	
						},
					},
					Bar2Group = {
						order = 12,
						type = "group",
						guiInline = true,
						name = "动作条2",
						args = {
							bar2fade = {
								type = "toggle",
								name = "自动隐藏",
								order = 1,								
							},
							bar2mouseover = {
								type = "toggle",
								name = "鼠标滑过显示",
								order = 2,								
							},
						},
					},
					Bar3Group = {
						order = 13,
						type = "group",
						guiInline = true,
						name = "动作条3",
						args = {
							bar3fade = {
								type = "toggle",
								name = "自动隐藏",
								order = 1,								
							},
							bar3mouseover = {
								type = "toggle",
								name = "鼠标滑过显示",
								order = 2,								
							},
						},
					},
					Bar4Group = {
						order = 14,
						type = "group",
						guiInline = true,
						name = "动作条4",
						args = {
							bar4fade = {
								type = "toggle",
								name = "自动隐藏",
								order = 1,								
							},
							bar4mouseover = {
								type = "toggle",
								name = "鼠标滑过显示",
								order = 2,								
							},
						},
					},
					Bar5Group = {
						order = 15,
						type = "group",
						guiInline = true,
						name = "动作条5",
						args = {
							bar5fade = {
								type = "toggle",
								name = "自动隐藏",
								order = 1,								
							},
							bar5mouseover = {
								type = "toggle",
								name = "鼠标滑过显示",
								order = 2,								
							},
						},
					},
					PetGroup = {
						order = 16,
						type = "group",
						guiInline = true,
						name = "宠物条",
						args = {
							petbarfade = {
								type = "toggle",
								name = "自动隐藏",
								order = 1,								
							},
							petbarmouseover = {
								type = "toggle",
								name = "鼠标滑过显示",
								order = 2,								
							},
						},
					},
					StanceGroup = {
						order = 17,
						type = "group",
						guiInline = true,
						name = "姿态",
						args = {
							stancebarfade = {
								type = "toggle",
								name = "自动隐藏",
								order = 1,								
							},
							stancebarmouseover = {
								type = "toggle",
								name = "鼠标滑过显示",
								order = 2,								
							},
						},
					},
				},
			},
		},
	}
	
	RayUIConfig.Options.args.profiles = RayUIConfig.profile
end


