local function TeamSelectButtonThink(self)
	local myplayercount = team.NumPlayers(self.TeamID)
	for i, teamid in pairs(TEAMS_PLAYING) do
		self:SetDisabled(team.NumPlayers(teamid) < myplayercount)
	end
end

local function TeamSelectButtonDoClick(self)
	RunConsoleCommand("nox_jointeam", self.TeamID)
end

local function TeamSelectColorPaint(self)
	surface.SetDrawColor(team.GetColor(self.TeamID))
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	surface.SetDrawColor(200, 200, 200, 255)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())

	draw.SimpleText(team.NumPlayers(self.TeamID), "DefaultBold", self:GetWide() / 2, self:GetTall() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function TeamSelectPaint(self)
	Derma_DrawBackgroundBlur(self)
end

function ClosepTeamSelect()
	if pTeamSelect and pTeamSelect:Valid() then pTeamSelect:Remove() end
end

function MakepTeamSelect()
	ClosepTeamSelect()

	local wid = 180

	local frame = vgui.Create("DPanel")
	frame:SetWide(wid)
	frame:Center()
	frame.Paint = TeamSelectPaint
	pTeamSelect = frame

	local y = 8

	local lab = EasyLabel(frame, "Select a team.", "DefaultBold", color_white)
	lab:SetPos(0, y)
	lab:CenterHorizontal()
	y = y + lab:GetTall() + 8

	for i, teamid in pairs(TEAMS_PLAYING) do
		local colorpanel = vgui.Create("DPanel", frame)
		colorpanel:SetSize(24, 24)
		colorpanel:SetPos(8, y)
		colorpanel.TeamID = teamid
		colorpanel.Paint = TeamSelectColorPaint

		local button = vgui.Create("DButton", frame)
		button:SetText(team.GetName(teamid))
		button:SetSize(wid - 40, 24)
		button:SetPos(32, y)
		button.TeamID = teamid
		button.Think = TeamSelectButtonThink
		button.DoClick = TeamSelectButtonDoClick
		y = y + button:GetTall() + 2
	end

	frame:SetTall(y + 8)
	frame:MakePopup()
end
