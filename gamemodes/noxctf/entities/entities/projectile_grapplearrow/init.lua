AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	phys:EnableDrag(false)
	phys:SetBuoyancyRatio(0.05)
	phys:Wake()

	self:GetOwner().GrappleBeam = self
end

function ENT:OnRemove()
	self:EmitSound("npc/barnacle/barnacle_crunch2.wav")
	local owner = self:GetOwner()
	if owner.GrappleBeam == self then
		owner.GrappleBeam = nil
	end
end

function ENT:Think()
	if self.StopPhysics then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
			phys:EnableCollisions(false)
		end
	end

	local owner = self:GetOwner()
	if owner:IsValid() and owner:Alive() and not (self:GetSkin() == 1 and owner:KeyDown(IN_JUMP)) then
		if self.ToAttach then
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableCollisions(false)
			end
			if self.ToAttach:IsValid() then
				constraint.Weld(self.ToAttach, self, 0, 0, 0, 1)
			end
			self.ToAttach = nil
		end

		local ownershootpos = owner:GetShootPos()
		local selfpos = self:GetPos()
		local dist = owner:NearestPoint(selfpos):Distance(selfpos)
		if not (TrueVisible(ownershootpos, selfpos + (ownershootpos - selfpos):GetNormal() * 16) and 48 < dist and dist < 4000) or owner:IsCarrying() then
			self:Remove()
			return
		end

		self:NextThink(CurTime())
		return true
	end

	self:Remove()
end

function ENT:PhysicsCollide(data, phys)
	if not self.Hit then
		local ent = data.HitEntity
		if not ent:IsPlayer() and not util.TraceLine({start=data.HitPos, endpos = data.HitPos + data.HitNormal * 48, mask=MASK_SOLID_BRUSHONLY}).HitSky then
			if not ent:IsValid() or not data.HitObject:IsValid() or not data.HitObject:IsMoveable() then
				self.Hit = true
				self:SetSkin(1)
				self:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
				self.StopPhysics = true
				self:NextThink(CurTime())
			elseif data.HitObject and data.HitObject:IsValid() and data.HitObject:IsMoveable() then
				self.Hit = true
				self:SetSkin(1)
				self:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
				self.ToAttach = data.HitEntity
				self:NextThink(CurTime())
			end
		end
	end
end
