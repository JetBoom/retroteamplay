-- This is actually how the classes/spells are now managed.
function GM:RegisterSpell(name, tab)
	local gm = GAMEMODE or GM
	local index = #Spells + 1

	tab.Delay = #string.Explode(" ", tab.Words) * 0.1
	
	local inserttab = {}
	for _, suggested in pairs(tab.Classes) do
		for i, classtab in ipairs(CLASSES) do
			if classtab.Name == suggested then
				inserttab[i] = true
			end
		end
	end
	
	tab.CLASSES = inserttab
	
	local wordtab = {}
	for i, word in ipairs(string.Explode(" ", tab.Words)) do
		table.insert(wordtab, "nox/"..word.."2.ogg")
	end
	
	tab.Words = wordtab
	
	if CLIENT and tab.Icon then
		tab.Icon = Material(tab.Icon)
	end

	Spells[index] = tab
	--Spells[index] = {Name=name, Desc=desc, Mana=mana, CLASSES=inserttab, Words=wordtab, Delay=#wordtab * 0.1, Icon=icon, Inversable=inversable, Hostile=hostile}
	NameToSpell[tab.Name] = index
	NameToSpellLower[string.lower(tab.Name)] = index
	if SERVER then
		SpellFunctions[index] = tab.Cast
	end
end

function GM:RegisterSpells()
	local included = {}
	local spells = file.Find(self.FolderName.."/gamemode/spells/*.lua", "LUA")

	table.sort(spells)
	for i, filename in ipairs(spells) do
		SPELL = {}

		include("spells/"..filename)
		
		if SPELL.Name then
			self:RegisterSpell(SPELL.Name, SPELL)
		else
			ErrorNoHalt("SPELL "..filename.." has no 'Name' member!")
		end

		included[filename] = SPELL
		SPELL = nil
	end
end


function GM:RegisterClass(name, tab)
	if tab.Hidden and tab.Hidden == true then return end

	local gm = GAMEMODE or GM
	local index = #CLASSES + 1

	if CLIENT then
		tab.RawIcon = tab.RawIcon or "spellicons/berserkercharge.png"
		tab.Image = tab.Image or "noxctf/classicons/warrior"

		if tab.RawIcon then tab.Icon = Material(tab.RawIcon) end
	end

	CLASSES[index] = tab
end

function GM:RegisterClasses()
	local included = {}
	local classes = file.Find(self.FolderName.."/gamemode/classes/*.lua", "LUA")

	table.sort(classes)
	for i, filename in ipairs(classes) do
		CLASS = {}

		include("classes/"..filename)

		if CLASS.Name then
			self:RegisterClass(CLASS.Name, CLASS)
		else
			ErrorNoHalt("CLASS "..filename.." has no 'Name' member!")
		end

		included[filename] = CLASS
		CLASS = nil
	end
end

GM:RegisterClasses()
--GM:RegisterSpells()