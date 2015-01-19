AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetModel("models/props_debris/concrete_spawnplug001a.mdl")
	self:SetMaterial("models/props/de_inferno/offwndwb_break")
	self:DrawShadow(false)
	self:SetAngles(Angle(0,math.random()*360,0))
	self.DeathTime = CurTime() + 5
	self.FadeTime = CurTime() + 4.5
end

function ENT:Think()
	local pos = self:GetPos()
	local owner = self:GetOwner()
	if not owner:IsValid() then self:Remove() end
	local ownerteam = owner:Team()
	if self.DeathTime <= CurTime() then
		self:Remove()
		return
	end
	for _, ent in pairs(ents.FindInBox(pos + Vector(-40,-40,0), pos + Vector(40,40,15))) do
		if ent:IsValid() and ent:IsPlayer() and ent:Alive() and ent ~= owner and ent:GetTeamID() ~= ownerteam then
			ent:GiveStatus("frostblade_freeze",0.2).Inflictor = owner
		end
	end
end

