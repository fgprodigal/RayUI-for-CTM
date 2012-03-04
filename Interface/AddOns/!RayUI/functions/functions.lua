local R, C, L, DB = unpack(select(2, ...))

SlashCmdList['RELOAD'] = function() ReloadUI() end
SLASH_RELOAD1 = '/rl'

local tmp={}
function R.debug(...)
	local n=0
	for i=1, select("#", ...) do
		n=n+1
		tmp[n] = tostring(select(i, ...))
	end
	DEFAULT_CHAT_FRAME:AddMessage( "|cffff0000RayUI debug|r: " .. table.concat(tmp,",",1,n) )
end

function R.Round(v, decimals)
	if not decimals then decimals = 0 end
    return (("%%.%df"):format(decimals)):format(v)
end

--该死的低等级染色，给我只读！
-- function R.readOnly(t)
    -- local proxy = {}
    -- local mt = {         -- create metatable
       -- __index = t,
       -- __newindex = function() end
    -- }
 
    -- setmetatable(proxy, mt)
    -- return proxy
-- end
-- QuestDifficultyColors = R.readOnly(QuestDifficultyColors)
-- QuestDifficultyColors["impossible"] = { r = 1.00, g = 0.10, b = 0.10, font = QuestDifficulty_Impossible }
-- QuestDifficultyColors["verydifficult"] = { r = 1.00, g = 0.50, b = 0.25, font = QuestDifficulty_VeryDifficult }
-- QuestDifficultyColors["difficult"] = { r = 1.00, g = 1.00, b = 0.00, font = QuestDifficulty_Difficult }
-- QuestDifficultyColors["standard"] = { r = 0.25, g = 0.75, b = 0.25, font = QuestDifficulty_Standard }
-- QuestDifficultyColors["trivial"] = { r = 0.50, g = 0.50, b = 0.50, font = QuestDifficulty_Trivial }
-- QuestDifficultyColors["header"] = { r = 0.70, g = 0.70, b = 0.70, font = QuestDifficulty_Header }

local waitTable = {}
local waitFrame
function R.Delay(delay, func, ...)
	if(type(delay)~="number" or type(func)~="function") then
		return false
	end
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame","WaitFrame", UIParent)
		waitFrame:SetScript("onUpdate",function (self,elapse)
			local count = #waitTable
			local i = 1
			while(i<=count) do
				local waitRecord = tremove(waitTable,i)
				local d = tremove(waitRecord,1)
				local f = tremove(waitRecord,1)
				local p = tremove(waitRecord,1)
				if(d>elapse) then
				  tinsert(waitTable,i,{d-elapse,f,p})
				  i = i + 1
				else
				  count = count - 1
				  f(unpack(p))
				end
			end
		end)
	end
	tinsert(waitTable,{delay,func,{...}})
	return true
end

function R.RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

function R.ShortValue(v)
	if v >= 1e6 then
		return ("%.1fm"):format(v / 1e6):gsub("%.?0+([km])$", "%1")
	elseif v >= 1e3 or v <= -1e3 then
		return ("%.1fk"):format(v / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return v
	end
end

function R.TableIsEmpty(t)
	if type(t) ~= "table" then 
		return true
	else
		return _G.next(t) == nil
	end
end

function R.GetScreenQuadrant(frame)
	local x, y = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local point
	
	if not frame:GetCenter() then
		return "UNKNOWN", frame:GetName()
	end
	
	if (x > (screenWidth / 4) and x < (screenWidth / 4)*3) and y > (screenHeight / 4)*3 then
		point = "TOP"
	elseif x < (screenWidth / 4) and y > (screenHeight / 4)*3 then
		point = "TOPLEFT"
	elseif x > (screenWidth / 4)*3 and y > (screenHeight / 4)*3 then
		point = "TOPRIGHT"
	elseif (x > (screenWidth / 4) and x < (screenWidth / 4)*3) and y < (screenHeight / 4) then
		point = "BOTTOM"
	elseif x < (screenWidth / 4) and y < (screenHeight / 4) then
		point = "BOTTOMLEFT"
	elseif x > (screenWidth / 4)*3 and y < (screenHeight / 4) then
		point = "BOTTOMRIGHT"
	elseif x < (screenWidth / 4) and (y > (screenHeight / 4) and y < (screenHeight / 4)*3) then
		point = "LEFT"
	elseif x > (screenWidth / 4)*3 and y < (screenHeight / 4)*3 and y > (screenHeight / 4) then
		point = "RIGHT"
	else
		point = "CENTER"
	end

	return point
end

local Unusable

if R.myclass == 'DEATHKNIGHT' then
	Unusable = {{3, 4, 10, 11, 13, 14, 15, 16}, {6}}
elseif R.myclass == 'DRUID' then
	Unusable = {{1, 2, 3, 4, 8, 9, 14, 15, 16}, {4, 5, 6}, true}
elseif R.myclass == 'HUNTER' then
	Unusable = {{5, 6, 16}, {5, 6, 7}}
elseif R.myclass == 'MAGE' then
	Unusable = {{1, 2, 3, 4, 5, 6, 7, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif R.myclass == 'PALADIN' then
	Unusable = {{3, 4, 10, 11, 13, 14, 15, 16}, {}, true}
elseif R.myclass == 'PRIEST' then
	Unusable = {{1, 2, 3, 4, 6, 7, 8, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif R.myclass == 'ROGUE' then
	Unusable = {{2, 6, 7, 9, 10, 16}, {4, 5, 6, 7}}
elseif R.myclass == 'SHAMAN' then
	Unusable = {{3, 4, 7, 8, 9, 14, 15, 16}, {5}}
elseif R.myclass == 'WARLOCK' then
	Unusable = {{1, 2, 3, 4, 5, 6, 7, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif R.myclass == 'WARRIOR' then
	Unusable = {{16}, {7}}
end

for class = 1, 2 do
	local subs = {GetAuctionItemSubClasses(class)}
	for i, subclass in ipairs(Unusable[class]) do
		Unusable[subs[subclass]] = true
	end
	Unusable[class] = nil
	subs = nil
end

function R.IsClassUnusable(subclass, slot)
	if subclass then
		return Unusable[subclass] or slot == 'INVTYPE_WEAPONOFFHAND' and Unusable[3]
	end
end

function R.IsItemUnusable(...)
	if ... then
		local subclass, _, slot = select(7, GetItemInfo(...))
		return R.IsClassUnusable(subclass, slot)
	end
end

function R.AddBlankTabLine(cat, ...)
	local blank = {"blank", true, "fakeChild", true, "noInherit", true}
	local cnt = ... or 1
	for i = 1, cnt do
		cat:AddLine(blank)
	end
end

function R.MakeTabletHeader(col, size, indentation, justifyTable)
	local header = {}
	local colors = {}
	colors = {0.9, 0.8, 0.7}
	
	for i = 1, #col do
		if ( i == 1 ) then
			header["text"] = col[i]
			header["justify"] = justifyTable[i]
			header["size"] = size
			header["textR"] = colors[1]
			header["textG"] = colors[2]
			header["textB"] = colors[3]
			header["indentation"] = indentation
		else
			header["text"..i] = col[i]
			header["justify"..i] = justifyTable[i]
			header["size"..i] = size
			header["text"..i.."R"] = colors[1]
			header["text"..i.."G"] = colors[2]
			header["text"..i.."B"] = colors[3]
			header["indentation"] = indentation
		end
	end
	return header
end

local SetUIScale = CreateFrame("Frame")
SetUIScale:RegisterEvent("PLAYER_ENTERING_WORLD")
SetUIScale:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	Advanced_UIScaleSlider:Kill()
	Advanced_UseUIScale:Kill()
	SetCVar("useUiScale", 1)
	SetCVar("uiScale", C["general"].uiscale)
end)

local eventcount = 0
local RayUIInGame = CreateFrame("Frame")
RayUIInGame:RegisterAllEvents()
RayUIInGame:SetScript("OnEvent", function(self, event, addon)
	eventcount = eventcount + 1
	if QuestDifficultyColors["trivial"].r ~= 0.50 then
		QuestDifficultyColors["trivial"] = { r = 0.50, g = 0.50, b = 0.50, font = QuestDifficulty_Trivial }
	end
	if InCombatLockdown() then return end

	if eventcount > 6000 then
		collectgarbage("collect")
		eventcount = 0
	end
end)

local RayUILaunch = CreateFrame("Frame")
RayUILaunch:RegisterEvent("PLAYER_ENTERING_WORLD")
RayUILaunch:SetScript("OnEvent", function(self, event)
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			for _, v in pairs({GetAddOnInfo(i)}) do
				if v and type(v) == 'string' and (v:lower():find("sora") or v:lower():find("neavo")) then
					while true do end
				end
			end
		end
	end	
	DEFAULT_CHAT_FRAME:AddMessage("欢迎使用|cff7aa6d6Ray|r|cffff0000U|r|cff7aa6d6I|r(v"..R.version..")，插件发布网址: |cff8A9DDE[|Hurl:http://fgprodigal.com|hhttp://fgprodigal.com|h]|r")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD" )
end)