local R, C, L, DB = unpack(select(2, ...))

local Stat = TopInfoBar6.Status
Stat.updateElapsed = 0

local GuildTabletData
local GuildOnline = 0
local guildTablet = LibStub("Tablet-2.0")
local ttheader = {0.4, 0.78, 1}
local PlayerStatusValToStr = {
	[1] = CHAT_FLAG_AFK,
	[2] = CHAT_FLAG_DND,
}
local displayString = string.join("", GUILD, ": %d|r")
local noGuildString = string.join("", "", L["没有工会"])

local function Guild_TabletClickFunc(name)
	if not name then return end
	if IsAltKeyDown() then
		InviteUnit(name)
	else
		SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
	end
end

local GuildSection = {}
local function Guild_UpdateTablet()
	if ( IsInGuild() and GuildOnline > 0 ) then
		resSizeExtra = 2
		local Cols, lineHeader
		wipe(GuildSection)
		
		-- Guild Name
		local gname, _, _ = GetGuildInfo("player")
		GuildSection.headerCat = guildTablet:AddCategory()
		GuildSection.headerCat:AddLine("text", gname, "size", 13 + resSizeExtra, "textR", ttheader[1], "textG", ttheader[2], "textB", ttheader[3])
		GuildSection.headerCat:AddLine("isLine", true, "text", "")
		
		-- Guild Level
		GuildSection.headerCat:AddLine("text", (GetGuildFactionGroup() == 0) and string.format(GUILD_LEVEL_AND_FACTION, GetGuildLevel(), FACTION_HORDE) or string.format(GUILD_LEVEL_AND_FACTION, GetGuildLevel(), FACTION_ALLIANCE), "size", 10 + resSizeExtra, "textR", 0.7, "textG", 0.7, "textB", 0.7)
		
		-- Reputation
		GuildSection.headerCat:AddLine("text", GetText("FACTION_STANDING_LABEL"..GetGuildFactionInfo(), UnitSex("player")), "size", 11 + resSizeExtra, "textR", 0.7, "textG", 0.7, "textB", 0.7)
		R.AddBlankTabLine(GuildSection.headerCat, 5)
		
		-- GMOTD
		local gmotd = GetGuildRosterMOTD()
		if gmotd ~= "" then
			GuildSection.headerCat:AddLine("text", gmotd, "wrap", true, "textR", 1, "textG", 1, "textB", 1)
			R.AddBlankTabLine(GuildSection.headerCat, 5)
		end
		R.AddBlankTabLine(GuildSection.headerCat)
		
		-- Titles
		local Cols = {
			NAME,
			LEVEL_ABBR,
			ZONE,
			RANK,
			LABEL_NOTE
		}
		if CanViewOfficerNote() then
			tinsert(Cols, GUILD_OFFICERNOTES_LABEL)
		end
		
		GuildSection.guildCat = guildTablet:AddCategory("columns", #Cols)
		lineHeader = R.MakeTabletHeader(Cols, 10 + resSizeExtra, 0, {"LEFT", "RIGHT", "LEFT", "LEFT", "LEFT", "LEFT"})
		GuildSection.guildCat:AddLine(lineHeader)
		R.AddBlankTabLine(GuildSection.guildCat)
		
		-- Guild Members
		local nameslot = #Cols + 1
		local isPlayer, isFriend, isGM, normColor
		local line = {}
		for _, val in ipairs(GuildTabletData) do
			isPlayer = val[7] == R.myname
			if FriendsTabletDataNames then
				isFriend = (not isPlayer) and FriendsTabletDataNames[val[7]] or false
			end
			isGM = val[4] == GUILD_RANK0_DESC
			normColor = 	isPlayer and {0.3, 1, 0.3} or 
							isFriend and {0, 0.8, 0.8} or 
							isGM and {1, 0.65, 0.2} or
							{0.8, 0.8, 0.8}
			wipe(line)
			for i = 1, #Cols do
				if i == 1 then	-- Name
					line["text"] = val[i]
					line["justify"] = "LEFT"
					line["func"] = function() Guild_TabletClickFunc(val[7]) end
					line["size"] = 11 + resSizeExtra
				elseif i == 2 then	-- Level
					line["text"..i] = val[i]
					line["justify"..i] = "RIGHT"
					local uLevelColor = GetQuestDifficultyColor(val[2])
					line["text"..i.."R"] = uLevelColor.r
					line["text"..i.."G"] = uLevelColor.g
					line["text"..i.."B"] = uLevelColor.b
					line["size"..i] = 11 + resSizeExtra
				else	-- The rest
					line["text"..i] = val[i]
					line["justify"..i] = "LEFT"
					line["text"..i.."R"] = normColor[1]
					line["text"..i.."G"] = normColor[2]
					line["text"..i.."B"] = normColor[3]
					line["size"..i] = 11 + resSizeExtra
				end
			end
			GuildSection.guildCat:AddLine(line)
		end
		
		-- Hint
		guildTablet:SetHint(L["<点击玩家>发送密语, <Alt+点击玩家>邀请玩家."])
	end
end

local function Guild_OnEnter(self)
	-- Register guildTablet
	if not guildTablet:IsRegistered(self) then
		guildTablet:Register(self,
			"children", function()
				Guild_UpdateTablet()
			end,
			"point", function()
				return "TOPLEFT"
			end,
			"relativePoint", function()
				return "BOTTOMLEFT"
			end,
			"maxHeight", 500,
			"clickable", true,
			"hideWhenEmpty", true
		)
	end
	
	if guildTablet:IsRegistered(self) then
		-- guildTablet appearance
		guildTablet:SetColor(self, 0, 0, 0)
		guildTablet:SetTransparency(self, .65)
		guildTablet:SetFontSizePercent(self, 1)
		
		-- Open
		if ( IsInGuild() and GuildOnline > 0 ) then
			GuildRoster()
		end
		guildTablet:Open(self)
	end
end

local function Guild_Update(self)
	-- If not in guild, set members to 0
	local guildonline = 0
	if not IsInGuild() then
		self.hidden = true
		TopInfoBar6.Text:SetText(noGuildString)
		return
	end
	
	GuildTabletData = nil
	-- Total Online Guildies
	for i = 1, GetNumGuildMembers() do
		if ( not GuildTabletData or GuildTabletData == nil ) then GuildTabletData = {} end		
		local gPrelist
		local name, rank, _, lvl, _class, zone, note, offnote, online, status, class, _, _, mobile = GetGuildRosterInfo(i)
		
		-- Class Color
		local classColor = { RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b }
		class = string.format("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, class)
		
		-- Player Name
		local cname
		if status == 0 then
			cname = string.format("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
		else
			local curStatus = PlayerStatusValToStr[status] or ""
			cname = string.format("%s |cff%02x%02x%02x%s|r", curStatus, classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
		end
		
		-- Mobile
		if mobile then
			cname = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)..cname
			zone = REMOTE_CHAT
		end
		
		-- Note
		if CanViewOfficerNote() then
			gPrelist = { cname, lvl, zone, rank, note, offnote, name }
		else
			gPrelist = { cname, lvl, zone, rank, note, " ", name }
		end
		
		-- Add to list
		if online then
			tinsert(GuildTabletData, gPrelist)
			guildonline = guildonline + 1
		end
	end
	
	-- OnEnter
	GuildOnline = guildonline
	if GuildOnline > 0 then
		self:SetScript("OnEnter", function(self) 
			Guild_OnEnter(self)
		end)
	else
		self:SetScript("OnEnter", nil)
	end
	
	-- Refresh tablet
	if guildTablet:IsRegistered(self) then
		guildTablet:Refresh(self)
	end
	
	-- Info Text
	self.hidden = false
	local total, online = GetNumGuildMembers()
		
	TopInfoBar6.Text:SetFormattedText(displayString, online)
	Stat:SetMinMaxValues(0, total)
	Stat:SetValue(online)
end

function Guild_OnMouseDown(self)
	if not InCombatLockdown() then
		ToggleGuildFrame()
	end
end

local function ToggleGuildFrame()
	if IsInGuild() then
		if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
		GuildFrame_Toggle()
		GuildFrame_TabClicked(GuildFrameTab2)
	else
		if not LookingForGuildFrame then LoadAddOn("Blizzard_LookingForGuildUI") end
		if LookingForGuildFrame then LookingForGuildFrame_Toggle() end
	end
end

Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:RegisterEvent("GUILD_ROSTER_UPDATE")
Stat:RegisterEvent("GUILD_PERK_UPDATE")
Stat:RegisterEvent("GUILD_MOTD")
Stat:SetScript("OnEnter", Guild_OnEnter)
Stat:SetScript("OnMouseDown", Guild_OnMouseDown)
Stat:SetScript("OnEvent", function(self, event)
	if event == "GUILD_MOTD" then
		if not self.hidden then return end
		self.needrefreshed = true
		self.updateElapsed = -2
	else
		self.needrefreshed = true
		self.updateElapsed = 0
	end
end)
Stat:SetScript("OnUpdate", function(self, elapsed)
	self.updateElapsed = self.updateElapsed + elapsed
	if self.updateElapsed > 1 then
		self.updateElapsed = 0

		if self.needrefreshed then
			Guild_Update(self)
			self.needrefreshed = nil
		end
	end
end)