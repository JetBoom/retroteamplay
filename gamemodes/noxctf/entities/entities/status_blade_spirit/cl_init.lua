include("shared.lua")

function ENT:Initialize()
	local owner = self:GetOwner()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))
	self.Seed = math.Rand(0, 10)
	self.YawSeed = math.Rand(0, 360)
	self.Col = owner:GetPlayerColor() * 100
	
	if MySelf == self:GetOwner() then
		MySelf:DI(NameToSpell["Blade Spirits"], -1)
	end
end

function ENT:OnRemove()
	if MySelf == self:GetOwner() then
		MySelf:DI(NameToSpell["Blade Spirits"], 0)
	end
end

local GlowMaterial = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	
	if not owner:IsValid() then return end
	
	if owner:IsInvisible() then return end

	local pos = owner:LocalToWorld(owner:OBBCenter())
	local radius = owner:BoundingRadius()
	local orbsize = radius * 0.4

	local ang = Angle(0, self.YawSeed, 0)
	ang:RotateAroundAxis(ang:Right(), math.sin((RealTime() + self.Seed) * 2) * 30)
	local up = ang:Up()
	ang:RotateAroundAxis(up, RealTime() * 300)

	local c = self.Col
	local numorbs = self:GetBlades()
	if numorbs > 0 then
		local rotation = 360 / numorbs
		for i=1, numorbs do
			ang:RotateAroundAxis(up, rotation)
			local orbpos = pos + ang:Forward() * radius
			render.SetMaterial(GlowMaterial)
			render.DrawSprite(orbpos, orbsize, orbsize, self.Col)
			render.SetMaterial(GlowMaterial)
			render.DrawSprite(orbpos, orbsize * 4, orbsize * 4, Color(c.r,c.g,c.b))
		end
	end
end
