// Source Forts compatability
ENT.Type = "point"

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:KeyValue(key, value)
	if self.AlreadyPicked and string.lower(key) == "skin" then return end

	if string.lower(key) == "skin" or string.lower(key) == "teamnum" then
		if tonumber(value) == 3 then
			self.RedTeam = true
		elseif tonumber(value) == 2 then
			self.BlueTeam = true
		elseif tonumber(value) == 4 then
			self.YellowTeam = true
		elseif tonumber(value) == 5 then
			self.GreenTeam = true
		end
		self.AlreadyPicked = true
	end
end
