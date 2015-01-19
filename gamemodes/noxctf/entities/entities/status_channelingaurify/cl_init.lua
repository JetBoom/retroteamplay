include("shared.lua")

local ct
function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-64, -64, -16), Vector(64, 64, 72))

	self.LifeTime = self:GetDieTime() - CurTime()

	ct = CurTime()

	local target = self:GetTarget()
	if MySelf == target then
		hook.Add("RenderScreenspaceEffects", "GoldEffect", self.RenderScreenspaceEffects)
		MySelf:DI(NameToSpell["Aurify"], self.LifeTime) 
	end

	hook.Add("TranslateActivity", self, self.TranslateActivity)
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
end

function ENT:StatusOnRemove(owner)
	local target = self:GetTarget()
	if MySelf == target then
		MySelf:DI(NameToSpell["Aurify"], 0)
	end
	hook.Remove("RenderScreenspaceEffects", "GoldEffect")
end

function ENT:StatusThink(owner)
	local target = self:GetTarget()
	if target:IsValid() and owner:IsValid() then
		local startpos = self:GetStartPos()
		self:SetRenderBoundsWS(startpos, target:NearestPoint(startpos))
	else
		self:SetRenderBounds(Vector(-64, -64, -16), Vector(64, 64, 72))
	end
end

local matBeam = Material("trails/plasma")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	local target = self:GetTarget()
	if not owner:IsValid() or not target:IsValid() then return end

	render.SetMaterial(matBeam)

	local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
	if not attach then return end
	startpos = attach.Pos

	local delta = 1 - (self:GetDieTime() - CurTime())/self.LifeTime
	endpos = target:GetPos() + target:GetUp() * target:OBBMaxs().z * delta + owner:GetRight() * 10 * math.sin(CurTime() * 5)

	render.DrawBeam(startpos, endpos, 10, -CurTime(), -CurTime() + .5, COLOR_YELLOW)
end

local nodraw = false
local matGold = Material("models/shiny")
function ENT:PrePlayerDraw(pl)
	if nodraw then return end
	local target = self:GetTarget()
	if not target:IsValid() then return end
	if pl ~= target then return end

	local delta = 1 - (self:GetDieTime() - CurTime())/self.LifeTime

	if render.SupportsVertexShaders_2_0() then
		local normal = pl:GetUp() * -1
		render.EnableClipping(true)
		render.PushCustomClipPlane(normal, normal:Dot(pl:GetPos() + -1 * normal * pl:OBBMaxs().z * delta))
	end

	if render.SupportsPixelShaders_2_0() then
		render.ModelMaterialOverride(matGold)
			render.SetColorModulation(1, 1, 0)
				nodraw = true
				pl:DrawModel()
				nodraw = false
			render.SetColorModulation(1, 1, 1)
		render.ModelMaterialOverride()
	end

	if render.SupportsVertexShaders_2_0() then
		render.PopCustomClipPlane()
		render.EnableClipping(false)
	end

	if render.SupportsVertexShaders_2_0() then
		local normal = pl:GetUp()
		render.EnableClipping(true)
		render.PushCustomClipPlane(normal, normal:Dot(pl:GetPos() + normal * pl:OBBMaxs().z * delta))
	end
end

function ENT:PostPlayerDraw(pl)
	if nodraw then return end
	local target = self:GetTarget()
	if not target:IsValid() then return end
	if pl ~= target then return end
	
	if render.SupportsVertexShaders_2_0() then
		render.PopCustomClipPlane()
		render.EnableClipping(false)
	end
end

local cmtab = {["$pp_colour_brightness"] = -.2, ["$pp_colour_contrast"] = 1, ["$pp_colour_colour"] = 1, ["$pp_colour_addr"] = 1, ["$pp_colour_mulr"] = 1, ["$pp_colour_addg"] = 1}
function ENT:RenderScreenspaceEffects()
	local delta = (CurTime() - ct) / 5
	cmtab["$pp_colour_brightness"] = -.2 * delta
	cmtab["$pp_colour_addr"] = delta
	cmtab["$pp_colour_addg"] = delta
	DrawColorModify(cmtab)
end