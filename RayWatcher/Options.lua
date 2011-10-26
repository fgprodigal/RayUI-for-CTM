local RayWatcherConfig = LibStub("AceAddon-3.0"):NewAddon("RayWatcherConfig", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("RayWatcherConfig", false)
local db = {}
local groupname = {}
local defaults = {}
local idinput
local DEFAULT_WIDTH = 800
local DEFAULT_HEIGHT = 500
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local _, ns = ...

function RayWatcherConfig:LoadDefaults()
	defaults.profile = {}
	defaults.profile.options = {}
	for i,v in pairs(ns.modules) do
		groupname[i] = i
		defaults.profile[i] = defaults.profile[i] or {}
		for ii,vv in pairs(v) do
			if type(vv) ~= 'table' then
				defaults.profile[i][ii] = vv
			end
		end
	end
end	

function RayWatcherConfig:OnInitialize()	
	RayWatcherConfig:RegisterChatCommand("rw", "ShowConfig")
	
	self.OnInitialize = nil
end

function RayWatcherConfig:ShowConfig() 
	ACD[ACD.OpenFrames.RayWatcherConfig and "Close" or "Open"](ACD,"RayWatcherConfig") 
end

function RayWatcherConfig:Load()
	self:LoadDefaults()
	-- Create savedvariables
	self.db = LibStub("AceDB-3.0"):New("RayWatcherDB", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	db = self.db.profile
	db.options.idinput = nil
	db.options.filterinput = nil
	db.options.unitidinput = nil
	db.options.casterinput = nil
	self:SetupOptions()
end

function RayWatcherConfig:OnProfileChanged(event, database, newProfileKey)
	StaticPopup_Show("CFG_RELOAD")
end


function RayWatcherConfig:SetupOptions()
	AC:RegisterOptionsTable("RayWatcherConfig", self.GenerateOptions)
	ACD:SetDefaultSize("RayWatcherConfig", DEFAULT_WIDTH, DEFAULT_HEIGHT)

	--Create Profiles Table
	self.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db);
	AC:RegisterOptionsTable("RayWatcherProfiles", self.profile)
	self.profile.order = -10
	
	self.SetupOptions = nil
end

function RayWatcherConfig.GenerateOptions()
	if RayWatcherConfig.noconfig then assert(false, RayWatcherConfig.noconfig) end
	if not RayWatcherConfig.Options then
		RayWatcherConfig.GenerateOptionsInternal()
		RayWatcherConfig.GenerateOptionsInternal = nil
	end
	return RayWatcherConfig.Options
end

function RayWatcherConfig.GenerateOptionsInternal()
	local function UpdateGroup()
		local current = db.options.GroupSelect or next(groupname)
		db.options.GroupSelect = current
		local buffs = RayWatcherConfig.Options.args.options.args.buffs.values
		local debuffs = RayWatcherConfig.Options.args.options.args.debuffs.values
		local cooldowns = RayWatcherConfig.Options.args.options.args.cooldowns.values
		local itemcooldowns = RayWatcherConfig.Options.args.options.args.itemcooldowns.values
		wipe(buffs)
		wipe(debuffs)
		wipe(cooldowns)
		wipe(itemcooldowns)
		for i in pairs(ns.modules[current].BUFF or {}) do
			if i ~= "unitIDs" and ns.modules[current].BUFF[i] then
				buffs[i] = GetSpellInfo(i) .. " (" .. i .. ")"
			end
		end
		for i in pairs(ns.modules[current].DEBUFF or {}) do
			if i ~= "unitIDs" and ns.modules[current].DEBUFF[i] then
				debuffs[i] = GetSpellInfo(i) .. " (" .. i .. ")"
			end
		end
		for i in pairs(ns.modules[current].CD or {}) do
			if ns.modules[current].CD[i] then
				cooldowns[i] = GetSpellInfo(i) .. " (" .. i .. ")"
			end
		end
		for i in pairs(ns.modules[current].itemCD or {}) do
			if ns.modules[current].itemCD[i] then
				itemcooldowns[i] = GetItemInfo(i) .. " (" .. i .. ")"
			end
		end
		if next(buffs) == nil then
			RayWatcherConfig.Options.args.options.args.buffs.hidden  = true
		else
			RayWatcherConfig.Options.args.options.args.buffs.hidden  = false			
		end
		if next(debuffs) == nil then
			RayWatcherConfig.Options.args.options.args.debuffs.hidden  = true
		else
			RayWatcherConfig.Options.args.options.args.debuffs.hidden  = false			
		end
		if next(cooldowns) == nil then
			RayWatcherConfig.Options.args.options.args.cooldowns.hidden  = true
		else
			RayWatcherConfig.Options.args.options.args.cooldowns.hidden  = false			
		end
		if next(itemcooldowns) == nil then
			RayWatcherConfig.Options.args.options.args.itemcooldowns.hidden  = true
		else
			RayWatcherConfig.Options.args.options.args.itemcooldowns.hidden  = false			
		end
	end
	
	local function UpdateInput(id, filter)
		db.options.idinput = tostring(id)
		db.options.filterinput = filter
		local current = db.options.GroupSelect
		db.options.unitidinput = ns.modules[current][filter][id].unitID
		db.options.casterinput = ns.modules[current][filter][id].caster
	end

	StaticPopupDialogs["CFG_RELOAD"] = {
		text = L["改变参数需重载应用设置"],
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept = function() ReloadUI() end,
		timeout = 0,
		whileDead = 1,
	}
	
	RayWatcherConfig.Options = {
		type = "group",
		name = "|cff7aa6d6Ray|r|cffff0000W|r|cff7aa6d6atcher|r",
		args = {
			RayWatcher_Header = {
				order = 1,
				type = "header",
				name = L["版本"]..GetAddOnMetadata("RayWatcher", "Version"),
				width = "full",		
			},
			ToggleAnchors = {
				order = 2,
				type = "execute",
				name = L["解锁锚点"],
				func = function()  ns.TestMode() end,
			},
			options = {
				order = 3,
				type = "group",
				name = L["选项"],
				get = function(info) UpdateGroup() return (db.options[ info[#info] ] or next(groupname)) end,
				set = function(info, value) db.options[ info[#info] ] = value; StaticPopup_Show("CFG_RELOAD") end,
				args = {
					GroupSelect = {
						order = 1,
						type = "select",
						name = "选择一个分组",
						set = function(info, value)
							db.options[ info[#info] ] = value
							UpdateGroup()
						end,
						values = groupname,						
					},
					spacer = {
						type = 'description',
						name = '',
						desc = '',
						order = 2,
					},
					mode = {
						order = 3,
						name = "模式",
						set = function(info, value) db[db.options.GroupSelect].mode = value StaticPopup_Show("CFG_RELOAD") end,
						get = function() return (db[db.options.GroupSelect].mode or "ICON") end,
						disabled = function(info) return not db.options.GroupSelect end,
						type = "select",
						width = "half",
						values = {
							["ICON"] = "图标",
							["BAR"] = "计时条",
						},
					},	
					spacer2 = {
						type = 'description',
						name = '',
						desc = '',
						width = "half",
						order = 4,
					},
					direction = {
						order = 5,
						name = "增长方向",
						set = function(info, value) db[db.options.GroupSelect].direction = value StaticPopup_Show("CFG_RELOAD") end,
						get = function() return db[db.options.GroupSelect].direction end,
						disabled = function(info) return not db.options.GroupSelect end,
						width = "half",
						type = "select",
						values = function()
							if db[db.options.GroupSelect].mode == "BAR" then
								return {
									["UP"] = "上",
									["DOWN"] = "下",
								}
							else
								return {
									["UP"] = "上",
									["DOWN"] = "下",
									["LEFT"] = "左",
									["RIGHT"] = "右",
								}
							end
						end,
					},	
					spacer3 = {
						type = 'description',
						name = '',
						desc = '',
						order = 6,
					},					
					size = {
						order = 7,
						name = "图标大小",
						set = function(info, value) db[db.options.GroupSelect].size = value StaticPopup_Show("CFG_RELOAD") end,
						get = function() return db[db.options.GroupSelect].size end,
						disabled = function(info) return not db.options.GroupSelect end,
						type = "range",
						min = 20, max = 80, step = 1,
					},
					barWidth = {
						order = 8,
						name = "计时条长度",
						set = function(info, value) db[db.options.GroupSelect].barwidth = value StaticPopup_Show("CFG_RELOAD") end,
						get = function() return (db[db.options.GroupSelect].barwidth or 150) end,
						hidden = function(info) return db[db.options.GroupSelect].mode ~= "BAR" end,
						type = "range",
						min = 50, max = 300, step = 1,
					},
					iconSide = {
						order = 9,
						name = "图标位置",
						set = function(info, value) db[db.options.GroupSelect].iconside = value StaticPopup_Show("CFG_RELOAD") end,
						get = function() return (db[db.options.GroupSelect].iconside or "LEFT") end,
						hidden = function(info) return db[db.options.GroupSelect].mode ~= "BAR" end,
						type = "select",
						width = "half",
						values = {
							["LEFT"] = "左",
							["RIGHT"] = "右",
						},
					},
					spacer4 = {
						type = 'description',
						name = '',
						desc = '',
						order = 10,
					},
					buffs = {
						order = 11,
						type = "select",
						name = "已有增益监视",
						set = function(info, value) UpdateInput(value, "BUFF") end,
						values = {},
					},
					debuffs = {
						order = 12,
						type = "select",
						name = "已有减益监视",
						set = function(info, value) UpdateInput(value, "DEBUFF") end,
						values = {},
					},
					cooldowns = {
						order = 13,
						type = "select",
						name = "已有冷却监视",
						set = function(info, value) UpdateInput(value, "CD") end,
						values = {},
					},
					itemcooldowns = {
						order = 14,
						type = "select",
						name = "已有物品冷却监视",
						set = function(info, value) UpdateInput(value, "itemCD") end,
						values = {},
					},
					spacer5 = {
						type = 'description',
						name = '',
						desc = '',
						width = "full",
						order = 15,
					},
					idinput = {
						order = 16,
						type = "input",
						name = "ID",
						get = function(info, value) return db.options[ info[#info] ] end,
						set = function(info, value) db.options[ info[#info] ] = value end,
						hidden = function(info) return not db.options.GroupSelect end,
					},
					filterinput = {
						order = 17,
						name = "类型",
						get = function(info, value) return db.options[ info[#info] ] end,
						set = function(info, value) db.options[ info[#info] ] = value end,
						hidden = function(info) return not db.options.GroupSelect end,
						type = "select",
						values = {
							["BUFF"] = "增益",
							["DEBUFF"] = "减益",
							["CD"] = "冷却",
							["itemCD"] = "物品冷却",
						},
					},
					spacer6 = {
						type = 'description',
						name = '',
						desc = '',
						order = 18,
					},
					unitidinput = {
						order = 19,
						type = "input",
						name = "监视对象",
						desc = "监视对象，如player,target....只能填一个",
						get = function(info, value) return db.options[ info[#info] ] end,
						set = function(info, value) db.options[ info[#info] ] = value end,
						hidden = function(info) return(db.options.filterinput~="BUFF" and db.options.filterinput~="DEBUFF") end,
					},
					casterinput = {
						order = 20,
						type = "input",
						name = "施法者",
						desc = "监视对象，如player,target,all....只能填一个，监视全部填all",
						get = function(info, value) return db.options[ info[#info] ] end,
						set = function(info, value) db.options[ info[#info] ] = value end,
						hidden = function(info) return(db.options.filterinput~="BUFF" and db.options.filterinput~="DEBUFF") end,
					},
					spacer7 = {
						type = 'description',
						name = '',
						desc = '',
						width = "full",
						order = 21,
					},
					addbutton = {
						order = 22,
						type = "execute",
						name = "添加",
						desc = "添加到当前分组",
						width = "half",
						disabled = function(info) return (not db.options.filterinput or not db.options.idinput) end,
						func = function()
							db[db.options.GroupSelect][db.options.filterinput] = db[db.options.GroupSelect][db.options.filterinput] or {}
							db[db.options.GroupSelect][db.options.filterinput][tonumber(db.options.idinput)] = {
								["caster"] = db.options.casterinput,
								["unitID"] = db.options.unitidinput,
							}
							ns.modules[db.options.GroupSelect][db.options.filterinput] = ns.modules[db.options.GroupSelect][db.options.filterinput] or {}
							ns.modules[db.options.GroupSelect][db.options.filterinput][tonumber(db.options.idinput)] = {
								["caster"] = db.options.casterinput,
								["unitID"] = db.options.unitidinput,
							}
							UpdateGroup()
							StaticPopup_Show("CFG_RELOAD")
						end,
					},
					deletebutton = {
						order = 23,
						type = "execute",
						name = "删除",
						desc = "从当前分组删除",
						width = "half",
						disabled = function(info) return not db.options.idinput end,
						func = function()
							db[db.options.GroupSelect][db.options.filterinput] = db[db.options.GroupSelect][db.options.filterinput] or {}
							db[db.options.GroupSelect][db.options.filterinput][tonumber(db.options.idinput)] = false
							ns.modules[db.options.GroupSelect][db.options.filterinput] = ns.modules[db.options.GroupSelect][db.options.filterinput] or {}
							ns.modules[db.options.GroupSelect][db.options.filterinput][tonumber(db.options.idinput)] = false
							UpdateGroup()
							StaticPopup_Show("CFG_RELOAD")
						end,
					},
				},
			},
		},
	}
	
	RayWatcherConfig.Options.args.profiles = RayWatcherConfig.profile
end