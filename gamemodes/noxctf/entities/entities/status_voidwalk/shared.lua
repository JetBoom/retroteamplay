ENT.Type = "anim"
ENT.Base = "status__base"

ENT.DisableJump = true

ENT.StartSound = {sound = "weapons/sniper/sniper_zoomin.wav", vol = 100, pitchLB = 50, pitchRB = 50}
ENT.EndSound = {sound = "weapons/sniper/sniper_zoomout.wav", vol = 100, pitchLB = 50, pitchRB = 50}
ENT.StatusImage = "spellicons/voidwalk.png"

ENT.Distance = 700

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if dmginfo:GetDamageType() == DMGTYPE_PIERCE or dmginfo:GetDamageType() == DMGTYPE_BASHING or dmginfo:GetDamageType() == DMGTYPE_SLASHING then
		dmginfo:SetDamage(0)
	end
end

-- for some reason putting this in the cl_init causes the time to be off by about .15 seconds
function ENT:StatusThink(owner)
	self.Time = self:GetDieTime() - CurTime()

	self:NextThink(CurTime())
	return true
end

function ENT:SetupDataTables()
	self:NetworkVar("Angle", 0, "Dir")
end

function ENT:PlayerCantCastSpell(pl, spellid)
	pl:LM(76)
	return true
end

function ENT:CanTakeFlag(owner, flag)
	return false
end

function ENT:PreMove(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMoveAngles(self:GetDir())

	move:SetMaxSpeed(self.Distance/.75)
	move:SetMaxClientSpeed(self.Distance/.75)
	move:SetForwardSpeed(10000)
	move:SetSideSpeed(0)

	if move:KeyDown(IN_DUCK) then
		move:SetButtons(move:GetButtons() - IN_DUCK)
	end
	
	if move:KeyDown(IN_WALK) then
		move:SetButtons(move:GetButtons() - IN_WALK)
	end

	return true
end
