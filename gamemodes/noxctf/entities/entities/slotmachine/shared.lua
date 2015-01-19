--[[
			  MPTV Slot Machine v3
  Made only for the Official Multiplayer TV Server

			   Created by: ptown2
				Model by: Benjy
]]--
util.PrecacheSound("slot_sounds/jackpot.wav")
util.PrecacheSound("slot_sounds/win.wav")
util.PrecacheSound("slot_sounds/stop.wav")
util.PrecacheSound("slot_sounds/pull.wav")
util.PrecacheSound("slot_sounds/coin_insert.wav")

include("sh_meta.lua")

ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.SlotDistance = 64
ENT.MinPot = 15000
ENT.MinBet = 25
ENT.MaxBet = 300
ENT.PerBet = ENT.MinBet
ENT.SlotEntries = {
	--{name, image (material, png), cashout (bet * multiplier), rarity (bigger = rarer)}
	{Name = "Radish", 		Image = "radish.png", 		Cashout = 1.5, 			Rarity = 25},
	{Name = "Ugly", 		Image = "ugly.png", 		Cashout = 3, 			Rarity = 50},
	{Name = "Gaben", 		Image = "gabe.png", 		Cashout = 5, 			Rarity = 75},
	{Name = "Zombie", 		Image = "zombie.png", 		Cashout = 10, 			Rarity = 100},
	{Name = "Box", 			Image = "box.png", 			Cashout = 12, 			Rarity = 100},
	{Name = "Rollermine",	Image = "rollermine.png", 	Cashout = 15, 			Rarity = 100},
	{Name = "Time Roller", 	Image = "timeroller.png", 	Cashout = "Jackpot", 	Rarity = 300}
}
ENT.Slots = {ENT.SlotEntries[#ENT.SlotEntries], ENT.SlotEntries[#ENT.SlotEntries], ENT.SlotEntries[#ENT.SlotEntries]}

--These are the slot rules.
function ENT:Randomize()
	for i, v in pairs(self.Slots) do
		--if not math.random(1, 2) == 1 then return end

		local nextslot = self.SlotEntries[math.random(1, #self.SlotEntries)]
		local random = math.random(1, nextslot.Rarity)

		if random <= 2 then
			self.Slots[i] = nextslot
		end
	end
end

function ENT:GetSlotWin(amount)
	--Cherry/Radish slot rule
	if self.Slots[1].Name == "Radish" then
		local cherries = 0
		for _, slots in pairs(self.Slots) do
			if self.Slots[1] == slots then
				cherries = cherries + 1
			end
		end

		self:SetWon(true)
		return (self.SlotEntries[1].Cashout * cherries) * amount
	end
	
	--Global slot rule
	if (self.Slots[1] == self.Slots[2] and self.Slots[2] == self.Slots[3] and self.Slots[3] == self.Slots[1]) then
		if self.Slots[1].Cashout == "Jackpot" then
			self:SetJackpot(true)
			return self:GetJackpotValue()
		end

		self:SetWon(true)
		return self.Slots[1].Cashout * amount
	end

	return 0
end


-- This is ONLY when using THE VGUI to control a slot machine. If it was made to work without VGUI then the whole code changes.
function StartSlotPlayer(pl, cmd, arg)
	if not arg[1] or not arg[2] then return end

	local self = Entity(arg[1])
	local bet = tonumber(arg[2])

	if not IsValid(self) or not IsValid(pl) or not IsValid(self:GetSlotPlayer()) then return end
	if not self:GetClass() == "slotmachine" then return end
	if bet > self.MaxBet or not self:IsCloseDistance(pl) or not pl:Alive() then return end
	
	--[[
		Use the same "bet" var to reduce the player's silver/verify the player's silver.

		Only return to cancel it, you can also edit pslot.lua to give a message to the player 
		for his low silver count and prevent the next click. (At the "Spin" button)
	]]--

	self:SetJackpot(false)
	self:SetWon(false)
	self:SetRolling(true)

	local rotate = math.random(400, 500)

	for i=1, rotate do
		self:Randomize()
	end

	self:SetDTInt(1, table.KeyFromValue(self.SlotEntries, self.Slots[1]))
	self:SetDTInt(2, table.KeyFromValue(self.SlotEntries, self.Slots[2]))
	self:SetDTInt(3, table.KeyFromValue(self.SlotEntries, self.Slots[3]))

	timer.Simple(2, function()
		self:SetRolling(false)	

		if not IsValid(self:GetSlotPlayer()) then return end
		if self:GetSlotWin(bet) ~= 0 then
			local silver = self:GetSlotWin(bet)
			self:SetSlotWinValue(silver) --For the client to recieve the win via their vguis. Doing otherwise would fuck up.
			
			--Use the same "silver" ver to add the player's silver.

			if self:GetJackpot() then
				self:SetJackpotValue(self.MinPot)
			end
		else
			self:AddJackpotValue(bet)
		end
	end)
end
concommand.Add("__nox_mptv_startslot", StartSlotPlayer)

function SetSlotPlayer(pl, cmd, arg)
	if not arg[1] then return end

	local self = Entity(arg[1])

	if not IsValid(self) or not IsValid(pl) or not IsValid(self:GetSlotPlayer()) then return end
	if not self:GetClass() == "slotmachine" then return end
	if not self:IsCloseDistance(pl) or not pl:Alive() then return end
	
	if pl == self:GetSlotPlayer() then
		self:ResetSlotMachine()
	end
end
concommand.Add("__nox_mptv_resetslot", SetSlotPlayer)