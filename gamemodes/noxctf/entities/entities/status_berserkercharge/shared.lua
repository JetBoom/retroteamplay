ENT.Type = "anim"
ENT.Base = "status__base"

ENT.StatusImage = "spellicons/berserkercharge.png"

function ENT:PlayerCantCastSpell(pl, spellid)
	if spellid == NameToSpell["Leap"] then return false end

	pl:LM(76)
	return true
end

function ENT:CanTakeFlag(owner, flag)
	return false
end

function ENT:PlaySound(owner, name)
	if name == "Start" then
		owner:EmitSound("nox/berserkercharge.ogg")
		owner:EmitSound("weapons/physcannon/superphys_launch"..math.random(2, 4)..".wav", 68, 250)
	end
end

function ENT:PostMove(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(move:GetMaxSpeed() + 200)
	move:SetMaxClientSpeed(move:GetMaxClientSpeed() + 200)
	move:SetForwardSpeed(10000)
	move:SetSideSpeed(0)
end

util.PrecacheSound("physics/concrete/boulder_impact_hard1.wav")
util.PrecacheSound("physics/concrete/boulder_impact_hard2.wav")
util.PrecacheSound("physics/concrete/boulder_impact_hard3.wav")
util.PrecacheSound("physics/concrete/boulder_impact_hard4.wav")
util.PrecacheSound("nox/berserkercharge.ogg")
util.PrecacheSound("weapons/mortar/mortar_shell_incomming1.wav")
util.PrecacheSound("weapons/physcannon/superphys_launch2.wav")
util.PrecacheSound("weapons/physcannon/superphys_launch3.wav")
util.PrecacheSound("weapons/physcannon/superphys_launch4.wav")
util.PrecacheModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
