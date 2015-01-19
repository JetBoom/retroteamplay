GM.HELP_TEXT = {"Generic Help Section"}

local wikiwarn = CreateClientConVar("nox_wikiwarning", 0, true, false)
function MakepHelp()
	if pHelp then
		pHelp:SetVisible(true)
		pHelp:MakePopup()
		return
	end

	local Window = vgui.Create("DFrame")
	local tall = 600
	local wide = 800
	Window:SetSize(wide, tall)
	Window:Center()
	Window:SetTitle(" ")
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:MakePopup()
	Window:SetDeleteOnClose(false)
	Window:SetKeyboardInputEnabled(false)
	Window:SetCursor("pointer")
	Window.Paint = function(frr)
		draw.RoundedBox(8, 0, 0, frr:GetWide(), frr:GetTall(), color_black)
		return true
	end
	pHelp = Window

	if not wikiwarn:GetBool() then
		RunConsoleCommand("nox_wikiwarning", "1")

		surface.SetFont("Default")
		local texw, texh = surface.GetTextSize("Just a little reminder, this is a VERY rough outline of BASIC gameplay.")
		local texw2, texh2 = surface.GetTextSize("The wiki has a much broader and detailed explaination as well as specific class, spell, vehicle, and projectile mechanics.")
		local texw3, texh3 = surface.GetTextSize("If you want to visit the wiki, it can be located at noxiousnet.com/wiki")

		local frm = vgui.Create("DFrame")
		local tll = texh * 11
		local wde = texw2 + 32
		frm:SetSize(wde, tll)
		frm:Center()
		frm:SetTitle("New players listen up!!!")
		frm:SetVisible(true)
		frm:SetDeleteOnClose(true)
		frm:SetKeyboardInputEnabled(false)
		frm.Paint = function(frr)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, frr:GetWide(), frr:GetTall())
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawOutlinedRect(0, 0, frr:GetWide(), frr:GetTall())
			return true
		end

		local label = vgui.Create("DLabel", frm)
		label:SetTextColor(color_white)
		label:SetFont("Default")
		label:SetText("Just a little reminder, this is a VERY rough outline of BASIC gameplay.")
		label:SetPos(wde * 0.5 - texw * 0.5, 48)
		label:SetSize(texw, texh)
		label:SetMouseInputEnabled(false)

		local label = vgui.Create("DLabel", frm)
		label:SetTextColor(color_white)
		label:SetFont("Default")
		label:SetText("The wiki has a much broader and detailed explaination as well as specific class, spell, vehicle, and projectile mechanics.")
		label:SetPos(wde * 0.5 - texw2 * 0.5, 48 + texh)
		label:SetSize(texw2, texh2)
		label:SetMouseInputEnabled(false)

		local label = vgui.Create("DLabel", frm)
		label:SetTextColor(color_white)
		label:SetFont("Default")
		label:SetText("If you want to visit the wiki, it can be located at http://noxiousnet.com/wiki")
		label:SetPos(wde * 0.5 - texw3 * 0.5, 48 + texh + texh2)
		label:SetSize(texw3, texh3)
		label:SetMouseInputEnabled(false)

		local dbut = vgui.Create("DButton", frm)
		dbut:SetText("Close")
		dbut:SizeToContents()
		dbut:SetWide(dbut:GetWide() + 16)
		dbut:SetTall(dbut:GetTall() + 12)
		dbut:SetPos(wde * 0.5 - dbut:GetWide() * 0.5, tll - dbut:GetTall() - 16)
		dbut.DoClick = function(dbb) dbb:GetParent():Close() end

		frm:MakePopup()
	end

	local label = vgui.Create("DLabel", Window)
	label:SetTextColor(COLOR_RED)
	label:SetFont("teamplay")
	label:SetText("F1: Help")
	label:SetPos(18, 2)
	surface.SetFont("teamplay")
	local texw, texh = surface.GetTextSize("F1: Help")
	label:SetSize(texw, texh)

	local label = vgui.Create("DLabel", Window)
	label:SetTextColor(COLOR_RED)
	label:SetFont("teamplay")
	label:SetText("F2: Change Class")
	surface.SetFont("teamplay")
	local texw, texh = surface.GetTextSize("F2: Change Class")
	label:SetPos(200 - texw * 0.5, 2)
	label:SetSize(texw, texh)

	local label = vgui.Create("DLabel", Window)
	label:SetTextColor(COLOR_RED)
	label:SetFont("teamplay")
	label:SetText("F3: Spell Setup")
	surface.SetFont("teamplay")
	local texw, texh = surface.GetTextSize("F3: Setup Abilities")
	label:SetPos(390 - texw * 0.5, 2)
	label:SetSize(texw, texh)

	local label = vgui.Create("DLabel", Window)
	label:SetTextColor(COLOR_RED)
	label:SetFont("teamplay")
	label:SetText("F4: Options")
	surface.SetFont("teamplay")
	local texw, texh = surface.GetTextSize("F4: Options")
	label:SetPos(640 - texw - 22, 2)
	label:SetSize(texw, texh)

	surface.SetFont("Default")
	local ___, defh = surface.GetTextSize("|")

	local y = 48
	for _, text in ipairs(GAMEMODE.HELP_TEXT) do
		if string.len(text) <= 1 then
			y = y + defh
		else
			local label = vgui.Create("DLabel", Window)
			local pretext = string.sub(text, 1, 2)
			if pretext == "^r" then
				label:SetTextColor(COLOR_RED)
				text = string.sub(text, 3)
			elseif pretext == "^g" then
				label:SetTextColor(COLOR_LIMEGREEN)
				text = string.sub(text, 3)
			elseif pretext == "^y" then
				label:SetTextColor(COLOR_YELLOW)
				text = string.sub(text, 3)
			elseif pretext == "^b" then
				label:SetTextColor(COLOR_CYAN)
				text = string.sub(text, 3)
			else
				label:SetTextColor(color_white)
			end
			label:SetFont("DefaultSmall")
			label:SetText(text)
			label:SetPos(16, y)
			label:SetSize(640, defh)
			y = y + defh
		end
	end

	local button = vgui.Create("DButton", Window)
	local bw = Window:GetWide() - 150
	button:SetPos(bw, 110)
	button:SetSize(130, 28)
	button:SetText("Close")
	button.DoClick = function(btn) btn:GetParent():SetVisible(false) end

	if NDB then
	local button = vgui.Create("DButton", Window)
	button:SetPos(bw, 80)
	button:SetSize(130, 28)
	button:SetText("Donations")
	button:SetTextColor(COLOR_YELLOW)
	button.DoClick = function(btn) OpenDonationHTML() end
	end

	local button = vgui.Create("DButton", Window)
	button:SetPos(bw, 50)
	button:SetSize(130, 28)
	button:SetText("Game Credits")
	button.DoClick = function(btn)
		local frame = vgui.Create("DFrame")
		frame:SetSize(640, 480)
		frame:Center()
		frame:SetTitle("NoX TeamPlay Credits")
		frame:SetCursor("pointer")
		frame:SetKeyboardInputEnabled(false)
		frame:SetVisible(true)

		local ctrl = vgui.Create("DListView", frame)
		local Col1 = ctrl:AddColumn("Name")
		local Col2 = ctrl:AddColumn("Contact")
		local Col3 = ctrl:AddColumn("Credits")
		Col2:SetMinWidth(100)
		Col2:SetMinWidth(100)
		Col3:SetMinWidth(200)
		for authorindex, authortab in ipairs(GAMEMODE.Credits) do
			ctrl:AddLine(unpack(authortab))
		end
		ctrl:SetSize(608, 432)
		ctrl:SetPos(16, 32)

		frame:MakePopup()
	end
end
