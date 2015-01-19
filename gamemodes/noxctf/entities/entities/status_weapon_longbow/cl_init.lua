include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/w_nox_longbow.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderBounds(Vector(-80, -80, -64), Vector(80, 80, 64))
end

function ENT:Draw()
	local owner = self:GetOwner()
	if owner:IsValid() and not (owner == MySelf and not owner:ShouldDrawLocalPlayer() and not owner:GetRagdollEntity()) then
		local rag = owner:GetRagdollEntity()
		if rag then
			owner = rag
		elseif not owner:Alive() or owner:IsInvisible() then return end

		local boneindex = owner:LookupBone("valvebiped.bip01_l_hand")
		if boneindex then
			local pos, ang = owner:GetBonePosition(boneindex)
			if pos then
				local c = owner:GetColor()
				self:SetColor(Color(255, 255, 255, math.max(1, c.a)))
				self:SetPos(pos + ang:Forward() * -4.75 + ang:Right() * 27.5 + ang:Up() * -58.5)
				ang:RotateAroundAxis(ang:Up(), 60)
				self:SetAngles(ang)
				self:SetModelScale(1, 0)
				self:DrawModel()
			end
		end
	end
end
