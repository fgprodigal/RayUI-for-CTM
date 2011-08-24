local R, C, DB = unpack(select(2, ...))

local autohide = CreateFrame("Frame")

local rabs = {}

if rABS_StanceBar and C["actionbar"].stancebarfade then table.insert(rabs, "rABS_StanceBar") end
if rABS_PetBar and C["actionbar"].petbarfade then table.insert(rabs, "rABS_PetBar") end
if rABS_MainMenuBar and C["actionbar"].bar1fade then table.insert(rabs, "rABS_MainMenuBar") end
if rABS_MultiBarBottomLeft and C["actionbar"].bar2fade then table.insert(rabs, "rABS_MultiBarBottomLeft") end
if rABS_MultiBarBottomRight and C["actionbar"].bar3fade then table.insert(rabs, "rABS_MultiBarBottomRight") end
if rABS_MultiBarRight and C["actionbar"].bar4fade then table.insert(rabs, "rABS_MultiBarRight") end
if rABS_MultiBarLeft and C["actionbar"].bar5fade then table.insert(rabs, "rABS_MultiBarLeft") end

if #rabs == 0 then return end

autohide:RegisterEvent("PLAYER_REGEN_ENABLED")
autohide:RegisterEvent("PLAYER_REGEN_DISABLED")
autohide:RegisterEvent("PLAYER_TARGET_CHANGED")
autohide:RegisterEvent("PLAYER_ENTERING_WORLD")
autohide:RegisterEvent("UNIT_ENTERED_VEHICLE")
autohide:RegisterEvent("UNIT_EXITED_VEHICLE")

autohide:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" and not UnitInVehicle("player") and not InCombatLockdown() then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		for _, v in ipairs(rabs) do 
			if _G[v]:GetAlpha()>0 then
				local fadeInfo = {};
				fadeInfo.mode = "OUT";
				fadeInfo.timeToFade = 0.5;
				fadeInfo.finishedFunc = function() _G[v]:Hide() end
				fadeInfo.startAlpha = _G[v]:GetAlpha()
				fadeInfo.endAlpha = 0
				UIFrameFade(_G[v], fadeInfo)
			end 
		end
	elseif event == "PLAYER_REGEN_ENABLED" and not UnitInVehicle("player") then
		if not UnitExists("target") or UnitIsDead("target") then
			for _, v in ipairs(rabs) do 
				if _G[v]:GetAlpha()>0 then
					local fadeInfo = {};
					fadeInfo.mode = "OUT";
					fadeInfo.timeToFade = 0.5;
					fadeInfo.finishedFunc = function() _G[v]:Hide() end
					fadeInfo.startAlpha = _G[v]:GetAlpha()
					fadeInfo.endAlpha = 0
					UIFrameFade(_G[v], fadeInfo)
				end
			end
		end
	elseif event == "PLAYER_REGEN_DISABLED" or event == "UNIT_ENTERED_VEHICLE" then
		for _, v in ipairs(rabs) do if _G[v]:GetAlpha()<1 then _G[v]:Show() UIFrameFadeIn(_G[v], 0.5, _G[v]:GetAlpha(), 1) end end
	elseif (event == "PLAYER_TARGET_CHANGED" and not InCombatLockdown() and not UnitInVehicle("player")) or  event == "UNIT_EXITED_VEHICLE" then
		if UnitExists("target") then
			for _, v in ipairs(rabs) do if _G[v]:GetAlpha()<1 then _G[v]:Show() UIFrameFadeIn(_G[v], 0.5, _G[v]:GetAlpha(), 1) end end
		else
			for _, v in ipairs(rabs) do 
				if _G[v]:GetAlpha()>0 then
					local fadeInfo = {};
					fadeInfo.mode = "OUT";
					fadeInfo.timeToFade = 0.5;
					fadeInfo.finishedFunc = function() _G[v]:Hide() end
					fadeInfo.startAlpha = _G[v]:GetAlpha()
					fadeInfo.endAlpha = 0
					UIFrameFade(_G[v], fadeInfo)
				end 
			end
		end
	end
end)