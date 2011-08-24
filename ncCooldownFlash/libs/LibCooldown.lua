local lib = LibStub:NewLibrary("LibCooldown", 1.0)
if not lib then return end

lib.startcalls = {}
lib.stopcalls = {}

function lib:RegisterCallback(event, func)
	assert(type(event)=="string" and type(func)=="function", "Usage: lib:RegisterCallback(event{string}, func{function})")
	if event=="start" then
		tinsert(lib.startcalls, func)
	elseif event=="stop" then
		tinsert(lib.stopcalls, func)
	else
		error("Argument 1 must be a string containing \"start\" or \"stop\"")
	end
end

local addon = CreateFrame("Frame")
local band = bit.band
local petflags = COMBATLOG_OBJECT_TYPE_PET
local mine = COMBATLOG_OBJECT_AFFILIATION_MINE
local spells = {}
local pets = {}
local items = {}
local watched = {}
local nextupdate, lastupdate = 0, 0

local function stop(id, class)
	watched[id] = nil

	for _, func in next, lib.stopcalls do
		func(id, class)
	end
end

local function update()
	for id, tab in next, watched do
		local duration = watched[id].dur - lastupdate
		if duration < 0 then
			stop(id, watched[id].class)
		else
			watched[id].dur = duration
			if nextupdate <= 0 or duration < nextupdate then
				nextupdate = duration
			end
		end
	end
	lastupdate = 0
	
	if nextupdate < 0 then addon:Hide() end
end

local function start(id, duration, class)
	update()

	watched[id] = {
		["dur"] = duration,
		["class"] = class,
	}
	addon:Show()
	
	for _, func in next, lib.startcalls do
		func(id, duration, class)
	end
	
	update()
end

local function parsespellbook(spellbook)
	i = 1
	while true do
		skilltype, id = GetSpellBookItemInfo(i, spellbook)
		if not id then break end
		
		name = GetSpellBookItemName(i, spellbook)
		if name and skilltype == "SPELL" and spellbook == BOOKTYPE_SPELL and not IsPassiveSpell(i, spellbook) then
			spells[name] = id
		elseif name and skilltype == "PETACTION" and spellbook == BOOKTYPE_PET and not IsPassiveSpell(i, spellbook) then
			pets[name] = id
		end
		
		i = i + 1
	end
end

-- events --
function addon:LEARNED_SPELL_IN_TAB()
	parsespellbook(BOOKTYPE_SPELL)
	parsespellbook(BOOKTYPE_PET)
end

function addon:SPELL_UPDATE_COOLDOWN()
	now = GetTime()
	
	for name, id in next, spells do
		local starttime, duration, enabled = GetSpellCooldown(name)
		
		if starttime == nil then
			watched[id] = nil
		elseif starttime ~= 0 then
			local timeleft = starttime + duration - now
		
			if enabled == 1 and timeleft > 1.5 then
				if not watched[id] then
					start(id, timeleft, "spell")
				end
			elseif enabled == 1 and watched[id] and timeleft <= 0 then
				stop(id, "spell")
			end
		end
	end
	
	for name, id in next, pets do
		local start, duration, enabled = GetSpellCooldown(name)

		if starttime == nil then
			watched[id] = nil
		elseif starttime ~= 0 then
			local timeleft = starttime + duration - now
		
			if enabled == 1 and timeleft > 1.5 then
				if not watched[id] then
					start(id, timeleft, "pet")
				end
			elseif enabled == 1 and watched[id] and timeleft <= 0 then
				stop(id, "pet")
			end
		end
	end
end

function addon:BAG_UPDATE_COOLDOWN()
	for name, id  in next, items do
		local _, duration, enabled = GetItemCooldown(id)
		if enabled == 1 and duration > 10 then
			start(id, duration, "item")
		elseif enabled == 1 and watched[id] and duration <= 0 then
			stop(id, "item")
		end
	end
end

function addon:PLAYER_ENTERING_WORLD()
	addon:LEARNED_SPELL_IN_TAB()
	addon:BAG_UPDATE_COOLDOWN()
	addon:SPELL_UPDATE_COOLDOWN()
end

hooksecurefunc("UseInventoryItem", function(slot)
	local link = GetInventoryItemLink("player", slot) or ""
	local id, name = string.match(link, ":(%w+).*|h%[(.+)%]|h")
	if id and not items[name] then
		items[name] = id
	end
end)

hooksecurefunc("UseContainerItem", function(bag, slot)
	local link = GetContainerItemLink(bag, slot) or ""
	local id, name = string.match(link, ":(%w+).*|h%[(.+)%]|h")
	if id and not items[name] then
		items[name] = id
	end
end)

for slot=1, 120 do
	local action, id = GetActionInfo(slot)
	if action == "item" then
		items[GetItemInfo(id)] = id
	end
end

function addon:ACTION_BAR_SLOT_CHANGED(slot)
	local action, id = GetActionInfo(slot)
	if action == "item" then
		items[GetItemInfo(id)] = id
	end
end

local function onupdate(self, elapsed)
	nextupdate = nextupdate - elapsed
	lastupdate = lastupdate + elapsed
	if nextupdate > 0 then return end
	
	update(self)
end

addon:Hide()
addon:SetScript("OnUpdate", onupdate)
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

addon:RegisterEvent("LEARNED_SPELL_IN_TAB")
addon:RegisterEvent("SPELL_UPDATE_COOLDOWN")
addon:RegisterEvent("BAG_UPDATE_COOLDOWN")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
