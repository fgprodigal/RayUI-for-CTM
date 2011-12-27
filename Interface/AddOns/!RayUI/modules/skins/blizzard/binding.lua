local R, C, L, DB = unpack(select(2, ...))

local function LoadSkin()
	R.SetBD(KeyBindingFrame, 2, 0, -38, 10)
	KeyBindingFrame:DisableDrawLayer("BACKGROUND")
	KeyBindingFrameOutputText:SetDrawLayer("OVERLAY")
	KeyBindingFrameHeader:SetTexture("")
	R.Reskin(KeyBindingFrameDefaultButton)
	R.Reskin(KeyBindingFrameUnbindButton)
	R.Reskin(KeyBindingFrameOkayButton)
	R.Reskin(KeyBindingFrameCancelButton)
	KeyBindingFrameOkayButton:ClearAllPoints()
	KeyBindingFrameOkayButton:SetPoint("RIGHT", KeyBindingFrameCancelButton, "LEFT", -1, 0)
	KeyBindingFrameUnbindButton:ClearAllPoints()
	KeyBindingFrameUnbindButton:SetPoint("RIGHT", KeyBindingFrameOkayButton, "LEFT", -1, 0)

	for i = 1, KEY_BINDINGS_DISPLAYED do
		local button1 = _G["KeyBindingFrameBinding"..i.."Key1Button"]
		local button2 = _G["KeyBindingFrameBinding"..i.."Key2Button"]

		button2:SetPoint("LEFT", button1, "RIGHT", 1, 0)
		R.Reskin(button1)
		R.Reskin(button2)
	end

	R.ReskinScroll(KeyBindingFrameScrollFrameScrollBar)
	R.ReskinCheck(KeyBindingFrameCharacterButton)
end

R.SkinFuncs["Blizzard_BindingUI"] = LoadSkin