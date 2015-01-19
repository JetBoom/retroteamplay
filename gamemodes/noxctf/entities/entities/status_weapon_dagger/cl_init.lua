include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/weapons/w_knife_t.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderBounds(Vector(-60, -60, -32), Vector(60, 60, 100))
end

function ENT:Draw()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local rag = owner:GetRagdollEntity()
		if rag then
			owner = rag
		elseif not owner:Alive() or owner:IsInvisible() or owner:GetStatus("voidwalk") or owner:GetStatus("shadowstorm") then return end

		local boneindex = owner:LookupBone("valvebiped.bip01_r_hand")
		if boneindex then
			local pos, ang = owner:GetBonePosition(boneindex)
			if pos then
				local c = owner:GetColor()
				self:SetColor(Color(255, 255, 255, math.max(1, c.a)))
				self:SetPos(pos + ang:Forward() * 3.1 + ang:Right() * 1.5 + ang:Up() * 4)
				ang:RotateAroundAxis(ang:Right(), 170)
				ang:RotateAroundAxis(ang:Up(), 180)
				self:SetAngles(ang)
				self:SetModelScale(1.3, 0)
				self:DrawModel()
			end
		end
	end
end
