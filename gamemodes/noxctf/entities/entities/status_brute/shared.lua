ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = {
	sound = {
		Sound("nox/brute1.ogg"),
		Sound("nox/brute2.ogg")
		},
	vol = 80,
	pitchLB = 100,
	pitchRB = 100
}
ENT.EndSound = {
	sound = {
		Sound("ambient/voices/cough1.wav"),
		Sound("ambient/voices/cough2.wav"),
		Sound("ambient/voices/cough3.wav"),
		Sound("ambient/voices/cough4.wav")
		},
	vol = 80,
	pitchLB = 100,
	pitchRB = 100
}
ENT.StatusImage = "spellicons/brutewarrior.png"

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	dmginfo:SetDamage(dmginfo:GetDamage() * 2.0)
end
