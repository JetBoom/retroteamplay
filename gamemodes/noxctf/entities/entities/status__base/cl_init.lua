include("shared.lua")

ENT.RenderBoundsMin = Vector(-64, -64, -18)
ENT.RenderBoundsMax = Vector(64, 64, 92)

function ENT:Initialize()
	self:DrawShadow(self.ShouldDrawShadow)
	self:SetRenderBounds(self.RenderBoundsMin, self.RenderBoundsMax)
	
	self.TeamCol = team.GetColor(self:GetOwner():GetTeamID()) or color_white
	
	if self.Move ~= nil then hook.Add("Move", self, self.Move) end
	if self.PreMove ~= nil then hook.Add("PreMove", self, self.PreMove) end
	if self.PostMove ~= nil then hook.Add("PostMove", self, self.PostMove) end
	
	self:StatusInitialize()
end

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		return self:StatusThink(owner)
	end
end

function ENT:OnRemove()
	--if self.Emitter then self.Emitter:Finish() end
	if self.AmbientSound then self.AmbientSound:Stop() end
	
	self:StatusOnRemove(self:GetOwner())
end

function ENT:Draw()
end
ENT.DrawTranslucent = ENT.Draw
