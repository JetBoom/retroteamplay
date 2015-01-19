include("shared.lua")

local fadetime = 1/5

function ENT:StatusInitialize()
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
	if MySelf == self:GetOwner() then hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects) end

	local ct = CurTime()
	local dt = self:GetDieTime()
	local lt = dt - ct
	self.LifeTime = lt
	self.FadeOutTime = ct + lt * fadetime
	self.FadeInTime = dt - lt * fadetime
end

local matWhite = Material("models/debug/debugwhite")
function ENT:PrePlayerDraw(pl)
	if pl ~= self:GetOwner() then return end
	if pl:GetStatus("invisibility") or pl:GetStatus("shadowstorm") then return end
	
	pl:RemoveAllDecals()

	local blend
	local time = self.Time
	if time >= self.LifeTime * (1 - fadetime) then
		blend = math.Clamp((self.FadeOutTime - CurTime()) / (self.LifeTime * fadetime), 0, 1)
	elseif time <= self.LifeTime * fadetime then
		blend = math.Clamp(1 - (self:GetDieTime() - CurTime()) / (self.LifeTime * fadetime), 0, 1)
	else
		blend = 0
	end

	render.SetBlend(blend)
	if blend <= .3 then
		render.SetColorModulation(0.5, 0.5, 0.5)
		render.ModelMaterialOverride(matWhite)
	end
end

function ENT:PostPlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	render.SetBlend(1)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end

-- all credit goes to zetanor for the below code
local colmod = {
	['$pp_colour_addr'] = 2/255,
	['$pp_colour_addg'] = 4/255,
	['$pp_colour_addb'] = 40/255,
	['$pp_colour_brightness'] = -0.1,
	['$pp_colour_contrast'] = 0.75,
	['$pp_colour_colour'] = 0.35,
	['$pp_colour_mulr'] = 3/255,
	['$pp_colour_mulg'] = 6/255,
	['$pp_colour_mulb'] = 12/255
}

local texGradientU = surface.GetTextureID('vgui/gradient-u')
local texGradientD = surface.GetTextureID('vgui/gradient-d')
local texGradientR = surface.GetTextureID('vgui/gradient-r')

local vignetteFraction = 0.3
local vignetteColor = Color(0, 0, 0, 220)
local entryFlashFactor = 5
function ENT:RenderScreenspaceEffects()
	local myColmod = table.Copy(colmod)
	local timeLeft = self:GetDieTime() - CurTime()
	local transitionTime = 0.15
	
	local scrW, scrH = ScrW(), ScrH()
	local vignetteSize = scrH*vignetteFraction
	
	surface.SetDrawColor(vignetteColor)
	
	surface.SetTexture(texGradientU)
	surface.DrawTexturedRect(0, 0, scrW, vignetteSize)
	surface.SetTexture(texGradientR)
	surface.DrawTexturedRect(scrW-vignetteSize, 0, vignetteSize, scrH)
	surface.SetTexture(texGradientD)
	surface.DrawTexturedRect(0, scrH-vignetteSize, scrW, vignetteSize)
	
	surface.SetTexture(texGradientU)
	surface.DrawTexturedRectRotated(vignetteSize/2, scrH/2, scrH, vignetteSize, 90)
	
	if timeLeft < transitionTime then
		myColmod['$pp_colour_brightness'] = myColmod['$pp_colour_brightness'] + 1 - timeLeft/transitionTime
	else
		myColmod['$pp_colour_brightness'] = math.max(1 + ((self:GetDieTime() - self.LifeTime) - CurTime()) / (transitionTime*entryFlashFactor), myColmod['$pp_colour_brightness'])
	end
	
	DrawColorModify(myColmod)
end