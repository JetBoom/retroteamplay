local PANEL = {}

AccessorFunc(PANEL, "m_NumberOfBars", "NumberOfBars", FORCE_NUMBER)
AccessorFunc(PANEL, "m_Ping", "Ping", FORCE_NUMBER)
AccessorFunc(PANEL, "m_tColor", "Color")

PANEL.MaxPing = 300

function PANEL:Init()
	self.Seed = math.Rand(0, 10)

	self:SetPing(0)
	self:SetNumberOfBars(4)
	self:SetColor(color_white)
end

function PANEL:Paint()
	local bars = self:GetNumberOfBars()
	local barw = math.floor(self:GetWide() / bars)
	local barht = self:GetTall() / bars

	local x = 0
	for bar = 1, bars do
		local barh = math.ceil(barht * bar)

		if self:GetPing() < self.MaxPing * (1 - (bar / bars)) + self.MaxPing / bars then
			surface.SetDrawColor(self:GetColor())
			surface.DrawRect(x, self:GetTall() - barh, barw, barh)
			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawOutlinedRect(x, self:GetTall() - barh, barw, barh)
		else
			local barh1 = barh * 0.2
			surface.SetDrawColor(math.sin(RealTime() * math.pi * 2) * 200 + 55, 0, 0, 255)
			surface.DrawRect(x, self:GetTall() - barh1, barw, barh1)
			surface.SetDrawColor(255, 255, 255, 100)
			surface.DrawOutlinedRect(x, self:GetTall() - barh, barw, barh)
		end

		x = x + barw
	end
end

vgui.Register("DEXPingBars", PANEL, "DPanel")
