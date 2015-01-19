hook.Add("Initialize", "GameTypeVotingInitialize", function()
	hook.Remove("Initialize", "GameTypeVotingInitialize")

	if not GAMEMODE.GameTypes then return end

	GAMEMODE.GameTypeVoted = {}
	GAMEMODE.GameTypeVotedVotes = {}
	GAMEMODE.GameTypeVotes = {}
	for _, gt in pairs(GAMEMODE.GameTypes) do
		GAMEMODE.GameTypeVotes[gt] = 0
	end
	GAMEMODE.TopGameTypeVotes = 0

	concommand.Add("votegt", function(sender, command, arguments)
		if not sender:IsValid() or CurTime() < (sender.NextVoteGameType or 0) then return end
		sender.NextVoteGameType = CurTime() + 1.5

		if not ENDGAME then
			sender:PrintMessage(HUD_PRINTTALK, "Can only vote for a gametype after the current game has ended!")
			return
		end

		if not VOTEMAPOVER or CurTime() < VOTEMAPOVER then
			sender:PrintMessage(HUD_PRINTTALK, "Can only vote for a gametype after the map voting stage!")
			return
		end

		arguments = arguments[1]
		if not arguments then return end

		local gonethrough = false
		for _, gt in pairs(GAMEMODE.GameTypes) do
			if arguments == gt then
				gonethrough = true
				break
			end
		end

		if not gonethrough then
			sender:PrintMessage(HUD_PRINTTALK, "Error. Gametype doesn't exist?")
			return
		end

		if GAMEMODE.NoGameTypeTwiceInRow and 1 < #GAMEMODE.GameTypes and arguments == GAMEMODE.GameType then sender:PrintMessage(HUD_PRINTTALK, "The same game type can't be played twice in a row.") return end

		local votes = 1

		local uid = sender:UniqueID()

		local votedalready = GAMEMODE.GameTypeVoted[uid]
		if votedalready == arguments then return end
		if votedalready then
			GAMEMODE.GameTypeVotes[votedalready] = GAMEMODE.GameTypeVotes[votedalready] - GAMEMODE.GameTypeVotedVotes[uid]
			GAMEMODE.GameTypeVotedVotes[uid] = nil
			GAMEMODE.GameTypeVoted[uid] = nil

			umsg.Start("recgtnumvotes")
				umsg.String(votedalready)
				umsg.Short(GAMEMODE.GameTypeVotes[votedalready])
			umsg.End()
		end

		GAMEMODE.GameTypeVoted[uid] = arguments
		GAMEMODE.GameTypeVotedVotes[uid] = votes
		GAMEMODE.GameTypeVotes[arguments] = GAMEMODE.GameTypeVotes[arguments] + votes

		local most = 0
		for _, gt in pairs(GAMEMODE.GameTypes) do
			if GAMEMODE.GameTypeVotes[gt] > most then
				most = GAMEMODE.GameTypeVotes[gt]
				file.Write(GAMEMODE_NAME.."_gametype.txt", gt)
			end
		end

		if votes == 1 then
			PrintMessage(HUD_PRINTTALK, sender:Name().." placed 1 vote for "..arguments..".")
		else
			PrintMessage(HUD_PRINTTALK, sender:Name().." placed "..votes.." votes for "..arguments..".")
		end

		umsg.Start("recgtnumvotes")
			umsg.String(arguments)
			umsg.Short(GAMEMODE.GameTypeVotes[arguments])
		umsg.End()
	end)
end)
