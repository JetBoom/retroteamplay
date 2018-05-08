include("shared.lua")

function ENT:StatusInitialize()
	local owner = self:GetOwner()
	self:DrawShadow(false)
	self:SetModel("models/w_nox_short_sword.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetRenderBounds(Vector(-60, -60, -32), Vector(60, 60, 100))
	self.Col = owner:GetPlayerColor() * 100
end

function ENT:Think()
	self:NextThink(CurTime())
	return true
end

matStorm = Material("Models/Effects/comball_sphere")
matBlood = Material("Models/Effects/slimebubble_sheet")
matShockwave = Material("effects/tvscreen_noise002a")
matFire = Material("Effects/Combineshield/comshieldwall")
matIce = Material("models/shiny")
matNull = Material("models/spawn_effect2")
function ENT:Draw()
	local owner = self:GetOwner()
	if owner:IsValid() then
		if not owner:Alive() or owner:IsInvisible() or owner.SwordThrow then return end
		

		local boneindex = owner:LookupBone("valvebiped.bip01_r_hand")
		if boneindex then
			local pos, ang = owner:GetBonePosition(boneindex)
			local null_mult
			local cor_mult
			local frost_mult
			local sang_mult
			local storm_mult
			local flame_mult
			local shock_mult
			if LocalPlayer() == owner then
				local mana = owner:GetMana()
				null_mult = mana < 20 and 0.33 or 1
				cor_mult = mana < 30 and 0.33 or 1
				frost_mult = math.min(mana,20) / 20 or 1
				sang_mult = mana < 25 and 0 or 1
				storm_mult = mana < 20 and 0.33 or 1
				flame_mult = mana < 15 and 0.33 or 1
				shock_mult = mana < 15 and 0.33 or 1
			else
				null_mult = 1
				cor_mult = 1
				frost_mult = 1
				sang_mult = 1
				storm_mult = 1
				flame_mult = 1
				shock_mult = 1
			end
			
			if pos then
				local c = self.Col
				self:SetColor(Color(c.r, c.g, c.b))
				self:SetPos(pos + ang:Forward() * 28.75 + ang:Right() * 2.4 + ang:Up() * 57.5)
				ang:RotateAroundAxis(ang:Right(), 180)
				ang:RotateAroundAxis(ang:Up(), 80)
				self:SetAngles(ang)
				self:SetModelScale(1, 0)
				self:DrawModel()
				if owner:GetStatus("spellsaber_frostblade") then
					self:SetupBones()
					self:SetModelScale(1, 0)
					render.SetColorModulation(0,0.6*frost_mult,1*frost_mult)
					render.SuppressEngineLighting(true)
					render.SetBlend(0.1*frost_mult)
					render.ModelMaterialOverride(matIce)
					self:DrawModel()
					render.ModelMaterialOverride()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(false)
					render.SetBlend(1)
				end
				if owner:GetStatus("spellsaber_corruptblade") then
					self:SetupBones()
					self:SetModelScale(1, 0)
					render.SetColorModulation(0.3*cor_mult,0,0.5*cor_mult)
					self:DrawModel()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1,1,1)
				end
				if owner:GetStatus("spellsaber_sanguineblade") then
					self:SetupBones()
					self:SetModelScale(1, 0)
					render.SetColorModulation(0.6*sang_mult,0,0)
					render.SuppressEngineLighting(true)
					render.SetBlend(0.7*sang_mult)
					render.ModelMaterialOverride(matBlood)
					self:DrawModel()
					render.ModelMaterialOverride()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(false)
					render.SetBlend(1)
				end
				if owner:GetStatus("spellsaber_stormblade") then
					self:SetupBones()
					self:SetModelScale(1, 0)
					render.SetColorModulation(2*storm_mult,0.8*storm_mult,0)
					render.SuppressEngineLighting(true)
					render.SetBlend(0.5*storm_mult)
					render.ModelMaterialOverride(matStorm)
					self:DrawModel()
					render.ModelMaterialOverride()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(false)
					render.SetBlend(1)
				end
				if owner:GetStatus("spellsaber_flameblade") then
					self:SetupBones()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1*flame_mult,0.4*flame_mult,0)
					render.SuppressEngineLighting(true)
					render.ModelMaterialOverride(matFire)
					self:DrawModel()
					self:SetModelScale(1.1, 0)
					self:DrawModel()
					render.ModelMaterialOverride()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(false)
				end
				if owner:GetStatus("spellsaber_nullblade") then
					self:SetupBones()
					self:SetModelScale(1, 0)
					render.SetColorModulation(0,0,1*null_mult)
					render.SuppressEngineLighting(true)
					render.ModelMaterialOverride(matNull)
					render.SetBlend(0.5*null_mult)
					self:DrawModel()
					render.ModelMaterialOverride()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(false)
					render.SetBlend(1)
				end
				if owner:GetStatus("spellsaber_shockblade") then
					self:SetupBones()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1*shock_mult,1*shock_mult,1*shock_mult)
					render.SuppressEngineLighting(true)
					render.ModelMaterialOverride(matShockwave)
					render.SetBlend(0.1*shock_mult)
					self:DrawModel()
					render.ModelMaterialOverride()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(false)
					render.SetBlend(1)
				end
			end
		end
	end
end
