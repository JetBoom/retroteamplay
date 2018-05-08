local VehicleTimers = {}
usermessage.Hook("RecVehTimer", function(um)
	VehicleTimers[um:ReadString()] = um:ReadFloat()
end)

local function LabelThink(self)
	local parent = self:GetParent()
	local tab = parent.Vehicle
	local count = 0
	for _, ent in pairs(ents.FindByClass(parent.Class)) do
		if ent:GetTeamID() == MySelf:GetTeamID() then
			count = count + 1
		end
	end

	local tim = VehicleTimers[tab.Name] and CurTime() < VehicleTimers[tab.Name]
	parent.ReLabel:SetVisible(tim)
	if tim then
		parent.ReLabel:SetText("Reacquire Time: "..util.ToMinutesSecondsMilliseconds(math.max(0, VehicleTimers[tab.Name] - CurTime())))
	end

	if count >= tab.Stocks then
		self:SetTextColor(COLOR_RED)
		parent.SubLabel:SetTextColor(COLOR_RED)
	else
		parent.SubLabel:SetTextColor(color_white)
		self:SetTextColor(COLOR_LIMEGREEN)
	end

	if count >= tab.Stocks or tim then
		parent.CreateButton:SetDisabled(true)
	else
		parent.CreateButton:SetDisabled(false)
	end

	parent.SubLabel:SetText("(Spawned: "..count.." / Max: "..tab.Stocks..")")
end

local function Command(btn)
	surface.PlaySound("buttons/button3.wav")
	MySelf:ConCommand(btn.Command)
	btn:GetParent():GetParent():GetParent():GetParent():SetVisible(false)
end

local pVehicle

function OpenVehicleMenu()
	if pVehicle then
		pVehicle:SetVisible(true)
		return
	end

	if NOVEHICLES then return end

	local pw = w * 0.5
	local ph = h * 0.75

	local Window = vgui.Create("DFrame")
	Window:SetPos(100, 100)
	Window:SetSize(pw, ph)
	Window:Center()
	Window:SetTitle("Vehicles")
	Window:SetVisible(true)
	Window:MakePopup()
	Window:SetDeleteOnClose(false)
	Window:SetKeyboardInputEnabled(false)
	pVehicle = Window

	local PanelList = vgui.Create("DPanelList", Window)
	PanelList:EnableVerticalScrollbar()
	PanelList:EnableHorizontal(false)
	PanelList:SetSize(pw - 16, ph - 64)
	PanelList:SetPos(8, 56)
	PanelList:SetSpacing(8)

	for class, veh in pairs(GAMEMODE:GetVehicles()) do
		if veh.Icon then
			local enabled = not (veh.IsHoverVehicle and NOHOVERVEHICLES) and not (veh.IsGroundVehicle and NOGROUNDVEHICLES) and not (veh.IsAirVehicle and NOAIRVEHICLES)
			local Panel = vgui.Create("Panel")

			Panel.Vehicle = veh
			Panel.Class = class

			local texturew, textureh = surface.GetTextureSize(surface.GetTextureID(veh.Icon))

			local Label = vgui.Create("DLabel", Panel)
			surface.SetFont("DefaultFontBold")
			local txtw, txth = surface.GetTextSize("Reacquire Time: 00:00:00")
			Label:SetText("Reacquire Time: 00:00:00")
			Label:SetTextColor(COLOR_RED)
			Label:SetFont("DefaultFontBold")
			Label:SetPos(8, 24 + txth + textureh)
			Label:SetSize(txtw, txth)
			Label.Think = LabelThink2
			Label:SetMouseInputEnabled(false)
			Label:SetKeyboardInputEnabled(false)
			Label:SetVisible(false)
			Panel.ReLabel = Label

			local Label = vgui.Create("DLabel", Panel)
			surface.SetFont("teamplay")
			if enabled then
				txtw, txth = surface.GetTextSize(veh.Name)
				Label:SetText(veh.Name)
				Label:SetTextColor(COLOR_LIMEGREEN)
				Label.Think = LabelThink
			else
				txtw, txth = surface.GetTextSize("(DISABLED) "..veh.Name)
				Label:SetText("(DISABLED) "..veh.Name)
				Label:SetTextColor(COLOR_RED)
			end
			Label:SetFont("teamplay")
			Label:SetPos(pw * 0.5 - txtw * 0.5, 8)
			Label:SetSize(txtw, txth)
			Label:SetMouseInputEnabled(false)
			Label:SetKeyboardInputEnabled(false)

			local y = 12 + Label:GetTall()

			local Label = vgui.Create("DLabel", Panel)
			surface.SetFont("teamplay")
			Label:SetText("Mana cost: "..veh.ManaToSpawn)
			Label:SetTextColor(COLOR_CYAN)
			Label:SizeToContents(txtw, txth)
			Label:SetPos(pw * 0.5 - Label:GetWide() * 0.5, y)
			Label:SetMouseInputEnabled(false)
			Label:SetKeyboardInputEnabled(false)

			y = y + Label:GetTall() + 4

			for i, line in ipairs(string.Explode("@", veh.Description)) do
				surface.SetFont("DefaultFontBold")
				local tw, th = surface.GetTextSize(line)
				local Label2 = vgui.Create("DLabel", Panel)
				Label2:SetText(line)
				--Label2:SetTextColor(color_white)
				Label2:SetFont("DefaultFontBold")
				Label2:SetPos(pw * 0.5 - tw * 0.5, y)
				Label2:SetSize(tw, th)
				y = y + th
			end

			local Label = vgui.Create("DLabel", Panel)
			surface.SetFont("DefaultFont")
			local txtw2, txth2 = surface.GetTextSize("(Spawned: 9999 / Max: 9999)")
			Label:SetText(".")
			Label:SetTextColor(COLOR_LIMEGREEN)
			Label:SetFont("DefaultFont")
			Label:SetPos(8, 24 + textureh)
			Label:SetSize(txtw2, txth2)
			Label:SetMouseInputEnabled(false)
			Label:SetKeyboardInputEnabled(false)
			Panel.SubLabel = Label

			local Control = vgui.Create("DButton", Panel)
			Control:SetText("Create")
			Control:SetPos(pw * 0.5 - 32, 72)
			Control:SetSize(64, 24)
			if enabled then
				Control.Command = "createvehicle "..class
				Control.DoClick = Command
				Panel.CreateButton = Control
			else
				Control:SetDisabled(true)
			end

			--[[local ModelButton = vgui.Create("SpawnIcon", Panel)
			ModelButton:SetModel(veh.Model)
			ModelButton:SetPos(38, 40)]]

			if veh.Icon then
				local Control = vgui.Create("DImage", Panel)
				Control:SetImage(veh.Icon)
				Control:SetPos(16, 16)
				Control:SetSize(texturew, textureh)
			end

			Panel:SetTall(128)

			PanelList:AddItem(Panel)
		end
	end

	PanelList:PerformLayout()
end
