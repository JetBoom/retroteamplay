include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 48))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)

	hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)
end

function ENT:StatusThink()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:StatusOnRemove()
	--self.Emitter:Finish()
end

local matCorrode = Material("models/spawn_effect2")
function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local c = owner:GetColor()
	if c.a < 230 then return end

	local pos

	local attach1 = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
	local attach2 = owner:GetAttachment(owner:LookupAttachment("anim_attachment_LH"))
	if not attach1 or not attach2 then return end
	pos1 = attach1.Pos + attach1.Ang:Forward() * 2
	pos2 = attach2.Pos + attach2.Ang:Forward() * 2
	
	local emitter = self.Emitter
	
	if not emitter then return end
	
	for i=1, 2 do
		particle = emitter:Add("sprites/light_glow02_add", pos1 + VectorRand())
		particle:SetVelocity(Vector(0,0,40) + VectorRand() * 20)
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(200)
		particle:SetStartSize(12)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(127.5, 255, 0)
		particle:SetGravity(Vector(0,0,-300))
		particle:SetCollide( true )
		particle:SetBounce( 0.2 )
	end

	for i=1, 2 do
		particle = emitter:Add("sprites/light_glow02_add", pos2 + VectorRand())
		particle:SetVelocity(Vector(0,0,40) + VectorRand() * 20)
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(200)
		particle:SetStartSize(12)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(127.5, 255, 0)
		particle:SetGravity(Vector(0,0,-300))
		particle:SetCollide( true )
		particle:SetBounce( 0.2 )
	end

	local wep
	wep = owner:GetStatus("weapon_*") or owner:GetActiveWeapon()
	if not IsValid(wep) then return end
	cam.Start3D(EyePos(), EyeAngles())
		render.MaterialOverride(matCorrode)
			render.SetColorModulation(.5, 1, 0)
				render.SetBlend(.9)
				wep:DrawModel()
				render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)
		render.MaterialOverride(0)
	cam.End3D()
end
