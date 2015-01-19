AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	hook.Add("SetupPlayerVisibility", self, self.SetupPlayerVisibility)
end

function ENT:SetupPlayerVisibility(ply, viewEntity)
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if ply ~= owner then return end
	
	for _, pl in pairs(player.GetAll()) do		
		if pl:IsValid() and pl:Alive() and pl ~= owner and pl:GetCenter():Distance(owner:GetCenter()) <= self.Radius then
			AddOriginToPVS(pl:GetCenter())
		end
	end
end