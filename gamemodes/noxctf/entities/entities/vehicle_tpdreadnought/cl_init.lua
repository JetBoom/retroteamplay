include('shared.lua')

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "npc/combine_gunship/dropship_engine_distant_loop1.wav")
	
	self.Pilot = NULL
	self.Cannoneer = NULL
	self.TailGunner = NULL
	self.LeftPassenger = NULL
	self.RightPassenger = NULL
	self.RearPassenger1 = NULL
	self.RearPassenger2 = NULL
end

function ENT:Think()
	self.AmbientSound:PlayEx(80, math.min(150, 90 + self:GetVelocity():Length() * 0.05))
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

ENT.MaxTraceHUDPaintLength = 1500

function ENT:TraceHUDPaint()
	if self:Team() == MySelf:Team() then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText(self.Name, "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		y = y + hhh * 1.2
		surface.SetDrawColor(255, 0, 0, 255)
		local health = self:GetVHealth()
		local maxhealth = self:GetMaxVHealth()
		surface.DrawRect(x - w * 0.05, y, (health / maxhealth) * w * 0.1, h * 0.02)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - w * 0.05, y, w * 0.1, h * 0.02)
		draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
	else
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText(self.Name, "teamplay", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		draw.SimpleText(team.GetName(self:Team()), "DefaultBold", x, y + hhh, COLOR_RED, TEXT_ALIGN_CENTER)
	end
end

function ENT:DrawHUD(seat)
	local _, hhh = surface.GetTextSize("A")
	local x, y = w * 0.5, h * 0.8
	draw.SimpleText(self.Name..(self:GetSkin() == 1 and " (ANCHORED)" or ""), "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
	y = y + hhh * 1.2
	surface.SetDrawColor(255, 0, 0, 255)
	local health = self:GetVHealth()
	local maxhealth = self:GetMaxVHealth()
	surface.DrawRect(x - w * 0.1, y, (health / maxhealth) * w * 0.2, h * 0.04)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawOutlinedRect(x - w * 0.1, y, w * 0.2, h * 0.04)
	draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y + hhh * 0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)
	
	if seat == self:GetPilotSeat() then
		local aimvec = MySelf:GetAimVector()
		local startpos = MySelf:GetShootPos()
		
		local pos = (self:GetPos() + self:GetRight() * -4096):ToScreen()
		GAMEMODE:DrawCrosshair(pos.x, pos.y, 32, COLOR_RED)
			
		local pos = (startpos + aimvec * 4096):ToScreen()
		GAMEMODE:DrawCrosshair(pos.x, pos.y, 24, COLOR_YELLOW)
	end
	
	if seat == self:GetGunnerSeat() then
		local aimvec = MySelf:GetAimVector()
		local startpos = MySelf:GetShootPos()
			
		local pos = (startpos + aimvec * 4096):ToScreen()
		GAMEMODE:DrawCrosshair(pos.x, pos.y, 24, COLOR_RED)
	end
	
	if seat == self:GetCannonGunnerSeat() then
		local cannon = self:GetCannon()
		if cannon:IsValid() then
			local aimvec = cannon:GetAngles()
			local startpos = MySelf:GetShootPos()
				
			local pos = (startpos + aimvec:Up() * 4096):ToScreen()
			GAMEMODE:DrawCrosshair(pos.x, pos.y, 24, COLOR_RED)
		end
	end

	surface.SetFont("DefaultSmall")
	local lw, lh = surface.GetTextSize("L-Passenger 1: ------------------------------------------")
	local x = w * 0.5
	local y = h * 0.89

	draw.RoundedBox(4, x - lw * 0.5, y - 4, lw, h * 0.11, color_black_alpha90)

	if self.Pilot:IsValid() then
		draw.DrawText("Pilot: "..self.Pilot:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.Cannoneer:IsValid() then
		draw.DrawText("Cannoneer: "..self.Cannoneer:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.TailGunner:IsValid() then
		draw.DrawText("Tail Gunner: "..self.TailGunner:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.LeftPassenger:IsValid() then
		draw.DrawText("Left Passenger: "..self.LeftPassenger:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.RightPassenger:IsValid() then
		draw.DrawText("Right Passenger: "..self.RightPassenger:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.RearPassenger1:IsValid() then
		draw.DrawText("Rear Passenger 1: "..self.RearPassenger1:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.RearPassenger2:IsValid() then
		draw.DrawText("Rear Passenger 2: "..self.RearPassenger2:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
end

function ENT:Draw()
	self:DrawModel()
end

function RecDND(ent, pilot, cannoneer, tailgunner, leftpassenger, rightpassenger, rearpassenger1, rearpassenger2)
	ent = Entity(ent)
	if ent:IsValid() then
		pilot = Entity(pilot)
		cannoneer = Entity(cannoneer)
		tailgunner = Entity(tailgunner)
		leftpassenger = Entity(leftpassenger)
		rightpassenger = Entity(rightpassenger)
		rearpassenger1 = Entity(rearpassenger1)
		rearpassenger2 = Entity(rearpassenger2)
		
		ent.Pilot = pilot
		ent.Cannoneer = cannoneer
		ent.TailGunner = tailgunner
		ent.LeftPassenger = leftpassenger
		ent.RightPassenger = rightpassenger
		ent.RearPassenger1 = rearpassenger1
		ent.RearPassenger2 = rearpassenger2
	end
end
