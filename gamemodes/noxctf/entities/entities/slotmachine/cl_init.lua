include("shared.lua")
include("pslot.lua")

local matGlow = Material("sprites/light_glow02_add")

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "ambient/atmosphere/city_beacon_loop1.wav")
	self.JackpotSound = CreateSound(self, "slot_sounds/jackpot.wav")
	self.WinSound = CreateSound(self, "slot_sounds/win.wav")

	--Trying to make it not be included in the gamemode itself (zs, rtp, hovergear, etc.)
	surface.CreateFont("Slot22", {font = "tahoma", size = 22, weight = 500, antialias = false})
	surface.CreateFont("Slot26", {font = "tahoma", size = 26, weight = 500, antialias = false})
	surface.CreateFont("Text3D", {font = "tahoma", size = 24, weight = 500, antialias = false})
end

function ENT:Draw()
	self:DrawModel()

	local pos, angles = self:GetPos(), self:GetAngles()
	local pset, aset = angles:Up()*7 + angles:Right()*-0.5 + angles:Forward()*5.3, Angle(0, 90, 90)

	cam.Start3D2D(pos +  pset, angles + aset, 0.5)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawRect(-18, -4, 34, 6)
			
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawRect(-18, 23, 34, 6)
		
			surface.SetDrawColor(Color(255, 255, 255, 255))
			surface.DrawRect(-18, 5, 10, 15)
			surface.DrawRect(-6, 5, 10, 15)
			surface.DrawRect(6, 5, 10, 15)

			surface.SetMaterial(Material("slot_icons/".. self.SlotEntries[ (self:IsRolling() and math.random(1, #self.SlotEntries) or self:GetDTInt(1)) ].Image ))
			surface.DrawTexturedRect(-18, 7, 10, 10)

			surface.SetMaterial(Material("slot_icons/".. self.SlotEntries[ (self:IsRolling() and math.random(1, #self.SlotEntries) or self:GetDTInt(2)) ].Image ))
			surface.DrawTexturedRect(-6, 7, 10, 10)

			surface.SetMaterial(Material("slot_icons/".. self.SlotEntries[ (self:IsRolling() and math.random(1, #self.SlotEntries) or self:GetDTInt(3)) ].Image ))
			surface.DrawTexturedRect(6, 7, 10, 10)
	cam.End3D2D()
	
	cam.Start3D2D(pos +  pset, angles + aset, 0.06)
		draw.DrawText("Jackpot: ".. self:GetJackpotValue(), "Text3D", -6, -18, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		
		if self:GetWon() or self:GetJackpot() then
			draw.DrawText( (self:GetJackpot() and "JACKPOT!" or "WIN!") .." ".. self:GetSlotWinValue() .." silver!", "Text3D", -6, 208, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		end
	cam.End3D2D()

	if self:GetJackpot() then
		local size = math.sin((RealTime() + 4)* 8) * 16 + 24
		local pset = angles:Up()*34 + angles:Forward()*-4

		render.SetMaterial(matGlow)
		render.DrawSprite(pos + pset, size, size, Color(255, 0, 0, 255))
	end
end

function ENT:Think()
	if self:GetJackpot() then
		self.JackpotSound:PlayEx(0.6, 100 + math.cos(CurTime()))
		self.AmbientSound:Stop()
		self.WinSound:Stop()
	elseif self:GetWon() then
		self.WinSound:PlayEx(0.6, 100)
		self.AmbientSound:Stop()
		self.JackpotSound:Stop()
	elseif not self:GetWon() and not self:GetJackpot() then
		self.AmbientSound:PlayEx(0.45, 95 + math.cos(CurTime()) * 5)
		self.JackpotSound:Stop()
		self.WinSound:Stop()
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	self.JackpotSound:Stop()
	self.WinSound:Stop()
end