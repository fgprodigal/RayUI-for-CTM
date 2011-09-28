local R, C, L, DB = unpack(select(2, ...))

----------------------------------------------------------------------------------
-- 屏蔽关键字
----------------------------------------------------------------------------------
local SpamList = {
	"蛋糕",
}

----------------------------------------------------------------------------------
-- 隐藏切天赋刷屏
----------------------------------------------------------------------------------
local spellfilters = {
	"^" .. gsub(ERR_LEARN_SPELL_S, "%%s", ".*") .. "$",
	"^" .. gsub(ERR_LEARN_ABILITY_S, "%%s", ".*") .. "$",
	"^" .. gsub(ERR_SPELL_UNLEARNED_S, "%%s", ".*") .. "$",
	"^" .. gsub(ERR_PET_LEARN_SPELL_S, "%%s", ".*") .. "$",
	"^" .. gsub(ERR_PET_LEARN_ABILITY_S, "%%s", ".*") .. "$",
	"^" .. gsub(ERR_PET_SPELL_UNLEARNED_S, "%%s", ".*") .. "$",
}

local function SPELL_FILTER(self, event, arg1)
	for _, v in pairs(spellfilters) do
		if strfind(arg1, v) and UnitLevel("player") == MAX_PLAYER_LEVEL then
			return true
		end
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SPELL_FILTER)

----------------------------------------------------------------------------------
-- 交易频道过滤
----------------------------------------------------------------------------------
local function TRADE_FILTER(self, event, arg1, arg2)
	if (SpamList and SpamList[1]) then
		for i, SpamList in pairs(SpamList) do
			if arg2 == UnitName("player") then return end
			if (strfind(arg1, SpamList)) then
				return true
			end
		end
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", TRADE_FILTER)

----------------------------------------------------------------------------------
-- 重复信息
----------------------------------------------------------------------------------
local Cache = {}
local function REPEAT_FILTER(self, event, arg1, arg2)
	if arg2 == UnitName("player") then return end
	local data = {name = arg2, msg = arg1, time = GetTime()}
	for i, v in pairs(Cache) do
		if GetTime() - v.time > 20 then
			tremove(Cache, i)
		else		
			if v.msg == arg1 then return true end
			
			local count = 0
			if (strlen(arg1) > strlen(v.msg)) then
				bigs = arg1
				smalls = v.msg
			else
				bigs = v.msg
				smalls = arg1
			end
			for i = 1, strlen(smalls) do
				if strfind(bigs, strsub(smalls, i, i + 1), 1, true) then
					count = count + 1
				end
			end
			if count / strlen(bigs) * 100 > 90 then
				return true
			end
		end
	end
	tinsert(Cache, data)
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", REPEAT_FILTER)