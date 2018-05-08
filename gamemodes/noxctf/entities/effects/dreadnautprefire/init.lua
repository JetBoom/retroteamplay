function EFFECT:Init(data)
	self.Ent = data:GetEntity()

	self.Emitter = ParticleEmitter(data:GetOrigin())
	self.Emitter:SetNearClip(24, 32)
	if self.Ent:IsValid() then
		self.DieTime = CurTime() + 3
		self.Ent:EmitSound("npc/strider/charging.wav", 78, 45)
	else
		self.DieTime = 0
	end

	self.Entity:SetRenderBounds(Vector(-1000, -1000, -1000), Vector(1000, 1000, 1000))

	self.RingSize = 200
end

function EFFECT:Think()
	if not (CurTime() < self.DieTime and self.Ent:IsValid() and self.Ent:Alive()) then
		--self.Emitter:Finish()
		return false
	elseif self.Ent == MySelf then
		self.Entity:SetPos(MySelf:GetShootPos() + MySelf:GetAimVector() * 16)
	else
		self.Entity:SetPos(self.Ent:EyePos())
	end

	return true
end

local matRing = Material("effects/select_ring")
function EFFECT:Render()
	local ent = self.Ent
	if not ent:IsValid() then return end

	if ent:IsInvisible() then return end

	local pos = ent:EyePos()
	local wep = ent:GetActiveWeapon()
	if wep:IsValid() then
		if ent == MySelf then
			local attach
			if MySelf:ShouldDrawLocalPlayer() then
				attach = wep:GetAttachment(1)
			else
				attach = MySelf:GetViewModel():GetAttachment(1)
			end
			if attach then
				pos = attach.Pos
			end
		else
			local attach = wep:GetAttachment(1)
			if attach then pos = attach.Pos end
		end
	end

	local emitter = self.Emitter
	emitter:SetPos(pos)
	for i=1, 2 do
		local dir = VectorRand():GetNormal()
		particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos + dir * 80)
		particle:SetVelocity(dir * -160)
		particle:SetDieTime(0.45)
		particle:SetStartAlpha(64)
		particle:SetEndAlpha(240)
		particle:SetStartSize(math.Rand(4, 6))
		particle:SetEndSize(math.Rand(8, 12))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(255, math.Rand(180, 250), math.Rand(100, 200))
	end

	self.RingSize = self.RingSize - FrameTime() * 7 * self.RingSize
	if self.RingSize < 2 then self.RingSize = self.RingSize + 200 end

	local aim = MySelf:GetAimVector()
	local size = self.RingSize
	render.SetMaterial(matRing)
	local col = Color(255, 120, 20, 255)
	render.DrawQuadEasy(pos, aim, size, size, col, size)
	render.DrawQuadEasy(pos, aim * -1, size, size, col, size)
end
