ENT.Type = "point"

function ENT:AcceptInput(name, activator, caller)
end

function ENT:Initialize()
	self.GameType = self.GameType or "CTF"
end

function ENT:Think()
end

function ENT:OnRemove()
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "oninitialize" then
		self:AddOnOutput("OnInitialize", value)
	elseif key == "gametype" then
		value = string.lower(value)
		for _, gt in pairs(GAMEMODE.GameTypes) do
			if string.lower(gt) == value then
				self.GameType = gt
				break
			end
		end
	end
end
