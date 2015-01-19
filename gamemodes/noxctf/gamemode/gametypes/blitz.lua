function GM:BLTZInitialize()
	self.Name = "Retro TeamPlay (Blitz)"
	self.GameType = "BLTZ"
	self.FlagEntity = "flag_blitz"
	BroadcastLua("GAMEMODE:BLTZInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:BLTZInitialize()")
	end)

	for _, ent in pairs(ents.FindByClass("prop_generator")) do 
		ent:Remove()
	end

	local ent = ents.Create(self.FlagEntity)
	if ent:IsValid() then
		ent:SetPos(self.BallDrop)
		ent:Spawn()
		self.Flag = ent
		self.Ball = ent
	end

	for i, teamid in pairs(TEAMS_PLAYING) do
		local tab = team.TeamInfo[teamid]
		if tab.FlagPoint then
			local ent = ents.Create("prop_blitzgoal")
			if ent:IsValid() then
				local entpos = tab.FlagPoint
				ent:SetPos(entpos)
				local pos = Vector(self.BallDrop.x, self.BallDrop.y, self.BallDrop.z)
				pos.z = entpos.z
				ent:SetAngles((pos - entpos):Angle())
				ent:SetTeamID(teamid)
				local col = team.GetColor(teamid)
				ent:SetColor(Color(col.r, col.g, col.b, 255))
				ent:Spawn()
				tab.Flag = ent
				ent:DropToFloor()
			end
		end
	end

	function self:BallReset()
		umsg.Start("BallReset")
		umsg.End()
	end

	function self:BallTaken(pl)
		umsg.Start("BallTaken")
			umsg.Entity(pl)
			umsg.Short(pl:GetTeamID())
		umsg.End()
	end

	function self:BallDropped(pl)
		if pl and pl:IsValid() then
			umsg.Start("BallDropped")
				umsg.Entity(pl)
				umsg.Short(pl:GetTeamID())
			umsg.End()
		end
	end

	function self:HandleOvertime()
		local topscore = 0
		local topteam = 0
		for _, teamid in pairs(TEAMS_PLAYING) do
			if topscore < team.GetScore(teamid) then
				topscore = team.GetScore(teamid)
				topteam = teamid
			end
		end
		local numwin = 0
		for _, teamid in pairs(TEAMS_PLAYING) do
			if topscore == team.GetScore(teamid) then
				numwin = numwin + 1
			end
		end

		if numwin == 1 then
			self:EndGame(topteam, {})
		else
			self:EndGame(0, {})
		end
	end
end
