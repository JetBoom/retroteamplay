function EFFECT:Init(effectdata)
	self.Ent = effectdata:GetEntity()
	self.Entity:SetRenderBounds(Vector(-200, -200, -200), Vector(200, 200, 200))
	self.DeathTime = CurTime() + 1
end

function EFFECT:Think()
	return CurTime() <= self.DeathTime
end

local matGlow = Material("sprites/light_glow02_add")
function EFFECT:Render()
	local ent = self.Ent
	if not ent:IsValid() then return end
	
	local boneindex = ent:LookupBone("valvebiped.bip01_l_hand")
	if boneindex then
		local delta = math.Clamp((self.DeathTime - CurTime()), 0, 1)
		local pos, ang = ent:GetBonePosition(boneindex)
		render.SetMaterial(matGlow)
		local size = 128 * (1 - delta)
		local pos = pos + ang:Right() * 3 + ang:Forward() * 3
		render.DrawSprite(pos, size, size, COLOR_YELLOW)
		render.DrawSprite(pos, size/2, size/2, color_white)
	end
end