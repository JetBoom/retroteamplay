include("shared.lua")
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.RenderBoundsMin = Vector(-128, -128, -128)
ENT.RenderBoundsMax = Vector(128, 128, 128)

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(20, 32)

	self:SetRenderBounds(Vector(-120, -120, -18), Vector(120, 120, 80))

end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:DrawTranslucent()

	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if owner:IsInvisible() then return end
	
	local c = self.TeamCol

	local boneindexr = owner:LookupBone("valvebiped.bip01_r_foot")
	if boneindexr then
		local pos, ang = owner:GetBonePosition(boneindexr)
		if pos then
			local emitter = self.Emitter

			local particle = emitter:Add("sprites/light_glow02_add", pos)
			particle:SetDieTime(0.6)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(1)
			particle:SetStartSize(12)
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(-0.8, 0.8))
			particle:SetColor(c.r, c.g, c.b)
			particle:SetBounce(0.7)

			particle = emitter:Add("effects/fire_cloud1", pos)
			particle:SetDieTime(0.2)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(1)
			particle:SetStartSize(6)
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(-0.8, 0.8))
		end
	end
	
	local boneindexl = owner:LookupBone("valvebiped.bip01_l_foot")
	if boneindexl then
		local pos, ang = owner:GetBonePosition(boneindexl)
		if pos then
			local emitter = self.Emitter

			local particle = emitter:Add("sprites/light_glow02_add", pos)
			particle:SetDieTime(0.6)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(1)
			particle:SetStartSize(12)
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(-0.8, 0.8))
			particle:SetColor(c.r, c.g, c.b)
			particle:SetBounce(0.7)

			particle = emitter:Add("effects/fire_cloud1", pos)
			particle:SetDieTime(0.2)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(1)
			particle:SetStartSize(6)
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(-0.8, 0.8))
		end
	end
end

