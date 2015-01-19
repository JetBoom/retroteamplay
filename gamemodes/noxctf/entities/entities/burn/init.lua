AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.DeathTime = CurTime() + 10
end

function ENT:Think()
	local owner = self:GetOwner()
	local pos = self:GetPos()
	if self.DeathTime <= CurTime() or self:WaterLevel() > 0 then
		self:Remove()
	end
	for _, ent in pairs(ents.FindInSphere(pos,10)) do
		if ent:IsPlayer() and ent:Alive() and (ent:GetTeamID() ~= owner:GetTeamID() or ent == owner) and TrueVisible(pos, ent:NearestPoint(pos)) and not ent:GetStatus("salamanderskin") then
			ent:GiveStatus("burn", 2).Inflictor = owner
		end
	end
end

