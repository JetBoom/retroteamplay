ENT.Type = "anim"
ENT.Base = "status__base"

ENT.DisableJump = true

function ENT:PostMove(pl, move)
	if pl ~= self:GetOwner() then return end
	
	move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
end
