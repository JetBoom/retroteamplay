local function GetClassGroup(class)
	return (class.Group == "Magic") and 1 or (class.Group == "Hybrid") and 2 or 3
end

local current_selected_class
local screens = math.min(1, ((w/3840) + 0.5) ^ 2)

local matBar = surface.GetTextureID("noxctf/classselect_bar" )
local matBarBack = surface.GetTextureID("noxctf/classselect_bar_back" )
local matClasstype = surface.GetTextureID("noxctf/classselect_type")
local matClassDetail = surface.GetTextureID("noxctf/classselect_detail")
local matNull = Material("null")

local class_colors = {}

class_colors[1] = Color(100,220,240,200) -- Magic
class_colors[2] = Color(120,170,250,200) -- Hybrid
class_colors[3] = Color(255,130,70,200) -- MeleeOther

class_colors[4] = Color(20,128,240) -- Magic Text
class_colors[5] = Color(30,100,255) -- Hybrid Text
class_colors[6] = Color(200,50,20) -- MeleeOther Text

local buttons = {}
local labels = {}

local centx,centy = w/2, h/2
local categW,categH = surface.GetTextureSize(matClasstype)
local Counts = {0, 0, 0}
local MaxCounts = {0, 0, 0}
local color_black_transparent = table.Copy(color_black)
color_black_transparent.a = 128

local color_orange_transparent = Color(255, 0, 0, 128)
local color_white_transparent = Color(255, 255, 255, 128)

local names = {"Magic", "Hybrid", "Melee / Other"}
local meter_names = {"Ease of Use", "Offense", "Defense", "Group Fighting", "Health", "Mana", "Mana Regeneration", "Speed"}
local meter = {}

for k,v in pairs(CLASSES) do
	if v.Group != "Hidden" then
		local id = GetClassGroup(v)
		MaxCounts[id] = MaxCounts[id] + 1
	end
end

local PANEL = {}
PANEL.Color = color_white

function PANEL:SetRating(rating)
	self.Color = HSVToColor(rating * 12, 1, 1)
	self.Rating = rating
end
function PANEL:Paint()
	if not self:GetParent():IsVisible() then return end
	local rating = self.Rating or 1
	local wid, hei = self:GetSize()
	
	surface.SetDrawColor(0, 0, 0, 210)
	surface.SetTexture(matBarBack)
	surface.DrawTexturedRect(0, 0, wid, hei)
	surface.SetDrawColor(self.Color.r, self.Color.g, self.Color.b, 255)
	surface.SetTexture(matBar)
	surface.DrawTexturedRect(0, 0, wid * rating * 0.1, hei)
	draw.SimpleText(self.Name, "ClassSelect3", wid/2, hei/2, self.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
vgui.Register("ClassRating2", PANEL, "Panel")

local function SwitchToClass(classindex)
	local class = CLASSES[classindex]
	if class.Group == "Hidden" or not meter[1] or not meter[1].SetRating then return end
	meter[1]:SetRating(class.EaseOfUse)
	meter[2]:SetRating(class.Offense)
	meter[3]:SetRating(class.Defense)
	meter[4]:SetRating(class.GroupFighting)
	meter[5]:SetRating(class.Health * 0.05)
	meter[6]:SetRating(class.Mana * 0.06)
	meter[7]:SetRating(class.ManaRegeneration * 0.65)
	meter[8]:SetRating((1 - ((SPEED_FASTEST - class.Speed) / (SPEED_FASTEST - SPEED_SLOWEST))) * 10)
end

local classmats = {}
local icon_directory = "noxctf/classicons/"

for k,v in pairs(file.Find("materials/"..icon_directory.."*.vmt", "MOD")) do
	v = string.sub(v, 1 ,-5)
	classmats[v] = Material(icon_directory .. v)
end

local function DrawClassDetail()
	surface.SetFont("ClassSelect3")
	local __, txH = surface.GetTextSize("A")
	local classicon_w,classicon_h = 256 * screens, 512 * screens
	
	local class = CLASSES[current_selected_class]
	if not class or class.Group == "Hidden" then return end
	
	local id = GetClassGroup(class)
	surface.SetDrawColor(class_colors[id])
	surface.SetTexture(matClassDetail)
	surface.DrawTexturedRect(0, 0, 512 * screens , 1024 * screens)
	
	if class.Image then
		surface.SetTexture(surface.GetTextureID(class.Image))
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(classicon_w/2, classicon_h/16, classicon_w, classicon_h)
	end

	surface.SetFont("ClassSelect2")
	
	local stringth = string.Explode("@", class.Description)
	
	for k, text in pairs(stringth) do
		draw.SimpleText(text, "ClassSelect3", classicon_w, (classicon_h - (16*screens)) + (k*txH) - ((#stringth*txH)/2), color_white, TEXT_ALIGN_CENTER, 0)
	end
	
	local classname = current_selected_class == MySelf:GetPlayerClass() and class.Name.." [C]" or class.Name
	draw.SimpleText(classname, "ClassSelect", classicon_w , 32*screens, class_colors[id+3],TEXT_ALIGN_CENTER, 0)
end
	
local function DrawClassSelection()
	for i=1,3 do
		local wid = 1024 * screens 
		local hei = 512 * screens
		local x = centx - (320 * screens)
		local y = centy + (360 * screens * ( i - 2 ))
		
		surface.SetDrawColor(class_colors[i])
		surface.SetTexture(matClasstype)
		surface.DrawTexturedRect(x-(wid/2), y-(hei/2), wid, hei)
		
		draw.SimpleText(names[i], "ClassSelect", x ,y-(160 * screens), class_colors[i+3], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
	
local frameClassSelect
function MakepClasses()
	if frameClassSelect and frameClassSelect:Valid() then frameClassSelect:Remove() end

	Counts = {0, 0, 0}
	current_selected_class = 0
	frameClassSelect = vgui.Create("DFrame")
	frameClassSelect:SetPos(0, 0)
	frameClassSelect:SetSize(ScrW(), ScrH())
	frameClassSelect:SetTitle("")
	frameClassSelect:SetDeleteOnClose(true)
	frameClassSelect:SetVisible(true)
	frameClassSelect:SetDraggable(false)
	frameClassSelect:ShowCloseButton(true)
	frameClassSelect:MakePopup()

	local panelClassDetail = vgui.Create("DPanel", frameClassSelect)
	local wid,hei = 512 * screens, 1024 * screens
	local x = 530 * screens + centx
	local y = centy
	
	panelClassDetail:SetPos(x-(wid /2) , y-(hei /2))
	panelClassDetail:SetSize(wid, hei)
	panelClassDetail:SetVisible(false)
		
	local panelClassUseButton = vgui.Create("DButton", panelClassDetail)
	local widb,heib = 200 * screens, 60 * screens
	panelClassUseButton:SetSize(widb, heib)
	panelClassUseButton:SetPos(wid/2 - (100 * screens), hei - (128 * screens))
	panelClassUseButton:SetText("USE CLASS")
	panelClassUseButton:SetFont("ClassSelect3")
	panelClassUseButton.DoClick = function(button)
		MySelf:ConCommand("CCChangeClass "..current_selected_class)
		frameClassSelect:Close()
	end
	panelClassUseButton.ApplySchemeSettings = function() end
	panelClassUseButton.Paint = function()
		draw.RoundedBox(6, 0, 0, widb,  heib, panelClassUseButton:IsDown() and color_orange_transparent or color_black_transparent)
	end

	for k,v in pairs(meter_names) do
		meter[k] = vgui.Create("ClassRating2",panelClassDetail)
		meter[k]:SetPos(128 * screens, 544 * screens + (k * 33 * screens))
		meter[k]:SetSize(256 * screens, 32 * screens)
		meter[k].Rating = k/#meter_names
		meter[k].Name = v
	end

	for k,v in pairs(CLASSES) do 

		if v.Group != "Hidden" then 
		
			local id = GetClassGroup(v)
			Counts[id] = Counts[id] + 1
			
			local row = centy + (360 * screens * (id-2))
			local column = (centx - (832 * screens)) + (((Counts[id]-0.5)/MaxCounts[id]) * (1024*screens))
			
			
			local restrictions = CLASSES[k].Restrictions
			local disable = false
			
			if restrictions then
				for _, restriction in pairs(restrictions) do
					if restriction == GAMEMODE.GameType then v.Disabled = true end
				end
			end
			
			if v.Disabled or GAMEMODE.DisabledClasses[id] then disable = true end
			
			local b = 0.666667 * screens
			
			--[[buttons[k] = vgui.Create("DModelPanel", frameClassSelect)
				local button = buttons[k]
				button:SetAnimated(true)
				button:SetModel(v.Model)
				button:SetSize(256 * b, 400 * b)
				button:SetPos(column - (128 * b), row - (200 * b))
				local ent = button.Entity
				
				ent:ResetSequence(ent:LookupSequence("idle_melee2"))
				ent:SetPoseParameter("breathing", 1)

				
				button:SetAmbientLight(class_colors[id])
				button:SetCamPos(Vector(48, 6, 56))
				--button:SetLookAt(Vector(0, 0, 0))
				local boneindex = ent:LookupBone("valvebiped.bip01_r_hand")
				--local pos, ang = ent:GetBonePosition(boneindex)
				--[[button.LayoutEntity = function(e, ent)
					if e.bAnimated then
						e:RunAnimation()
					end
				end
				
				if disable then
					button:SetColor(color_black)
					button:SetDisabled(true)
				else
					button.DoClick = function( button )
						if current_selected_class == k then 
							current_selected_class = 0
							 panelClassDetail:SetVisible( false )
							surface.PlaySound( "buttons/button6.wav" )
						else
							current_selected_class = k
							SwitchToClass(k)
							panelClassDetail:SetVisible( true )
							surface.PlaySound( "buttons/button9.wav" )
						end
					end
					
					button.DoRightClick = function( button )
						MySelf:ConCommand("CCChangeClass "..k)
						frameClassSelect:Close()
					end
				end]]
				
			buttons[k] = vgui.Create("DImageButton", frameClassSelect)
			local button = buttons[k]
			
			if v.Image then
				button:SetMaterial(v.Image)
			end
			
			local b = 0.666667 * screens
			
			button:SetSize(256 * b, 512 * b)
			button:SetPos(column-(128 * b), row-(256 * b))
			button:SetDrawBorder(false)
			button:SetText("")
			button.Paint = nil
			
			if disable then
				button:SetColor(color_black)
				button:SetDisabled(true)
			else
				button.DoClick = function(button)
					if current_selected_class == k then 
						current_selected_class = 0
						 panelClassDetail:SetVisible(false)
						surface.PlaySound("buttons/button6.wav")
					else
						current_selected_class = k
						SwitchToClass(k)
						panelClassDetail:SetVisible(true)
						surface.PlaySound("buttons/button9.wav")
					end
				end
				
				buttons[k].DoRightClick = function(button)
					MySelf:ConCommand("CCChangeClass "..k)
					frameClassSelect:Close()
				end
			end

			labels[k] = vgui.Create("DLabel", frameClassSelect)
			local label = labels[k]
			local name = k == MySelf:GetPlayerClass() and v.Name.." [C]" or not disable and v.Name or "[DISABLED]"
			label:SetText(name)
			label:SetFont("ClassSelect2")
			
			surface.SetFont( "ClassSelect2" )
			local xheight, yheight = surface.GetTextSize(name)
			
			label:SetPos(column - (xheight/2), row - (128*screens) - (yheight/2))
			label:SetSize(xheight, yheight)
			label:SetColor(class_colors[id+3])
		end
	end

	panelClassDetail.Paint = DrawClassDetail
	frameClassSelect.Paint = DrawClassSelection
end
