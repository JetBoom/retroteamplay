function EFFECT:Init(data)
	local pos = data:GetOrigin()

	self.Ent = data:GetEntity()

	if self.Ent:IsValid() then
		self.DieTime = CurTime() + 0.25
	else
		self.DieTime = 0
	end

	sound.Play("weapons/rpg/rocketfire1.wav", pos, 80, math.Rand(105, 115))
	--sound.Play("weapons/stinger_fire1.wav", pos, 80, math.Rand(95, 105))

	self.Entity:SetRenderBounds(Vector(-1000, -1000, -1000), Vector(1000, 1000, 1000))

	ExplosiveEffect(pos, 130, 130, DMGTYPE_FIRE)
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matRing = Material("effects/select_ring")
local colRing = Color(255, 120, 20, 255)
function EFFECT:Render()
	local ct = CurTime()
	if ct < self.DieTime then
		local ent = self.Ent
		if not ent:IsValid() or not ent:Alive() then return end

		if not ent:IsVisibleTarget(MySelf) then return end

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
				if attach then
					pos = attach.Pos
				end
			end
		end

		render.SetMaterial(matRing)
		local size = (0.25 - (self.DieTime - ct)) * 1000
		colRing.a = math.min(255, (self.DieTime - ct) * 1000) * ent:GetAlphaModulation()
		local dir = ent:GetAimVector()
		render.DrawQuadEasy(pos, dir, size, size, colRing, 0)
		render.DrawQuadEasy(pos, dir * -1, size, size, colRing, 0)
	end
end
