function GM:HTFInitialize()
	self.GameType = "HTF"
	self.FlagEntity = "flag_htf"
	BroadcastLua("GAMEMODE:HTFInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:HTFInitialize()")
	end)

	hook.Add("PlayerInitialSpawn", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:HTFInitialize()")
		pl.CarryLevel = 0
		pl.RealCarryTime = 0
	end)

	for _, teamid in pairs(TEAMS_PLAYING) do
		team.TeamInfo[teamid].RealScore = 0
		team.TeamInfo[teamid].LastMinute = math.floor(HTF_TIME / 60) - 1
	end

	function self:HandleOvertime()
		BroadcastLua("OVERTIME=true")
		self:CenterPrintAll("OVER TIME! Prop health carved!~snox/allyscore.wav", "COLOR_RED")
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

	--Flag Dropped
	function self:HTF_FlagDropped(byplayer)
		self:CenterPrintAll(byplayer:Name().." of "..team.GetName(byplayer:Team()).." dropped the flag!~snox/nflagdrop.wav")
	end

	function self:HTF_FlagTaken(byplayer)
		self:CenterPrintAll(byplayer:Name().." of "..team.GetName(byplayer:Team()).." has the flag!~snox/nflagpickup.wav")
	end

	function self:HTF_FlagReset()
		self:CenterPrintAll("The flag has been reset.~snox/nflagreturn.wav")
	end

	function self:HTF_AwardPoints(carrier, carrierteam, deltatime, ent)
		if ENDGAME then return end

		local tab = team.TeamInfo[carrierteam]
		if not tab.RealScore then tab.RealScore = 0 end
		if not tab.LastMinute then tab.LastMinute = math.floor(HTF_TIME / 60) end

		local newscore = math.min(HTF_TIME, tab.RealScore + deltatime)
		tab.RealScore = newscore

		if team.GetScore(carrierteam) < math.ceil(newscore) then
			team.SetScore(carrierteam, math.ceil(newscore))
			if math.floor((HTF_TIME - newscore) / 60) < tab.LastMinute and HTF_TIME ~= newscore then
			tab.LastMinute = math.floor((HTF_TIME - newscore) / 60)

				if tab.LastMinute == 0 then
					self:CenterPrintAll(team.GetName(carrierteam).." has ONE MORE MINUTE left to win!!~snpc/roller/mine/rmine_tossed1.wav", "COLOR_RED")
				else
					self:CenterPrintAll(team.GetName(carrierteam).." has "..(tab.LastMinute + 1).." more minutes left to win!~sweapons/physcannon/energy_sing_flyby2.wav")
				end
			end
		end

		carrier.RealCarryTime = carrier.RealCarryTime + deltatime * 0.2
		if carrier.CarryLevel < math.ceil(carrier.RealCarryTime) then
			carrier.CarryLevel = math.ceil(carrier.RealCarryTime)
			if NDB then carrier:AddSilver(20) end
			carrier:AddFrags(1)
		end

		if HTF_TIME <= newscore then
			self:EndGame(carrierteam, {})
		end
	end

	function self:GameTypePlayerDisconnected(pl)
		for _, ent in pairs(ents.FindByClass(self.FlagEntity)) do
			if ent:GetCarrier() == pl then
				ent:Dropped(pl)
			end
		end
	end

	--timer.Simple(1, function() GAMEMODE.SetMode(GAMEMODE, 2) end)
end
