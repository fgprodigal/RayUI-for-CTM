local R, L, P = unpack(select(2, ...)) --Inport: Engine, Locales, ProfileDB
local IF = R:GetModule("InfoBar")

local function LoadFriend()
	local infobar = _G["RayUITopInfoBar5"]
	local Status = infobar.Status
	infobar.Text:SetText(FRIEND)
	Status:SetValue(0)

	Status.updateElapsed = 0

	local friendsTablets = LibStub("Tablet-2.0")
	local FriendsTabletData = {}
	local FriendsTabletDataNames = {}
	local FriendsOnline = 0
	local displayString = string.join("", "%s: ", "", "%d|r")

	local ClassLookup = {}
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		ClassLookup[v] = k
	end
	for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		ClassLookup[v] = k
	end

	local function Friends_TabletClickFunc(name, iname, toonid)
		if not name then return end
		if IsAltKeyDown() then
			if not FriendsFrame_HasInvitePermission() then return end
			if toonid then
				BNInviteFriend(toonid)
			elseif iname == "" then
				InviteUnit(name)
			else
				InviteUnit(iname)
			end
		else
			SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
		end
	end

	local FriendsCat
	local function Friends_BuildTablet()
		local curFriendsOnline = 0
		wipe(FriendsTabletData)
		wipe(FriendsTabletDataNames)

		-- Standard Friends
		for i = 1, GetNumFriends() do
			local name, lvl, class, area, online, status, note = GetFriendInfo(i)
			if online then
				if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
				if ( not FriendsTabletDataNames or FriendsTabletDataNames == nil ) then FriendsTabletDataNames = {} end
				
				curFriendsOnline = curFriendsOnline + 1
				
				-- Class
				local classColor = RAID_CLASS_COLORS[ClassLookup[class]] and { RAID_CLASS_COLORS[ClassLookup[class]].r, RAID_CLASS_COLORS[ClassLookup[class]].g, RAID_CLASS_COLORS[ClassLookup[class]].b } or {1, 1, 1}
				class = string.format("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, class)
				
				-- Name
				local cname
				if ( status == "" and name ) then
					cname = string.format("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
				elseif ( name ) then
					cname = string.format("%s |cff%02x%02x%02x%s|r", status, classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
				end
				
				-- Add Friend to list
				local _, faction = UnitFactionGroup("player")
				tinsert(FriendsTabletData, { cname, lvl, area, faction, "WoW", name, note, "" })
				if name then
					FriendsTabletDataNames[name] = true
				end
			end
		end
		
		-- Battle.net Friends
		for t = 1, BNGetNumFriends() do
			local BNid, BNfirstname, BNlastname, toonname, toonid, client, online, lastonline, isafk, isdnd, broadcast, note = BNGetFriendInfo(t)
			
			-- WoW friends
			if ( online and client=="WoW" ) then
				if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
				if ( not FriendsTabletDataNames or FriendsTabletDataNames == nil ) then FriendsTabletDataNames = {} end
				
				local _,name, _, realmName, _, faction, race, class, guild, area, lvl = BNGetToonInfo(toonid)
				curFriendsOnline = curFriendsOnline + 1
				
				if (realmName == R.myrealm) then
					FriendsTabletDataNames[toonname] = true
				end

				-- Class
				local classColor = RAID_CLASS_COLORS[ClassLookup[class]] and { RAID_CLASS_COLORS[ClassLookup[class]].r, RAID_CLASS_COLORS[ClassLookup[class]].g, RAID_CLASS_COLORS[ClassLookup[class]].b } or {1, 1, 1}
				class = string.format("|cff%02x%02x%02x%s|r", classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, class)
				
				-- Name
				local cname
				local realname = string.format("%s %s", BNfirstname, BNlastname)
				if ( realmName == GetRealmName() ) then
					-- On My Realm
					cname = string.format(
						"|cff%02x%02x%02x%s|r |cffcccccc(|r|cff%02x%02x%02x%s|r|cffcccccc)|r",
						FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
						realname,
						classColor[1] * 255, classColor[2] * 255, classColor[3] * 255,
						name
					)
				else
					-- On Another Realm
					cname = string.format(
						"|cff%02x%02x%02x%s|r |cffcccccc(|r|cff%02x%02x%02x%s|r|cffcccccc-%s)|r",
						FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
						realname,
						classColor[1] * 255, classColor[2] * 255, classColor[3] * 255,
						name,
						realmName
					)
				end
				if (isafk and name ) then
					cname = string.format("%s %s", CHAT_FLAG_AFK, cname)
				elseif(isdnd and name) then
					cname = string.format("%s %s", CHAT_FLAG_DND, cname)
				end
				
				-- Faction
				if faction == 0 then
					faction = FACTION_HORDE
				else
					faction = FACTION_ALLIANCE
				end

				-- Add Friend to list
				tinsert(FriendsTabletData, { cname, lvl, area, faction, client, realname, note, name, ["toonid"] = toonid })
				
			-- SC2 friends
			elseif ( online and client=="S2" ) then
				if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
				
				local _,name, _, realmName, faction, _, race, class, guild, area, lvl, gametext = BNGetToonInfo(toonid)
				client = "SC2"
				curFriendsOnline = curFriendsOnline + 1
				
				-- Name
				local cname
				local realname = string.format("%s %s", BNfirstname, BNlastname)
				cname = string.format(
					"|cff%02x%02x%02x%s|r |cffcccccc(%s)|r",
					FRIENDS_BNET_NAME_COLOR.r * 255, FRIENDS_BNET_NAME_COLOR.g * 255, FRIENDS_BNET_NAME_COLOR.b * 255,
					realname,
					toonname
				)
				if ( isafk and toonname ) then
					cname = string.format("%s %s", CHAT_FLAG_AFK, cname)
				elseif ( isdnd and toonname ) then
					cname = string.format("%s %s", CHAT_FLAG_DND, cname)
				end
				
				-- Add Friend to list
				tinsert(FriendsTabletData, { cname, "", gametext, "", client, realname, note })
			end
		end
		
		-- OnEnter
		FriendsOnline = curFriendsOnline
	end

	local function Friends_UpdateTablet()
		if ( FriendsOnline > 0 and FriendsTabletData ) then
			resSizeExtra = 2
			local Cols, lineHeader
			Friends_BuildTablet()
			
			-- Title
			local Cols = {
				NAME,
				LEVEL_ABBR,
				ZONE,
				FACTION,
				GAME
			}
			FriendsCat = friendsTablets:AddCategory("columns", #Cols)
			lineHeader = R:MakeTabletHeader(Cols, 10 + resSizeExtra, 0, {"LEFT", "RIGHT", "LEFT", "LEFT", "LEFT"})
			FriendsCat:AddLine(lineHeader)
			R:AddBlankTabLine(FriendsCat)
			
			-- Friends
			for _, val in ipairs(FriendsTabletData) do
				local line = {}
				for i = 1, #Cols do
					if i == 1 then	-- Name
						line["text"] = val[i]
						line["justify"] = "LEFT"
						line["func"] = function() Friends_TabletClickFunc(val[6],val[8], val["toonid"]) end
						line["size"] = 11 + resSizeExtra
					elseif i == 2 then	-- Level
						line["text"..i] = val[2]
						line["justify"..i] = "RIGHT"
						local uLevelColor = GetQuestDifficultyColor(tonumber(val[2]) or 1)
						line["text"..i.."R"] = uLevelColor.r
						line["text"..i.."G"] = uLevelColor.g
						line["text"..i.."B"] = uLevelColor.b
						line["size"..i] = 11 + resSizeExtra
					else	-- The rest
						line["text"..i] = val[i]
						line["justify"..i] = "LEFT"
						line["text"..i.."R"] = 0.8
						line["text"..i.."G"] = 0.8
						line["text"..i.."B"] = 0.8
						line["size"..i] = 11 + resSizeExtra
					end
				end
				FriendsCat:AddLine(line)
			end
			
			-- Hint
			friendsTablets:SetHint(L["<点击玩家>发送密语, <Alt+点击玩家>邀请玩家."])
		end
		collectgarbage()
	end

	local function Friends_OnEnter(self)
		if InCombatLockdown() then return end

		-- Register friendsTablets
		if not friendsTablets:IsRegistered(self) then
			friendsTablets:Register(self,
				"children", function()
					Friends_BuildTablet()
					Friends_UpdateTablet()
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
		
		if friendsTablets:IsRegistered(self) then
			-- friendsTablets appearance
			friendsTablets:SetColor(self, 0, 0, 0)
			friendsTablets:SetTransparency(self, .65)
			friendsTablets:SetFontSizePercent(self, 1)
			
			-- Open
			if ( FriendsOnline > 0 ) then
				ShowFriends()
			end
			friendsTablets:Open(self)
		end
	end

	local function Friends_Update(self)
		local totalFriends, onlineFriends = GetNumFriends()
		local totalBN, numBNetOnline = BNGetNumFriends()
		infobar.Text:SetFormattedText(displayString, FRIENDS, onlineFriends + numBNetOnline)
		self:SetMinMaxValues(0, totalFriends + totalBN)
		self:SetValue(onlineFriends + numBNetOnline)
		
		if onlineFriends + numBNetOnline > 0 then
			self:SetScript("OnEnter", Friends_OnEnter)
		else
			self:SetScript("OnEnter", nil)
		end
	end

	function Friends_OnMouseDown(self)
		if not InCombatLockdown() then
			ToggleFriendsFrame()
		end
	end

	Status:SetScript("OnMouseDown", Friends_OnMouseDown)
	Status:SetScript("OnEnter", Friends_OnEnter)

	Status:RegisterEvent("FRIENDLIST_UPDATE")
	Status:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	Status:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	Status:RegisterEvent("PLAYER_ENTERING_WORLD")

	Status:SetScript("OnEvent", function(self, event)
		self.needrefreshed = true
		self.updateElapsed = 0
	end)
	Status:SetScript("OnUpdate", function(self, elapsed)
		self.updateElapsed = self.updateElapsed + elapsed
		if self.updateElapsed > 1 then
			self.updateElapsed = 0

			if self.needrefreshed then
				Friends_Update(self)
				self.needrefreshed = nil
			end
		end
	end)
	Friends_OnEnter(Status)
end

IF:RegisterInfoText("Friend", LoadFriend)