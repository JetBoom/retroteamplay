function GM:HVSTInitialize()
	self.Name = "Retro TeamPlay (Harvest)"
	self.GameType = "HVST"
	self.FlagEntity = "grandcapacitor"
	BroadcastLua("GAMEMODE:HVSTInitialize()")
	hook.Add("PlayerReady", "GMSend2", function(pl)
		pl:SendLua("GAMEMODE:HVSTInitialize()")
	end)

	function self:HandleOvertime()
		self:CenterPrintAll("OVER TIME! Grand Capacitors are gaining mana! Prop health carved!~snox/allyscore.wav", "COLOR_RED")

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
