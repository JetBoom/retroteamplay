ENT.Type = "anim"

function ENT:Initialize()
	self:DrawShadow(false)
	NOAIRVEHICLES = true
	self.Think = nil
end

function ENT:OnRemove()
end
