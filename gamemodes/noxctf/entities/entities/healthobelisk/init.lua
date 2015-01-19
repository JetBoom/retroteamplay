AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Alive()
	return false
end

function ENT:Think()
	if self.Mana < self.MaxMana and self.LastDrain + 1 < CurTime() then
		self.Mana = math.min(self.MaxMana, self.Mana + FrameTime() * 16)
		local brightness = math.ceil(math.max(self.Mana * 2.55, 30))
		if self.LastBrightness ~= math.ceil(brightness*0.1) then
			self:SetColor(Color(brightness, brightness * 0.5, 0, 255))
			self.LastBrightness = brightness
		end
	end
end

function ENT:Touch(ent, drain)
	if ent:IsPlayer() and ent:Health() < ent:GetMaxHealth() and self.Mana > 0 then
		local amount = math.ceil(math.min(self.Mana, FrameTime() * 66))
		ent:SetHealth(math.min(ent:Health() + amount, ent:GetMaxHealth()))
		self.Mana = math.max(0, self.Mana - amount)
		local brightness = math.max(self.Mana * 2.55, 30)
		if self.LastBrightness ~= math.ceil(brightness * 0.1) then
			self:SetColor(Color(255, brightness * 0.125, 0, 255))
			self.LastBrightness = brightness
		end
		self.LastDrain = CurTime()
		if CurTime() >= self.NextSound then
			self:EmitSound("nox/managain.ogg")
			self.NextSound = CurTime() + 0.75
		end
	end
end

local rockmodels = {"models/props_wasteland/rockcliff01b.mdl",
"models/props_wasteland/rockcliff01c.mdl",
"models/props_wasteland/rockcliff01e.mdl",
"models/props_wasteland/rockcliff01g.mdl"}

function ENT:Initialize()
	self:SetModel(rockmodels[math.random(1, #rockmodels)])
	self:SetUseType(SIMPLE_USE)
	--self:PhysicsInit(SOLID_VPHYSICS)
	self:PhysicsInitBox(Vector(-14, -14, -48), Vector(14, 14, 48))
	self:SetCollisionBounds(Vector(-14, -14, -48), Vector(14, 14, 48))
	--self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(255, 32, 0, 255))
	self.Mana = 100
	self.MaxMana = 100
	self.LastDrain = -10
	self.NextSound = -10
	self.LastBrightness = 255
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Sleep()
	end
end
