local texDropped = surface.GetTextureID("noxctf/flagicon_dropped")
local texTaken = surface.GetTextureID("noxctf/flagicon_field")
local texHome = surface.GetTextureID("noxctf/flagicon_home")
local texDroppedIcon = surface.GetTextureID("noxctf/flagicon_dropped")
local texField = surface.GetTextureID("noxctf/flagicon_field")

local function DrawGameTypeHUD(self, curtime, screenscale)
	local wid, hei = screenscale * 228, screenscale * 72

	local halfwid = w * 0.5
	local x = halfwid - wid * 0.5
	draw.RoundedBox(8, x, 0, wid, hei, color_black_alpha180)

	local y = screenscale * 8

	local flag = ents.FindByClass(GAMEMODE.FlagEntity)[1]
	local flagvalid = flag and flag:IsValid()
	if ENDGAME then
		draw.DrawText("Game Over", "ChatFont", halfwid, y, color_white, TEXT_ALIGN_CENTER)
	elseif GAMEMODE.Intermission then
		draw.DrawText("GOAL!!", "ChatFont", halfwid, y, color_white, TEXT_ALIGN_CENTER)
	elseif GAMESTATE == GAMESTATE_PLAY then
		if flagvalid then
			local owner = flag:GetOwner()
			if owner:IsValid() and owner:IsPlayer() then
				if owner == MySelf then
					draw.DrawText("You have the ball!", "ChatFont", halfwid, y, Color(30, 255, 30, 60 + math.abs(math.sin(RealTime() * 8) * 195)), TEXT_ALIGN_CENTER)
				elseif owner:Team() == MySelf:Team() then
					draw.DrawText("Team has the ball!", "ChatFont", halfwid, y, Color(30, 255, 255, 60 + math.abs(math.sin(RealTime() * 6) * 195)), TEXT_ALIGN_CENTER)
				else
					draw.DrawText("Enemy has the ball!", "ChatFont", halfwid, y, Color(255, 20, 20, 60 + math.abs(math.sin(RealTime() * 10) * 195)), TEXT_ALIGN_CENTER)
				end
			elseif flag:GetSkin() == 2 then
				draw.DrawText("Ball is down!", "ChatFont", halfwid, y, Color(255, 255, 255, 200 + math.abs(math.sin(RealTime() * 4) * 55)), TEXT_ALIGN_CENTER)
			else
				draw.DrawText("Ball is home", "ChatFont", halfwid, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
			end
		end
	elseif GAMESTATE == GAMESTATE_BUILD then
		draw.DrawText("Waiting for players", "ChatFont", halfwid, y - screenscale * math.max(0.25, math.sin(RealTime() * 10)) * 8, Color(255, 255, 255, 60 + math.abs(math.sin(RealTime() * 5) * 195)), TEXT_ALIGN_CENTER)
	elseif GAMESTATE == GAMESTATE_VERIFY then
		draw.DrawText("Verify your bases", "ChatFont", halfwid, y, color_white, TEXT_ALIGN_CENTER)
	end
	local texw, texh = surface.GetTextSize("T")
	y = y + texh + screenscale * 8

	local fTimeLeft
	if GAMEMODE.Intermission then
		fTimeLeft = math.max(0, BLITZ_INTERMISSION_TIME - (CurTime() - GAMEMODE.IntermissionBegan))
	else
		fTimeLeft = math.max(0, ROUND_LENGTH - curtime)
	end

	local strTimeLeft
	if fTimeLeft <= 10 then
		strTimeLeft = string.ToMinutesSecondsMilliseconds(fTimeLeft)
	else
		strTimeLeft = ToMinutesSeconds(fTimeLeft)
	end

	draw.DrawText(strTimeLeft, "ChatFont", halfwid, y, color_white, TEXT_ALIGN_CENTER)

	y = screenscale * 8

	local myteam = MySelf:Team()
	local scale32 = screenscale * 32
	local scale64 = scale32 * 2
	for i, teamid in pairs(TEAMS_PLAYING) do
		local flagtex = TeamFlags[teamid]
		local col = team.GetColor(teamid)
		if flagtex then
			local statusx
			if i == 1 then
				statusx = x + wid + screenscale * 8
			elseif i == 2 then
				statusx = x - scale64 - screenscale * 8
			elseif i == 3 then
				statusx = x + wid + screenscale * 16 + scale64
			elseif i == 4 then
				statusx = x - scale64 * 2 - screenscale * 16
			end

			draw.RoundedBox(8, statusx, 0, scale64, scale64 + y, color_black_alpha180)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(flagtex)
			surface.DrawTexturedRect(statusx + scale32 * 0.5, scale32, scale32, scale32)

			draw.DrawText(team.GetScore(teamid).."/"..BLITZ_SCORE_LIMIT, "ChatFont", statusx + scale32, screenscale * 4, col, TEXT_ALIGN_CENTER)
		end

		local flag = team.GetFlag(teamid)
		if flag:IsValid() then
			local toscreen = flag:GetPos():ToScreen()
			if toscreen.visible then
				surface.SetTexture(texHome)
				surface.SetDrawColor(col.r, col.g, col.b, 255)
				surface.DrawTexturedRectRotated(toscreen.x, toscreen.y, scale32, scale32, math.sin(curtime * 2) * 30)
			end
		end
	end

	if MySelf:IsCarrying() then
		local mypos = MySelf:GetShootPos()
		local closestpoint
		local closest = 99999
		for _, teamid in pairs(TEAMS_PLAYING) do
			if teamid ~= myteam then
				local fp = team.TeamInfo[teamid].FlagPoint
				if fp then
					local dist = fp:Distance(mypos)
					if dist < closest then
						closest = dist
						closestpoint = fp
					end
				end
			end
		end

		if closestpoint then
			local toscr = (closestpoint + Vector(0, 0, -72)):ToScreen()
			if toscr.visible then
				local x, y = toscr.x, toscr.y

				--surface.SetTexture(texCarryHint)
				local brit = math.abs(math.cos(curtime * 10)) * 200
				--surface.SetDrawColor(brit, 255, brit, 255)
				--surface.DrawTexturedRect(x - screenscale * 128, y - screenscale * 128, screenscale * 256, screenscale * 256)]]

				draw.SimpleText("G O A L", "teamplay_scoreboard", x, y, Color(brit, 255, brit, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			end
		end
	end

	if not flagvalid then return end

	local toscreen = flag:GetPos():ToScreen()
	local skin = flag:GetSkin()
	local r,g,b,a = flag:GetColor()
	surface.SetDrawColor(r, g, b, 255)
	if skin == 0 then
		if toscreen.visible then
			surface.SetTexture(texHome)
			surface.DrawTexturedRectRotated(toscreen.x, toscreen.y, scale32, scale32, math.sin(curtime * 2) * 30)
		end
	elseif skin == 1 then
		if toscreen.visible then
			surface.SetTexture(texField)
			surface.DrawTexturedRectRotated(toscreen.x, toscreen.y, scale32, scale32, 0)
			surface.SetTexture(surface.GetTextureID("VGUI/loading-rotate"))
			local siz = math.abs(math.sin(curtime * 5) * screenscale * 26 + screenscale * 10) + scale64 + screenscale * 16
			local dehue = math.abs(math.sin(curtime * 5) * 200)
			surface.SetDrawColor(255, 255 - dehue, 255 - dehue, 180)
			surface.DrawTexturedRectRotated(toscreen.x, toscreen.y, siz, siz, curtime * 360)
		end
	elseif toscreen.visible then
		surface.SetTexture(texDropped)
		local bounce = math.abs(math.cos(curtime * 4)) * scale32
		surface.DrawTexturedRectRotated(toscreen.x, toscreen.y - bounce * 0.5, scale32, scale32, 0)
	end
end

function GM:BLTZInitialize()
	self.Name = "Retro TeamPlay (Blitz)"
	self.GameType = "BLTZ"
	self.FlagEntity = "flag_blitz"
	self.DrawGameTypeHUD = DrawGameTypeHUD

	function self:GameTypeEndIntermission()
		timer.Destroy("CreateGoalShockwaves")
	end

	function self:BallTaken(pl, teamid)
		if teamid == MySelf:Team() then
			surface.PlaySound("nox/nflagpickup.ogg")
		else
			surface.PlaySound("npc/roller/mine/rmine_tossed1.wav")
		end

		if pl:IsValid() and pl:IsPlayer() then
			self:AddNotify(pl:Name().." of the "..team.GetName(teamid).." team picked up the ball!!", team.GetColor(teamid), 6)
		else
			self:AddNotify("The "..team.GetName(teamid).." team picked up the ball!!", team.GetColor(teamid), 6)
		end
	end

	function self:BallDropped(pl, teamid)
		surface.PlaySound("nox/knockout.ogg")

		if pl:IsValid() and pl:IsPlayer() then
			self:AddNotify(pl:Name().." of the "..team.GetName(teamid).." team dropped the ball!!", team.GetColor(teamid), 6)
		else
			self:AddNotify("The "..team.GetName(teamid).." team dropped the ball!!", team.GetColor(teamid), 6)
		end
	end

	function self:BallReset()
		surface.PlaySound("nox/nflagreturn.ogg")

		self:AddNotify("Ball has been reset!", color_white, 6)
	end

	usermessage.Hook("BallScored", function(um)
		self:BallScored(um:ReadEntity(), um:ReadShort(), um:ReadEntity(), um:ReadEntity())
	end)

	usermessage.Hook("BallReset", function(um)
		self:BallReset()
	end)

	usermessage.Hook("BallTaken", function(um)
		self:BallTaken(um:ReadEntity(), um:ReadShort())
	end)

	usermessage.Hook("BallDropped", function(um)
		self:BallDropped(um:ReadEntity(), um:ReadShort())
	end)

	local function CreateShockwave(pos, ang)
		--ParticleEffect("aurora_shockwave", pos + Vector(0, 0, math.sin(CurTime() * 3) * 24), ang)
	end

	local lasttop = 0
	function self:BallScored(pl, teamid, ball, goal)
		surface.PlaySound("ambient/levels/citadel/portal_open1_adpcm.wav")
		surface.PlaySound("nox/flagcaptured.ogg")

		if pl:IsValid() and pl:IsPlayer() then
			self:AddNotify(pl:Name().." scores for the "..team.GetName(teamid).." team!!", team.GetColor(teamid), BLITZ_INTERMISSION_TIME + 1)
		else
			self:AddNotify("The "..team.GetName(teamid).." team scores!!", team.GetColor(teamid), BLITZ_INTERMISSION_TIME + 1)
		end

		local maxscore = 0
		local maxteam = 0
		for _, id in ipairs(TEAMS_PLAYING) do
			if team.GetScore(id) > maxscore then
				maxteam = id
				maxscore = team.GetScore(id)
			end
		end

		if maxteam ~= lasttop and maxteam == selfteam then
			lasttop = maxteam
			self:AddNotify(team.GetName(selfteam).." takes the lead!!", team.GetColor(maxteam), BLITZ_INTERMISSION_TIME + 1)
		end

		local pos, ang = goal:GetPos() + Vector(0, 0, 32), Angle(0, 0, 0)
		if pl == MySelf and goal:IsValid() then
			ParticleEffect("citadel_shockwave", pos + Vector(0, 0, math.sin(CurTime() * 3) * 24), ang)
		end

		timer.Create("CreateGoalShockwaves", 0.35, 0, CreateShockwave(pos, ang))
	end
end
