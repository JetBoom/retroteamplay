include("shared.lua")

function ENT:Initialize()
	self.Col = self:GetOwner():GetPlayerColor() * 100
	self:DrawShadow(false)
	self:SetColor(Color(self.Col.r,self.Col.g,self.Col.b,255))
	self:SetMaterial("Models/props_pipes/PipeMetal001a")
	self.AmbientSound = CreateSound(self, "npc/manhack/mh_blade_loop1.wav")
end

function ENT:Think()
	
	if self:GetVelocity():Length() > 0 then
		self.AmbientSound:PlayEx(1,90)
	else
		self.AmbientSound:Stop()
	end
	
	
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:DrawTranslucent()
	local pos = self:GetPos()
	local vel = self:GetVelocity()
	local len = vel:Length()

	local dist = 20

	self:SetModelScale( 1, 0 )

	self:SetupBones()
	self:DrawModel()

	if len > 10 then
		self.LastPos = pos
		
		for i=0, 8 do
			local gpos = pos - vel:GetNormal() * ( len/1100 * ( dist + dist * i ) )

			self:SetPos( gpos )

			self:SetModelScale( 1 - 0.1 * i, 0 )

			self:SetupBones()

			render.SetBlend( 0.8 - i * 0.1  )
			self:DrawModel()
			render.SetBlend( 1 )

		end

		self:SetPos( self.LastPos )
	end

end