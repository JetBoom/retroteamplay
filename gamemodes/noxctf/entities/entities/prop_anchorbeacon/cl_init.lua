include("shared.lua")

util.PrecacheSound("npc/scanner/scanner_scan_loop1.wav")

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "npc/scanner/scanner_scan_loop1.wav")
end

function ENT:Think()
	if self:IsOpaque() then
		self.AmbientSound:PlayEx(0.7, 100 + math.cos(CurTime()))
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end
