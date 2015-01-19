AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.NextAttack = 0
	self:Fire("attack", "", 1)
	--self:Fire("evaluate", "", 0.1)
	self.Think = nil
end

function ENT:AcceptInput(name, activator, caller)
	if name == "attack" then
		self:Fire("attack", "", 1)

		--if self.Powered and not self.Destroyed then
		if not self.Destroyed then
			local pos = self:GetPos()
			local tr = util.TraceLine({start=pos, endpos=pos + self:GetUp() * 63, filter=self})
			local ent = tr.Entity
			if ent:IsValid() and tr.Fraction > 0.1 then
				if ent.ScriptVehicle and ent:Team() == self:GetTeamID() then
					local oldhealth = ent:GetVHealth()
					local maxhealth = ent:GetMaxVHealth()
					local newhealth = math.min(oldhealth + 30, maxhealth)
					if newhealth ~= oldhealth and GAMEMODE:DrainPower(self, 4) then
						ent:SetVHealth(newhealth)
						--self:EmitSound("buttons/lever"..math.random(1,7)..".wav", 75, 135)
						local snd = math.random(1,12)
						if snd == 4 or snd == 9 or snd == 11 then snd = snd + 1 end
						self:EmitSound("npc/dog/dog_servo"..snd..".wav", 75, 115)
						if newhealth > maxhealth * 0.3 then
							for _, ent2 in pairs(ents.FindByClass("env_fire_trail")) do
								if ent2:GetParent() == ent then
									ent2:Remove()
								end
							end
							ent.Ignited = false
						end
					end
				elseif ent.PHealth and ent:GetTeamID() == self:GetTeamID() and not ent:IsPlayerHolding() and not (OVERTIME and ent:GetClass()=="prop_generator") then
					local maxhealth = ent.MaxPHealth
					local col = team.GetColor(ent:GetTeamID())
					if ent.PHealth ~= maxhealth and GAMEMODE:DrainPower(self, 4) then
						if ent.Destroyed then
							local newhealth = math.ceil(math.min(ent.PHealth + math.Clamp(ent.MaxPHealth * 0.02, 5, 15), maxhealth))
							local brit = newhealth / maxhealth
							if newhealth == maxhealth then
								ent.Destroyed = nil
								ent.PHealth = maxhealth
								ent:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), 255))
								ent:SetCollisionGroup(COLLISION_GROUP_NONE)
								ent:GetPhysicsObject():EnableCollisions(true)
								ent:Fire("created", "", 0)
								local entpos = ent:GetPos()
								local effectdata = EffectData()
									effectdata:SetEntity(ent)
									effectdata:SetOrigin(entpos)
								util.Effect("building_spawn", effectdata, true, true)
								if 100 < maxhealth then
									local home = team.TeamInfo[ent:GetTeamID()].FlagPoint
									if home:Distance(entpos) < 1400 then
										local ownersteamid = ent.Owner
										for _, pl in pairs(player.GetAll()) do
											if pl:SteamID() == ownersteamid or pl:SteamID() == self.Owner then
												pl:CenterPrint("Crafting Bonus (+1)", "COLOR_LIMEGREEN", 3)
												pl:AddSilver(CRAFTER_CORE_DEFENSE_BONUS)
												pl:AddFrags(1)
												pl:AddDefense(1)
											end
										end
									end
								end
							else
								ent.PHealth = newhealth
								ent:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), math.ceil(brit * 240)))
							end
						else
							local newhealth = math.ceil(math.min(ent.PHealth + math.Clamp(ent.MaxPHealth * 0.025, 12, 25), maxhealth))
							ent.PHealth = newhealth
							local brit = newhealth / maxhealth
							ent:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), 255))
						end
						local snd = math.random(1,12)
						if snd == 4 or snd == 9 or snd == 11 then snd = snd + 1 end
						self:EmitSound("npc/dog/dog_servo"..snd..".wav", 75, 115)
					end
				end
			end
		end

		return true
	--elseif name == "evaluate" then
		--self:Fire("evaluate", "", 1)
		--GAMEMODE:Evaluate(self)
	--	return true
	elseif name == "powered" then
		self:SetSkin(1)
		return true
	elseif name == "depowered" then
		self:SetSkin(0)
		return true
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 20
ENT.OffenseBonus = 2
ENT.FragsBonus = 2
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
