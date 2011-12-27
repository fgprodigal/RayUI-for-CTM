-----------------------------------------------------
-- All starts here baby!

-- Credit Nightcracker
-----------------------------------------------------

-- including system

local addon, engine = ...
engine[1] = {} -- R, functions, constants
engine[2] = {} -- C, config
engine[3] = {} -- L, locale
engine[4] = {} -- DB

setmetatable(engine[3], {__index = function(_, key) return key end})
RayUI = engine 

--[[
	This should be at the top of every file inside of the RayUI AddOn:
	
	local R, C, L, DB = unpack(select(2, ...))

	This is how another addon imports the RayUI engine:
	
	local R, C, L, DB = unpack(RayUI)
]]