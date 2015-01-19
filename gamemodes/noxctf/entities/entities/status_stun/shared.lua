ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Hostile = true

ENT.DisableJump = true

ENT.StartSound = Sound("nox/stunon.ogg")
ENT.EndSound = Sound("nox/stunoff.ogg")
ENT.StatusImage = "spellicons/stun.png"

function ENT:PostMove(pl, move)
	if pl ~= self:GetOwner() then return end
	
	move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
end
