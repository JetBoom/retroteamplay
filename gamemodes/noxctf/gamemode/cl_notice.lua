COLOR_WHITE = Color(255, 255, 255, 255)
COLOR_GREEN = Color(0, 255, 0, 255)
COLOR_RED = Color(255, 0, 0, 255)

local cpMessage = ""
local cpColor = Color(255, 255, 255)
local cpDieTime = 0
local cpStartTime = 0
local cpMessageWidth = 0
local cpMessageHeight = 0

local texGradRight = surface.GetTextureID("VGUI/gradient-r")
function GM:DrawCenterPrint()
	if CurTime() < cpDieTime then
		local screenscale = BetterScreenScale()

		local x, y = w * 0.5, h * 0.75
		local a = math.min(1, cpDieTime - CurTime())
		local gradw = (64 + (1 - a) * w) * screenscale + cpMessageWidth
		local gradh = 32 * screenscale + cpMessageHeight
		cpColor.a = a * 255
		surface.SetTexture(texGradRight)
		surface.SetDrawColor(10, 10, 10, a * 120)
		surface.DrawTexturedRectRotated(x + gradw, y, gradw, gradh, 180)
		surface.DrawTexturedRectRotated(x - gradw, y, gradw, gradh, 0)
		gradw = gradw
		surface.DrawRect(x - gradw * 0.5, y - gradh * 0.5, gradw, gradh)
		draw.SimpleText(cpMessage, "teamplay_centerprint", x, y, cpColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function GM:CenterPrint(message, color, lifetime)
	cpStartTime = CurTime()
	cpDieTime = cpStartTime + (lifetime or 5)
	cpMessage = message or ""
	surface.SetFont("teamplay_centerprint")
	cpMessageWidth, cpMessageHeight = surface.GetTextSize(cpMessage)
	cpMessageWidth = math.ceil(cpMessageWidth * 0.5) * 2
	cpMessageHeight = math.ceil(cpMessageHeight * 0.5) * 2
	color = color or color_white
	cpColor.r = color.r
	cpColor.g = color.g
	cpColor.b = color.b

	local m, s = string.match(cpMessage, "(.-)~s(.+)")
	if s then
		cpMessage = m
		surface.PlaySound(s)
	end
end
GM.CenterPrintAll = GM.CenterPrint

local HUDNotes = {}
function GM:AddNotify(str, color, length)
	if not str then return end

	length = length or 4
	color = color or color_white

	for _, note in pairs(HUDNotes) do
		if note.text == str then
			note.recv = RealTime()
			note.death = RealTime() + length
			note.color = table.Copy(color)
			if length <= 1 then
				note.color.a = math.floor(length * 255)
			end
			return
		end
	end

	local tab = {}
	tab.text = str
	tab.recv = RealTime()
	tab.death = RealTime() + length
	tab.color = table.Copy(color)

	if 4 < #HUDNotes then
		table.remove(HUDNotes, #HUDNotes)
	end

	table.insert(HUDNotes, 1, tab)
end

function GM:PaintNotes()
	if #HUDNotes < 1 then return end

	local y = h * 0.8
	for i, note in ipairs(HUDNotes) do
		if note then
			if RealTime() < note.death then
				if note.death - RealTime() <= 1 then
					note.color.a = math.floor((note.death - RealTime()) * 255)
				end
				draw.SimpleText(note.text, "NoticeFont", w * 0.5, y, note.color, TEXT_ALIGN_CENTER)
				local addx, addy = surface.GetTextSize(note.text)
				y = y - addy
			else
				table.remove(HUDNotes, i)
				i = i - 1
			end
		end
	end
end
