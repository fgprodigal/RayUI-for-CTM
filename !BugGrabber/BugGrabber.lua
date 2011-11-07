--
-- $Id: BugGrabber.lua 164 2010-11-27 01:23:31Z rabbit $
--
-- The BugSack and BugGrabber team is:
-- Current Developer: Rabbit
-- Past Developers: Rowne, Ramble, industrial, Fritti, kergoth, ckknight
-- Testers: Ramble, Sariash
--
--[[

BugGrabber, World of Warcraft addon that catches errors and formats them with a debug stack.
Copyright (C) 2008 The BugGrabber Team

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

]]

-----------------------------------------------------------------------
-- Global config variables

MAX_BUGGRABBER_ERRORS = 1000

-- If we get more errors than this per second, we stop all capturing until the
-- user tells us to continue.
BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE = 20
BUGGRABBER_TIME_TO_RESUME = 60
BUGGRABBER_SUPPRESS_THROTTLE_CHAT = nil

-----------------------------------------------------------------------
-- Localization
local L = {
	NO_DISPLAY_1 = "|cffff4411You seem to be running !BugGrabber with no display addon to go along with it. Although !BugGrabber provides a slash command for accessing in-game errors, a display addon can help you manage these errors in a more convenient way.|r",
	NO_DISPLAY_2 = "|cffff4411The standard !BugGrabber display is called |r|cff44ff44BugSack|r|cffff4411, and can probably be found on the same site where you found !BugGrabber.|r",
	NO_DISPLAY_STOP = "|cffff4411If you don't want to be reminded about this again, please run |cff44ff44/stopnag|r|cffff4411.|r",
	STOP_NAG = "|cffff4411!BugGrabber will not nag about missing |r|cff44ff44BugSack|r|cffff4411 again until next patch.|r",
	CMD_CREATED = "An error has been detected, use /buggrabber to print it.",
	USAGE = "Usage: /buggrabber <1-%d>.",
	ERROR_INDEX = "The provided index must be a number.",
	ERROR_UNKNOWN_INDEX = "The index %d does not exist in the load error table.",
	STARTUP_ERRORS = "There were %d startup errors:",
	STARTUP_ERRORS_MANY = "There were %d startup errors, please use /buggrabber <number> to print them.",
	UNIQUE_CAPTURE = "BugGrabber captured a unique error:\n%s\n---",
	ADDON_CALL_PROTECTED = "[%s] AddOn '%s' tried to call the protected function '%s'.",
	ADDON_CALL_PROTECTED_MATCH = "^%[(.*)%] (AddOn '.*' tried to call the protected function '.*'.)$",
	ADDON_DISABLED = "|cffffff7fBugGrabber|r and |cffffff7f%s|r cannot coexist together. |cffffff7f%s|r has been disabled because of this. If you want to, you may exit out, disable |cffffff7fBugGrabber|r and reenable |cffffff7f%s|r.",
	BUGGRABBER_STOPPED = "|cffffff7fBugGrabber|r has stopped capturing errors, since it has captured more than %d errors per second. Capturing will resume in %d seconds.",
	BUGGRABBER_RESUMING = "|cffffff7fBugGrabber|r is capturing errors again.",
}
-----------------------------------------------------------------------

local _, addon = ...

local frame = CreateFrame("Frame")

local real_seterrorhandler = seterrorhandler

-- Fetched from X-BugGrabber-Display in the TOC of a display addon.
-- Should implement :FormatError(errorTable).
local displayObjectName = nil

local totalElapsed = 0
local errorsSinceLastReset = 0
local paused = nil
local looping = false

local stateErrorDatabase = {}
local slashCmdCreated = nil
local slashCmdErrorList = {}

local isBugGrabbedRegistered = false
local callbacks = nil
local function setupCallbacks()
	if not callbacks and LibStub and LibStub("CallbackHandler-1.0", true) then
		callbacks = LibStub("CallbackHandler-1.0"):New(addon)
		function callbacks:OnUsed(target, eventname)
			if eventname == "BugGrabber_BugGrabbed" then isBugGrabbedRegistered = true end
		end
		function callbacks:OnUnused(target, eventname)
			if eventname == "BugGrabber_BugGrabbed" then isBugGrabbedRegistered = false end
		end
	end
end
local function triggerEvent(...)
	if not callbacks then setupCallbacks() end
	if callbacks then callbacks:Fire(...) end
end

local function slashHandler(index)
	if not index or tostring(index) == "" then
		print(L.USAGE:format(#slashCmdErrorList))
		return
	end
	if not tonumber(index) then
		print(L.ERROR_INDEX)
		return
	end
	index = tonumber(index)
	if not slashCmdErrorList[index] then
		print(L.ERROR_UNKNOWN_INDEX:format(index))
		return
	end
	local err = slashCmdErrorList[index]
	if type(err) ~= "table" or (type(err.message) ~= "string" and type(err.message) ~= "table") then return end
	local found = nil
	if displayObjectName and _G[displayObjectName] then
		local display = _G[displayObjectName]
		if type(display) == "table" and type(display.FormatError) == "function" then
			found = true
			print(tostring(index) .. ". " .. display:FormatError(err))
		end
	end
	if not found then
		local m = err.message
		if type(m) == "table" then
			m = table.concat(m, "")
		end
		print(tostring(index) .. ". " .. m)
	end
end

local function createSlashCmd()
	if slashCmdCreated then return end
	local name = "BUGGRABBERCMD"
	local counter = 0
	repeat
		name = "BUGGRABBERCMD"..tostring(counter)
		counter = counter + 1
	until not _G.SlashCmdList[name] and not _G["SLASH_"..name.."1"]
	_G.SlashCmdList[name] = slashHandler
	_G["SLASH_"..name.."1"] = "/buggrabber"

	slashCmdCreated = true
	if not isBugGrabbedRegistered then
		print(L.CMD_CREATED)
	end
end

function addon:StoreError(errorObject)
	local db = self:GetDB()
	db[#db + 1] = errorObject
	-- Save only the last <limit> errors (otherwise the SV gets too big)
	if #db > BugGrabberDB.limit then
		table.remove(db, 1)
	end
end

local function saveError(message, errorType)
	-- Start with the date, time and session
	local oe = {}
	oe.message = message .. "\n  ---"
	oe.session = BugGrabberDB and BugGrabberDB.session or 0
	oe.time = date("%Y/%m/%d %H:%M:%S")
	oe.type = errorType
	oe.counter = 1

	-- WoW crashes when strings > 983 characters are stored in the
	-- SavedVariables file, so make sure we don't exceed that limit.
	if oe.message:len() > 980 then
		local m = oe.message
		oe.message = {}
		local maxChunks, chunks = 5, 0
		while m:len() > 980 and chunks <= maxChunks do
			local q
			q, m = m:sub(1, 980), m:sub(981)
			oe.message[#oe.message + 1] = q
			chunks = chunks + 1
		end
		if m:len() > 980 then m = m:sub(1, 980) end
		oe.message[#oe.message + 1] = m
	end

	-- Insert the error into the correct database if it's not there already.
	-- If it is, just increment the counter.
	local found = false
	local db = addon:GetDB()
	local oe_message = oe.message
	if type(oe_message) == "table" then
		oe_message = oe_message[1]
	end
	for i, err in next, db do
		local err_message = err.message
		if type(err_message) == "table" then
			err_message = err_message[1]
		end
		if err_message == oe_message and err.session == oe.session then
			-- This error already exists in the current session, just increment
			-- the counter on it.
			if type(err.counter) ~= "number" then
				err.counter = 1
			end
			err.counter = err.counter + 1

			oe = nil
			oe = err

			found = true
			break
		end
	end

	-- If the error was not found in the current session, append it to the
	-- database.
	if not found then
		addon:StoreError(oe)
	end

	-- Trigger event.
	if not looping then
		local e = "BugGrabber_" .. (errorType == "event" and "Event" or "Bug") .. "Grabbed" .. (found and "Again" or "")
		triggerEvent(e, oe)

		if not found then
			slashCmdErrorList[#slashCmdErrorList + 1] = oe
			createSlashCmd()
		end
	end
end

local function scan(o)
	local version, revision = nil, nil
	for k, v in pairs(o) do
		if type(k) == "string" then
			local low = k:lower()
			if not version and (low == "version" or low:find("version")) and (type(v) == "string" or type(v) == "number") then
				version = v
			elseif not revision and (low == "rev" or low:find("revision")) and (type(v) == "string" or type(v) == "number")  then
				revision = v
			end
		end
		if version and revision then break end
	end
	return version, revision
end

-- Error handler
local function grabError(err)
	if paused then return end
	err = tostring(err)

	-- Get the full backtrace
	local real =
		err:find("^.-([^\\]+\\)([^\\]-)(:%d+):(.*)$") or
		err:find("^%[string \".-([^\\]+\\)([^\\]-)\"%](:%d+):(.*)$") or
		err:find("^%[string (\".-\")%](:%d+):(.*)$") or err:find("^%[C%]:(.*)$")

	err = err .. "\n" .. debugstack(real and 4 or 3)
	local errorType = "error"

	-- Normalize the full paths into last directory component and filename.
	local errmsg = ""
	looping = false

	for trace in err:gmatch("(.-)\n") do
		local match, found, path, file, line, msg, _
		found = false

		-- First detect an endless loop so as to abort it below
		if trace:find("BugGrabber") then
			looping = true
		end

		-- "path\to\file-2.0.lua:linenum:message" -- library
		if not found then
			match, _, path, file, line, msg = trace:find("^.-([^\\]+\\)([^\\]-%-%d+%.%d+%.lua)(:%d+):(.*)$")
			local addonName = trace:match("^.-[A%.][d%.][d%.][Oo]ns\\([^\\]-)\\")
			if match then
				if LibStub then
					local major = file:gsub("%.lua$", "")
					local lib, minor = LibStub(major, true)
					path = major .. "-" .. (minor or "?")
					if addonName then
						file = " (" .. addonName .. ")"
					else
						file = ""
					end
				end
				found = true
			end
		end
		
		-- "Interface\AddOns\path\to\file.lua:linenum:message"
		if not found then
			match, _, path, file, line, msg = trace:find("^.-[A%.][d%.][d%.][Oo]ns\\(.*)([^\\]-)(:%d+):(.*)$")
			if match then
				found = true
				local addonName = path:gsub("\\.*$", "")
				local addonObject = _G[addonName]
				if not addonObject then
					addonObject = _G[addonName:match("^[^_]+_(.*)$")]
				end
				local version, revision = nil, nil
				if LibStub and LibStub(addonName, true) then
					local _, r = LibStub(addonName, true)
					version = r
				end
				if type(addonObject) == "table" then
					local v, r = scan(addonObject)
					if v then version = v end
					if r then revision = r end
				end
				local objectName = addonName:upper()
				if not version then version = _G[objectName .. "_VERSION"] end
				if not revision then revision = _G[objectName .. "_REVISION"] or _G[objectName .. "_REV"] end
				if not version then version = GetAddOnMetadata(addonName, "Version") end
				if not version and revision then version = revision
				elseif type(version) == "string" and revision and not version:find(revision) then
					version = version .. "." .. revision
				end
				if not version then version = GetAddOnMetadata(addonName, "X-Curse-Packaged-Version") end
				if version then
					path = addonName .. "-" .. version .. path:gsub("^[^\\]*", "")
				end
			end
		end
		
		-- "path\to\file.lua:linenum:message"
		if not found then
			match, _, path, file, line, msg = trace:find("^.-([^\\]+\\)([^\\])(:%d+):(.*)$")
			if match then
				found = true
			end
		end

		-- "[string \"path\\to\\file.lua:<foo>\":linenum:message"
		if not found then
			match, _, path, file, line, msg = trace:find("^%[string \".-([^\\]+\\)([^\\]-)\"%](:%d+):(.*)$")
			if match then
				found = true
			end
		end

		-- "[string \"FOO\":linenum:message"
		if not found then
			match, _, file, line, msg = trace:find("^%[string (\".-\")%](:%d+):(.*)$")
			if match then
				found = true
				path = "<string>:"
			end
		end

		-- "[C]:message"
		if not found then
			match, _, msg = trace:find("^%[C%]:(.*)$")
			if match then
				found = true
				path = "<in C code>"
				file = ""
				line = ""
			end
		end

		-- ADDON_ACTION_BLOCKED
		if not found then
			match, _, file, msg = trace:find(L.ADDON_CALL_PROTECTED_MATCH)
			if match then
				found = true
				path = "<event>"
				file = "ADDON_ACTION_BLOCKED"
				line = ""
				errorType = "event"
			end
		end

		-- Anything else
		if not found then
			path = trace--"<unknown>"
			file = ""
			line = ""
			msg = line
		end

		-- Add it to the formatted error
		errmsg = errmsg .. path .. file .. line .. ":" .. msg .. "\n"
	end

	errorsSinceLastReset = errorsSinceLastReset + 1

	local locals = debuglocals(real and 4 or 3)
	if locals then
		errmsg = errmsg .. "\nLocals:|r\n" .. locals
	end

	-- Store the error
	saveError(errmsg, errorType)
end

local function onUpdateFunc(self, elapsed)
	totalElapsed = totalElapsed + elapsed
	if totalElapsed > 1 then
		if not paused then
			-- Seems like we're getting more errors/sec than we want.
			if errorsSinceLastReset > BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE then
				addon:Pause()
			end
			errorsSinceLastReset = 0
			totalElapsed = 0
		elseif totalElapsed > BUGGRABBER_TIME_TO_RESUME and paused then
			addon:Resume()
		end
	end
end

function addon:Reset()
	stateErrorDatabase = {}
	BugGrabberDB.errors = {}
end

-- Determine the proper DB and return it
function addon:GetDB()
	return BugGrabberDB.save and BugGrabberDB.errors or stateErrorDatabase
end

function addon:GetSessionId()
	return BugGrabberDB.session
end

-- Simple setters/getters for settings, meant to be accessed by BugSack
function addon:GetSave()
	return BugGrabberDB.save
end

function addon:ToggleSave()
	BugGrabberDB.save = not BugGrabberDB.save
	if BugGrabberDB.save then
		BugGrabberDB.errors = stateErrorDatabase
		stateErrorDatabase = {}
	else
		stateErrorDatabase = BugGrabberDB.errors
		BugGrabberDB.errors = {}
	end
end

function addon:GetLimit()
	return BugGrabberDB.limit
end

function addon:SetLimit(l)
	if type(l) ~= "number" or l < 10 or l > MAX_BUGGRABBER_ERRORS then
		return
	end

	BugGrabberDB.limit = math.floor(l)
	local db = self:GetDB()
	while #db > l do
		table.remove(db, 1)
	end
end

function addon:IsThrottling()
	return BugGrabberDB.throttle
end

function addon:UseThrottling(flag)
	BugGrabberDB.throttle = flag and true or false
	if flag and not frame:GetScript("OnUpdate") then
		frame:SetScript("OnUpdate", onUpdateFunc)
	elseif not flag then
		frame:SetScript("OnUpdate", nil)
	end
end

function addon:RegisterAddonActionEvents()
	frame:RegisterEvent("ADDON_ACTION_BLOCKED")
	frame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	triggerEvent("BugGrabber_AddonActionEventsRegistered")
end

function addon:UnregisterAddonActionEvents()
	frame:UnregisterEvent("ADDON_ACTION_BLOCKED")
	frame:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
	triggerEvent("BugGrabber_AddonActionEventsUnregistered")
end

function addon:IsPaused()
	return paused
end

function addon:Pause()
	if paused then return end

	if not BUGGRABBER_SUPPRESS_THROTTLE_CHAT then
		print(L.BUGGRABBER_STOPPED:format(BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE, BUGGRABBER_TIME_TO_RESUME))
	end
	self:UnregisterAddonActionEvents()
	paused = true
	triggerEvent("BugGrabber_CapturePaused")
end

function addon:Resume()
	if not paused then return end

	if not BUGGRABBER_SUPPRESS_THROTTLE_CHAT then
		print(L.BUGGRABBER_RESUMING)
	end
	self:RegisterAddonActionEvents()
	paused = nil
	triggerEvent("BugGrabber_CaptureResumed")
	totalElapsed = 0
end

local function createSwatter()
	-- Need this so Stubby will feed us errors instead of just
	-- dumping them to the chat frame.
	_G.Swatter = {
		IsEnabled = function() return true end,
		OnError = function(msg, frame, stack, etype, ...)
			grabError(tostring(msg) .. tostring(stack))
		end,
	}
end

local function addonLoaded(msg)
	if msg == "!BugGrabber" then
		real_seterrorhandler(grabError)

		-- Persist defaults and make sure we have sane SavedVariables
		if type(BugGrabberDB) ~= "table" then BugGrabberDB = {} end
		local sv = BugGrabberDB
		if type(sv.session) ~= "number" then sv.session = 0 end
		if type(sv.errors) ~= "table" then sv.errors = {} end
		if type(sv.limit) ~= "number" then sv.limit = 50 end
		if type(sv.save) ~= "boolean" then sv.save = true end
		if type(sv.throttle) ~= "boolean" then sv.throttle = true end

		-- From now on we can persist errors. Create a new session.
		sv.session = sv.session + 1

		-- Determine the correct database
		local db = addon:GetDB()
		-- Cut down on the nr of errors if it is over the limit
		while #db > sv.limit do
			table.remove(db, 1)
		end
		if sv.throttle then
			frame:SetScript("OnUpdate", onUpdateFunc)
		end

		-- load locales
		if type(addon.LoadTranslations) == "function" then
			local locale = GetLocale()
			if locale ~= "enUS" and locale ~= "enGB" then
				addon:LoadTranslations(locale, L)
			end
			addon.LoadTranslations = nil
		end

		local hasDisplay = nil
		for i = 1, GetNumAddOns() do
			local meta = GetAddOnMetadata(i, "X-BugGrabber-Display")
			local _, _, _, enabled = GetAddOnInfo(i)
			if meta and enabled then
				displayObjectName = meta
				hasDisplay = true
				break
			end
		end

		if not hasDisplay then
			local currentInterface = select(4, GetBuildInfo())
			if type(currentInterface) ~= "number" then currentInterface = 0 end
			if not sv.stopnag or sv.stopnag < currentInterface then
				print(L.NO_DISPLAY_1)
				print(L.NO_DISPLAY_2)
				print(L.NO_DISPLAY_STOP)
				_G.SlashCmdList.BugGrabberStopNag = function()
					print(L.STOP_NAG)
					sv.stopnag = currentInterface
				end
				_G.SLASH_BugGrabberStopNag1 = "/stopnag"
			end
		end
	elseif (msg == "!Swatter" or (type(SwatterData) == "table" and SwatterData.enabled)) and Swatter then
		print(L.ADDON_DISABLED:gsub("%%s", "Swatter"))
		DisableAddOn("!Swatter")
		SwatterData.enabled = nil
		real_seterrorhandler(grabError)
		SlashCmdList.SWATTER = nil
		SLASH_SWATTER1, SLASH_SWATTER2 = nil, nil
		for k, v in pairs(Swatter) do
			if type(v) == "table" and v.UnregisterEvent then
				v:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
				v:UnregisterEvent("ADDON_ACTION_BLOCKED")
				if v.UnregisterAllEvents then
					v:UnregisterAllEvents()
				end
			end
		end
	elseif msg == "Stubby" then
		createSwatter()
	end
end

-- Now register for our needed events
frame:SetScript("OnEvent", function(self, event, arg1, arg2)
	if event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
		grabError(L.ADDON_CALL_PROTECTED:format(event, arg1 or "?", arg2 or "?"))
	elseif event == "ADDON_LOADED" then
		addonLoaded(arg1 or "?")
		if not callbacks then setupCallbacks() end
	elseif event == "PLAYER_LOGIN" then
		real_seterrorhandler(grabError)
		if IsAddOnLoaded("Stubby") and type(_G.Swatter) ~= "table" then
			createSwatter()
		end
	end
end)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
addon:RegisterAddonActionEvents()

real_seterrorhandler(grabError)
function seterrorhandler() --[[ noop ]] end

_G.BugGrabber = addon

-- vim:set ts=4:
