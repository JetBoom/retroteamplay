include("shared.lua")

usermessage.Hook("recturrettarget", function(um)
	local target = um:ReadEntity()
	local turret = Entity(um:ReadShort())

	if turret:IsValid() and target:IsValid() then
		if turret.EndTargeting < CurTime() or turret.Target ~= target then
			turret:EmitSound("npc/turret_floor/active.wav")
		end
		turret.Target = target
		turret.EndTargeting = CurTime() + 3
	end
end)

function ENT:Draw()
	local c = self:GetColor()
	if c.a == 255 then
		local ct = CurTime()
		local target = self.Target
		if ct < self.EndTargeting and target:IsValid() and 0 < target:Health() then
			local eyepos = self:GetPos() + self:GetUp() * 64
			local ang = self:WorldToLocalAngles((target:NearestPoint(eyepos) - eyepos):Angle())
			local newyaw = math.Approach(self.PoseYaw, math.Clamp(math.NormalizeAngle(ang.yaw), -75, 75), FrameTime() * 100)
			self:SetPoseParameter("aim_yaw", newyaw)
			self.PoseYaw = newyaw
			local newpitch = math.Approach(self.PosePitch, math.Clamp(math.NormalizeAngle(ang.pitch), -15, 15), FrameTime() * 75)
			self:SetPoseParameter("aim_pitch", newpitch)
			self.PosePitch = newpitch
		else
			local newyaw = math.Approach(self.PoseYaw, math.sin(ct + self.Seed) * 45, FrameTime() * 60)
			self:SetPoseParameter("aim_yaw", newyaw)
			self.PoseYaw = newyaw
			local newpitch = math.Approach(self.PosePitch, math.cos((ct + self.SeedTwo) * 1.4) * 15, FrameTime() * 30)
			self:SetPoseParameter("aim_pitch", newpitch)
			self.PosePitch = newpitch
		end
	else
		self:SetPoseParameter("aim_pitch", 15)
	end

	self:DrawModel()
end

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	self.NextRequest = 0
	self.EndTargeting = 0
	self.Target = NULL
	self.AmbientSound = CreateSound(self, "npc/turret_wall/turret_loop1.wav")
	self.PosePitch = 0
	self.PoseYaw = 0
	self.Seed = math.Rand(0, 10)
	self.SeedTwo = math.Rand(0, 10)
end

function ENT:Think()
	local c = self:GetColor()
	if c.a == 255 then
		self.AmbientSound:PlayEx(0.5, 100 + math.sin(CurTime()) * 0.1)
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:Info(um)
	local str = um:ReadString()
	if str == "deny" then
		self.DeniedAccess = true
		return
	end

	local stuff = string.Explode(",", str)
	self.PHealth = tonumber(stuff[1])
	self.MaxPHealth = tonumber(stuff[2])
	self.AmmoType = stuff[3]
end

ENT.MaxTraceHUDPaintLength = 256

function ENT:TraceHUDPaint()
	if self.PHealth then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText("Auto-Turret", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		y = y + hhh * 1.2
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x - 100, y, 200, hhh)
		surface.SetDrawColor(255, 0, 0, 255)
		local health = self.PHealth
		local maxhealth = self.MaxPHealth
		surface.DrawRect(x - 100, y, (health / maxhealth) * 200, hhh)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - 100, y, 200, hhh)
		draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		y = y + hhh
		if self.AmmoType == "NONE" then
			draw.SimpleText("(NO BARREL)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Barrel: "..self.AmmoType, "teamplaytargetidsmall", x, y, color_white, TEXT_ALIGN_CENTER)
		end
	end

	if not self.DeniedAccess and self.NextRequest < CurTime() then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end
