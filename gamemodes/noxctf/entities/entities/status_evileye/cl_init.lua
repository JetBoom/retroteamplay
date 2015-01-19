include("shared.lua")

ENT.NextEmit = 0
ENT.Players = {}
ENT.Weps = {}

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(16, 24)
	
	hook.Add("PostDrawTranslucentRenderables", self, self.PostDrawTranslucentRenderables)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() or (MySelf == owner and not owner:ShouldDrawLocalPlayer()) or owner:IsInvisible() then return end
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + math.max(1, EFFECT_IQUALITY) * 0.03

	local attach = owner:GetAttachment(owner:LookupAttachment("eyes"))
	if not attach then return end
	local pos1 = attach.Pos + owner:GetForward() * 1.2 + owner:GetRight() * 1.5 - owner:GetUp() * .2
	local pos2 = attach.Pos + owner:GetForward() * 1.2 - owner:GetRight() * 1.5 - owner:GetUp() * .2

	local col = self.TeamCol

	local emitter = self.Emitter
	local particle = emitter:Add("sprites/light_glow02_add", pos1)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(255)
	particle:SetStartSize(4)
	particle:SetEndSize(1)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-0.8, 0.8))
	particle:SetColor(col.r, col.g, col.b)
	particle:SetVelocity((-owner:GetForward() + owner:GetRight() + owner:GetUp()) * 6)
		
	local particle = emitter:Add("sprites/light_glow02_add", pos2)
	particle:SetDieTime(0.3)
	particle:SetStartAlpha(255)
	particle:SetStartSize(4)
	particle:SetEndSize(1)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-0.8, 0.8))
	particle:SetColor(col.r, col.g, col.b)
	particle:SetVelocity((-owner:GetForward() - owner:GetRight() + owner:GetUp()) * 6)
end

local matGlow = Material("sprites/glow04_noz")
local matCham = Material("models/shiny")
function ENT:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	local owner = self:GetOwner()
	if MySelf ~= owner then return end
		
	if #self.Players > 0 then table.Empty(self.Players) end
	if #self.Weps > 0 then table.Empty(self.Weps) end

	cam.IgnoreZ(true)
		render.SuppressEngineLighting(true)
			render.ModelMaterialOverride(matCham)
				for _, pl in pairs(player.GetAll()) do		
					if pl:IsValid() and pl:Alive() and pl ~= owner and not pl:GetStatus("shadowstorm") and pl:GetCenter():Distance(owner:GetCenter()) <= self.Radius then
						local delta = 1 - pl:GetCenter():Distance(owner:GetCenter()) / self.Radius 
						render.SetBlend(math.min(1, delta * self.MaxVisibility))
							local c = team.GetColor(pl:GetTeamID()) or color_white
							render.SetColorModulation(c.r/255, c.g/255, c.b/255)
								pl:DrawModel()
								table.insert(self.Players, pl)

								local wep = pl:GetActiveWeapon()
								if wep and wep:IsValid() then
									table.insert(self.Weps, wep)
								end
				
								local status = pl:GetStatus("weapon_*")
								if status and status:IsValid() then
									table.insert(self.Weps, status)
								end
							render.SetColorModulation(1, 1, 1)
						render.SetBlend(1)
					end
				end
			render.ModelMaterialOverride()
		render.SuppressEngineLighting(false)
	cam.IgnoreZ(false)

	for _, pl in pairs(self.Players) do
		if pl:IsValid() and pl:Alive() then
			pl:DrawModel()

			if pl:GetCenter():Distance(owner:GetCenter()) <= self.Radius/2 then
				local pos = pl:GetPos() + pl:GetUp() * pl:OBBMaxs() * .7 + pl:GetRight() * 4
				local delta = math.Clamp(pl:Health() / pl:GetMaxHealth(), 0, 1)
				render.SetMaterial(matGlow)
				local siz = 28 + 8*math.sin(CurTime() * 3)
				cam.IgnoreZ(true)
					render.DrawSprite(pos, siz, siz, Color(255 * (1 - delta), 255 * delta, 0))
				cam.IgnoreZ(false)
			end
		end
	end
	
	for _, wep in pairs(self.Weps) do
		if wep:IsValid() then
			wep:DrawModel()
		end
	end
end