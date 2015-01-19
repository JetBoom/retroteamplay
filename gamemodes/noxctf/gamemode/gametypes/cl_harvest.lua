local matHome = surface.GetTextureID("noxctf/flagicon_home")

local function DrawGameTypeHUD(self, curtime)
	local fx = 4
	local fy = 4
	for i, teamid in pairs(TEAMS_PLAYING) do
		local flag = team.TeamInfo[teamid].Flag

		if flag:IsValid() then
			local toscreen = (flag:GetPos() + Vector(0, 0, 32)):ToScreen()
			local col = team.GetColor(teamid)
			local r, g, b = col.r, col.g, col.b

			surface.SetDrawColor(0, 0, 0, 90)
			surface.DrawRect(fx, fy, 36, 36)
			surface.SetDrawColor(r, g, b, 200)
			surface.DrawOutlinedRect(fx, fy, 36, 36)
			draw.SimpleText("GC", "teamplay_scoreboard", fx + 18, fy, col, TEXT_ALIGN_CENTER)

			if toscreen.visible then
				surface.SetTexture(matHome)
				surface.DrawTexturedRect(toscreen.x - 16, toscreen.y - 32, 32, 32)

				surface.SetFont("DefaultBold")
				local texw, texh = surface.GetTextSize("Mana Shield: 99999")
				draw.RoundedBox(4, toscreen.x - texw * 0.5, toscreen.y + 16, texw, texh + 4, color_black_alpha90)
				draw.DrawText("Mana: "..team.GetScore(teamid), "Default", toscreen.x, toscreen.y + 16, color_white, TEXT_ALIGN_CENTER)
			end

			draw.SimpleText(tostring(team.GetScore(teamid)).."/"..tostring(GC_MAX_MANA), "teamplay_teamscores", fx + 44, fy, team.TeamInfo[teamid].Color, TEXT_ALIGN_LEFT)

			fy = fy + 40
			if 64 < fy then
				fx = 200
				fy = 4
			end
		end
	end

	draw.RoundedBox(8, 2, SCORE_HEIGHT - SCORE_TEXT_HEIGHT + 4, SCORE_WIDTH, SCORE_TEXT_HEIGHT * 2.1, color_black_alpha90)

	if END_GAME then
		draw.DrawText("Ending map...", "DefaultSmall", SCORE_WIDTH - 16, SCORE_HEIGHT - SCORE_TEXT_HEIGHT, COLOR_RED, TEXT_ALIGN_RIGHT)
	else
		local tim = ROUND_LENGTH - curtime
		if tim < 0 then
			draw.DrawText("OVER TIME", "DefaultBold", 16, SCORE_HEIGHT - SCORE_TEXT_HEIGHT + 6, COLOR_RED, TEXT_ALIGN_LEFT)
		elseif tim <= 10 then
			local floortim = math.floor(tim)
			if lastsoundtime != floortim then
				surface.PlaySound("buttons/button17.wav")
				lastsoundtime = floortim
			end
			draw.SimpleText("Harvest: "..string.ToMinutesSecondsMilliseconds(math.max(0, tim)), "DefaultBold", 16, SCORE_HEIGHT - SCORE_TEXT_HEIGHT + 6, COLOR_RED, TEXT_ALIGN_LEFT)
		else
			draw.SimpleText("Harvest: "..ToMinutesSeconds(tim), "DefaultBold", 16, SCORE_HEIGHT - SCORE_TEXT_HEIGHT + 6, color_white, TEXT_ALIGN_LEFT)
		end
	end
end

function GM:HVSTInitialize()
	self.Name = "Retro TeamPlay (Harvest)"
	self.GameType = "Harvest"
	self.FlagEntity = "grandcapacitor"
	self.DrawGameTypeHUD = DrawGameTypeHUD
	self.HELP_TEXT = string.Explode("@", [[^rNoX TeamPlay: Harvest@ @The point of this gamemode is to harvest enough mana in your grand capacitor.@Grand capacitors are invulnerable.@Grand capacitors can be used to power nearby deployables.@During OVER TIME, grand capacitors will generate mana.@Some props have weaknesses to certain elements and strengths against others.@Example, metal props are good against physical damage but bad against electricity.@There are numerous special props you can also use. Most special props have frequencies on them.@If a prop is the same frequency as another nearby prop, it can not operate correctly and will be removed.@Most special structures must be placed on solid, flat ground.@ @^rGaining Silver@Silver is earned by doing just about anything benificial for your team.@Attacking the enemy core will earn you lots of Silver and so will defending your own from attackers.@Killing enemies will give you Silver according to how long that enemy has been alive.@Spawn killing will give you very limited Silver, while killing experienced people will earn you tons.@ @^rCharacter advancement@Classes and abilities are all currently free but some require awards.@Awards are gained by doing special things like killing 1,000 people or other specific things.@ @^rUsing spells and abilities@Mana Obelisks hold regenerating amuonts of mana for your own reserves. Simply touch them to absorb their mana.@New spells and abilities can be bound to your radial speedbar by pressing F3.@Hold right click to select your speedbar if you have any spells assigned. Hold right + left to bring up your secondary speed bar.@Press a directional key while the speedbar is open to set that ability as your speedkey.@Use your ability or spell selected by pressing SPRINT.@You can also bind spells DIRECTLY to keys using bind key "cast spell name"@bind t "cast death ray" in the console will make you instantly cast Death Ray.@Some spells and abilities have an inversed effect that can be activated by holding USE while casting them.@This is invaluable when supporting your teamates. Remember that some classes do not actually have any abilities at all!@ @^rBuilding@Most maps allow you to build during a building phase. Use right click to spawn props and even more advanced things like teleporters and turrets.@ @^rVehicles@This gamemode supports the use of vehicles. Vehicles are spawned through the use of a vehicle pad, wich must be spawned during build mode or by your team's Crafters.@Each team has a maximum amount of vehicles that can be spawned at a time!@ @ @^rNote that this is in constant development and updates/additions are added frequently!!]])
end
