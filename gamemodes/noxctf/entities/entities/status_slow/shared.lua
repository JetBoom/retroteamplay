ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Hostile = true

ENT.StartSound = Sound("nox/slowon.ogg")
ENT.EndSound = Sound("nox/slowoff.ogg")
ENT.StatusImage = "spellicons/slow.png"

-- We use PreMove, a custom hook which is called before all other move logic.
-- This lets other statuses have priority, we're just altering the person's base speed.
function ENT:PreMove(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(math.min(move:GetMaxSpeed(), 110))
	move:SetMaxClientSpeed(move:GetMaxSpeed())
end
