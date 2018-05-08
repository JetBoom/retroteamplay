ENT.Type = "anim"
ENT.Base = "status__base"

ENT.SpeedBoost = 40

ENT.StartSound = Sound("nox/hasteon.ogg")
ENT.EndSound = Sound("nox/hasteoff.ogg")
ENT.StatusImage = "spellicons/haste.png"

function ENT:PreMove(pl, move)
	if pl ~= self:GetOwner() then return end

	local speed = move:GetMaxSpeed() + self.SpeedBoost
	move:SetMaxSpeed(speed)
	move:SetMaxClientSpeed(speed)
end
