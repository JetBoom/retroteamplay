function GM:KOTHInitialize()
	self.GameType = "KOTH"
	self.FlagEntity = nil
	BroadcastLua("GAMEMODE:KOTHInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:KOTHInitialize()")
	end)

	hook.Add("PlayerInitialSpawn", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:KOTHInitialize()")
		pl.KingTime = 0
	end)

	for _, teamid in pairs(TEAMS_PLAYING) do
		team.TeamInfo[teamid].RealScore = 0
		team.TeamInfo[teamid].LastMinute = math.floor(KOTH_TIME / 60)
	end

	function self:KOTH_AreaMoved()
		self:CenterPrintAll("The hill has moved!~snox/nflagdrop.wav")
	end

	local nextrandomize = 60
	function self:KOTH_AwardPoints()
		if ENDGAME or #player.GetAll() <= 1 then return end

		local kothent = KOTHENT

		if kothent then
			local kpos = kothent:GetPos()

			local teamcount = {}
			for _, teamid in pairs(TEAMS_PLAYING) do
				teamcount[teamid] = 0
			end

			for _, ent in pairs(player.GetAll()) do
				if ent:Alive() then
					local pos = ent:GetPos()
					pos.z = kpos.z
					if pos:Distance(kpos) < 512 then
						local teamid = ent:Team()
						teamcount[teamid] = teamcount[teamid] + 1
					end
				end
			end

			local topplayers = 0
			local topteam = 0
			for teamid, count in pairs(teamcount) do
				if topplayers < count then
					topplayers = count
					topteam = teamid
				end
			end
			local numwin = 0
			for teamid, count in pairs(teamcount) do
				if topplayers == count then
					numwin = numwin + 1
				end
			end

			if numwin == 1 then
				team.SetScore(topteam, team.GetScore(topteam) + 1)
				if KOTH_TIME <= team.GetScore(topteam) then
					self:EndGame(topteam, {})
					return
				end
			end

			if nextrandomize < CurTime() then
				nextrandomize = CurTime() + 60

				local tab = ents.FindByClass("hillarea")
				if 0 < #tab then
					local currentpos = kothent:GetPos()
					for i=1, #tab do
						local pos = tab[i]:GetPos()
						if pos.x == currentpos.x and pos.y == currentpos.y then
							table.remove(tab, i)
							break
						end
					end
					if #tab <= 0 then return end
					self:KOTH_AreaMoved()
					kothent:SetPos(tab[math.random(1, #tab)]:GetPos())
				else
					local pos = Vector(0,0,0)
					for _, teamid in pairs(TEAMS_PLAYING) do
						pos = pos + team.TeamInfo[teamid].FlagPoint
					end
					pos = pos / #TEAMS_PLAYING
					pos = pos + Vector(math.Rand(-1500, 1500), math.Rand(-1500, 1500), 0)
					local x = 0
					while util.PointContents(pos) ~= 0 and x < 100 do
						x = x + 1

						pos = Vector(0,0,0)
						for _, teamid in pairs(TEAMS_PLAYING) do
							pos = pos + team.TeamInfo[teamid].FlagPoint
						end
						pos = pos / #TEAMS_PLAYING
						pos = pos + Vector(math.Rand(-1500, 1500), math.Rand(-1500, 1500), 0)
					end
					self:KOTH_AreaMoved()
					kothent:SetPos(pos)
				end
			end
		end
	end

	local ent = ents.Create("koth")
	if ent:IsValid() then
		local tab = ents.FindByClass("kotharea")
		local tab2 = ents.FindByClass("balldrop")
		if 0 < #tab then
			ent:SetPos(tab[math.random(1, #tab)]:GetPos())
		elseif 0 < #tab2 then
			ent:SetPos(tab2[math.random(1, #tab2)]:GetPos())
		else
			local pos = Vector(0,0,0)
			for _, teamid in pairs(TEAMS_PLAYING) do
				pos = pos + team.TeamInfo[teamid].FlagPoint
			end
			pos = pos / #TEAMS_PLAYING
			ent:SetPos(pos)
		end
		ent:Spawn()
		KOTHENT = ent
	end
end
