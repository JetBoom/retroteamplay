team = {}
team.TeamInfo = {}
team.DefaultColor = Color(255, 255, 100, 255)

team.TeamInfo[TEAM_CONNECTING] = {Name = "Joining/Connecting", Color = DefaultColor, Score = 0, Props = 9999}
team.TeamInfo[TEAM_UNASSIGNED] = {Name = "Unassigned", Color = DefaultColor, Score = 0, Props = 9999}
team.TeamInfo[TEAM_SPECTATOR] = {Name = "Spectator", Color = DefaultColor, Score = 0, Props = 9999}

function team.SetUp(id, name, color)
	team.TeamInfo[id] = {Name = name, Color = color, Score = 0, Props = 0}
end

function team.TotalDeaths(index)
	if not index then return 0 end

	local score = 0
	for id, pl in pairs(player.GetAll()) do
		if pl:Team() == index then
			score = score + pl:Deaths()
		end
	end
	return score
end

function team.TotalFrags(index)
	if not index then return 0 end

	local score = 0
	for id, pl in pairs(player.GetAll()) do
		if pl:Team() == index then
			score = score + pl:Frags()
		end
	end
	return score
end

function team.NumPlayers(index)
	if index then
		return #team.GetPlayers(index)
	end
	return 0
end

function team.GetPlayers(index)
	if not index then return {} end

	local TeamPlayers = {}

	for id,pl in pairs(player.GetAll()) do
		if pl:Team() == index then
			table.insert(TeamPlayers, pl)
		end
	end

	return TeamPlayers
end

function team.GetScore(index)
	if index then
		return GetGlobalInt(index.."Sc", 0)
	end

	return 0
end

function team.GetProps(index)
	if index then
		return GetGlobalInt(index.."Pro", 0)
	end

	return 0
end

function team.SetProps(index, props)
	if index then
		SetGlobalInt(index.."Pro", props)
	end
end

function team.AddProps(index, props)
	if index then
		team.SetProps(index, team.GetProps(index) + props)
	end
end

function team.GetMana(index)
	return GetGlobalInt(index.."Mana", 0)
end

function team.SetMana(index, mana)
	SetGlobalInt(index.."Mana", mana)
end

function team.GetMaxMana(index)
	return GetGlobalInt(index.."MaxMana", 1000)
end

function team.SetMaxMana(index, mana)
	SetGlobalInt(index.."MaxMana", mana)
end

function team.GetManaRate(index)
	return GetGlobalInt(index.."MRate", 0)
end

function team.SetManaRate(index, rate)
	SetGlobalInt(index.."MRate", rate)
end

function team.GetName(index)
	if not team.TeamInfo[index] then return "" end
	return team.TeamInfo[index].Name
end

function team.GetColor(index)
	if not team.TeamInfo[index] then return team.DefaultColor end
	return team.TeamInfo[index].Color
end

function team.SetScore(index, score)
	if index then
		SetGlobalInt(index.."Sc", score)
	end
end

function team.AddScore(index, score)
	if index then
		team.SetScore(index, team.GetScore(index) + score)
	end
end

function team.TotalValue(index)
	local value = 0
	for _, pl in pairs(team.GetPlayers(index)) do
		value = value + pl:TeamValue()
	end
	return value
end

function team.GetColor(index)
	if team.TeamInfo[index] then
		return team.TeamInfo[index].Color
	end

	return team.DefaultColor
end
