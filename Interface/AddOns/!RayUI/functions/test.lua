local R, C, L, DB = unpack(select(2, ...))
local ADDON_NAME = ...

local inRaid = false
local latestver = R.version
partyuserlist = {}

local function SendVersion()
	SendAddonMessage("RAYUI", "Version:"..R.version, "GUILD")
	local zoneType = select(2, IsInInstance())
	if zoneType == "pvp" or zoneType == "arena" then
		SendAddonMessage("RAYUI", "Version:"..R.version, "BATTLEGROUND")
	elseif GetRealNumRaidMembers() > 0 then
		SendAddonMessage("RAYUI", "Version:"..R.version, "RAID")
	elseif GetRealNumPartyMembers() > 0 then
		SendAddonMessage("RAYUI", "Version:"..R.version, "PARTY")
	end
end

function R.CheckAnnouncer()
	local maxguid = ""
	local maxname
	for name,guid in pairs(partyuserlist) do
		if guid > maxguid then
			maxguid = guid
			maxname = name
		end
	end
	return maxname
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:SetScript("OnEvent", function(self, event, ...)
	if type(f[event]) == "function" then
		f[event](self, ...)
	end
end)

function f:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	RegisterAddonMessagePrefix("RAYUI")
	SendAddonMessage("RAYUI", "Version:"..R.version, "GUILD")
end

function f:PLAYER_ENTERING_BATTLEGROUND()
	SendAddonMessage("RAYUI", "Version:"..R.version, "BATTLEGROUND")
end

function f:PARTY_MEMBERS_CHANGED()
	if (not inRaid) and (GetRealNumRaidMembers() > 0 or GetRealNumPartyMembers() > 0) then
		inRaid = true
		wipe(partyuserlist)
		partyuserlist[R.myname] = UnitGUID(R.myname)
		if GetRealNumRaidMembers() > 0 then
			SendAddonMessage("RAYUI", "Enter", "RAID")
		elseif GetRealNumPartyMembers() > 0 then
			SendAddonMessage("RAYUI", "Enter", "PARTY")
		end
	elseif inRaid and GetRealNumRaidMembers() == 0 and GetRealNumPartyMembers() == 0 then
		inRaid = false
		wipe(partyuserlist)
	else
		for name in pairs(partyuserlist) do
			if not UnitInParty(name) then
				partyuserlist[name] = nil
			end
		end
	end
	
	if GetRealNumRaidMembers() > 0 then
		SendAddonMessage("RAYUI", "Version:"..R.version, "RAID")
	elseif GetRealNumPartyMembers() > 0 then
		SendAddonMessage("RAYUI", "Version:"..R.version, "PARTY")
	end
end

function f:CHAT_MSG_ADDON(prefix, msg, channel, sender)
	if not (prefix == "RAYUI" and msg) then return end
	-- R.debug(sender..": "..msg, channel)
	if msg:find("Version:") then
		local version = msg:match("Version:(%d+)")
		if version > latestver then
			latestver = version
			DEFAULT_CHAT_FRAME:AddMessage(format("发现|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r新版本: %d(%s)", version, sender))
		elseif version < R.version then
			SendAddonMessage("RAYUI", "Version:"..R.version, channel)
		end
	end
	if channel == "RAID" or channel == "PARTY" then
		if msg == "Enter" and sender ~= R.myname  then
			SendAddonMessage("RAYUI", "Welcome", channel)
			partyuserlist[sender] = UnitGUID(sender) or ""
		elseif msg == "Welcome" then
			partyuserlist[sender] = UnitGUID(sender) or ""
		end
	end
end