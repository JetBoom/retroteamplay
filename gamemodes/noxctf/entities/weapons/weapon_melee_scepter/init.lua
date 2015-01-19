AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Classes = {"Alchemist"}
SWEP.Droppable = "pickup_scepter"

function SWEP:WeaponSpecialAttack2(owner)
	owner:GlobalCooldown(0.9)
	timer.Simple(0.6, function() 
		if owner:IsValid() and owner:Alive() then
			local pos = owner:GetShootPos() + owner:GetUp() * -15 + owner:GetRight() * 25 + owner:GetForward() * 40
			if TrueVisible(owner:GetCenter(), pos) then
				local ent = ents.Create("projectile_scepter")
				if ent:IsValid() then
					ent:SetOwner(owner)
					ent:SetTeamID(owner:GetTeamID())
					local c = team.GetColor(owner:GetTeamID()) or color_white
					ent:SetColor(Color(c.r, c.g, c.b, 255))
					ent:SetPos(pos)
					ent:Spawn()
					local dir = (owner:GetEyeTrace().HitPos - pos):GetNormal()
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous(dir * self.ProjectileSpeed)
					end
					owner.WeaponStatus:SetOrbSize(CurTime() + self.Special2Cooldown - .2)
				else
					ent:Remove()
				end
			end
		end
	end)
end