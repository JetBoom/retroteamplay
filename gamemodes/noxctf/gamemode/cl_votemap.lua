local numgtvotes = {}

function GetMostGTVotes()
	local most = 0
	local gtname = "this one"
	for name, num in pairs(numgtvotes) do
		if most < num then
			most = num
			gtname = name
		end
	end

	return gtname, most
end

function GM:GetGTVotes()
	return numgtvotes
end

usermessage.Hook("recgtnumvotes", function(um)
	numgtvotes[um:ReadString()] = um:ReadShort()
end)

hook.Add("Initialize", "GameTypeVotingInitialize", function()
	hook.Remove("Initialize", "GameTypeVotingInitialize")

	if not GAMEMODE.GameTypes then return end

	function OpenGTVoteMenu()
		if pVoteMap then
			pVoteMap:SetVisible(false)
		end

		if pGTVote and pGTVote:Valid() then
			return
		end

		local wid = 340
		local halfwid = wid * 0.5

		local Window = vgui.Create("DFrame")
		Window:SetWide(wid)
		Window:SetTitle("Vote for a Game Type!")
		Window:SetDeleteOnClose(true)
		Window:SetKeyboardInputEnabled(false)
		pGTVote = Window

		local y = 32

		local wb = WordBox(Window, "Vote for a Game Type to be played next!", "DefaultBold", COLOR_RED)
		wb:SetPos(halfwid - wb:GetWide() * 0.5, y)
		y = y + wb:GetTall() + 8

		local lab = EasyLabel(Window, "The next game type is")
		lab:SetPos(8, y)
		lab.Think = function(me)
			local gtname, numvotes = GetMostGTVotes()
			if me.MostVotes ~= numvotes or me.GTName ~= gtname then
				me.MostVotes = numvotes
				me.GTName = gtname
				me:SetText("The next game type is "..gtname.." with "..numvotes.." votes.")
				me:SizeToContents()
			end
		end
		y = y + lab:GetTall() + 16

		for i, gt in ipairs(GAMEMODE.GameTypes) do
			local but = EasyButton(Window, GAMEMODE.GameTranslates[gt] or gt, 0, 4)
			but:SetWide(wid - 16)
			but:SetPos(8, y)
			but.GameType = gt
			but.Votes = -1
			but.OldThink = but.Think
			but.Think = function(me)
				local votes = numgtvotes[me.GameType] or 0

				if votes ~= me.Votes then
					me:SetText((GAMEMODE.GameTranslates[me.GameType] or me.GameType).." - "..votes.." votes")
				end
			end
			if GAMEMODE.GameTypeDescriptions and GAMEMODE.GameTypeDescriptions[gt] then
				but:SetTooltip(GAMEMODE.GameTypeDescriptions[gt])
			end
			but.DoClick = function()
				RunConsoleCommand("votegt", gt)
			end

			y = y + but:GetTall() + 4
		end

		Window:SetTall(y + 4)
		Window:Center()
		Window:SetVisible(true)
		Window:MakePopup()
	end
	concommand.Add("votegtopen", OpenGTVoteMenu)
end)
