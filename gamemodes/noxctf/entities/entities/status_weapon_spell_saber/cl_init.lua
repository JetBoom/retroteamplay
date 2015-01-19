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
					render.SetColorModulation(0,0.6,1)
					render.SuppressEngineLighting(true)
					render.SetBlend(0.1)
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
					render.SetColorModulation(0.3,0,0.5)
					self:DrawModel()
					self:SetModelScale(1, 0)
					render.SetColorModulation(1,1,1)
				end
				if owner:GetStatus("spellsaber_sanguineblade") then
					self:SetupBones()
					self:SetModelScale(1, 0)
					render.SetColorModulation(0.6,0,0)
					render.SuppressEngineLighting(true)
					render.SetBlend(0.7)
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
					render.SetColorModulation(2,0.8,0)
					render.SuppressEngineLighting(true)
					render.SetBlend(0.5)
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
					render.SetColorModulation(1,0.4,0)
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
					render.SetColorModulation(0,0,1)
					render.SuppressEngineLighting(true)
					render.ModelMaterialOverride(matNull)
					render.SetBlend(0.5)
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
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(true)
					render.ModelMaterialOverride(matShockwave)
					render.SetBlend(0.1)
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
