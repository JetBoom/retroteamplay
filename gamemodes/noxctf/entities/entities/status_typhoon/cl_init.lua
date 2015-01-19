include("shared.lua")

function ENT:StatusInitialize()
	self.NextTwirl = 0
end

function ENT:DrawTranslucent()
end

function ENT:StatusThink(owner)
	if self.NextTwirl < CurTime() then
		self.NextTwirl = CurTime() + 0.25

		local mypos = owner:GetPos() + Vector(0, 0, 16)
		local addin = math.sin(CurTime() * 5) * 200
		for i=0, 10 do
			ExplosiveEffect(self:GetPos() + Vector(math.Rand(-100, 100), math.Rand(-100, 100), i * (200 + addin)), 260, -70, DMGTYPE_WIND)
		end
	end
end

