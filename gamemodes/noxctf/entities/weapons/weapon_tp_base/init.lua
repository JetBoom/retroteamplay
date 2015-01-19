AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:AddWearables()
	if not self.Wearables then return end

	if IsValid(self.Owner) then
		for k, v in pairs(self.Wearables) do
			self.Owner:AddWearable(v, true)
		end
		self.Owner:UpdateWearables()
	end
end

function SWEP:RemoveWearables()
	if not self.Wearables then return end

	if IsValid(self.Owner) then
		for k, v in pairs(self.Wearables) do
			self.Owner:RemoveWearable(v, true)
		end
		self.Owner:UpdateWearables()
	end
end
