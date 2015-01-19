ENT.Type = "anim"
ENT.Base = "status__base"

ENT.DisableJump = true

function ENT:PostMove(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(move:GetMaxSpeed() * 0.5)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.5)
end