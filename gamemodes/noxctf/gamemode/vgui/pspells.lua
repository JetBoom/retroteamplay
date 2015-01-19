local CurrentSpellButton

function MakepSpells()
	if pSpells then
		pSpells:Remove()
		pSpells = nil
	end

	if MySelf:NumCastableSpells() == 0 then
		MySelf:ChatPrint("Your class can not cast any spells or use abilities and thus can not use this menu.")
		return
	end

	local pw = 480
	local ph = 600

	local Window = vgui.Create("DFrame")
	Window:SetSize(pw, ph)
	Window:Center()
	Window:SetTitle("Hotkeys - " .. MySelf:GetPlayerClassTable().Name)
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:SetKeyboardInputEnabled(false)
	Window:MakePopup()
	pSpells = Window

	local cy = 72
	local cx = 32
	local SpellsSorted = MySelf:GetCastableSpells()
	for i=1, #SpellsSorted do
		button = vgui.Create("SpellBindingSelectButton", Window)
		button.SpellID = SpellsSorted[i]
		button:SetPos(cx, cy)
		button:SetSize(32, 32)

		cx = cx + 32
		if cx >= pw - 32 then
			cx = 32
			cy = cy + 32
		end
	end

	local dX = pw * 0.5 - 80
	local dY = ph * 0.5 - 80

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_FORWARD + IN_MOVELEFT
	button.Set = 2
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 64

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_FORWARD
	button.Set = 2
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 64

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_FORWARD + IN_MOVERIGHT
	button.Set = 2
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dY = dY + 32
	dX = dX - 96

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_FORWARD + IN_MOVELEFT
	button.Set = 1
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_FORWARD
	button.Set = 1
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_FORWARD + IN_MOVERIGHT
	button.Set = 1
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX - 64
	dY = dY + 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_MOVELEFT
	button.Set = 1
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX - 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_MOVELEFT
	button.Set = 2
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 96

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_MOVERIGHT
	button.Set = 1
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_MOVERIGHT
	button.Set = 2
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX - 96
	dY = dY + 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_BACK + IN_MOVELEFT
	button.Set = 1
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_BACK
	button.Set = 1
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_BACK + IN_MOVERIGHT
	button.Set = 1
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX - 96
	dY = dY + 32

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_MOVELEFT + IN_BACK
	button.Set = 2
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 64

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_BACK
	button.Set = 2
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	dX = dX + 64

	local button = vgui.Create("SpellBindingButton", Window)
	button.Bind = IN_BACK + IN_MOVERIGHT
	button.Set = 2
	button:SetPos(dX, dY)
	button:SetSize(32, 32)

	local label = vgui.Create("DLabel", Window)
	label.OldPaint = label.Paint
	label.Paint = function(lab)
		if CurrentSpellButton then
			label:SetText(CurrentSpellButton.Name)
			label:SetTextColor(COLOR_CYAN)
			label:SetFont("DefaultBold")
			surface.SetFont("DefaultBold")
			local texw, texh = surface.GetTextSize(CurrentSpellButton.Name)
			label:SetSize(texw, texh)
			label:SetPos(lab:GetParent():GetWide() * 0.5 - texw * 0.5, 32)
			--label:SetVisible(true)
		else
			--label:SetVisible(false)
			label:SetText(" ")
		end
		--label:OldPaint()
	end
	--label:Think()

	local label = vgui.Create("DLabel", Window)
	label.OldPaint = label.Paint
	label.Paint = function(lab)
		if CurrentSpellButton then
			label:SetText(CurrentSpellButton.Desc)
			label:SetTextColor(COLOR_GOLD)
			surface.SetFont("Default")
			local texw, texh = surface.GetTextSize(CurrentSpellButton.Desc)
			label:SetSize(texw, texh)
			label:SetPos(lab:GetParent():GetWide() * 0.5 - texw * 0.5, 36 + texh)
			--label:SetVisible(true)
		else
			--label:SetVisible(false)
			label:SetText(" ")
		end
		--label:OldPaint()
	end
	--label:Think()

	surface.SetFont("Default")
	local getw, geth = surface.GetTextSize("Set")

	local y = ph - 11 * geth
	local x = 32

	local label = vgui.Create("DLabel", Window)
	local txt = "Click on a spell up top and then click on a slot to assign it to a speedkey."
	label:SetPos(x, y)
	label:SetSize(surface.GetTextSize(txt))
	label:SetTextColor(color_white)
	label:SetText(txt)
	label:SetFont("Default")

	y = y + geth

	local label = vgui.Create("DLabel", Window)
	local txt = "Right click a speedkey to clear it."
	label:SetPos(x, y)
	label:SetSize(surface.GetTextSize(txt))
	label:SetTextColor(color_white)
	label:SetText(txt)
	label:SetFont("Default")

	y = y + geth

	local label = vgui.Create("DLabel", Window)
	local txt = "Spells set configs are saved on your computer by class name."
	label:SetPos(x, y)
	label:SetSize(surface.GetTextSize(txt))
	label:SetTextColor(color_white)
	label:SetText(txt)
	label:SetFont("Default")

	y = y + geth

	local label = vgui.Create("DLabel", Window)
	local txt = "Some classes do not use spells and this menu will be blank if so."
	label:SetPos(x, y)
	label:SetSize(surface.GetTextSize(txt))
	label:SetTextColor(color_white)
	label:SetText(txt)
	label:SetFont("Default")

	y = y + geth

	local label = vgui.Create("DLabel", Window)
	local txt = "  - Hold right mouse button and move in that direction for spell set 1."
	label:SetPos(x, y)
	label:SetSize(surface.GetTextSize(txt))
	label:SetTextColor(color_white)
	label:SetText(txt)
	label:SetFont("Default")

	y = y + geth

	local label = vgui.Create("DLabel", Window)
	local txt = "  - Hold right AND left mouse button and move in that direction for spell set 2."
	label:SetPos(x, y)
	label:SetSize(surface.GetTextSize(txt))
	label:SetTextColor(color_white)
	label:SetText(txt)
	label:SetFont("Default")

	y = y + geth

	local label = vgui.Create("DLabel", Window)
	local txt = "  - Cast your active spell by pushing your sprint key."
	label:SetPos(x, y)
	label:SetSize(surface.GetTextSize(txt))
	label:SetTextColor(color_white)
	label:SetText(txt)
	label:SetFont("Default")

	y = y + geth * 2

	--[[local label = vgui.Create("DLabel", Window)
	local txt = "You can bind spells directly to keys with the console. Example: bind \"t\" \"cast fire bolt\""
	label:SetPos(x, y)
	label:SetSize(surface.GetTextSize(txt))
	label:SetTextColor(color_white)
	label:SetText(txt)
	label:SetFont("Default")]]
end

local PANEL = {}
function PANEL:OnMousePressed(mc)
	if MySelf:NumCastableSpells() == 0 or not BINDBUTTONSPELL and mc ~= MOUSE_RIGHT then return end

	local set = self.Set
	local bind = self.Bind
	local class = MySelf:GetPlayerClass()

	if mc == MOUSE_LEFT then
		SPELL_SHEETS[class][bind][set] = Spells[BINDBUTTONSPELL].Name
		nospellshint = false

		surface.PlaySound("buttons/button9.wav")
		GAMEMODE:SaveSpellSheet(class)
	elseif mc == MOUSE_RIGHT then
		SPELL_SHEETS[class][bind][set] = "-"

		surface.PlaySound("buttons/button9.wav")
		GAMEMODE:SaveSpellSheet(class)
	end
end
function PANEL:Paint()
	if MySelf:NumCastableSpells() == 0 then return true end
	
	local tab = NameToSpellLower[ string.lower(tostring(SPELL_SHEETS[MySelf:GetPlayerClass()][self.Bind][self.Set])) ]
	if tab then
		surface.SetMaterial(Spells[tab].Icon)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
	else
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
	end
	--draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), bgColor)
	--draw.SimpleText(tab.Icon, "Default", self:GetWide() / 2, self:GetTall() / 2, fgColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return true
end
vgui.Register("SpellBindingButton", PANEL, "Button")


local PANEL = {}
function PANEL:DoClick()
	if BINDBUTTONSPELL and BINDBUTTONSPELL == self.SpellID then
		BINDBUTTONSPELL = nil
		surface.PlaySound("buttons/button18.wav")
	else
		BINDBUTTONSPELL = self.SpellID
		surface.PlaySound("buttons/button17.wav")
	end
end
function PANEL:Paint()
	local x, y = self:GetPos()
	local parentx, parenty = self:GetParent():GetPos()
	x, y = x + parentx, y + parenty
	local mx, my = gui.MousePos()
	local wid, hei = self:GetSize()
	local csb = mx >= x and mx <= x + wid and my >= y and my <= y + hei
	if csb then
		CurrentSpellButton = Spells[self.SpellID]
	end

	if BINDBUTTONSPELL then
		if BINDBUTTONSPELL == self.SpellID then
			surface.SetDrawColor(140, 255, 140, 255)
		else
			surface.SetDrawColor(130, 130, 130, 255)
		end
	elseif csb then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
	else
		surface.SetDrawColor(255, 255, 255, 255)
	end

	surface.SetMaterial(Spells[self.SpellID].Icon)
	surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())

	return true
end
vgui.Register("SpellBindingSelectButton", PANEL, "Button")
