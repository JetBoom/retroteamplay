include("shared.lua")

util.PrecacheSound("physics/glass/glass_largesheet_break1.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break2.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break3.wav")

function ENT:Draw()
	local scale = math.max(0.05, self.DeathTime - CurTime())
	if scale > 0.75 then
		local midscale = (1 - scale) * 1.6
		self:SetModelScale(midscale * (1 - scale) * 2, 0)
		self:SetColor(Color(30, 150, 255, math.min(255, scale * 300)))
	else
		self:SetModelScale(scale * 1.6, 0)
		self:SetColor(Color(30, 150, 255, math.min(255, scale * 300)))
	end
	self:DrawModel()
end

function ENT:Initialize()
	self.DeathTime = CurTime() + 1
	self:SetMaterial("models/shadertest/shader2")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	ExplosiveEffect(self:GetPos(), 48, 30, DMGTYPE_ICE)
end

function ENT:Think()
	if not self.Played then
		self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 80, math.random(160, 180))
	end
	self.Played = true

	self:SetAngles(Angle(0, RealTime() * 50, 0))
end

function ENT:OnRemove()
end
