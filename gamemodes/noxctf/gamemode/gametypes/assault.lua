function GM:ASLTInitialize()
	self.GameType = "ASLT"
	self.FlagEntity = "core"
	BroadcastLua("GAMEMODE:ASLTInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:ASLTInitialize()")
	end)

	function self:HandleOvertime()
		self:CenterPrintAll("OVER TIME! Core health is now draining! Prop health carved!~snox/allyscore.wav")
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

	function SortTeams(a, b)
		local aamount = team.NumPlayers(a)
		local bamount = team.NumPlayers(b)

		if aamount < bamount * 1.2 and bamount * 0.8 < aamount then
			if BUILD_LENGTH < CurTime() then
				local ascore = math.ceil(team.GetScore(a) * 0.001)
				local bscore = math.ceil(team.GetScore(b) * 0.001)
				if ascore == bscore then
					return team.TotalFrags(a) < team.TotalFrags(b)
				else
					return ascore < bscore
				end
			else
				return team.TotalWeight(a) < team.TotalWeight(b)
			end
		end

		return aamount < bamount
	end
end
