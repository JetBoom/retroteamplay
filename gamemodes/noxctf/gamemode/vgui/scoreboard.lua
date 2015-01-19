local PANEL = {}

function PANEL:Init()
	self.Children = {}
end

local function SortPlayers(a, b)
	local afrags = a:Frags()
	local bfrags = b:Frags()

	if afrags == bfrags then
		return a:Deaths() < b:Deaths()
	end

	return bfrags < afrags
end

local function emptypaint(self)
	local pl = self.Player
	if pl:IsValid() then
		local wid, tall =  self:GetWide(), self:GetTall()
		local teamcol = team.GetColor(pl:GetTeamID()) or color_white
		surface.SetDrawColor(teamcol.r * 0.75, teamcol.g * 0.75, teamcol.b * 0.75, 255)
		surface.DrawRect(0, 0, wid, tall)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(0, 0, wid, tall)
		if pl == MySelf then
			local brit = math.min(255, math.sin(RealTime() * 6) * 180 + 255)
			surface.SetDrawColor(brit, brit, brit, 255)
		else
			surface.SetDrawColor(85, 85, 85, 255)
		end
		surface.DrawOutlinedRect(1, 1, wid - 2, tall - 2)

		local mid = tall * 0.5

		surface.SetFont("teamplay")
		local nam = pl:Name()
		local namew, nameh = surface.GetTextSize(nam)
		if wid * 0.5 <= 40 + namew then
			surface.SetFont("scoreboardfine")
			local namew2, nameh2 = surface.GetTextSize(nam)
			draw.RoundedBox(8, 44, mid - nameh * 0.5 - 2, namew2 + 8, nameh + 4, color_black)
			draw.SimpleText(nam, "scoreboardfine", 48, mid, teamcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			draw.RoundedBox(8, 44, mid - nameh * 0.5 - 2, namew + 8, nameh + 4, color_black)
			draw.SimpleText(nam, "teamplay", 48, mid, teamcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local classtab = pl:GetPlayerClassTable()
		if classtab.Icon then
			surface.SetMaterial(classtab.Icon)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(wid * 0.4 - 16, 2, 32, 32)
		else
			draw.SimpleText(classtab.Name, "DefaultFontBold", wid * 0.4, mid, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local stats = string.Explode("@", pl:GetNetworkedString("tpstats", "0@0@0@0"))
		local kills = stats[1]
		local assists = stats[2]
		local offense = stats[3]
		local defense = stats[4]

		surface.SetFont("scoreboardfine")
		local fw, fh = surface.GetTextSize("TEXT!")
		fh = math.max(fh, 16)

		draw.RoundedBox(8, wid * 0.5 - 4, mid - fh * 0.5 - 2, wid * 0.5 - 8, fh + 4, color_black)
		local score = pl:Frags()
		if score < 0 then
			draw.SimpleText(score, "scoreboardfine", wid * 0.5, mid, COLOR_RED, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(score, "scoreboardfine", wid * 0.5, mid, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		draw.SimpleText(kills, "scoreboardfine", wid * 0.575, mid, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(assists, "scoreboardfine", wid * 0.65, mid, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(pl:Deaths(), "scoreboardfine", wid * 0.725, mid, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(offense, "scoreboardfine", wid * 0.8, mid, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(defense, "scoreboardfine", wid * 0.875, mid, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local ping = pl:Ping()
		if ping < 125 then
			draw.SimpleText(ping, "scoreboardfine", wid - 16, mid, COLOR_LIMEGREEN, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		elseif ping < 200 then
			draw.SimpleText(ping, "scoreboardfine", wid - 16, mid, COLOR_YELLOW, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(ping, "scoreboardfine", wid - 16, mid, COLOR_RED, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end
	return true
end

local function profileopen(self)
	local player = self.Player
	if player:IsValid() then
		if NDB then NDB.GeneralPlayerMenu(player, true) end
	end
end

local Scroll = 0

function PANEL:Refresh()
	for _, child in pairs(self.Children) do
		child:Remove()
	end

	self.Children = {}

	local x = 8
	local y = 16

	local list = vgui.Create("DPanelList", self)
	list:SetSize(self:GetWide() - 32, self:GetTall() - 80)
	list:SetPos(16, 64)
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(false)
	list:SetSpacing(2)
	self.PanelList = list
	table.insert(self.Children, list)
	--timer.SimpleEx(0, list.VBar.SetScroll, list.VBar, Scroll)

	local PlayerSorted = player.GetAll()
	table.sort(PlayerSorted, SortPlayers)

	local panelw, panelh = list:GetWide() - 16, 36

	for i, pl in ipairs(PlayerSorted) do
		local panel = vgui.Create("Button", self)
		panel:SetSize(panelw, 36)
		panel.Paint = emptypaint
		panel.DoClick = profileopen
		panel.Player = pl
		panel.SmallFont = SmallFont

		local avatar = vgui.Create("AvatarImage", panel)
		avatar:SetPos(4, 2)
		avatar:SetSize(32, 32)
		avatar:SetPlayer(pl)
		avatar:SetTooltip("Click here to view "..pl:Name().." Steam Community profile.")

		list:AddItem(panel)
	end

	local tteams = #TEAMS_PLAYING
	local spacing = self:GetWide() / (tteams + 1)
	for i, teamid in ipairs(TEAMS_PLAYING) do
		local nump = team.NumPlayers(teamid)
		if nump == 1 then
			nump = "1 player"
		else
			nump = nump.." players"
		end
		local txt = team.GetName(teamid).." - "..nump
		surface.SetFont("teamplay")
		local sbw, sbh = surface.GetTextSize(txt)
		local panel = vgui.Create("DLabel", self)
		panel:SetPos(i * spacing - sbw * 0.5, 8)
		panel:SetSize(sbw, sbh)
		panel:SetText(txt)
		panel:SetFont("teamplay")
		panel:SetTextColor(team.GetColor(teamid))
		table.insert(self.Children, panel)
	end

	surface.SetFont("scoreboardfine")
	local sbw, sbh = surface.GetTextSize("Player")
	local texy = 62 - sbh
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(48, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Player")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)

	local sbw, sbh = surface.GetTextSize("Class")
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(self:GetWide() * 0.4 - sbw * 0.5, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Class")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)

	local sbw, sbh = surface.GetTextSize("Score")
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(16 + list:GetWide() * 0.5, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Score")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)

	local sbw, sbh = surface.GetTextSize("Kills")
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(16 + list:GetWide() * 0.575 - sbw * 0.5, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Kills")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)

	local sbw, sbh = surface.GetTextSize("Assists")
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(16 + list:GetWide() * 0.65 - sbw * 0.5, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Assists")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)

	local sbw, sbh = surface.GetTextSize("Deaths")
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(16 + list:GetWide() * 0.725 - sbw * 0.5, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Deaths")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)

	local sbw, sbh = surface.GetTextSize("Offense")
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(16 + list:GetWide() * 0.8 - sbw * 0.5, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Offense")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)

	local sbw, sbh = surface.GetTextSize("Defense")
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(16 + list:GetWide() * 0.875 - sbw * 0.5, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Defense")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)

	local sbw, sbh = surface.GetTextSize("Ping")
	local panel = vgui.Create("DLabel", self)
	panel:SetPos(list:GetWide() - sbw, texy)
	panel:SetSize(sbw, sbh)
	panel:SetText("Ping")
	panel:SetFont("scoreboardfine")
	panel:SetTextColor(color_white)
	table.insert(self.Children, panel)
end

function PANEL:Paint()
	local wid, hei = self:GetWide(), self:GetTall()
	draw.RoundedBox(8, 0, 0, wid, hei, color_black_alpha180)

	return true
end

function PANEL:PerformLayout()
	local tryw = math.max(800, w * 0.75)
	local tryh = math.max(600, h * 0.75)
	self:SetSize(tryw, tryh)
	self:Center()

	--self:Refresh()
end

PANEL.NextRefresh = 0

function PANEL:Think()
	if self.NextRefresh < CurTime() then
		self.NextRefresh = CurTime() + 3
		if self.PanelList then
			Scroll = self.PanelList.VBar:GetScroll()
		end
		self:Refresh()
	end
end

vgui.Register("ScoreBoard", PANEL, "Panel")
