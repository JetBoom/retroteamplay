include("shared.lua")

util.PrecacheSound("NPC_CombineGunship.RotorSound")

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(120, 140)
	self.NextSmoke = 0
	self.Pilot = NULL
	self.LeftGunner = NULL
	self.RightGunner = NULL
	self.LeftPassenger1 = NULL
	self.LeftPassenger2 = NULL
	self.RightPassenger1 = NULL
	self.RightPassenger2 = NULL

	self.PilotGunSound = CreateSound(self, "npc/combine_gunship/gunship_weapon_fire_loop6.wav")
	self.LeftGunnerSound = CreateSound(self, "npc/combine_gunship/gunship_weapon_fire_loop6.wav")
	self.RightGunnerSound = CreateSound(self, "npc/combine_gunship/gunship_weapon_fire_loop6.wav")
	self.RotorSound = CreateSound(self, "NPC_CombineGunship.RotorSound")
end

function ENT:CalcViewFirstFunc(seat, ply, origin, angles, fov, znear, zfar)
	if ply == self.Pilot then
		return {origin = origin, angles = self:GetAngles()}
	end
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
	self.RotorSound:PlayEx(100, math.min(150, 100 + self:GetVelocity():Length() * 0.03))
	local skin = self:GetSkin()
	if skin == 0 then
		self.PilotGunSound:Stop()
	elseif skin == 1 then
		self.PilotGunSound:PlayEx(95, 100)
	elseif skin == 2 then
		self.PilotGunSound:Play()
	elseif skin == 3 then
		self.PilotGunSound:Play()
	end
end

function ENT:OnRemove()
	self.Emitter:Finish()
	self.RotorSound:Stop()
	self.PilotGunSound:Stop()
	self.LeftGunnerSound:Stop()
	self.RightGunnerSound:Stop()
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
	local x, y = w * 0.5, h * 0.8
	draw.SimpleText(self.Name, "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
	local _, hhh = surface.GetTextSize("A")
	y = y + hhh * 1.2
	surface.SetDrawColor(255, 0, 0, 255)
	local health = self:GetVHealth()
	local maxhealth = self:GetMaxVHealth()
	surface.DrawRect(x - w * 0.1, y, (health / maxhealth) * w * 0.2, h * 0.04)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawOutlinedRect(x - w * 0.1, y, w * 0.2, h * 0.04)
	draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y + hhh * 0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)

	if self.Pilot == MySelf then
		local getpos = self:GetPos()
		local startpos = getpos + self:GetUp() * 59.5 + self:GetForward() * 170 + self:GetRight() * -62.5
		local pos = util.TraceLine({start=startpos, endpos = startpos + MySelf:GetAimVector() * 8000, filter = self, mask = MASK_SOLID}).HitPos:ToScreen()
		GAMEMODE:DrawCrosshair(pos.x, pos.y, 32, COLOR_RED)
		--[[local x, y = pos.x, pos.y
		local w2 = w * 0.015
		surface.SetDrawColor(255, 0, 0, 200)
		surface.DrawLine(x - w2, y, x + w2, y)
		surface.DrawLine(x, y - w2, x, y + w2)
		surface.SetDrawColor(255, 255, 255, 200)
		local w3 = w2 * 1.5
		local w4 = w3 * 2
		surface.DrawOutlinedRect(x - w3, y - w3, w4, w4)]]

		local pos = (startpos + self:GetForward() * 4096):ToScreen()
		local x, y = pos.x, pos.y
		local w2 = w * 0.025
		surface.SetDrawColor(0, 255, 0, 200)
		surface.DrawLine(x, y - w2, x, y + w2)

		local fw = MySelf:GetAimVector()
		fw.y = 0
		local pos2 = (startpos + fw:GetNormal() * 4096):ToScreen()
		local x2, y2 = pos.x, pos.y
		surface.SetDrawColor(255, 230, 0, 200)
		surface.DrawLine(x2, y2 - w2, x2, y2 + w2)

		surface.DrawLine(x, y, x2, y2)
	elseif self.LeftGunner == MySelf or self.RightGunner == MySelf then
		local startpos = MySelf:EyePos()
		local pos = util.TraceLine({start = startpos, endpos = startpos + MySelf:GetAimVector() * 4096, filter = self, mask = MASK_SOLID}).HitPos:ToScreen()
		GAMEMODE:DrawCrosshair(pos.x, pos.y, 32, COLOR_RED)
		--[[local x, y = pos.x, pos.y
		local w2 = w * 0.015
		surface.SetDrawColor(255, 0, 0, 200)
		surface.DrawLine(x - w2, y, x + w2, y)
		surface.DrawLine(x, y - w2, x, y + w2)
		surface.SetDrawColor(255, 255, 255, 200)
		local w3 = w2 * 1.5
		local w4 = w3 * 2
		surface.DrawOutlinedRect(x - w3, y - w3, w4, w4)]]
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
	if self.LeftGunner:IsValid() then
		draw.DrawText("L-Gunner: "..self.LeftGunner:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.RightGunner:IsValid() then
		draw.DrawText("R-Gunner: "..self.RightGunner:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.LeftPassenger1:IsValid() then
		draw.DrawText("L-Passenger 1: "..self.LeftPassenger1:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.LeftPassenger2:IsValid() then
		draw.DrawText("L-Passenger 2: "..self.LeftPassenger2:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.RightPassenger1:IsValid() then
		draw.DrawText("R-Passenger 1: "..self.RightPassenger1:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.RightPassenger2:IsValid() then
		draw.DrawText("R-Passenger 2: "..self.RightPassenger2:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
end

function ENT:Draw()
	self:DrawModel()

	if self.NextSmoke <= CurTime() then
		self.NextSmoke = CurTime() + 0.025

		local particle = self.Emitter:Add("particles/smokey", self:GetPos())
		particle:SetVelocity(VectorRand() * 8)
		particle:SetDieTime(1.9)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(14, 16))
		particle:SetEndSize(4)
		particle:SetRoll(math.random(0, 360))
		local c = team.GetColor(self:Team())
		particle:SetColor(c.r, c.g, c.b)
	end
end

usermessage.Hook("RecDSD", function(um)
	local ent = um:ReadEntity()

	if ent:IsValid() then
		ent.Pilot = um:ReadEntity() or NULL
		ent.LeftGunner = um:ReadEntity() or NULL
		ent.RightGunner = um:ReadEntity() or NULL
		ent.LeftPassenger1 = um:ReadEntity() or NULL
		ent.LeftPassenger2 = um:ReadEntity() or NULL
		ent.RightPassenger1 = um:ReadEntity() or NULL
		ent.RightPassenger2 = um:ReadEntity() or NULL
	end
end)

function RecDSD(ent, pilot, leftgunner, rightgunner, leftpassenger1, leftpassenger2, rightpassenger1, rightpassenger2)
	--print( "Dropship Crew Dump ["..tostring(CurTime()).."]" )
	--print( pilot, leftgunner, rightgunner, leftpassenger1, leftpassenger2, rightpassenger1, rightpassenger2 )
	ent = Entity(ent)
	if ent:IsValid() then
		pilot = Entity(tonumber(pilot) or 0)
		leftgunner = Entity(tonumber(leftgunner) or 0)
		rightgunner = Entity(tonumber(rightgunner) or 0)
		leftpassenger1 = Entity(tonumber(leftpassenger1) or 0)
		leftpassenger2 = Entity(tonumber(leftpassenger2) or 0)
		rightpassenger1 = Entity(tonumber(leftpassenger1) or 0)
		rightpassenger2 = Entity(tonumber(rightpassenger2) or 0)

		if pilot:IsValid() and pilot:IsPlayer() then
			ent.Pilot = pilot
		end
		if leftgunner:IsValid() and leftgunner:IsPlayer() then
			ent.LeftGunner = leftgunner
		end
		if rightgunner:IsValid() and rightgunner:IsPlayer() then
			ent.RightGunner = rightgunner
		end
		if leftpassenger1:IsValid() and leftpassenger1:IsPlayer() then
			ent.LeftPassenger1 = leftpassenger1
		end
		if leftpassenger2:IsValid() and leftpassenger2:IsPlayer() then
			ent.LeftPassenger2 = leftpassenger2
		end
		if rightpassenger1:IsValid() and rightpassenger1:IsPlayer() then
			ent.RightPassenger1 = rightpassenger1
		end
		if rightpassenger2:IsValid() and rightpassenger2:IsPlayer() then
			ent.RightPassenger2 = rightpassenger2
		end
	end
end
