util.PrecacheSound("nox/forceofnature_start.ogg")

function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	local c = team.GetColor(math.Round(data:GetMagnitude()))
	self.Col = c

	if self.Ent:IsPlayer() and self.Ent:Alive() then
		self.DieTime = CurTime() + 1
		self.Ent:EmitSound("nox/forceofnature_start.ogg", 90, math.random(95, 105))
		local pos = self.Ent:GetShootPos() + self.Ent:GetAimVector() * 32
		self.Emitter = ParticleEmitter(pos)
	else
		self.DieTime = -1
	end
	self.NextEmit = 0
end

function EFFECT:Think()
	if self.Ent:IsPlayer() and self.Ent:Alive() and CurTime() <= self.DieTime then
		local pos = self.Ent:GetShootPos() + self.Ent:GetAimVector() * 32
		self.Entity:SetPos(pos)
		self.Emitter:SetPos(pos)
		return true
	end

	--self.Emitter:Finish()
	return false
end

local matGlow = Material("sprites/light_glow02_add")
function EFFECT:Render()
	if self.Ent:IsValid() then
		local pos = self.Ent:GetShootPos() + self.Ent:GetAimVector() * 32
		local emitter = self.Emitter
		local c = self.Col
		local delta = self.DieTime - CurTime()
		
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, 128 * (1 - delta), 128 * (1 - delta), c)
		
		for i=1, math.random(2, 5) do
			local vDir = VectorRand():GetNormal()
			local particle = emitter:Add("sprites/glow04_noz", pos + vDir * 128)
			particle:SetVelocity(vDir * -256)
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(math.Rand(0, 40))
			particle:SetEndAlpha(240)
			particle:SetStartSize(math.Rand(1, 4))
			particle:SetEndSize(10)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-30, 30))
			particle:SetColor(c.r, c.g, c.b)
		end
	end
end
