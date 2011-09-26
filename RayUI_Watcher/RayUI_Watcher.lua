local RayUIWatcher = LibStub("AceAddon-3.0"):NewAddon("RayUI_Watcher", "AceConsole-3.0","AceEvent-3.0")

local _, ns = ...
local _, myclass = UnitClass("player")
local page, db
local colors = RAID_CLASS_COLORS
local modules = {}
local testing = false

local function CreateShadow(f)
	if f.shadow then return end
	
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -3, 3)
	shadow:SetPoint("BOTTOMRIGHT", 3, -3)
	shadow:SetBackdrop({
	bgFile = [[Interface\ChatFrame\ChatFrameBackground.blp]], 
	edgeFile = [[Interface\AddOns\RayUI_Watcher\media\glowTex.tga]], 
	edgeSize = 5,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	shadow:SetBackdropColor(.05,.05,.05, .9)
	shadow:SetBackdropBorderColor(0, 0, 0, 1)
	f.shadow = shadow
	f.glow = shadow
end

local function capitalize(str)
	if str == nil then
		return nil, "the string parameter is nil"
	end
	local ch = string.sub(str, 1, 1)
	local len = string.len(str)
	if ch < 'a' or ch > 'z' then
		return str
	end
	ch = string.char(string.byte(ch) - 32)
	if len == 1 then
		return ch
	else
		return ch .. string.sub(str, 2, len)
	end
end

function RayUIWatcher:PrintCmd(input)
	input = input:trim():match("^(.-);*$")
	local func, err = loadstring("LibStub(\"AceConsole-3.0\"):Print(" .. input .. ")")
	if not func then
		LibStub("AceConsole-3.0"):Print("错误: " .. err)
	else
		func()
	end
end

function RayUIWatcher:OnInitialize()
	self:RegisterChatCommand("print", "PrintCmd")
	if type(ns.watchers[myclass]) == "table" then
		for _, t in ipairs(ns.watchers[myclass]) do
			self:NewWatcher(t)
		end
	end
	if type(ns.watchers["ALL"]) == "table" then
		for _, t in ipairs(ns.watchers["ALL"]) do
			self:NewWatcher(t)
		end
	end
	ns.watchers = nil
	local lockgroup = page:CreateMultiSelectionGroup("锁定/解锁模块")
	page:AnchorToTopLeft(lockgroup)
	lockgroup:AddButton("锁定", "lock")
	lockgroup.OnCheckInit = function(self, value) 
			if db.lock ~= nil then
			return db.lock
		else
			return false
		end
	end
	lockgroup.OnCheckChanged = function(self, value, checked)
		testing = not checked
		for _, v in pairs(modules) do
			v:TestMode(testing)
		end				
		db.lock = checked == 1 and true or false
	end
	
	local group = page:CreateMultiSelectionGroup("选择启用的模块")
	page:AnchorToTopLeft(group, 0, -50)
	for _, v in pairs(modules) do
		group:AddButton(v:GetName(), v:GetName())
	end
	group.OnCheckInit = function(self, value)
		if db.profiles[myclass][value] ~= nil then
			return db.profiles[myclass][value]
		else
			return RayUIWatcher:GetModule(value):IsEnabled()
		end
	end
	group.OnCheckChanged = function(self, value, checked)
		if checked then
			RayUIWatcher:GetModule(value):Enable()
			db.profiles[myclass][value] = true
		else
			RayUIWatcher:GetModule(value):Disable()
			db.profiles[myclass][value] = false
		end
	end
end

function RayUIWatcher:OnEnable()
end

function RayUIWatcher:OnDisable()
	print("|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r Watcher已禁用")
end

function RayUIWatcher:NewWatcher(data)
	if type(data) ~= 'table' then 
		error(format("bad argument #1 to 'RayUIWatcher:New' (table expected, got %s)", type(name)))
		return
	end
	local name, module
	for i, v in pairs(data) do
		if type(v) ~= "table" then
			if i:lower()=="name" then
				name = v
			end
		end
	end
	if name then
		module = self:NewModule(name, "AceConsole-3.0", "AceEvent-3.0")
	else
		error("can't find argument 'name'")
		return
	end
	
	module.list = {}
	module.bufflist = {}
	module.debufflist = {}	
	module.cdlist = {}
	module.itemlist = {}
	module.button = {}	
	
	for i, v in pairs(data) do
		if type(v) ~= "table" or (type(v) == "table" and type(i) ~= "number") then
			module[i:lower()] = v
		else
			table.insert(module.list, v)
		end
	end

	function module:OnEnable()
		if self.parent then
			self.parent:Show()
		end
		self:TestMode(testing)
		self:Update()
	end
	
	function module:OnDisable()
		self:Print("模块已禁用")
		if self.parent then
			self.parent:Hide()
		end
	end
	
	function module:CreateButton(mode)
		local button=CreateFrame("Frame", nil, self.parent)
		CreateShadow(button)
		button:SetWidth(self.size)
		button:SetHeight(self.size)
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetPoint("TOPLEFT", button , 2, -2)
		button.icon:SetPoint("BOTTOMRIGHT", button , -2, 2)
		button.count = button:CreateFontString(nil, "OVERLAY")
		button.count:SetFont(ns.font, ns.fontsize, ns.fontflag)
		button.count:SetPoint("BOTTOMRIGHT", button , "BOTTOMRIGHT", 0, 0)
		button:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				if self.filter == "BUFF" then
					GameTooltip:SetUnitAura(self.unitId, self.index, "HELPFUL")
				elseif self.filter == "DEBUFF" then
					GameTooltip:SetUnitAura(self.unitId, self.index, "HARMFUL")
				elseif self.filter == "ITEM" then
					GameTooltip:SetHyperlink(select(2,GetItemInfo(self.spellID)))
				else
					GameTooltip:SetSpellByID(self.spellID)
				end
				GameTooltip:Show()
			end)
		button:SetScript("OnLeave", function(self) 
				GameTooltip:Hide() 
			end)
		if mode=="BAR" then
			button.statusbar = CreateFrame("StatusBar", nil, button)
			button.statusbar:SetFrameStrata("BACKGROUND")
			button.statusbar.bg = CreateFrame("StatusBar", nil, button.statusbar)
			button.statusbar.bg:SetPoint("TOPLEFT", -2, 2)
			button.statusbar.bg:SetPoint("BOTTOMRIGHT", 2, -2)
			CreateShadow(button.statusbar.bg)
			button.statusbar:SetWidth(self.barwidth - 6)
			button.statusbar:SetHeight(5)
			button.statusbar:SetStatusBarTexture([[Interface\AddOns\RayUI_Watcher\media\statusbar.tga]])
			button.statusbar:SetStatusBarColor(colors[myclass].r, colors[myclass].g, colors[myclass].b, 1)
			if ( self.iconside == "RIGHT" ) then
				button.statusbar:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", -5, 2)
			else
				button.statusbar:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 5, 2)
			end
			button.statusbar:SetMinMaxValues(0, 1)
			button.statusbar:SetValue(1)
			button.time = button:CreateFontString(nil, "OVERLAY")
			button.time:SetFont(ns.font, ns.fontsize, ns.fontflag)
			button.time:SetPoint("BOTTOMRIGHT", button.statusbar, "TOPRIGHT", 0, 2)
			button.time:SetText("60")
			button.name = button:CreateFontString(nil, "OVERLAY")
			button.name:SetFont(ns.font, ns.fontsize, ns.fontflag)
			button.name:SetPoint("BOTTOMLEFT", button.statusbar, "TOPLEFT", 0, 2)
			button.name:SetText("技能名称")
			button.mode = "BAR"
		else			
			button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
			button.cooldown:SetAllPoints(button.icon)
			button.cooldown:SetReverse()
			button.mode = "ICON"	
		end
		return button
	end
	
	function module:UpdateButton(button, index, icon, count, duration, expires, spellID, unitId, filter)
		button.icon:SetTexture(icon)
		button.icon:SetTexCoord(.1, .9, .1, .9)
		button.count:SetText(count==0 and "" or count)
		if button.cooldown then
			CooldownFrame_SetTimer(button.cooldown, filter == "CD" and expires or (expires - duration), duration, 1)
		end
		button.index = index
		button.filter = filter
		button.unitId = unitId
		button.spellID = spellID
		if filter == "ITEM" then
			button.spn = GetItemInfo(spellID)
		else
			button.spn = GetSpellInfo(spellID)
		end
		button:Show()
	end
	
	local function CDUpdate(self, elapsed)
		local start, duration
		if self.filter == "ITEM" then
			start, duration = GetItemCooldown(self.spellID)
		else
			start, duration = GetSpellCooldown(self.spellID)
		end
		if self.mode == "BAR" then
			self.statusbar:SetMinMaxValues(0, duration)
			local time = start + duration - GetTime()
			self.statusbar:SetValue(time)
			if time <= 60 then
				self.time:SetFormattedText("%.1f", time)
			else
				self.time:SetFormattedText("%d:%.2d", time/60, time%60)
			end
			self.name:SetText(self.spn)
		end
		if start == 0 then
			self:SetScript("OnUpdate", nil)
			module:Update()
		end
	end
	
	local function BarUpdate(self, elapsed)
		if self.spellID then
			if self.filter ~= "CD" then				
				local _, _, _, _, _, duration, expires = UnitAura(self.unitId, self.index, self.filter == "BUFF" and "HELPFUL" or "HARMFUL")
				-- module:Print(duration, expires)
				self.statusbar:SetMinMaxValues(0, duration)
				local time = expires - GetTime()
				self.statusbar:SetValue(time)
				self.name:SetText(self.spn)
				if time <= 60 then
					self.time:SetFormattedText("%.1f", time)
				else
					self.time:SetFormattedText("%d:%.2d", time/60, time%60)
				end
			end
		end
	end
	
	function module:CheckAura(unitID, filter, num)
		local index = 1
		local list = self[filter:lower().."list"]
		if next(list) then
			if filter == "CD" or filter == "ITEM" then
				for i,v in pairs(list) do
					local start, duration, icon
					if unitID == "item" then
						start, duration = GetItemCooldown(i)
						_, _, _, _, _, _, _, _, _, icon = GetItemInfo(i)
					else
						start, duration = GetSpellCooldown(i)
						_, _, icon = GetSpellInfo(i)
					end
					if start~= 0 and duration>2 then						
						if not self.button[num] then
							self.button[num] = self:CreateButton(self.mode)					
							if num == 1 then 
								self.button[num]:SetPoint("CENTER", self.parent, "CENTER", 0, 0)
							elseif self.direction == "LEFT" then
								self.button[num]:SetPoint("RIGHT", self.button[num-1], "LEFT", -5, 0)
							elseif self.direction == "UP" then
								self.button[num]:SetPoint("BOTTOM", self.button[num-1], "TOP", 0, 5)
							elseif self.direction == "DOWN" then
								self.button[num]:SetPoint("TOP", self.button[num-1], "BOTTOM", 0, -5)
							else
								self.button[num]:SetPoint("LEFT", self.button[num-1], "RIGHT", 5, 0)
							end
						end	
						self:UpdateButton(self.button[num], nil, icon, 0, duration, start, i, unitID, filter)
						self.button[num]:SetScript("OnUpdate", CDUpdate)
						num = num + 1
					end
				end
			else
				-- while UnitAura(unitID,index, filter == "BUFF" and "HELPFUL" or "HARMFUL") do
				while _G["Unit"..capitalize(filter:lower())](unitID,index) do
					local _, _, icon, count, _, duration, expires, caster, _, _, spellID = _G["Unit"..capitalize(filter:lower())](unitID,index)
					if list[spellID] then
						if list[spellID].unitId == unitID and (list[spellID].caster == caster or list[spellID].caster == "all")then
							if not self.button[num] then
								self.button[num] = self:CreateButton(self.mode)					
								if num == 1 then 
									self.button[num]:SetPoint("CENTER", self.parent, "CENTER", 0, 0)
								elseif self.direction == "LEFT" then
									self.button[num]:SetPoint("RIGHT", self.button[num-1], "LEFT", -5, 0)
								elseif self.direction == "UP" then
									self.button[num]:SetPoint("BOTTOM", self.button[num-1], "TOP", 0, 5)
								elseif self.direction == "DOWN" then
									self.button[num]:SetPoint("TOP", self.button[num-1], "BOTTOM", 0, -5)
								else
									self.button[num]:SetPoint("LEFT", self.button[num-1], "RIGHT", 5, 0)
								end
							end	
							self:UpdateButton(self.button[num], index, icon, count, duration, expires, spellID, unitID, filter)
							if self.mode == "BAR" then
								self.button[num]:SetScript("OnUpdate", BarUpdate)
							else
								self.button[num]:SetScript("OnUpdate", nil)
							end
							num = num + 1
						end
					end
					index = index + 1
				end
			end
		end
		return num
	end

	function module:Update()
		local num = 1
		for i = 1, #self.button do
			self.button[i]:Hide()
		end
		
		num = self:CheckAura("player","CD",num)
		num = self:CheckAura("item","ITEM",num)
		num = self:CheckAura("player","BUFF",num)
		num = self:CheckAura("player","DEBUFF",num)
		num = self:CheckAura("target","BUFF",num)
		num = self:CheckAura("target","DEBUFF",num)
		num = self:CheckAura("focus","DEBUFF",num)
	end
	
	function module:TestMode(arg)
		if not self:IsEnabled() then return end
		if arg == true then
			local num = 1
			module:UnregisterEvent("UNIT_AURA")
			module:UnregisterEvent("PLAYER_TARGET_CHANGED")
			module:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
			for _, subt in pairs({"buff", "debuff", "cd", "item"}) do
				for i,v in next,self[subt.."list"] do
					if not self.button[num] then
						self.button[num] = self:CreateButton(self.mode)					
						if num == 1 then 
							self.button[num]:SetPoint("CENTER", self.parent, "CENTER", 0, 0)
						elseif self.direction == "LEFT" then
							self.button[num]:SetPoint("RIGHT", self.button[num-1], "LEFT", -5, 0)
						elseif self.direction == "UP" then
							self.button[num]:SetPoint("BOTTOM", self.button[num-1], "TOP", 0, 5)
						elseif self.direction == "DOWN" then
							self.button[num]:SetPoint("TOP", self.button[num-1], "BOTTOM", 0, -5)
						else
							self.button[num]:SetPoint("LEFT", self.button[num-1], "RIGHT", 5, 0)
						end
					end
					local icon
					if subt == "item" then
						_, _, _, _, _, _, _, _, _, icon = GetItemInfo(i)
					else
						_, _, icon = GetSpellInfo(i)
					end
					self:UpdateButton(self.button[num], 1, icon, 9, 0, 0, i, "player", subt:upper())
					num = num + 1
				end
			end
			self.moverFrame:Show()
		else
			module:RegisterEvent("UNIT_AURA")
			module:RegisterEvent("PLAYER_TARGET_CHANGED")
			module:RegisterEvent("SPELL_UPDATE_COOLDOWN")
			for _, v in pairs(modules) do
				v:Update()
			end
			self.moverFrame:Hide()
		end
	end
	
	function module:UNIT_AURA()
		self:Update()
	end
	
	function module:PLAYER_TARGET_CHANGED()
		self:Update()
	end
	
	function module:SPELL_UPDATE_COOLDOWN()
		self:Update()
	end
	
	function module:PLAYER_ENTERING_WORLD()
		if db.profiles[myclass][self:GetName()] == false then
			self:Disable()
		else
			self:Update()
		end
		
		if db.lock ~= true then
			self:TestMode(true)
		end
	end
	
	module.parent = CreateFrame("Frame", module.name, UIParent)
	module.parent:SetSize(module.size, module.size)
	module.parent:SetPoint(unpack(module.setpoint))
	module.parent:SetMovable(true)
	
	local mover = CreateFrame("Frame", nil, module.parent)
	module.moverFrame = mover
	mover:SetAllPoints(module.parent)
	mover:SetFrameStrata("FULLSCREEN_DIALOG")
	mover.mask = mover:CreateTexture(nil, "OVERLAY")
	mover.mask:SetAllPoints(mover)
	mover.mask:SetTexture(0, 1, 0, 0.5)
	mover.text = mover:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	mover.text:SetPoint("CENTER")
	mover.text:SetText(module.name)
	
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
	mover:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)

	mover:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.name)
		GameTooltip:AddLine("拖拽左键移动，右键设置", 1, 1, 1)
		GameTooltip:Show()
	end)
	
	mover:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			page:Open()
		end
	end)

	mover:SetScript("OnUpdate", nil)
	
	mover:Hide()
	
	for i, t in ipairs(module.list) do
		if t.filter == "BUFF" then
			module.bufflist[t.spellID] = {unitId = t.unitId, caster = t.caster,}
		elseif t.filter == "DEBUFF" then
			module.debufflist[t.spellID] = {unitId = t.unitId, caster = t.caster,}
		elseif t.filter == "CD" then
			if t.spellID then
				module.cdlist[t.spellID] = true
			end
			if t.itemID then
				module.itemlist[t.itemID] = true
			end
		end
	end
	
	module:RegisterEvent("UNIT_AURA")
	module:RegisterEvent("PLAYER_TARGET_CHANGED")
	module:RegisterEvent("PLAYER_ENTERING_WORLD")
	module:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	
	tinsert(modules, module)
end

page = UICreateInterfaceOptionPage("RayUI_WatcherOptionPage", RayUIWatcher:GetName(), "一个很2B的技能监视")
RayUIWatcher.optionPage = page
page.title:SetText(RayUIWatcher:GetName().." "..GetAddOnMetadata("RayUI_Watcher", "Version"))
page:RegisterEvent("ADDON_LOADED")
page:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "RayUI_Watcher" then

		if type(RayUI_WatcherDB) ~= "table" then
			RayUI_WatcherDB = {}
		end

		db = RayUI_WatcherDB

		if type(db.profiles) ~= "table" then
			db.profiles = {}
		end
		
		if type(db.profiles[myclass]) ~= "table" then
			db.profiles[myclass] = {}
		end
	end
end)

SLASH_TESTMODE1="/testmode"
SlashCmdList["TESTMODE"]=function(msg)
	testing = not testing
	for _, v in pairs(modules) do		
		v:TestMode(testing)
	end
end