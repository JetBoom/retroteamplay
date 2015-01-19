function GM:CTFInitialize()
	self.GameType = "CTF"
	self.FlagEntity = "flag"
	BroadcastLua("GAMEMODE:CTFInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:CTFInitialize()")
	end)

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
			MAX_SCORE = topscore + 1
			self:CenterPrintAll("OVER TIME! "..MAX_SCORE.." point"..(MAX_SCORE == 1 and "" or "s").." to win! Prop health carved!~snox/allyscore.wav")
			for _, prop in pairs(ALLPROPS) do
				if prop.PHealth then
					prop.PHealth = math.ceil(prop.PHealth * 0.25)
					prop.MaxPHealth = math.ceil(prop.MaxPHealth * 0.25)
				end
			end
			for _, proptype in pairs(PROPTYPES) do
				proptype.PHealth = math.ceil(proptype.PHealth * 0.25)
			end
		end
	end

	function self:GameTypePlayerDisconnected(pl)
		for _, ent in pairs(ents.FindByClass(self.FlagEntity)) do
			if ent:GetCarrier() == pl then
				ent:Dropped(pl)
			end
		end
	end
end
