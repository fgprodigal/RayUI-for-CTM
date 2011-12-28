local RayUIConfig = LibStub("AceAddon-3.0"):NewAddon("RayUIConfig", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RayUIConfig", false)
local LSM = LibStub("LibSharedMedia-3.0")
local R, C, DB
local db = {}
local defaults
local DEFAULT_WIDTH = 700
local DEFAULT_HEIGHT = 500
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

function RayUIConfig:LoadDefaults()
	R, C, _, DB = unpack(RayUI)
	--Defaults
	defaults = {
		profile = {
			general = DB["general"],
			media = DB["media"],
			worldmap = DB["worldmap"],
			minimap = DB["minimap"],
			nameplates = DB["nameplates"],
			bag = DB["bag"],
			chat = DB["chat"],
			tooltip = DB["tooltip"],
			buff = DB["buff"],
			cooldownflash = DB["cooldownflash"],
			uf = DB["uf"],
			raid = DB["raid"],
			actionbar = DB["actionbar"],
			misc = DB["misc"],
			skins = DB["skins"],
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
	local R, C, _, DB = unpack(RayUI)

	StaticPopupDialogs["CFG_RELOAD"] = {
		text = L["改变参数需重载应用设置"],
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
				name = L["版本"]..R.version,
				width = "full",		
			},
			ToggleAnchors = {
				order = 2,
				type = "execute",
				name = L["解锁锚点"],
				desc = L["解锁并移动头像和动作条"],
				func = function()
					ACD["Close"](ACD,"RayUIConfig")
					R.ToggleMovers()
					GameTooltip_Hide()
				end,
			},
			general = {
				order = 4,
				type = "group",
				name = L["一般"],
				get = function(info) return db.general[ info[#info] ] end,
				set = function(info, value) db.general[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					uiscale = {
						order = 1,
						name = L["UI缩放"],
						desc = L["UI界面缩放"],
						type = "range",
						min = 0.64, max = 1, step = 0.01,
						isPercent = true,
					},
					logo = {
						order = 2,
						type = "toggle",
						name = L["登陆Logo"],
						desc = L["开关登陆时的Logo"],
					},
				},
			},
			media = {
				order = 5,
				type = "group",
				name = L["字体材质"],
				get = function(info) return db.media[ info[#info] ] end,
				set = function(info, value) db.media[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					fontGroup = {
						order = 1,
						type = "group",
						name = L["字体"],
						guiInline = true,
						args = {
							font = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 1,
								name = L["一般字体"],
								values = AceGUIWidgetLSMlists.font,	
							},
							fontsize = {
								type = "range",
								order = 2,
								name = L["字体大小"],
								type = "range",
								min = 9, max = 15, step = 1,
							},
							dmgfont = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 3,
								name = L["伤害字体"],
								values = AceGUIWidgetLSMlists.font,	
							},
							pxfont = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 4,
								name = L["像素字体"],
								values = AceGUIWidgetLSMlists.font,	
							},
							cdfont = {
								type = "select", dialogControl = 'LSM30_Font',
								order = 5,
								name = L["冷却字体"],
								values = AceGUIWidgetLSMlists.font,	
							},
						},
					},
					textureGroup = {
						order = 2,
						type = "group",
						name = L["材质"],
						guiInline = true,
						args = {
							normal = {
								type = "select", dialogControl = 'LSM30_Statusbar',
								order = 1,
								name = L["一般材质"],
								values = AceGUIWidgetLSMlists.statusbar,								
							},
							blank = {
								type = "select", dialogControl = 'LSM30_Statusbar',
								order = 2,
								name = L["空白材质"],
								values = AceGUIWidgetLSMlists.statusbar,								
							},		
							glow = {
								type = "select", dialogControl = 'LSM30_Border',
								order = 3,
								name = L["阴影边框"],
								values = AceGUIWidgetLSMlists.border,								
							},
						},
					},
					soundGroup = {
						order = 3,
						type = "group",
						name = L["声音"],
						guiInline = true,
						args = {
							warning = {
								type = "select", dialogControl = 'LSM30_Sound',
								order = 1,
								name = L["报警声音"],
								values = AceGUIWidgetLSMlists.sound,							
							},
						},						
					},
				},
			},
			modules = {
				order = 6,
				type = "group",
				name = L["模块"],				
				args = {
					worldmapGroup = {
						order = 1,
						type = "group",
						name = L["世界地图"],
						guiInline = true,
						get = function(info) return db.worldmap[ info[#info] ] end,
						set = function(info, value) db.worldmap[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
						args = {
							enable = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
							lock = {
								order = 2,
								name = L["地图锁定"],
								type = "toggle",
								disabled = function() return not db.worldmap.enable end,
							},
							scale = {
								order = 3,
								name = L["地图大小"],
								type = "range",
								min = 0.5, max = 1, step = 0.01,
								isPercent = true,
								disabled = function() return not db.worldmap.enable end,
							},
							ejbuttonscale = {
								order = 4,
								name = L["Boss头像大小"],
								type = "range",
								min = 0.6, max = 1, step = 0.01,
								isPercent = true,
								disabled = function() return not db.worldmap.enable end,
							},
							partymembersize = {
								order = 5,
								name = L["队友标示大小"],
								type = "range",
								min = 20, max = 30, step = 1,
								disabled = function() return not db.worldmap.enable end,
							},
						},
					},
					minimapGroup = {
						order = 2,
						type = "group",
						name = L["小地图"],
						guiInline = true,
						get = function(info) return db.minimap[ info[#info] ] end,
						set = function(info, value) db.minimap[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
						args = {
							enable = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
						},
					},
					nameplatesGroup = {
						order = 3,
						type = "group",
						name = L["姓名板"],
						guiInline = true,
						get = function(info) return db.nameplates[ info[#info] ] end,
						set = function(info, value) db.nameplates[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
						args = {
							enable = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
							showdebuff = {
								order = 2,
								name = L["显示debuff"],
								type = "toggle",
							},
							combat = {
								order = 3,
								name = L["自动显示/隐藏"],
								type = "toggle",
							},
						},
					},
					bagGroup = {
						order = 3,
						type = "group",
						name = L["背包"],
						guiInline = true,
						get = function(info) return db.bag[ info[#info] ] end,
						set = function(info, value) db.bag[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
						args = {
							enable = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
						},
					},
					chatGroup = {
						order = 4,
						type = "group",
						name = L["聊天栏"],
						guiInline = true,
						get = function(info) return db.chat[ info[#info] ] end,
						set = function(info, value) db.chat[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
						args = {
							enable = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
							spacer = {
								order = 2,
								name = " ",
								desc = " ",
								type = "description",
							},
							width = {
								order = 3,
								name = L["长度"],
								type = "range",
								min = 300, max = 600, step = 1,
								disabled = function() return not db.chat.enable end,
							},
							height = {
								order = 4,
								name = L["高度"],
								type = "range",
								min = 100, max = 300, step = 1,
								disabled = function() return not db.chat.enable end,
							},
							autohide = {
								order = 5,
								name = L["自动隐藏聊天栏"],
								desc = L["短时间内没有消息则自动隐藏聊天栏"],
								type = "toggle",
								disabled = function() return not db.chat.enable end,
							},
							autohidetime = {
								order = 6,
								name = L["自动隐藏时间"],
								desc = L["设置多少秒没有新消息时隐藏"],
								type = "range",
								min = 5, max = 60, step = 1,
								disabled = function() return not db.chat.autohide or not db.chat.enable end,
							},
							autoshow = {
								order = 6,
								name = L["自动显示聊天栏"],
								desc = L["频道内有信消息则自动显示聊天栏，关闭后如有新密语会闪烁提示"],
								type = "toggle",
								disabled = function() return not db.chat.enable end,
							},
						},
					},
					tooltipGroup = {
						order = 5,
						type = "group",
						name = L["鼠标提示"],
						guiInline = true,
						get = function(info) return db.tooltip[ info[#info] ] end,
						set = function(info, value) db.tooltip[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
						args = {
							enable = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
							cursor = {
								order = 2,
								name = L["跟随鼠标"],
								type = "toggle",
								disabled = function() return not db.tooltip.enable end,
							},
						},
					},
					buffGroup = {
						order = 6,
						type = "group",
						name = L["BUFF"],
						guiInline = true,
						get = function(info) return db.buff[ info[#info] ] end,
						set = function(info, value) db.buff[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
						args = {
							enable = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
						},
					},
					cooldownflashGroup = {
						order = 7,
						type = "group",
						name = L["冷却提示"],
						guiInline = true,
						get = function(info) return db.cooldownflash[ info[#info] ] end,
						set = function(info, value) db.cooldownflash[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
						args = {
							enable = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
						},
					},
				},
			},
			uf = {
				order = 7,
				type = "group",
				name = L["头像"],
				get = function(info) return db.uf[ info[#info] ] end,
				set = function(info, value) db.uf[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD"); end,
				args = {
					colors = {
						order = 1,
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
						order = 2,
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
						order = 3,
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
				},
			},
			raid = {
				order = 8,
				type = "group",
				name = L["团队"],
				get = function(info) return db.raid[ info[#info] ] end,
				set = function(info, value) db.raid[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD"); end,
				args = {
					enable = {
						order = 1,
						name = L["启用"],
						type = "toggle",
					},
					size = {
						order = 2,
						type = "group",
						name = L["大小"],
						guiInline = true,
						args = {
							width = {
								order = 1,
								name = L["单位长度"],
								min = 50, max = 150, step = 1,
								type = "range",
								hidden = function() return not db.raid.enable end,
							},
							height = {
								order = 2,
								name = L["单位高度"],
								min = 20, max = 50, step = 1,
								type = "range",
								hidden = function() return not db.raid.enable end,
							},
							spacing = {
								order = 3,
								name = L["间距"],
								min = 1, max = 20, step = 1,
								type = "range",
								hidden = function() return not db.raid.enable end,
							},
							numCol = {
								order = 4,
								name = L["小队数"],
								min = 1, max = 8, step = 1,
								type = "range",
								hidden = function() return not db.raid.enable end,
							},
							powerbarsize = {
								order = 5,
								name = L["法力条高度"],
								type = "range",
								min = 0, max = 0.5, step = 0.01,
								hidden = function() return not db.raid.enable end,
							},
							outsideRange = {
								order = 6,
								name = L["超出距离透明度"],
								type = "range",
								min = 0, max = 1, step = 0.05,
								hidden = function() return not db.raid.enable end,
							},
							aurasize = {
								order = 7,
								name = L["技能图标大小"],
								type = "range",
								min = 10, max = 30, step = 1,
								hidden = function() return not db.raid.enable end,
							},
							indicatorsize = {
								order = 8,
								name = L["角标大小"],
								type = "range",
								min = 2, max = 10, step = 1,
								hidden = function() return not db.raid.enable end,
							},
							leadersize = {
								order = 9,
								name = L["职责图标大小"],
								type = "range",
								min = 8, max = 20, step = 1,
								hidden = function() return not db.raid.enable end,
							},
							symbolsize = {
								order = 10,
								name = L["特殊标志大小"],
								desc = L["特殊标志大小, 如愈合祷言标志"],
								type = "range",
								min = 8, max = 20, step = 1,
								hidden = function() return not db.raid.enable end,
							},
						},
					},
					visible = {
						order = 3,
						type = "group",
						name = L["显示"],
						guiInline = true,
						args = {
							showwhensolo = {
								order = 1,
								name = L["solo时显示"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							showplayerinparty = {
								order = 2,
								name = L["在队伍中显示自己"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							showgridwhenparty = {
								order = 3,
								name = L["小队也显示团队框体"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
						},
					},
					direction = {
						order = 4,
						type = "group",
						name = L["排列"],
						guiInline = true,
						args = {
							horizontal = {
								order = 1,
								name = L["水平排列"],
								desc = L["小队成员水平排列"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							growth = {
								order = 2,
								name = L["小队增长方向"],
								type = "select",
								values = {
									["UP"] = L["上"],
									["DOWN"] = L["下"],
									["LEFT"] = L["左"],
									["RIGHT"] = L["右"],
								},
								hidden = function() return not db.raid.enable end,
							},
						},
					},
					arrows = {
						order = 5,
						type = "group",
						name = L["箭头"],
						guiInline = true,
						args = {
							arrow = {
								order = 1,
								name = L["箭头方向指示"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							arrowmouseover = {
								order = 2,
								name = L["鼠标悬停时显示"],
								desc = L["只在鼠标悬停时显示方向指示"],
								type = "toggle",
								hidden = function() return not (db.raid.enable and db.raid.arrow) end,
							},
						},
					},
					predict = {
						order = 6,
						type = "group",
						name = L["预读"],
						guiInline = true,
						args = {
							healbar = {
								order = 1,
								name = L["治疗预读"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							healoverflow = {
								order = 2,
								name = L["显示过量预读"],
								type = "toggle",
								hidden = function() return not (db.raid.enable and db.raid.healbar) end,
							},
							healothersonly = {
								order = 3,
								name = L["只显示他人预读"],
								type = "toggle",
								hidden = function() return not (db.raid.enable and db.raid.healbar) end,
							},
						},
					},
					icons = {
						order = 7,
						type = "group",
						name = L["图标文字"],
						guiInline = true,
						args = {
							roleicon = {
								order = 1,
								name = L["职责图标"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							afk = {
								order = 2,
								name = L["AFK文字"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							
							deficit = {
								order = 3,
								name = L["缺失生命文字"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							actual = {
								order = 4,
								name = L["当前生命文字"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							perc = {
								order = 5,
								name = L["生命值百分比"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
						},
					},
					others = {
						order = 8,
						type = "group",
						name = L["其他"],
						guiInline = true,
						args = {
							dispel = {
								order = 1,
								name = L["可驱散提示"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							highlight = {
								order = 2,
								name = L["鼠标悬停高亮"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							tooltip = {
								order = 3,
								name = L["鼠标提示"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
							hidemenu = {
								order = 4,
								name = L["屏蔽右键菜单"],
								type = "toggle",
								hidden = function() return not db.raid.enable end,
							},
						},
					},
				},
			},
			actionbar = {
				order = 9,
				type = "group",
				name = L["动作条"],
				get = function(info) return db.actionbar[ info[#info] ] end,
				set = function(info, value) db.actionbar[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					barscale = {
						order = 1,
						name = L["动作条缩放"],
						type = "range",
						min = 0.5, max = 1.5, step = 0.01,
						isPercent = true,
					},
					petbarscale = {
						order = 2,
						name = L["宠物动作条缩放"],
						type = "range",
						min = 0.5, max = 1.5, step = 0.01,
						isPercent = true,
					},
					buttonsize = {
						order = 3,
						name = L["按键大小"],
						type = "range",
						min = 20, max = 35, step = 1,
					},
					buttonspacing = {
						order = 4,
						name = L["按键间距"],
						type = "range",
						min = 1, max = 10, step = 1,
					},
					macroname = {
						order = 5,
						name = L["显示宏名称"],
						type = "toggle",
					},
					itemcount = {
						order = 6,
						name = L["显示物品数量"],
						type = "toggle",
					},
					hotkeys = {
						order = 7,
						name = L["显示快捷键"],
						type = "toggle",
					},
					showgrid = {
						order = 8,
						name = L["显示空按键"],
						type = "toggle",
					},
					CooldownAlphaGroup = {
						order = 11,
						type = "group",
						name = L["根据CD淡出"],
						guiInline = true,
						args = {
							cooldownalpha = {
								type = "toggle",
								name = L["启用"],
								order = 1,
							},
							spacer = {
								type = 'description',
								name = '',
								desc = '',
								order = 2,
							},
							cdalpha = {
								order = 3,
								name = L["CD时透明度"],
								type = "range",
								min = 0, max = 1, step = 0.05,
								disabled = function() return not db.actionbar.cooldownalpha end,
							},
							readyalpha = {
								order = 4,
								name = L["就绪时透明度"],
								type = "range",
								min = 0, max = 1, step = 0.05,
								disabled = function() return not db.actionbar.cooldownalpha end,
							},
							stancealpha = {
								type = "toggle",
								name = L["姿态条"],
								order = 5,
								disabled = function() return not db.actionbar.cooldownalpha end,
							},
						},
					},
					Bar1Group = {
						order = 12,
						type = "group",
						name = L["动作条1"],
						guiInline = true,
						args = {
							bar1fade = {
								type = "toggle",
								name = L["自动隐藏"],
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
						order = 13,
						type = "group",
						guiInline = true,
						name = L["动作条2"],
						args = {
							bar2fade = {
								type = "toggle",
								name = L["自动隐藏"],
								order = 1,								
							},
							bar2mouseover = {
								type = "toggle",
								name = L["鼠标滑过显示"],
								order = 2,								
							},
						},
					},
					Bar3Group = {
						order = 14,
						type = "group",
						guiInline = true,
						name = L["动作条3"],
						args = {
							bar3fade = {
								type = "toggle",
								name = L["自动隐藏"],
								order = 1,								
							},
							bar3mouseover = {
								type = "toggle",
								name = L["鼠标滑过显示"],
								order = 2,								
							},
						},
					},
					Bar4Group = {
						order = 15,
						type = "group",
						guiInline = true,
						name = L["动作条4"],
						args = {
							bar4fade = {
								type = "toggle",
								name = L["自动隐藏"],
								order = 1,								
							},
							bar4mouseover = {
								type = "toggle",
								name = L["鼠标滑过显示"],
								order = 2,								
							},
						},
					},
					Bar5Group = {
						order = 16,
						type = "group",
						guiInline = true,
						name = L["动作条5"],
						args = {
							bar5fade = {
								type = "toggle",
								name = L["自动隐藏"],
								order = 1,								
							},
							bar5mouseover = {
								type = "toggle",
								name = L["鼠标滑过显示"],
								order = 2,								
							},
						},
					},
					PetGroup = {
						order = 17,
						type = "group",
						guiInline = true,
						name = L["宠物条"],
						args = {
							petbarfade = {
								type = "toggle",
								name = L["自动隐藏"],
								order = 1,								
							},
							petbarmouseover = {
								type = "toggle",
								name = L["鼠标滑过显示"],
								order = 2,								
							},
						},
					},
					StanceGroup = {
						order = 18,
						type = "group",
						guiInline = true,
						name = L["姿态条"],
						args = {
							stancebarfade = {
								type = "toggle",
								name = L["自动隐藏"],
								order = 1,								
							},
							stancebarmouseover = {
								type = "toggle",
								name = L["鼠标滑过显示"],
								order = 2,								
							},
						},
					},
				},
			},
			misc = {
				order = 10,
				type = "group",
				name = L["小玩意儿"],
				get = function(info) return db.misc[ info[#info] ] end,
				set = function(info, value) db.misc[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					anouncegroup = {
						order = 1,
						type = "group",
						name = L["通报"],
						guiInline = true,
						args = {
							anounce = {
								order = 1,
								name = L["启用"],
								desc = L["打断通报，打断、驱散、进出战斗文字提示"],
								type = "toggle",
							},
						},
					},
					auctiongroup = {
						order = 2,
						type = "group",
						name = L["拍卖行"],
						guiInline = true,
						args = {
							auction = {
								order = 1,
								name = L["启用"],
								desc = L["Shift + 右键直接一口价，价格上限请在misc/auction.lua里设置"],
								type = "toggle",
							},
						},
					},
					autodezgroup = {
						order = 3,
						type = "group",
						name = L["自动贪婪"],
						guiInline = true,
						args = {
							autodez = {
								order = 1,
								name = L["启用"],
								desc = L["满级之后自动贪婪/分解绿装"],
								type = "toggle",
							},
						},
					},
					autoreleasegroup = {
						order = 4,
						type = "group",
						name = L["自动释放尸体"],
						guiInline = true,
						args = {
							autorelease = {
								order = 1,
								name = L["启用"],
								desc = L["战场中自动释放尸体"],
								type = "toggle",
							},
						},
					},
					merchantgroup = {
						order = 5,
						type = "group",
						name = L["商人"],
						guiInline = true,
						args = {
							merchant = {
								order = 1,
								name = L["启用"],
								desc = L["自动修理、自动卖灰色物品"],
								type = "toggle",
							},
							poisons = {
								order = 2,
								name = L["补购毒药"],
								desc = L["自动补购毒药，数量在misc/merchant.lua里修改"],
								disabled = function() return not (R.myclass == "ROGUE" and db.misc.merchant) end,
								type = "toggle",
							},
						},
					},
					questgroup = {
						order = 6,
						type = "group",
						name = L["任务"],
						guiInline = true,
						args = {
							quest = {
								order = 1,
								name = L["启用"],
								desc = L["任务等级，进/出副本自动收起/展开任务追踪，任务面板的展开/收起全部分类按钮"],
								type = "toggle",
							},
							automation = {
								order = 2,
								name = L["自动交接任务"],
								desc = L["自动交接任务，按shift点npc则不自动交接"],
								disabled = function() return not db.misc.quest end,
								type = "toggle",
							},
						},
					},
					remindergroup = {
						order = 7,
						type = "group",
						name = L["buff提醒"],
						guiInline = true,
						args = {
							reminder = {
								order = 1,
								name = L["启用"],
								desc = L["缺失重要buff时提醒"],
								type = "toggle",
							},
						},
					},
					raidbuffremindergroup = {
						order = 8,
						type = "group",
						name = L["团队buff提醒"],
						guiInline = true,
						args = {
							raidbuffreminder = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
							raidbuffreminderparty = {
								order = 2,
								name = L["单人隐藏团队buff提醒"],
								type = "toggle",
								disabled = function() return not db.misc.raidbuffreminder end,
							},
						},
					},					
				},
			},
			skins = {
				order = 11,
				type = "group",
				name = L["插件美化"],
				get = function(info) return db.skins[ info[#info] ] end,
				set = function(info, value) db.skins[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					skadagroup = {
						order = 1,
						type = "group",
						name = L["Skada"],
						guiInline = true,
						args = {
							skada = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
							skadaposition = {
								order = 2,
								name = L["固定Skada位置"],
								type = "toggle",
								disabled = function() return not db.skins.skada end,
							},
						},
					},
					dbmgroup = {
						order = 2,
						type = "group",
						name = L["DBM"],
						guiInline = true,
						args = {
							dbm = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
							dbmposition = {
								order = 2,
								name = L["固定DBM位置"],
								type = "toggle",
								disabled = function() return not db.skins.dbm end,
							},
						},
					},
					ace3group = {
						order = 3,
						type = "group",
						name = L["ACE3控制台"],
						guiInline = true,
						args = {
							ace3 = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
						},
					},
					acpgroup = {
						order = 4,
						type = "group",
						name = L["ACP"],
						guiInline = true,
						args = {
							acp = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
						},
					},
					atlaslootgroup = {
						order = 5,
						type = "group",
						name = L["Atlasloot"],
						guiInline = true,
						args = {
							atlasloot = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
						},
					},
					bigwigsgroup = {
						order = 6,
						type = "group",
						name = L["BigWigs"],
						guiInline = true,
						args = {
							bigwigs = {
								order = 1,
								name = L["启用"],
								type = "toggle",
							},
						},
					},
				},
			},
		},
	}
	
	RayUIConfig.Options.args.profiles = RayUIConfig.profile
end

local RayUIConfigButton = CreateFrame("Button", "RayUIConfigButton", GameMenuFrame, "GameMenuButtonTemplate")
RayUIConfigButton:SetSize(GameMenuButtonMacros:GetWidth(), GameMenuButtonMacros:GetHeight())
GameMenuFrame:SetHeight(GameMenuFrame:GetHeight()+GameMenuButtonMacros:GetHeight());
GameMenuButtonOptions:SetPoint("TOP", RayUIConfigButton, "BOTTOM", 0, -2)
RayUIConfigButton:SetPoint("TOP", GameMenuButtonHelp, "BOTTOM", 0, -2)
RayUIConfigButton:SetText(L["|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r设置"])
RayUIConfigButton:SetScript("OnClick", function()
	HideUIPanel(GameMenuFrame)
	RayUIConfig:ShowConfig()
end)

local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_ENTERING_WORLD")
a:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	R.Reskin(RayUIConfigButton)
	local font = {GameMenuButtonMacros:GetFontString():GetFont()}
	local shadow = {GameMenuButtonMacros:GetFontString():GetShadowOffset()}
	RayUIConfigButton:GetFontString():SetFont(unpack(font))
	RayUIConfigButton:GetFontString():SetShadowOffset(unpack(shadow))
end)