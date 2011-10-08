local R, C, L, DB = unpack(select(2, ...))

----------------------------------------------------------------------------------
-- 屏蔽关键字
----------------------------------------------------------------------------------
local SpamList = {
	"蛋糕",
}

----------------------------------------------------------------------------------
--	Talent Spec Spam Filter 防止切天賦時洗頻
--	By Azmenen of Kargath
----------------------------------------------------------------------------------

local TalentSpecSpam = {};

local minTime = 1; -- the minimum time to allow for results to be collected.   NOTE: minTime seconds after TalentSpecSpam.time, the tables will be printed and then emptied

TalentSpecSpam.time = 8;

TalentSpecSpam.patterns = {};

TalentSpecSpam.patternFragments = {};

TalentSpecSpam.unlearned = {};
TalentSpecSpam.learned = {};
TalentSpecSpam.learnedspell = {};
TalentSpecSpam.alreadyseen = {};

TalentSpecSpam.globalPatterns = {
	[1] = _G["ERR_SPELL_UNLEARNED_S"], -- You have unlearned %s.
	[2] = _G["ERR_LEARN_ABILITY_S"], -- You have learned a new ability : %s.
	[3] = _G["ERR_LEARN_SPELL_S"], -- You have learned a new spell : %s.
};

TalentSpecSpam.link = {
	[1] = TalentSpecSpam.unlearned,
	[2] = TalentSpecSpam.learned,
	[3] = TalentSpecSpam.learnedspell,
};

function TalentSpecSpam.addBetterStuff(in_string)
	local temp = string.gsub(in_string, "%%1$s", "(%%S+)");
	toReturn = string.gsub(temp, "%%s", "(%%S+)");
	
	return toReturn;
end

function TalentSpecSpam.sanitizePeriods(in_string)
	local toReturn = "";
	for i=1, in_string:len() do
		if (in_string:sub(i,i) == ".") then
			toReturn = toReturn .. "%.";
		else
			toReturn = toReturn .. in_string:sub(i,i);
		end
	end
	return toReturn;
end

function TalentSpecSpam.makeFragments(in_string)
	local tbl = {
		[1] = "",
		[2] = "",
	};
	
	local value = "";
	local mod_string = TalentSpecSpam.sanitizePeriods(in_string);
	for i=1, mod_string:len() do
		if (mod_string:sub(i,i+1) == "%s") then
			tbl[1] = value;
			tbl[2] = mod_string:sub(i+2);
			return tbl;
		elseif (mod_string:sub(i,i+3) == "%1$s") then
			tbl[1] = value;
			tbl[2] = mod_string:sub(i+4);
			return tbl;
		else
			value = value .. mod_string:sub(i,i);
		end
	end
	
	tbl[1] = mod_string;
	return tbl;
end

for index, globalString in ipairs (TalentSpecSpam.globalPatterns) do
	TalentSpecSpam.patterns[index] = TalentSpecSpam.addBetterStuff(globalString);
	TalentSpecSpam.patternFragments[index] = TalentSpecSpam.makeFragments(globalString);
end

function TalentSpecSpam.TalentSpecSpamFilter(self, event, msg)
	for i=1, #(TalentSpecSpam.patterns) do
		if (msg:find(TalentSpecSpam.patterns[i])) then
			local tempString, finalString = "", "";
			
			if (TalentSpecSpam.patternFragments[i][1] ~= "") then
				tempString = string.gsub(msg, TalentSpecSpam.patternFragments[i][1], "");
			else tempString = msg;
			end
			
			if (TalentSpecSpam.patternFragments[i][2] ~= "") then
				finalString = string.gsub(tempString, TalentSpecSpam.patternFragments[i][2], "");
			else finalString = tempString;
			end
			
			if (TalentSpecSpam.alreadyseen[i] == nil) then TalentSpecSpam.alreadyseen[i] = {}; end
			if (TalentSpecSpam.alreadyseen[i][finalString] == nil) then
				TalentSpecSpam.alreadyseen[i][finalString] = true;
				
				local tempTable = TalentSpecSpam.link[i];
				tempTable[#(tempTable) + 1] = finalString;
				
				TalentSpecSpam.time = GetTime();
				TalentSpecSpam.frame:SetScript("OnUpdate", TalentSpecSpam.summarize);
			end
			
			return true;
		end
	end
	
	return false;
end

function TalentSpecSpam.print(intable)
	local toReturn = "";
	for k,name in pairs(intable) do
		toReturn = toReturn .. name .. ", ";
	end
	
	return toReturn;
end

function TalentSpecSpam.removeLastComma(instring)
	local toReturn = "";
	
	for i=instring:len(), 1, -1 do
		if (instring:sub(i,i) == ",") then
			return instring:sub(1,i-1);
		end
	end
	
	return toReturn;
end

function TalentSpecSpam.summarize()
	if ((GetTime() - TalentSpecSpam.time) > minTime) then
		TalentSpecSpam.frame:SetScript("OnUpdate", nil);
		
		if (#(TalentSpecSpam.unlearned) > 0) then
			DEFAULT_CHAT_FRAME:AddMessage(string.gsub(TalentSpecSpam.globalPatterns[1], "%%s", TalentSpecSpam.removeLastComma(TalentSpecSpam.print(TalentSpecSpam.unlearned))), 1, 1, 0);
		end
		
		if ((#(TalentSpecSpam.learned) > 0) or (#(TalentSpecSpam.learnedspell) > 0)) then
			DEFAULT_CHAT_FRAME:AddMessage(string.gsub(TalentSpecSpam.globalPatterns[2], "%%s", TalentSpecSpam.removeLastComma(TalentSpecSpam.print(TalentSpecSpam.learned) .. TalentSpecSpam.print(TalentSpecSpam.learnedspell))), 1, 1, 0);
		end
		
		for k, tbl in ipairs (TalentSpecSpam.link) do wipe(tbl); end
		wipe(TalentSpecSpam.alreadyseen);
	end
end

TalentSpecSpam.frame = CreateFrame("Frame", "TalentSpecSpamFilterFrame", UIParent);
TalentSpecSpam.frame:SetScript("OnUpdate", TalentSpecSpam.summarize);

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", TalentSpecSpam.TalentSpecSpamFilter);

----------------------------------------------------------------------------------
-- 隐藏切天赋刷屏
----------------------------------------------------------------------------------
-- local spellfilters = {
	-- "^" .. gsub(ERR_LEARN_SPELL_S, "%%s", ".*") .. "$",
	-- "^" .. gsub(ERR_LEARN_ABILITY_S, "%%s", ".*") .. "$",
	-- "^" .. gsub(ERR_SPELL_UNLEARNED_S, "%%s", ".*") .. "$",
	-- "^" .. gsub(ERR_PET_LEARN_SPELL_S, "%%s", ".*") .. "$",
	-- "^" .. gsub(ERR_PET_LEARN_ABILITY_S, "%%s", ".*") .. "$",
	-- "^" .. gsub(ERR_PET_SPELL_UNLEARNED_S, "%%s", ".*") .. "$",
-- }

-- local function SPELL_FILTER(self, event, arg1)
	-- for _, v in pairs(spellfilters) do
		-- if strfind(arg1, v) and UnitLevel("player") == MAX_PLAYER_LEVEL then
			-- return true
		-- end
	-- end
-- end
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SPELL_FILTER)

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