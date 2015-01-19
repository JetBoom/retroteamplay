function pSlotMachine(data)
	local machine = data:ReadEntity()
	local bet = machine.MinBet
	local started = true

	local Window = vgui.Create("DFrame")
	Window:SetTitle(" ")
	Window:SetSize(425, 150)
	Window:Center()
	Window:AlignBottom(25)
	--Window:SetDraggable(true)
	Window:ShowCloseButton(false)
	Window:MakePopup()
	Window.Think = function(me)
		local player = machine:GetSlotPlayer()
		
		if player == NULL then me:Remove() return end
		if not player:Alive() then
			me:Remove()
		end
	end

	local NoticeWin = vgui.Create("DPanel", Window)
	NoticeWin:SetSize(370, 40)
	NoticeWin:SetPos(5, 5)
	
	local BetNum = vgui.Create("DLabel", NoticeWin)
	BetNum:SetFont("Slot26")
	BetNum:SetText("Bet: ".. bet)
	BetNum:SetColor(Color(0, 0, 0, 255))
	BetNum:SizeToContents()
	BetNum:Center()
	BetNum.Think = function(me)
		me:SetText("Bet: ".. bet)
		me:SizeToContents()
		me:Center()
		me:AlignLeft(5)
	end
	
	
	local BetText = vgui.Create("DLabel", NoticeWin)
	BetText:SetFont("Slot26")
	BetText:SetText("AAA")
	BetText:SetColor(Color(0, 0, 0, 255))
	BetText:SizeToContents()
	BetText:Center()
	BetText.Think = function(me)
		if machine:IsRolling() then
			me:SetText("Good Luck!")
		elseif machine:GetWon() or machine:GetJackpot() then
			me:SetText( (machine:GetJackpot() and "JACKPOT!" or "You get") .." ".. machine:GetSlotWinValue() .." silver!")
		elseif not machine:GetWon() then
			me:SetText("Try again :(")
		end
		
		if started then
			me:SetText("Welcome back!")
		end
		
		me:SizeToContents()
		me:Center()
		me:AlignRight(5)
	end
	
	local Bet = vgui.Create("DButton", Window)
	Bet:SetSize(80, 80)
	Bet:AlignLeft(10)
	Bet:AlignBottom(5)
	Bet:SetFont("Slot22")
	Bet:SetText("Bet")
	Bet.DoClick = function()
		bet = bet + machine.PerBet
		if bet > machine.MaxBet then
			bet = machine.MinBet
		end
		
		surface.PlaySound("slot_sounds/coin_insert.wav")
	end
	
	local MaxBet = vgui.Create("DButton", Window)
	MaxBet:SetSize(80, 80)
	MaxBet:Center()
	MaxBet:AlignBottom(5)
	MaxBet:SetFont("Slot22")
	MaxBet:SetText("Max Bet")
	MaxBet.DoClick = function()
		if machine:IsRolling() then return end
		started = false
		bet = machine.MaxBet	

		surface.PlaySound("slot_sounds/pull.wav")
		RunConsoleCommand("__nox_mptv_startslot", machine:EntIndex(), bet)
	end

	local Spin = vgui.Create("DButton", Window)
	Spin:SetSize(80, 80)
	Spin:AlignRight(10)
	Spin:AlignBottom(5)
	Spin:SetFont("Slot22")
	Spin:SetText("Spin")
	Spin.DoClick = function()
		if machine:IsRolling() then return end
		started = false

		surface.PlaySound("slot_sounds/pull.wav")
		RunConsoleCommand("__nox_mptv_startslot", machine:EntIndex(), bet)
	end
	
	local Close = vgui.Create("DButton", Window)
	Close:SetSize(40, 40)
	Close:AlignTop(5)
	Close:AlignRight(5)
	Close:SetFont("Slot26")
	Close:SetText("X")
	Close.DoClick = function()
		if machine:IsRolling() then return end

		surface.PlaySound("buttons/button5.wav")
		RunConsoleCommand("__nox_mptv_resetslot", machine:EntIndex())

		Window:Remove()
	end
	
	surface.PlaySound("buttons/bell1.wav")
end
usermessage.Hook("openslotwindow", pSlotMachine)