  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  local MediaPath = "Interface\\Addons\\m_Buffs\\media\\"
  cfg.auratex = MediaPath.."iconborder" 
  cfg.font = MediaPath.."ROADWAY.ttf"
  cfg.backdrop_texture = MediaPath.."backdrop"
  cfg.backdrop_edge_texture = MediaPath.."backdrop_edge"
  
  -----------------------------
  -- CONFIG
  -----------------------------
  cfg.iconsize = 35 									-- Buffs and debuffs size
  cfg.timefontsize = 14									-- Time font size
  cfg.countfontsize = 15								-- Count font size
  cfg.spacing = 4										-- Spacing between icons
  cfg.timeYoffset = -8									-- Verticall offset value for time text field
  cfg.BUFFpos = {"TOPRIGHT","UIParent", -20, -25} 		-- Buffs position
  cfg.DEBUFFpos = {"TOPRIGHT", "UIParent", -20, -120}	-- Debuffs position
  -- cfg.BUFFpos = {"TOPRIGHT", Minimap, "TOPLEFT", -8, 2} 		-- Buffs position
  -- cfg.DEBUFFpos = {"TOPRIGHT", Minimap, "TOPLEFT", -8, -93}	-- Debuffs position

  -- HANDOVER
  ns.cfg = cfg
