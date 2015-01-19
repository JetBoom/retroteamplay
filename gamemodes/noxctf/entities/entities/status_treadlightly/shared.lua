ENT.Type = "anim"
ENT.Base = "status__base"

ENT.DisableJump = true

ENT.StartSound = Sound("nox/threadin.ogg")
ENT.EndSound = Sound("nox/threadout.ogg")
ENT.StatusImage = "spellicons/assassinthreadlightly.png"

function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(150)
	move:SetMaxClientSpeed(150)
end
