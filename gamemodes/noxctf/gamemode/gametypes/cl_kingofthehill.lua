currentholding = TEAM_SPECTATOR

local matField = surface.GetTextureID("noxctf/flagicon_field")
local lastwarningtime = 0
local nextholdingupdate = 0

local function DrawGameTypeHUD(self, curtime)
	local flag = ents.FindByClass("koth")[1]
	if not flag or not flag:IsValid() then return end

	local toscreen = (flag:GetPos() + Vector(0, 0, 32)):ToScreen()
	local teamcarrying = flag:GetSkin()

	if toscreen.visible then
		local c = team.GetColor(currentholding) or Color(255, 255, 255, 255)

		surface.SetTexture(matField)
		surface.SetDrawColor(c.r, c.g, c.b, 255)
		surface.DrawTexturedRect(toscreen.x - 16, toscreen.y - 32, 32, 32)
	end

	if nextholdingupdate < curtime then
		nextholdingupdate = curtime + 0.5

		currentholding = TEAM_SPECTATOR

		local kothent = ents.FindByClass("koth")[1]
		if kothent and kothent:IsValid() then
			local kpos = kothent:GetPos()

			for _, teamid in pairs(TEAMS_PLAYING) do
				team.TeamInfo[teamid].CurrentInArea = 0
			end

			for _, ent in pairs(player.GetAll()) do
				if ent:Alive() then
					local pos = ent:GetPos()
					pos.z = kpos.z
					if pos:Distance(kpos) < 512 then
						local teamid = ent:Team()
						team.TeamInfo[teamid].CurrentInArea = team.TeamInfo[teamid].CurrentInArea + 1
					end
				end
			end

			local topplayers = 0
			local topteam = 0
			for teamid, teamtab in pairs(team.TeamInfo) do
				if topplayers < team.TeamInfo[teamid].CurrentInArea then
					topplayers = team.TeamInfo[teamid].CurrentInArea
					topteam = teamid
				end
			end

			local numwin = 0
			if 0 < topplayers then
				for teamid, teamtab in pairs(team.TeamInfo) do
					if topplayers == teamtab.CurrentInArea then
						currentholding = teamid
						numwin = numwin + 1
					end
				end

				if numwin ~= 1 then currentholding = 0 end
			end
		end
	end

	local fx = 4
	local fy = 4
	for i, teamid in pairs(TEAMS_PLAYING) do
		local col = team.TeamInfo[teamid].Color
		local tim = (KOTH_TIME - team.GetScore(teamid))
		local text = ToMinutesSeconds(tim)
		if teamid == currentholding then
			surface.SetDrawColor(40, 40, 40, 110)
			surface.DrawRect(fx, fy, 64, 32)
			if 0 < math.sin(RealTime() * 23) then
				surface.SetDrawColor(col.r, col.g, col.b, 200)
				surface.DrawOutlinedRect(fx, fy, 64, 32)
				draw.SimpleText(text, "Default", fx + 24, fy + 16, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				draw.SimpleText(team.TeamInfo[teamid].CurrentInArea, "teamplay", fx + 60, fy + 16, col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			else
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawOutlinedRect(fx, fy, 64, 32)
				draw.SimpleText(text, "DefaultBold", fx + 24, fy + 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				draw.SimpleText(team.TeamInfo[teamid].CurrentInArea, "teamplay", fx + 60, fy + 16, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
			if tim < 20 then
				local floortim = math.floor(tim)
				if lastwarningtime ~= floortim then
					surface.PlaySound("buttons/button17.wav")
					lastwarningtime = floortim
				end
			end
		else
			surface.SetDrawColor(0, 0, 0, 90)
			surface.DrawRect(fx, fy, 64, 32)
			surface.SetDrawColor(col.r, col.g, col.b, 200)
			surface.DrawOutlinedRect(fx, fy, 64, 32)
			draw.SimpleText(text, "Default", fx + 24, fy + 16, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			draw.SimpleText(team.TeamInfo[teamid].CurrentInArea, "teamplay", fx + 60, fy + 16, col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		fy = fy + 40
		if 64 < fy then
			fx = 72
			fy = 4
		end
	end

	draw.RoundedBox(8, 2, SCORE_HEIGHT - SCORE_TEXT_HEIGHT - 2, SCORE_WIDTH, SCORE_TEXT_HEIGHT * 2.1, color_black_alpha90)

	if END_GAME then
		draw.DrawText("Ending map...", "DefaultSmall", SCORE_WIDTH - 16, SCORE_HEIGHT - SCORE_TEXT_HEIGHT, COLOR_RED, TEXT_ALIGN_RIGHT)
	else
		draw.DrawText("King of the Hill", "DefaultBold", 16, SCORE_HEIGHT - SCORE_TEXT_HEIGHT, color_white, TEXT_ALIGN_LEFT)
	end
end

function GM:KOTHInitialize()
	self.GameType = "KOTH"
	self.FlagEntity = nil
	self.DrawGameTypeHUD = DrawGameTypeHUD
	self.HELP_TEXT = string.Explode("@", [[^rNoX TeamPlay: KOTH@ @The point of this gametype is to control the king area for the longest time.@Props have a respectable amount of health. Use them to fortify your base.@Some props have weaknesses to certain elements and strengths against others.@Example, metal props are good against physical damage but bad against electricity.@There are numerous special props you can also use. Most special props have frequencies on them.@If a prop is the same frequency as another nearby prop, it can not operate correctly and will be removed.@Most special structures must be placed on solid, flat ground.@ @^rGaining Silver@Silver is earned by doing just about anything benificial for your team.@Attacking the enemy base will earn you lots of Silver and so will defending your own from attackers.@Killing enemies will give you Silver according to how long that enemy has been alive.@Spawn killing will give you very limited Silver, while killing experienced people will earn you tons.@ @^rCharacter advancement@Classes and abilities are all currently free but some require awards.@Awards are gained by doing special things like killing 1,000 people or other specific things.@ @^rUsing spells and abilities@Mana Obelisks hold regenerating amuonts of mana for your own reserves. Simply touch them to absorb their mana.@New spells and abilities can be bound to your radial speedbar by pressing F3.@Hold right click to select your speedbar if you have any spells assigned. Hold right + left to bring up your secondary speed bar.@Press a directional key while the speedbar is open to set that ability as your speedkey.@Use your ability or spell selected by pressing SPRINT.@You can also bind spells DIRECTLY to keys using bind key "cast spell name"@bind t "cast death ray" in the console will make you instantly cast Death Ray.@Some spells and abilities have an inversed effect that can be activated by holding USE while casting them.@This is invaluable when supporting your teamates.@Some classes do not actually have any abilities at all!@ @^rBuilding@Most maps allow you to build during a building phase. Use right click to spawn props and even more advanced things like teleporters and turrets.@ @^rVehicles@This gamemode supports the use of vehicles. Vehicles are spawned through the use of a vehicle pad, wich must be spawned during build mode or built by your team's Crafters.@Each team has a maximum amount of vehicles that can be spawned at a time.@ @ @^rNote that this is in constant development and updates/additions are added frequently!!]])

	for _, teamtab in pairs(team.TeamInfo) do
		teamtab.CurrentInArea = 0
	end
end
