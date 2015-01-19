AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Col = self:GetOwner():GetPlayerColor() * 100
	self:DrawShadow(false)
	self:SetColor(Color(self.Col.r,self.Col.g,self.Col.b,255))
	self:SetMaterial("Models/props_pipes/PipeMetal001a")
	self:SetModel("models/props_junk/sawblade001a.mdl")
	self:PhysicsInitSphere(8)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:Wake()
	end
	self.DeathTime = CurTime() + 30
	self.Sticked = false
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
	end
	
	if self.PhysicsData and not self.Sticked then
		self.Sticked = true
		local phys = self:GetPhysicsObject()
		local data = self.PhysicsData
		local ent = data.HitEntity
		if ent:IsValid() then
			local owner = self:GetOwner()
			if ent:IsPlayer() then
				ent:BloodSpray(data.HitPos, 8, data.OurOldVelocity:GetNormal(), 150)
			end
			ent:TakeSpecialDamage(10, DMGTYPE_SLASHING, owner, self)
			ent:EmitSound("ambient/machines/slicer"..math.random(1,4)..".wav", 76, math.random(108, 112))
			self:Remove()
		end
		if phys:IsValid() then
			local heading = data.OurOldVelocity:GetNormal()
			local ang = heading:Angle()
			local hitpos = data.HitPos - heading * 10
			self:SetSolid(SOLID_NONE)
			self.DeathTime = CurTime() + 5
			phys:EnableMotion( false )
			phys:SetAngles(ang)
			phys:SetPos(hitpos)
			self:EmitSound("ambient/machines/slicer"..math.random(1,4)..".wav", 76, math.random(108, 112))
		end
	end
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end