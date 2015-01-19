local function MakeProp(btn)
	RunConsoleCommand("_tp_craftobject", btn.PropType, btn.MaterialType)
	surface.PlaySound("buttons/button14.wav")
end

local function neutralpaint(p)
	surface.SetDrawColor(65, 65, 65, 255)
	surface.DrawRect(0, 0, p:GetWide(), p:GetTall())
	surface.SetDrawColor(150, 150, 150, 150)
	surface.DrawOutlinedRect(0, 0, p:GetWide(), p:GetTall())

	return true
end

local function noitempaint(p)
	surface.SetDrawColor(65, 65, 65, 255)
	surface.DrawRect(0, 0, p:GetWide(), p:GetTall())
	surface.SetDrawColor(255, 0, 0, 150)
	surface.DrawOutlinedRect(0, 0, p:GetWide(), p:GetTall())

	return true
end

local function hasitempaint(p)
	surface.SetDrawColor(65, 65, 65, 255)
	surface.DrawRect(0, 0, p:GetWide(), p:GetTall())
	surface.SetDrawColor(20, 255, 20, 150)
	surface.DrawOutlinedRect(0, 0, p:GetWide(), p:GetTall())

	return true
end

local function MaterialOnSelect(p, index, value, data)
	cookie.Set("noxbuildingmaterial_"..p.Name, value)
	p:GetParent().MaterialType = value
	p:GetParent():GetParent().MaterialType = value
end

local function AddBuilding(tab, index)
	local Panel = vgui.Create("DButton")
	Panel:SetText(" ")
	Panel.PropType = index
	Panel.DoClick = MakeProp

	local button = vgui.Create("SpawnIcon", Panel)
	button:SetPos(8, 8)
	button:SetModel(tab.Model)
	button:SetMouseInputEnabled(false)

	local bsizex, bsizey = button:GetSize()
	local xx, yy = bsizex + 16, 8

	surface.SetFont("teamplay_nooutline")
	local txt = tab.Name
	local tsizex, tsizey = surface.GetTextSize(txt)
	local label = vgui.Create("DLabel", Panel)
	label:SetSize(tsizex, tsizey)
	label:SetFont("teamplay_nooutline")
	label:SetText(txt)
	label:SetTextColor(color_white)
	label:SetPos(xx, yy)
	yy = yy + tsizey

	if tab.UsableMaterials then
		local ctrl = vgui.Create("DComboBox", Panel)
		ctrl:SetPos(594, 56)
		ctrl.Name = tab.Name
		local getcookie = cookie.GetString("noxbuildingmaterial_"..tab.Name)
		if getcookie and getcookie ~= "" and table.HasValue(GAMEMODE.ResistanceToString, getcookie) then
			ctrl:SetText(getcookie)
			ctrl.MaterialType = getcookie
			Panel.MaterialType = getcookie
		else
			ctrl:SetText("Use Default Material")
			ctrl.MaterialType = "Use Default Material"
			Panel.MaterialType = "Use Default Material"
		end
		ctrl:AddChoice("Use Default Material")
		for i, typ in pairs(tab.UsableMaterials) do
			ctrl:AddChoice(GAMEMODE.ResistanceToString[typ])
		end
		ctrl:SetWide(150)
		ctrl.OnSelect = MaterialOnSelect
	end

	Panel.Paint = neutralpaint

	local txt = tab.PHealth.." Health"
	surface.SetFont("DefaultSmall")
	local tsizex, tsizey = surface.GetTextSize(txt)
	local label = vgui.Create("DLabel", Panel)
	label:SetSize(tsizex, tsizey)
	label:SetFont("DefaultSmall")
	label:SetText(txt)
	label:SetTextColor(COLOR_LIMEGREEN)
	label:SetPos(xx, yy)
	yy = yy + tsizey

	if tab.ClusterPrevention then
		local txt = "Operating frequency: "..tab.ClusterPrevention
		local tsizex, tsizey = surface.GetTextSize(txt)
		local label = vgui.Create("DLabel", Panel)
		label:SetSize(tsizex, tsizey)
		label:SetFont("DefaultSmall")
		label:SetText(txt)
		label:SetTextColor(COLOR_YELLOW)
		label:SetPos(xx, yy)
		yy = yy + tsizey
	end

	if tab.SolidBase then
		local txt = "Must be placed on solid ground"
		local tsizex, tsizey = surface.GetTextSize(txt)
		local label = vgui.Create("DLabel", Panel)
		label:SetSize(tsizex, tsizey)
		label:SetFont("DefaultSmall")
		label:SetText(txt)
		label:SetTextColor(COLOR_RED)
		label:SetPos(xx, yy)
		yy = yy + tsizey
	end

	if tab.NoWater then
		local txt = "Inoperable in water"
		local tsizex, tsizey = surface.GetTextSize(txt)
		local label = vgui.Create("DLabel", Panel)
		label:SetSize(tsizex, tsizey)
		label:SetFont("DefaultSmall")
		label:SetText(txt)
		label:SetTextColor(COLOR_RED)
		label:SetPos(xx, yy)
		yy = yy + tsizey
	end

	Panel:SetSize(w * 0.2 - 16, 80)
	Panel:SetPos(8, 0)

	return Panel
end

local function CategorySwitch(p, index, value, data)
	surface.PlaySound("buttons/button9.wav")
	MakepBuilder(true, value)
end

local CategoryTips = {}
CategoryTips["Props"] = "Experiment with different material types to get the best defenses for the right situations."
CategoryTips["Deployables"] = "None of these require Mana in order to function."
CategoryTips["Powered Deployables"] = "These all require a Mana from the resource management pool to work! They are all made of metal."
CategoryTips["Resource Management"] = "Resources are vital to your team's success and are required to power some deployables."
CategoryTips["Auto-Turret Barrels"] = "To be attached to Auto-Turrets. They can be found in Powered Deployables."
CategoryTips["Mountable Turret Barrels"] = "To be attached to Mountable Turrets. They can be found in Powered Deployables."

local pBuilder

function MakepBuilder(delete, category)
	if pBuilder and pBuilder:Valid() then
		if delete then
			pBuilder:Remove()
		else
			pBuilder:SetVisible(true)
			return
		end
	end

	category = category or PROPTYPES[1].Group

	local pw = 800
	local ph = 600

	pBuilder = vgui.Create("DEXRoundedPanel")
	pBuilder:SetSize(pw, ph)

	local cpanel = vgui.Create("DPanel", pBuilder)
	local txt = CategoryTips[category]
	if txt then
		surface.SetFont("Default")
		local tsizex, tsizey = surface.GetTextSize(txt)
		cpanel:SetSize(tsizex + 16, tsizey + 8)
		local label = vgui.Create("DLabel", cpanel)
		label:SetPos(8, cpanel:GetTall() * 0.5 - tsizey * 0.5)
		label:SetSize(tsizex, tsizey)
		label:SetFont("Default")
		label:SetText(txt)
		label:SetTextColor(color_black)
		cpanel:SetVisible(true)
		cpanel:SetMouseInputEnabled(false)
		cpanel:SetKeyboardInputEnabled(false)
		cpanel:SetPos(pw * 0.5 - (tsizex * 0.5 + 8), 40)
	end

	local categories = {}
	local alreadyadded = {}
	for _, tab in ipairs(PROPTYPES) do
		if not alreadyadded[tab.Group] then
			table.insert(categories, tab.Group)
			alreadyadded[tab.Group] = true
		end
	end

	local ctrl = vgui.Create("DComboBox", pBuilder)
	ctrl:SetPos(16, 8)
	ctrl:SetText(category)
	for i, cat in ipairs(categories) do
		ctrl:AddChoice(cat)
	end
	ctrl:SetWide(170)
	ctrl.OnSelect = CategorySwitch

	local wb = WordBox(pBuilder, "Select a building category", nil, color_black)
	wb:SetPos(188, 8)

	local PanelList = vgui.Create("DPanelList", pBuilder)
	PanelList:EnableVerticalScrollbar()
	PanelList:EnableHorizontal(false)
	PanelList:SetSize(pw - 32, ph - 250)
	PanelList:SetPos(16, 72)
	PanelList:SetSpacing(8)
	pBuilder.PanelList = PanelList

	local wb = WordBox(pBuilder, "Damage Multipliers", "DefaultBold", color_black)
	wb:SetPos(pw * 0.5 - wb:GetWide() * 0.5, ph - 175)

	local ctrl = vgui.Create("DListView", pBuilder)
	ctrl:AddColumn("Material"):SetMinWidth(128)
	for i, typ in ipairs(DAMAGETYPES) do
		ctrl:AddColumn(typ)
	end
	for x, mat in ipairs(GAMEMODE.ResistanceToString) do
		local tabmul = {}
		for i, typ in ipairs(DAMAGETYPES) do
			table.insert(tabmul, (RESISTANCE_TABLES[x][i] or 1) * 100 .. "%")
		end
		ctrl:AddLine(mat, unpack(tabmul))
	end
	ctrl:SetSize(pw - 32, 140)
	ctrl:SetPos(16, ph - 148)

	for i, tab in ipairs(PROPTYPES) do
		if tab.Group == category or not tab.Group then
			local rightgt = true
			if tab.GameTypes then
				rightgt = false
				for _, gt in pairs(tab.GameTypes) do
					if GAMEMODE.GameType == gt then
						rightgt = true
						break
					end
				end
			end

			PanelList:AddItem(AddBuilding(tab, i))
		end
	end

	pBuilder:Center()
	pBuilder:MakePopup()
	pBuilder:SetKeyboardInputEnabled(false)
end

concommand.Add("+menu", function()
	if MySelf:GetPlayerClassTable().Name == "Crafter" and not MySelf:GetActiveWeapon().NoBuilderMenu and MySelf:Alive() then
		MakepBuilder()
	end
end)

concommand.Add("-menu", function()
	if pBuilder and pBuilder:Valid() then
		pBuilder:SetVisible(false)
	end
end)
