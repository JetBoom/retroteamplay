ENT.Type = "anim"
ENT.Base = "status__base"

ENT.StatusImage = "spellicons/dragoondash.png"

function ENT:CanTakeFlag(owner, flag)
	return false
end

function ENT:PlaySound(owner, name)
	if name == "Start" then
		owner:EmitSound("ambient/fire/ignite.wav", 82, 80)
	end
	if name == "End" then
		owner:EmitSound("ambient/fire/gascan_ignite1.wav")
	end
end

function ENT:PostMove(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(move:GetMaxSpeed() + 150)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() + 150)
	move:SetForwardSpeed(10000)
	move:SetSideSpeed(0)
end


util.PrecacheSound("ambient/fire/ignite.wav")
util.PrecacheSound("ambient/fire/gascan_ignite1.wav")
util.PrecacheSound("weapons/mortar/mortar_shell_incomming1.wav")
util.PrecacheSound("weapons/physcannon/superphys_launch2.wav")
util.PrecacheSound("weapons/physcannon/superphys_launch3.wav")
util.PrecacheSound("weapons/physcannon/superphys_launch4.wav")

