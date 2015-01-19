include("shared.lua")

ENT.NextEmit = 0

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	--self.Emitter:SetNearClip(10, 12)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) then return end

	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		local aimvec = owner:GetAimVector()
		local aimang = owner:EyeAngles()
		local pos = owner:GetShootPos() + aimvec * 4 + aimang:Right() + aimang:Up() * -0.5

		render.SetMaterial(matGlow)
		render.DrawSprite(pos + math.sin(CurTime() * 6) * aimang:Right() + math.cos(CurTime() * 6) * aimang:Up(), 4, 4, COLOR_WHITE)
		render.DrawSprite(pos + math.cos(CurTime() * 6) * 2 * aimang:Right() + math.sin(CurTime() * 6) * 2 * aimang:Up(), 4, 4, COLOR_RED)
		render.DrawSprite(pos + math.cos(CurTime() * 6) * -2 * aimang:Right() + math.sin(CurTime() * 6) * -2 * aimang:Up(), 4, 4, COLOR_RED)
	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			local aimvec = owner:GetAimVector()
			local aimang = owner:EyeAngles()
			local pos = attach.Pos + aimvec * 4 + aimang:Right() + aimang:Up() * -0.5

			render.SetMaterial(matGlow)
			render.DrawSprite(pos + math.sin(CurTime() * 6) * 6 * aimang:Right() + math.cos(CurTime() * 6) * 6 * aimang:Up(), 12, 12, COLOR_WHITE)
			render.DrawSprite(pos + math.cos(CurTime() * 6) * 9 * aimang:Right() + math.sin(CurTime() * 6) * 9 * aimang:Up(), 12, 12, COLOR_RED)
			render.DrawSprite(pos + math.cos(CurTime() * 6) * -9 * aimang:Right() + math.sin(CurTime() * 6) * -9 * aimang:Up(), 12, 12, COLOR_RED)
		end
	end
end
