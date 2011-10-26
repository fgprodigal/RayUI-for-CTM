local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("RayWatcherConfig", "zhCN", true)
if not L then return end

L["版本"] = true
L["改变参数需重载应用设置"] = true
L["解锁锚点"] = true
L["选项"] = true
L["选择一个分组"] = true
L["模式"] = true
	L["图标"] = true
	L["计时条"] = true
L["增长方向"] = true
	L["上"] = true
	L["下"] = true
	L["左"] = true
	L["右"] = true
L["图标大小"] = true
L["计时条长度"] = true
L["图标位置"] = true
L["已有增益监视"] = true
L["已有减益监视"] = true
L["已有冷却监视"] = true
L["已有物品冷却监视"] = true
L["ID"] = true
L["类型"] = true
L["增益"] = true
L["减益"] = true
L["冷却"] = true
L["物品冷却"] = true
L["监视对象"] = true
	L["监视对象，如player,target....只能填一个"] = true
L["施法者"] = true
	L["监视对象，如player,target,all....只能填一个，监视全部填all"] = true
L["添加"] = true
	L["添加到当前分组"] = true
L["删除"] = true
	L["从当前分组删除"] = true