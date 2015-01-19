include("shared.lua")

function ENT:StatusInitialize()
	local owner = self:GetOwner()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -128), Vector(40, 40, 128))
	self:SetModelScale( 1.5, 0 )
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(34, 42)

end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local function GetRandomBonePos(pl)
	if pl ~= MySelf or pl:ShouldDrawLocalPlayer() then
		local bone = pl:GetBoneMatrix(math.random(0,25))
		if bone then
			return bone:GetTranslation()
		end
	end

	return pl:GetShootPos()
end

local ring = Material("effects/select_ring")
function ENT:Draw()
	local ent = self:GetOwner()
	if not ent:IsValid() or not ent:IsVisibleTarget(MySelf) then return end
	
	local pos
	if ent == MySelf and not ent:ShouldDrawLocalPlayer() then
		local aa, bb = ent:WorldSpaceAABB()
		pos = Vector(math.Rand(aa.x, bb.x), math.Rand(aa.y, bb.y), math.Rand(aa.z, bb.z))
	else
		pos = GetRandomBonePos(ent)
	end

	local emitter = self.Emitter
	for i = 1, 2 do
		local particle = emitter:Add("particle/particle_smokegrenade", pos + VectorRand():GetNormalized() * 2)
		particle:SetDieTime(math.Rand(0.4, 0.5))
		particle:SetColor(10,10,255)
		particle:SetStartSize(5)
		particle:SetEndSize(10)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetVelocity(ent:GetVelocity())
		particle:SetAirResistance(32)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.5, 1.5))
	end
	
	render.SetMaterial(ring)
	render.DrawQuadEasy( ent:GetPos() + Vector(0,0,45 + 25 * math.sin(CurTime() * 3)), Vector(0,0,1), 50, 50, COLOR_BLUE, 0 )
	render.DrawQuadEasy( ent:GetPos() + Vector(0,0,45 - 25 * math.sin(CurTime() * 3)), Vector(0,0,1), 50, 50, COLOR_BLUE, 0 )
end
