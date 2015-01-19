include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(20, 32)

	self:SetRenderBounds(Vector(-120, -120, -18), Vector(120, 120, 80))

	hook.Add("HUDPaint", self, self.HUDPaint)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local matCircle = Material("awesomestrike/simplecircle")
function ENT:HUDPaint()
	if LocalPlayer() ~= self:GetOwner() then return end
	if self:GetOwner():ShouldDrawLocalPlayer() then return end

	local x, y = ScrW() * 0.35, ScrH() * 0.5
	local wid = 15 * BetterScreenScale()

	surface.SetMaterial(matCircle)
	surface.SetDrawColor(165, 50, 10, 105)
	surface.DrawTexturedRectRotated(x, y, wid, wid * math.max(1, self.Fatigue * 2), 20)
	surface.SetDrawColor(165, 50, 10, 105)
	surface.DrawTexturedRectRotated(ScrW() - x, y, wid, wid * math.max(1, self.Fatigue * 2), -20)
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if owner:IsInvisible() then return end

	local c = self.TeamCol
	local alpha = 255 * math.max(0.05,self.Fatigue/10)
	local origin = owner:LookupBone("ValveBiped.Bip01_Spine2")
   
	if origin then
			local pos, ang = owner:GetBonePosition(origin)
		   
			ang.r = ang.r + 25
			ang:RotateAroundAxis(ang:Forward(),-15)
			pos = pos + ang:Right()*4 + ang:Forward()*5
		   
			local frq,amp = 5,35
		   
			if owner:OnGround() then
					frq,amp = 2,20
			else   
					frq,amp = 10,45
			end
		   
			local EndLeft, EndRight = pos, pos
		   
			local Si = math.cos(RealTime() * frq)*amp
			local Co = math.sin(RealTime() * frq)*amp/2
		   
			local co2 = math.cos(RealTime() * frq)
		   
			local leftang, rightang = -55+Si, 55-Si
		   
		   
			local AngLeft = Angle(ang.p+math.Clamp(Co,-5,15),ang.y-15,ang.r+leftang)
		   
		   
			local StartLeft = pos + AngLeft:Right()*3.5
			EndLeft = pos + AngLeft:Right()*50
		   
			local AngRight = Angle(ang.p+math.Clamp(Co,-5,15),ang.y-15,ang.r+rightang)
		   
			local StartRight = pos + AngRight:Right()*3.5
			EndRight = pos + AngRight:Right()*50

			self.NextPuff = self.NextPuff or 0
   
			if self.NextPuff > CurTime() then return end
			self.NextPuff = CurTime() + 0.01
		   
			local emitter = self.Emitter
		   
			local start, curang = StartLeft, AngLeft
			local temp = -3.3
			for num=1,2 do
   
					for i=1, 9 do
						   
							if i~=9 then
									local particle = emitter:Add("effects/fire_cloud1", start + curang:Right()*(5*i)+VectorRand()*math.random(-2,2)+curang:Up()*(co2*i*temp))
									particle:SetStartAlpha(10)
									particle:SetEndAlpha(alpha)
									particle:SetStartSize(math.random(10, 14))
									particle:SetEndSize(0)
									particle:SetColor(c.r * 0.8, c.g * 0.8, c.b * 0.8)
									particle:SetDieTime(math.Rand(0.1, 0.2))
									particle:SetCollide( true )
							end
						   
							if math.random(1,30) == 1 then
									local particle = emitter:Add("sprites/glow04_noz", start + curang:Right()*(5*i)+VectorRand() * math.random(1,3))
									particle:SetVelocity(VectorRand() * 7)
									particle:SetDieTime(math.Rand(0.9,3))
									particle:SetStartAlpha(255)
									particle:SetStartSize(math.Rand(4,9))
									particle:SetEndSize(0)
									particle:SetRoll(180)
									particle:SetColor(c.r, c.g, c.b)
									particle:SetCollide( true )
									particle:SetGravity( Vector( 0, 0, -110 ) )
							end
						   
							for k=1, i do
									if i ~= 9 or (i==9 and k<=7) then
											local particle = emitter:Add("effects/fire_cloud1", start + curang:Right()*(5*i) + curang:Forward()*(-4*k)+VectorRand()*math.random(-2,2)+curang:Up()*(co2*i*temp))
											particle:SetStartAlpha(10)
											particle:SetEndAlpha(alpha)
											particle:SetStartSize(math.random(4, 9))
											particle:SetEndSize(0)
											particle:SetColor(185, 170, 45)
											particle:SetDieTime(math.Rand(0.1, 0.2))
											particle:SetCollide( true )
									end
							end
					end
				   
			start, curang = StartRight, AngRight
			temp = temp*-1
			end
		   
   
	end
end

