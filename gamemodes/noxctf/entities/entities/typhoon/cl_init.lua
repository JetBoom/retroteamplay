include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:DrawShadow(false)
	self.NextTwirl = 0
end

function ENT:DrawTranslucent()
end

function ENT:Think()
	if self.NextTwirl < CurTime() then
		self.NextTwirl = CurTime() + 0.25

		local mypos = self:GetPos()
		local addin = math.sin(CurTime() * 5) * 200
		for i=0, 10 do
			ExplosiveEffect(self:GetPos() + Vector(math.Rand(-100, 100), math.Rand(-100, 100), i * (200 + addin)), 260, -70, DMGTYPE_WIND)
		end
	end
end
