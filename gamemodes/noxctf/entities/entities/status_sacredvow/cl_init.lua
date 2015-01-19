include("shared.lua")

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-1000, -1000, -1000), Vector(1000, 1000, 1000))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 40)

	self.Rotation = 120
	self.NextEmit = 0
end

function ENT:StatusThink(owner)
	local caster = self:GetCaster()
	if caster:IsValid() and caster:Alive() then
		self.Emitter:SetPos(caster:GetPos())
	end
end

function ENT:EmitParticle(pos, vel, r, g, b, mat)
	local particle = self.Emitter:Add(mat, pos)
	particle:SetVelocity(vel)
	particle:SetDieTime(math.Rand(0.2, 0.4))
	particle:SetStartAlpha(230)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(12, 24))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-8, 8))
	particle:SetColor(r, g, b)
	particle:SetAirResistance(10)
end

local matBeam = Material("trails/electric")
local matGlow = "sprites/glow04_noz"
function ENT:DrawTranslucent()
	local caster = self:GetCaster()
	local owner = self:GetOwner()
	if caster:IsValid() then
		local col = team.GetColor(caster:GetTeamID()) or color_white
		local pos1 = owner:GetCenter() + Vector(0, 0, 10)
		local pos2 = caster:GetCenter() + Vector(0, 0, 10)
		local dist = pos1:Distance(pos2)
		
		render.SetMaterial(matBeam)
		render.DrawBeam(pos1, pos2, 40 * (1 - dist/self.Dist), CurTime() + .5, CurTime(), Color(col.r, col.g, col.b, 255))
	
	if self:GetSkin() == 1 then
		local leftfoot = caster:LookupBone("valvebiped.bip01_l_foot")
		local rightfoot = caster:LookupBone("valvebiped.bip01_r_foot")
		if leftfoot and rightfoot then
			local lpos, lang = caster:GetBonePosition(leftfoot)
			local rpos, rang = caster:GetBonePosition(rightfoot)
		
			self:EmitParticle(lpos, Vector(0, 0, 100), 255, 255, 0, matGlow) 
			self:EmitParticle(rpos, Vector(0, 0, 100), 255, 255, 0, matGlow)
		end
	end
	end
end
