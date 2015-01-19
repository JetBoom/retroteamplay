include("shared.lua")

function ENT:StatusInitialize()
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
	hook.Add("HUDPaint", self, self.HUDPaint)
end

local matCircle = Material("awesomestrike/simplecircle")
function ENT:HUDPaint()
	if LocalPlayer() ~= self:GetOwner() then return end

	local x, y = ScrW() * 0.5, ScrH() * 0.65
	local wid = 48 * BetterScreenScale()
	local viswid = self:GetVisibility(LocalPlayer()) * wid

	surface.SetMaterial(matCircle)
	surface.SetDrawColor(10, 10, 10, 120)
	surface.DrawTexturedRectRotated(x, y, wid, wid, 0)
	surface.SetDrawColor(0, 177, 255, 120)
	surface.DrawTexturedRectRotated(x, y, (wid * 4 + viswid) / 5, viswid, 0)
end

function ENT:GetVisibility(pl)
	if pl:GetStatus("shadowstorm") then return 0 end
	local MySelf = LocalPlayer()
	local plteam = pl:Team()

	local blend = 0
	local infravision = false
	if MySelf == pl then
		-- A bit more difficult here, we actually need to run a loop and see if anyone else is looking at us.
		local radiusblend = 0
		local dotblend = 0
		for _, ent in pairs(ents.FindInSphere(pl:GetPos(), self.FadeInDotDistance + pl:BoundingRadius())) do
			if not ent:IsPlayer() or ent == pl or ent:Team() == plteam then continue end

			local eyepos = ent:EyePos()
			local nearest = pl:NearestPoint(eyepos)
			local distance = eyepos:Distance(nearest)

			if distance < self.FadeInRadius then
				radiusblend = math.max(radiusblend, (1 - distance / self.FadeInRadius) ^ 1.5)
			end

			if distance < self.FadeInDotDistance then
				dotblend = math.max(dotblend, math.max(0, (ent:EyeAngles():Forward():Dot((nearest - eyepos):GetNormalized()) ^ 3 - 0.8) * 5) * (1 - distance / self.FadeInDotDistance))
			end

			if ent:GetStatus("infravision") or ent:GetStatus("evileye") then
				infravision = true
			end
		end

		blend = blend + radiusblend + dotblend + math.min(pl:GetVelocity():Length() / self.FadeInSpeed, 1) ^ 1.5
	else
		local eyepos = EyePos()
		local nearest = pl:NearestPoint(eyepos)
		local distance = eyepos:Distance(nearest)

		if distance < self.FadeInRadius then
			blend = blend + (1 - distance / self.FadeInRadius) ^ 1.5
		end

		if distance < self.FadeInDotDistance then
			blend = blend + math.max(0, (EyeVector():Dot((nearest - eyepos):GetNormalized()) ^ 3 - 0.8) * 5) * (1 - distance / self.FadeInDotDistance)
		end

		if MySelf:GetStatus("infravision") or MySelf:GetStatus("evileye") then
			infravision = true
		end

		blend = blend + math.min(pl:GetVelocity():Length() / self.FadeInSpeed, 1) ^ 1.5
	end

	if pl:Crouching() then blend = blend * 0.90 end

	blend = blend / 4

	if pl:GetStatus("treadlightly") then blend = blend / 6 end
	
	if infravision then blend = math.max(blend, 0.5) end

	if pl:GetStatus("voidwalk") then blend = 0 end

	return blend
end

function ENT:PostPlayerDraw(pl)
	if pl ~= self:GetOwner() then return end
	if pl:GetStatus("shadowstorm") then return end

	render.SetBlend(1)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end

local matWhite = Material("models/debug/debugwhite")
function ENT:PrePlayerDraw(pl)
	if pl ~= self:GetOwner() then return end
	if pl:GetStatus("shadowstorm") then return end

	local blend = self:GetVisibility(pl)

	if pl:Team() == LocalPlayer():Team() then
		blend = math.max(blend, 0.1)
	elseif blend <= 0 then return true end -- Don't draw at all.

	blend = blend * self.FadeInPower
	
	render.SetBlend(blend)
	if blend <= 0.3 then
		render.SetColorModulation(0.2, 0.2, 0.2)
		render.ModelMaterialOverride(matWhite)
	end
end
