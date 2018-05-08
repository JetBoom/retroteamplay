ENT.Type = "anim"
ENT.Base = "status__base"
ENT.Animation = "longsword_defensive"
ENT.StartSound = {sound = Sound("npc/metropolice/gear"..math.random(1,6)..".wav"), vol = 70, pitchLB = 95, pitchRB = 105}
ENT.EndSound = {sound = Sound("npc/metropolice/gear"..math.random(1,6)..".wav"), vol = 70, pitchLB = 90, pitchRB = 100}

function ENT:PostMove(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(move:GetMaxSpeed()/2)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed()/2)
end