include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/w_nox_short_sword.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderBounds(Vector(-60, -60, -32), Vector(60, 60, 100))
end

function ENT:Draw()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local rag = owner:GetRagdollEntity()
		if rag then
			owner = rag
		elseif not owner:Alive() or owner:IsInvisible() then return end

		local boneindex = owner:LookupBone("valvebiped.bip01_r_hand")
		if boneindex then
			local pos, ang = owner:GetBonePosition(boneindex)
			if pos then
				local c = owner:GetColor()
				self:SetColor(Color(255, 255, 255, math.max(1, c.a)))
				self:SetPos(pos + ang:Forward() * 33.85 + ang:Right() * 2.4 + ang:Up() * 56.4)
				ang:RotateAroundAxis(ang:Right(), 175)
				ang:RotateAroundAxis(ang:Up(), 80)
				self:SetAngles(ang)
				self:SetModelScale(1, 0)
				self:DrawModel()
			end
		end
	end
end
