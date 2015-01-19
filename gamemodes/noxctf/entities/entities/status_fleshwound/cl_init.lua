include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 48))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)

	self:GetOwner().FleshWound = self
	
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
end

function ENT:StatusOnRemove(owner)
	if IsValid(owner) then
		owner.FleshWound = nil
	end
end

local matFlesh = Material("models/flesh")
function ENT:PrePlayerDraw(pl)
	if self:GetOwner() == pl then
		local col = team.GetColor(pl:Team())
		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
		render.ModelMaterialOverride(matFlesh)
	end
end

function ENT:PostPlayerDraw(pl)
	if self:GetOwner() == pl then
		render.SetColorModulation(1, 1, 1)
		render.ModelMaterialOverride()
	end
end

function ENT:StatusThink()
	if self.Emitter then
		self.Emitter:SetPos(self:GetPos())
	end
end

local function GetRandomBonePos(pl)
	if pl ~= MySelf or MySelf:ShouldDrawLocalPlayer() then
		local bone = pl:GetBoneMatrix(math.random(0,25))
		if bone then
			return bone:GetTranslation()
		end
	end
	return pl:GetShootPos()
end

local function CollideCallback(particle, hitpos, hitnormal)
	if not particle.HitAlready then
	
		particle.HitAlready = true
		
		if math.random(10) == 1 then
			sound.Play("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.random(95, 105))
		end
	
		if math.random(2) == 2 then
			util.Decal(math.random(3) != 1 and "Blood" or "Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
		end
		particle:SetDieTime(0)
	end	
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or owner:IsInvisible() then return end

	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end
	
	local pos = GetRandomBonePos(owner)
	
	local attach = owner:GetAttachment(math.random(2) == 2 and owner:LookupAttachment("anim_attachment_RH") or owner:LookupAttachment("anim_attachment_LH"))
	if attach then
		pos = attach.Pos + attach.Ang:Forward() * 2
	end
	
	local emitter = self.Emitter
	
	if not emitter then return end
	
	self.NextEmit = self.NextEmit or 0
	
	if self.NextEmit > CurTime() then return end
	
	self.NextEmit = CurTime() + 0.005
	
	particle = emitter:Add("noxctf/sprite_bloodspray"..math.random(8), pos + VectorRand()*2)//"Decals/flesh/Blood"..math.random(5)
		particle:SetVelocity(VectorRand() * 35 + vector_up * 25 + owner:GetVelocity())
		particle:SetDieTime(math.Rand(0.05, 0.6))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(6)
		particle:SetEndSize(math.random(1,2))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(250, 0, 0)
		particle:SetAirResistance(20)
		particle:SetLighting(true)
		particle:SetRollDelta(math.Rand(-5, 5))
		particle:SetGravity(Vector(0,0,-340))
		particle:SetCollide( true )
		particle:SetCollideCallback(CollideCallback)

end
