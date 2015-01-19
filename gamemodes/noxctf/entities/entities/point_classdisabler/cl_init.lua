include("shared.lua")

function ENT:Draw()
end

function ENT:Initialize()
	self:DrawShadow(false)
	self.Think = nil
end

function DecrDisClasses(str)
	for i=1, string.len(str) do
		if string.sub(str, i, i) == "1" then
			GAMEMODE.DisabledClasses[i] = true
		end
	end
end
