include("vgui/scoreboard.lua")

GM.ShowScoreboard = false

local pScoreBoard = nil

function GM:CreateScoreboard()
	if ScoreBoard then
		ScoreBoard:Remove()
		ScoreBoard = nil
	end
	pScoreBoard = vgui.Create("ScoreBoard")
	pScoreBoard:Refresh()
end

function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true

	gui.EnableScreenClicker(true)

	if pScoreBoard then
		pScoreBoard:SetVisible(true)
		pScoreBoard:Refresh()
	else
		self:CreateScoreboard()
		pScoreBoard:SetVisible(true)
		pScoreBoard:Refresh()
	end
end

function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false

	gui.EnableScreenClicker(false)

	pScoreBoard:SetVisible(false)
	pScoreBoard:Refresh()
end

function GM:HUDDrawScoreBoard()
end
