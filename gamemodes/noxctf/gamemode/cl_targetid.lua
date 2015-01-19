TARGETID_LAST = MySelf
local texHealthBar = surface.GetTextureID("gui/gradient_down")
function GM:HUDDrawTargetID()
	if not IsValid(MySelf) then return end

	local trace = MySelf:GetEyeTrace()

	local entity = trace.Entity
	if not (entity:IsValid() and entity:IsPlayer()) then return end

	surface.SetFont("teamplaytargetid")
	local text = entity:Name()
	local __w, __h = surface.GetTextSize(text)
	local otherteam = entity:Team()
	local x, y = w * 0.5, h * 0.5 + 30

	if MySelf:Team() == otherteam then
		draw.SimpleText(text, "teamplaytargetid", x, y, Color(0,255,0,255), TEXT_ALIGN_CENTER)
		y = y + __h
		surface.SetDrawColor(225, 0, 0, 255)
		local hl = entity:Health()
		surface.DrawRect(w * 0.45, y, (hl / entity:GetMaxHealth()) * w * 0.1, h * 0.02)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(w * 0.45, y, w*0.1, h*0.02)
		draw.SimpleText(hl, "HUDHintTextLarge", x, y+2, Color(255,255,255,255), TEXT_ALIGN_CENTER, 0)
		surface.SetDrawColor(0,0,0,150)
		surface.SetTexture(texHealthBar)
		surface.DrawTexturedRect(w * 0.45, y, (hl / entity:GetMaxHealth()) * w * 0.1, h * 0.02)
	else
		if not entity:IsInvisible() then
			draw.SimpleText(text, "teamplaytargetid", x, y, Color(255,0,0,255), TEXT_ALIGN_CENTER)
			y = y + __h
			draw.SimpleText(team.GetName(otherteam), "teamplaytargetidsmall", x, y, COLOR_ENEMY, TEXT_ALIGN_CENTER)
		end
		TARGETID_LAST = entity
	end
end
