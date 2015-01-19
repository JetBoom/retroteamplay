LP = LocalPlayer

local LocalizedStuff = {}

LocalizedStuff[-1] = "NULL"
LocalizedStuff[0] = " "
LocalizedStuff[3] = "Your team's global prop limit has been reached."
LocalizedStuff[4] = "You don't have enough Silver to spawn this."
LocalizedStuff[5] = "Your building rights have been suspended."
LocalizedStuff[6] = "Location is too close to enemy building."
LocalizedStuff[7] = "Location is too close to a player."
LocalizedStuff[8] = "Location is too far from a friendly building."
LocalizedStuff[9] = "Invalid location."
LocalizedStuff[17] = "You will respawn here if you die."
LocalizedStuff[18] = "Your respawn point no longer exists!"
LocalizedStuff[21] = "Not enough mana."
LocalizedStuff[22] = "Your class can't cast _1_!"
LocalizedStuff[23] = "Unknown spell ID."
LocalizedStuff[24] = "You must specify a spell name."
LocalizedStuff[26] = "You must wait to use this ability again."
LocalizedStuff[27] = "Your concentration has been broken."
LocalizedStuff[28] = "Too close to a verification beacon to place that here."
LocalizedStuff[29] = "Too close to an objective to place it there."
LocalizedStuff[30] = "You can't teleport while holding a flag."
LocalizedStuff[31] = "Your concentration has been broken by a War Cry."
LocalizedStuff[32] = "You mark the location."
LocalizedStuff[33] = "You must be on the ground to cast this spell!"
LocalizedStuff[34] = "A War Cry has interrupted your casting!"
LocalizedStuff[35] = "You can't concentrate on any more creatures."
LocalizedStuff[36] = "You have too many of those in play!"
LocalizedStuff[37] = "That location is blocked."
LocalizedStuff[38] = "Your manually bound spawn point has been lost."
LocalizedStuff[39] = "You must near your flag stand to change classes."
LocalizedStuff[40] = "You can't change classes while carrying the flag!"
LocalizedStuff[41] = "This doesn't belong to you."
LocalizedStuff[42] = "This belongs to to _1_."
LocalizedStuff[43] = "This used to belong to _1_. It is now yours."
LocalizedStuff[44] = "That spell is forbidden by the current game rules."
LocalizedStuff[45] = "That ability is forbidden by the current game rules."
LocalizedStuff[46] = "The _1_ class requires that you have the award: '_2_'!"
LocalizedStuff[47] = "The _1_ class requires _2_ defeated enemies!"
LocalizedStuff[48] = "You don't have enough mana for all of those spells!"
LocalizedStuff[50] = "You have reached your personal maximum of those."
LocalizedStuff[51] = "Your team has reached the maximum amount of those."
LocalizedStuff[52] = "You can't use Evade while holding the flag."
LocalizedStuff[53] = "Typhoon can only be used outside."
LocalizedStuff[54] = "That spell is disabled on this map."
LocalizedStuff[55] = "You can't teleport while under the effects of Anchor."
LocalizedStuff[56] = "Jolt can only be used outside."
LocalizedStuff[57] = "This Health Dispenser requires time to recharge."
LocalizedStuff[58] = "This Teleport Pad requires mana from a Mana Capacitor."
LocalizedStuff[59] = "You can't use Grapple Arrow while carrying the flag!"
LocalizedStuff[60] = "Poison Rain can only be used outside."
LocalizedStuff[61] = "That location is blocked by an Anchor Beacon."
LocalizedStuff[62] = "You can only focus on channeling one spell at a time."
LocalizedStuff[63] = "There wouldn't be enough room here."
LocalizedStuff[64] = "You must be on the ground to create an earthquake."
LocalizedStuff[65] = "You are being weighed down."
LocalizedStuff[66] = "You need to cool down."
LocalizedStuff[68] = "You are mana stunned."
LocalizedStuff[70] = "You used a bind, thus your concentration has been broken."
LocalizedStuff[72] = "Your mind is still focused from the previous spell."
LocalizedStuff[74] = "You cannot cast a spell while dead."
LocalizedStuff[75] = "You are unable to perform this action."
LocalizedStuff[76] = "You are unable to use other abilities while charging."
LocalizedStuff[77] = "You are too focused on channeling blink."
LocalizedStuff[78] = "You are frozen solid."
LocalizedStuff[79] = "You are knocked down."
LocalizedStuff[80] = "You are stunned."
LocalizedStuff[81] = "Sun Beam can only be used outside."
LocalizedStuff[82] = "You must wait to use another ability."
LocalizedStuff[83] = "You must wait to attack."
LocalizedStuff[84] = "You require a longbow for that ability!"
LocalizedStuff[85] = "You must look at the ground to use that ability."
LocalizedStuff[86] = "You need to stand by a soul to cast this spell."
LocalizedStuff[87] = "Not enough free space to cast this spell."
LocalizedStuff[88] = "You have been turned into gold."
LocalizedStuff[89] = "You failed to absorb any life essence."
LocalizedStuff[90] = "You cannot traverse the void while carrying the flag."
LocalizedStuff[91] = "You must attach the nether bomb to a solid surface."
LocalizedStuff[92] = "Too close to a player spawn."
LocalizedStuff[93] = "Planting bomb for maximum damage..."
LocalizedStuff[94] = "Bomb planted successfully."

function GetLocalized(int)
	return LocalizedStuff[int] or "NULL"
end
GL = GetLocalized

usermessage.Hook("lm", function(um)
	local int = um:ReadShort()
	local args = um:ReadString()
	local str = GetLocalized(int)
	if 0 < string.len(args) then
		args = string.Explode("@", args)
		for k, v in ipairs(args) do
			str = string.gsub(str, "_"..k.."_", v)
		end
	end
	GAMEMODE:AddNotify(str, COLOR_WHITE, 4)
end)

usermessage.Hook("lmr", function(um)
	local int = um:ReadShort()
	local args = um:ReadString()
	local str = GetLocalized(int)
	if 0 < string.len(args) then
		args = string.Explode("@", args)
		for k, v in ipairs(args) do
			str = string.gsub(str, "_"..k.."_", v)
		end
	end
	GAMEMODE:AddNotify(str, COLOR_RED, 4)
end)

usermessage.Hook("lmg", function(um)
	local int = um:ReadShort()
	local args = um:ReadString()
	local str = GetLocalized(int)
	if 0 < string.len(args) then
		args = string.Explode("@", args)
		for k, v in ipairs(args) do
			str = string.gsub(str, "_"..k.."_", v)
		end
	end
	GAMEMODE:AddNotify(str, COLOR_LIMEGREEN, 4)
end)

function LM(int, args)
	local str = GetLocalized(int)
	if args then
		for k, v in ipairs(args) do
			str = string.gsub(str, "_"..k.."_", v)
		end
	end
	GAMEMODE:AddNotify(str, COLOR_WHITE, 4)
end

function LMR(int, args)
	local str = GetLocalized(int)
	if args then
		for k, v in ipairs(args) do
			str = string.gsub(str, "_"..k.."_", v)
		end
	end
	GAMEMODE:AddNotify(str, COLOR_RED, 4)
end

function LMG(int, args)
	local str = GetLocalized(int)
	if args then
		for k, v in ipairs(args) do
			str = string.gsub(str, "_"..k.."_", v)
		end
	end
	GAMEMODE:AddNotify(str, COLOR_LIMEGREEN, 4)
end

function AM(str)
	GAMEMODE:AddNotify("Admin: "..str, COLOR_RED, 10)
end
