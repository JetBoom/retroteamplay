include("shared.lua")

function ENT:Initialize()
	self.Col = self:GetOwner():GetPlayerColor() * 100
	self:DrawShadow(false)
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 36)
	self.Emitter2 = ParticleEmitter(self:GetPos(), true)
	self.Emitter2:SetNearClip(28, 36)
	self.AmbientSound = CreateSound(self, "npc/combine_gunship/engine_rotor_loop1.wav")
	self.Sword = ClientsideModel("models/w_nox_short_sword.mdl", RENDERGROUP_OPAQUE)
	self.Sword:SetModelScale( 1.5, 0 )
	self.OriginalOwner = self:GetOwner()
	self.OriginalOwner.SwordThrow = true
end

function ENT:Think()
	self.AmbientSound:Play()
	self.Emitter:SetPos(self:GetPos())
	self.Emitter2:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.Emitter2:Finish()
	self.AmbientSound:Stop()
	self.Sword:Remove()
	self.OriginalOwner.SwordThrow = false
end

local matBolt = Material("Effects/laser1")
local matSprite = Material("effects/yellowflare")
function ENT:Draw()
	local owner = self:GetOwner()
	local pos, ang = self:GetPos(), self:GetAngles()
	local c = self.Col
	
--	render.DrawLine( pos, pos + ang:Forward() * 100, COLOR_RED, true )
--	render.DrawLine( pos, pos + ang:Right() * 100, COLOR_BLUE, true )
--	render.DrawLine( pos, pos + ang:Up() * 100, COLOR_GREEN, true )
	if owner:GetStatus("spellsaber_flameblade") then
		local emitter = self.Emitter
		for i=1, 4 do
			local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), pos + VectorRand() * 4 + ang:Up() * math.random(10,65))
			particle:SetVelocity(self:GetVelocity())
			particle:SetDieTime(math.Rand(0.3,0.5))
			particle:SetGravity(Vector(0,0,math.random(200,300)))
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(100)
			particle:SetStartSize(6)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle = emitter:Add("particle/particle_smokegrenade", pos + VectorRand() * 4 + ang:Up() * math.random(10,65))
			particle:SetVelocity(self:GetVelocity())
			particle:SetColor(50,50,50)
			particle:SetDieTime(math.Rand(0.4,0.6))
			particle:SetGravity(Vector(0,0,math.random(100,200)))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(125)
			particle:SetStartSize(0)
			particle:SetEndSize(12)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
		end
	end
	if owner:GetStatus("spellsaber_corruptblade") then
	local emitter = self.Emitter
		local particle = emitter:Add("particle/particle_noisesphere", pos + ang:Right() * math.random(4,-4) + VectorRand() * 2 + ang:Up() * 12)
		particle:SetDieTime(1)
		particle:SetColor(math.random(50,220),0,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(100)
		particle:SetStartSize(7)
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
		particle:SetVelocity(self:GetVelocity() + ang:Up() * 90)
	end
	if owner:GetStatus("spellsaber_sanguineblade") then
		local emitter = self.Emitter
		for i=1, 12 do
			local particle = emitter:Add("effects/blood2", pos + VectorRand() * 4 + ang:Up() * math.random(10,65))
			particle:SetDieTime(0.2)
			particle:SetColor(math.random(90,125),0,0)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(4)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetVelocity(self:GetVelocity())
		end
		for i=1, 3 do
			local emitpos = pos + ang:Up() * 65
			local particle = emitter:Add("effects/blood_core", emitpos)
			particle:SetDieTime(1.5)
			particle:SetColor(130,0,0)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartLength(15)
			particle:SetEndLength(1)
			particle:SetStartSize(math.random(6,10))
			particle:SetEndSize(0)
			particle:SetGravity(Vector(0,0,math.random(-300,-400)))
			particle:SetVelocity((emitpos - (self:GetPos() + VectorRand() * math.random(-5,5))):GetNormal() * math.random(100,475))
			particle:SetCollide(true)
		end
	end
	if owner:GetStatus("spellsaber_stormblade") then
		local emitter = self.Emitter
		for i=1, 8 do
			local particle = emitter:Add("effects/rollerglow", pos + ang:Up() * math.random(10,65))
			particle:SetDieTime(0.1)
			particle:SetColor(255,50,0)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(15)
			particle:SetEndSize(15)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetVelocity(self:GetVelocity())
		end
		render.SetMaterial(matBolt)
		local bstart = pos + ang:Up() * 65
		local bend = pos + ang:Up() * 2
		for i=1,4 do
			local bpos = pos + VectorRand() * math.random(-10,10) + ang:Up() * 50
			local bpos2 = pos + VectorRand() * math.random(-15,15) + ang:Up() * 27
			render.StartBeam(4)
			render.AddBeam(bstart, 12, 0, COLOR_YELLOW)
			render.AddBeam(bpos, 12, 0, COLOR_YELLOW)
			render.AddBeam(bpos2, 12, 0, COLOR_YELLOW)
			render.AddBeam(bend, 12, 0, COLOR_YELLOW)
			render.EndBeam()
		end
		render.SetMaterial(matSprite)
		for i=1, math.random(2, 5) do
			render.DrawSprite(bend, 22 + math.sin(CurTime() * 12), 22 + math.sin(CurTime() * 9), COLOR_YELLOW)
			render.DrawSprite(bstart, 6, 6, COLOR_YELLOW)
		end
	end
	if owner:GetStatus("spellsaber_frostblade") then
		local emitter = self.Emitter
		for i=1, 8 do
			local particle = emitter:Add("particle/snow", pos + VectorRand() * 6 + ang:Up() * math.random(10,65))
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(20)
			particle:SetEndAlpha(0)
			particle:SetStartSize(12)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
		end
		for i=1, 12 do
			local startpos = pos + VectorRand() * 4 + ang:Up() * math.random(10,65)
			local endpos = pos + ang:Up() * 38
			local particle = emitter:Add("effects/yellowflare", startpos)
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(125)
			particle:SetEndAlpha(0)
			particle:SetStartSize(3)
			particle:SetEndSize(3)
			particle:SetVelocity((startpos - endpos):GetNormal() * math.Rand(60,90))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetAirResistance(10)
		end
	end
	if owner:GetStatus("spellsaber_nullblade") then
		local emitter = self.Emitter
		for i=1, 5 do
			local startpos = pos + VectorRand():GetNormal() * 20 + ang:Up() * math.random(10,65)
			local endpos = pos + ang:Up() * 38
			local particle = emitter:Add("effects/blueflare1", startpos)
			particle:SetDieTime(0.5)
			particle:SetColor(50,50,255)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(12)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetVelocity((startpos - endpos):GetNormal() * math.Rand(-40, -65))
		end
	end
	if owner:GetStatus("spellsaber_shockblade") then
		local emitter = self.Emitter2
		local particlepos = pos + ang:Up() * math.random(10,65)
		local particle = emitter:Add("effects/select_ring", particlepos)
		particle:SetDieTime(0.1)
		particle:SetColor(255,255,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(10)
		ang:RotateAroundAxis(ang:Right(), 90)
		particle:SetAngles(ang)
		particle:SetVelocity(self:GetVelocity())
		particle = emitter:Add("effects/select_ring", particlepos)
		particle:SetDieTime(0.2)
		particle:SetColor(255,255,255)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(14)
		particle:SetAngles(ang)
		particle:SetVelocity(self:GetVelocity())
		ang:RotateAroundAxis(ang:Right(), -90)
	end
	
	if not self.Sword:IsValid() then
		self.Sword = ClientsideModel("models/w_nox_short_sword.mdl", RENDERGROUP_OPAQUE)
		self.Sword:SetModelScale( 1.5, 0 )
	end
	self.Sword:SetPos((pos + ang:Forward() * -11.25 + ang:Right() * -36 + ang:Up() * -90))
	self.Sword:SetColor(Color(c.r,c.g,c.b))
	ang:RotateAroundAxis(ang:Right(), -2)
	self.Sword:SetAngles(ang)
end

