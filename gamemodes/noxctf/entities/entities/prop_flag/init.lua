// Source Forts compatability
ENT.Type = "point"

function ENT:Initialize()
	self:Fire("kill", "", 15)
end

function ENT:KeyValue(key, value)
	if string.lower(key) == "teamnum" then
		if tonumber(value) == 3 then
			if team.TeamInfo[TEAM_RED] then
				team.TeamInfo[TEAM_RED].FlagPoint = self:GetPos()
			end
		elseif tonumber(value) == 2 then
			if team.TeamInfo[TEAM_BLUE] then
				team.TeamInfo[TEAM_BLUE].FlagPoint = self:GetPos()
			end
		elseif tonumber(value) == 4 then
			if team.TeamInfo[TEAM_YELLOW] then
				team.TeamInfo[TEAM_YELLOW].FlagPoint = self:GetPos()
			end
		elseif tonumber(value) == 5 then
			if team.TeamInfo[TEAM_GREEN] then
				team.TeamInfo[TEAM_GREEN].FlagPoint = self:GetPos()
			end
		end
	end
end
