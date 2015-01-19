ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.StartSound = {sound = Sound("nox/infravisionon.ogg"), vol = 100, pitchLB = 130, pitchRB = 130}
ENT.EndSound = {sound = Sound("nox/infravisionoff.ogg"), vol = 100, pitchLB = 130, pitchRB = 130}
ENT.StatusImage = "spellicons/evileye.png"

ENT.Radius = 1500
ENT.MaxVisibility = .2 -- do not change this above 1

function ENT:PostProcessDamage(attacker, inflictor, dmginfo)
	self:Remove()
end