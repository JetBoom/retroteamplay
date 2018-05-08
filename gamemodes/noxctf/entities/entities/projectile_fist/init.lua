AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_noxious/fist/fist_of_vengeance.mdl")
	self:DrawShadow(true)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_NONE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
		phys:Wake()
		phys:SetVelocityInstantaneous(Vector(0, 0, -975))
	end
	self.Touched = {}
	self.DeathTime = CurTime() + 30
	self.Bounce = false
end

function ENT:Think()
	self:GetPhysicsObject():AddAngleVelocity(self:GetPhysicsObject():GetAngleVelocity() * -1)

	if self.DeathTime <= CurTime() then
		self:Remove()
	end

	if self:GetPos().z <= (self.Destination.z + 170) and not self.Bounce then
		self.Bounce = true
		local effectdata = EffectData()
			effectdata:SetOrigin(self.Destination)
		util.Effect("fistofvengeancehit", effectdata)
		util.ScreenShake(self.Destination, 700, 4, 2, 1400)
		self.DeathTime = CurTime() + 1.5
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(Vector(0, 0, 400))
		end
	end

	for _, ent in pairs(ents.FindInSphere(self:GetPos() + Vector(0,0,-50), 185)) do
		if not self.Touched[ent] and not self.Bounce then
			local owner = self:GetOwner()
			if not owner:IsValid() then owner = self end

			if ent:GetTeamID() ~= self:GetTeamID() or ent == owner then
				if ent.PHealth or ent.ScriptVehicle or ent.VehicleParent then
					ent:TakeSpecialDamage(35, DMGTYPE_GENERIC, owner, self)
				elseif ent:IsPlayer() then
					ent:TakeSpecialDamage(35, DMGTYPE_GENERIC, owner, self)
					ent:Stun(1)
				end
			end
			self.Touched[ent] = true
		end
	end

	self:NextThink(CurTime())
	return true
end
