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

local function CreateTutorialFrame(name, parent, width, height, text)
	local frame = CreateFrame("Frame", name, parent, "GlowBoxTemplate")
	frame:SetSize(width, height)	
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	local arrow = CreateFrame("Frame", nil, frame, "GlowBoxArrowTemplate")
	arrow:SetPoint("TOP", frame, "BOTTOM", 0, 4)

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetJustifyH("CENTER")
	frame.text:SetSize(width - 20, height - 20)
	frame.text:SetFontObject(GameFontHighlightLeft)
	frame.text:SetPoint("CENTER")
	frame.text:SetText(text)
	frame.text:SetSpacing(4)

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 6, 6)
	R.ReskinClose(close)
	
	return frame
end

-- local tutorial1 = CreateTutorialFrame(nil, GameMenuFrame, 220, 100, "點擊進入RayUI控制台.")
-- tutorial1:SetPoint("BOTTOM", RayUIConfigButton, "TOP", 0, 20)

-- local tutorial2 = CreateTutorialFrame(nil, UIParent, 150, 100, "右鍵點擊打開追蹤菜單, 中鍵點擊打開微型菜單.")
-- tutorial2:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 50)