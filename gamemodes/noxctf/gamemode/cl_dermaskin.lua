function surface.CreateLegacyFont(font, size, weight, antialias, additive, name, shadow, outline, blursize)
	surface.CreateFont(name, {font = font, size = size, weight = weight, antialias = antialias, additive = additive, shadow = shadow, outline = outline, blursize = blursize})
end

local SKIN = {}

SKIN.PrintName 		= "NoxRTP - Black"
SKIN.Author 		= "ZC0M"
SKIN.DermaVersion	= 1

--_print( "DERMA SKIN LOADING: "..SKIN.PrintName.." by "..SKIN.Author.."..." )

SKIN.colOutline	= Color(0, 250, 0, 250)

// Buttons
SKIN.colButtonText				= Color( 255, 255, 255, 255 )		-- 
SKIN.colButtonTextDisabled		= Color( 255, 255, 255, 150 )
SKIN.colButtonBorder			= Color( 20, 20, 20, 75 )
SKIN.colButtonBorderHighlight	= Color( 0, 255, 0, 100 )
--SKIN.colButtonBorderHighlight	= Color( 255, 255, 255, 0 )
SKIN.colButtonBorderShadow		= Color( 0, 150, 0, 125 )

// Common controls & widgets
SKIN.control_color 				= Color( 50, 50, 50, 155 )
SKIN.control_color_highlight	= Color( 50, 50, 50, 125 )
SKIN.control_color_highlight2	= Color( 0, 0, 0, 125 )
SKIN.control_color_active 		= Color( 0, 150, 0, 255 )
SKIN.control_color_active2 		= Color( 0, 0, 0, 200 )
SKIN.control_color_bright 		= Color( 0, 0, 0, 255 )
SKIN.control_color_dark 		= Color( 0, 0, 0, 200 ) 
SKIN.control_color_dark2 		= Color( 0, 0, 0, 255 )
SKIN.control_color 				= Color( 100, 100, 100, 200 )

SKIN.control_color_highlight	= Color( 130, 130, 130, 125 )
SKIN.control_color_active 		= Color( 120, 120, 120, 125 )
SKIN.control_color_bright 		= Color( 100, 100, 100, 175 )
SKIN.control_color_dark 		= Color( 80, 80, 80, 200 )

// Frame and panel backgrounds
SKIN.bg_color 					= Color( 75, 50, 50, 155 )
SKIN.bg_color_sleep 			= Color( 0, 25, 0, 155 )
SKIN.bg_color_dark				= Color( 0, 0, 0, 155 )
SKIN.bg_color_bright			= Color( 100, 100, 100, 155 )
// Secondary backgrounds
SKIN.bg_alt1 					= Color( 0, 0, 0 , 155 )
SKIN.bg_alt2 					= Color( 25, 25, 25, 155 )

// Fonts
SKIN.fontButton					= "DefaultSmall"
SKIN.fontTab					= "TabLarge"
SKIN.fontFrame					= "Default"
SKIN.fontForm 					= "DefaultSmallDropShadow"
SKIN.fontLabel 					= "Default"
SKIN.fontLargeLabel 			= "Default"

SKIN.colTabBG 					= Color(0, 0, 0, 255)
SKIN.colPropertySheet 			= Color( 0, 50, 0 , 255 )
SKIN.colTab			 			= SKIN.colPropertySheet
SKIN.colTabInactive				= Color( 75, 90, 60, 155 )
SKIN.colTabShadow				= Color( 60, 60, 60, 255 )
SKIN.colTabText		 			= Color( 255, 255, 255, 255 )
SKIN.colTabTextInactive			= Color( 200, 200, 200, 155 )
SKIN.colNumberWangBG			= Color( 100, 100, 100, 255 )

surface.CreateLegacyFont("trebuchet", 18, 500, true, false, "dbuttonfont")

function cutLength ( str, pW, font )
	surface.SetFont(font);
	
	local sW = pW - 40;
	
	for i = 1, string.len(str) do
		local sStr = string.sub(str, 1, i);
		local w, h = surface.GetTextSize(sStr);
		
		if (w > pW || (w > sW && string.sub(str, i, i) == " ")) then
			local cutRet = cutLength(string.sub(str, i + 1), pW, font);
			
			local returnTable = {sStr};
			
			for k, v in pairs(cutRet) do
				table.insert(returnTable, v);
			end
			
			return returnTable;
		end
	end
	
	return {str};
end

function SKIN:DrawGenericBackground( border1, border2, w, h, color )

	surface.SetDrawColor( color )
	surface.DrawRect( 0, 0, w, h )

end

function SKIN:DrawTransparentDoubleGradientBackground( x, y, w, h, r, g, b, r2, g2, b2 )

	for i=1, h, 3 do

		local gradient = (i / h)
		surface.SetDrawColor( (r*(1-gradient))+(r2*gradient), (g*(1-gradient))+(g2*gradient), (b*(1-gradient))+(b2*gradient), ((gradient*2)+3)*50 )
		surface.DrawRect( x, y+i, w, 3 )

	end 
	surface.SetDrawColor( 0, 0, 0, 100)
	surface.DrawOutlinedRect( x, y, w, h)
end

function SKIN:DrawDoubleGradientBackground( x, y, w, h, r, g, b, r2, g2, b2 )

for i=1, h, 3 do

	local gradient = (i / h)
	surface.SetDrawColor( (r*(1-gradient))+(r2*gradient), (g*(1-gradient))+(g2*gradient), (b*(1-gradient))+(b2*gradient), 150 )
	surface.DrawRect( x, y+i, w, 3 )

	end 
	surface.SetDrawColor( 0, 0, 0, 155)
	surface.DrawOutlinedRect( x, y, w, h)
end


function SKIN:DrawDoubleColourBackground( x, y, w, h, p, r, g, b, r2, g2, b2 )

	surface.SetDrawColor( r, b, g, 255 )
	surface.DrawRect( x, y, w, h/p )

	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawRect( x+3, y+3, w-3, math.Clamp((h/10)-3, 1, 2) )
	surface.SetDrawColor( 255, 255, 255, 155 )
	--surface.DrawRect( x+3, y+3, 1, h-6 )


	for i=(h/p), h, 3 do
	
	surface.SetDrawColor( r*(1-(i/h))+r2*(i/h), g*(1-(i/h))+g2*(i/h), b*(1-(i/h))+b2*(i/h), 255 )
	surface.DrawRect( x, i, w, 3)
	end
end

function SKIN:DrawHorDoubleColourBackground( x, y, w, h, p, r, g, b, r2, g2, b2 )


	surface.SetDrawColor( r, b, g, 255 )
	surface.DrawRect( x, y, w/p, h )

	for i=(w/p), w, 3 do

	surface.SetDrawColor( r*(1-(i/w))+r2*(i/w), g*(1-(i/w))+g2*(i/w), b*(1-(i/w))+b2*(i/w), 255 )
	surface.DrawRect( i, y, 3, h)
	end
end

function SKIN:DrawHorDoubleGradientBackground( x, y, w, h, r, g, b, r2, g2, b2 )

for i=1, w, 3 do

	local gradient = (i / w)
	surface.SetDrawColor( (r*(1-gradient))+(r2*gradient), (g*(1-gradient))+(g2*gradient), (b*(1-gradient))+(b2*gradient), 1 )
	surface.DrawRect( x+i, y, 3, h )

	end 

end

/*---------------------------------------------------------
	Frame & Form
---------------------------------------------------------*/

function SKIN:PaintFrame( panel )

	local color = self.bg_color

	self:DrawTransparentDoubleGradientBackground( 0, 0, panel:GetWide(), panel:GetTall(), 0, 0, 0, 0, 75, 25 )
	
	self:DrawDoubleGradientBackground( 0, 0, panel:GetWide(), panel:GetTall(), 0, 0, 0, 40, 40, 40 )
	
	surface.SetDrawColor( 0, 0, 0, 255)
	surface.DrawOutlinedRect( 0, 0, panel:GetWide(), 27)
	surface.SetDrawColor( self.colOutline )
	surface.DrawRect( 0, panel:GetTall()-3, panel:GetWide(), 1 )
	
	end

function SKIN:PaintForm( panel )

	local color = self.bg_color_sleep

	self:DrawDoubleGradientBackground( 0, 9, panel:GetWide(), panel:GetTall()-9, 0, 0, 0, 0, 50, 0 )

	end

/*---------------------------------------------------------
	NumSlider
---------------------------------------------------------*/

function SKIN:PaintNumSlider( panel )

	local w, h = panel:GetSize()
	
	self:DrawHorDoubleGradientBackground( 0, 0, w, h, 0, 0, 0, 0, 50, 0 )
	
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawRect( 3, h/2, w-6, 1 )
	
	end

/*---------------------------------------------------------
	Tooltip
---------------------------------------------------------*/
function SKIN:PaintTooltip( panel )

	local w, h = panel:GetSize()
	local contents = panel.Contents
	if not contents then return end
	
	DisableClipping( true )
	
	// This isn't great, but it's not like we're drawing 1000's of tooltips all the time
	for i=1, 4 do
	
		local BorderSize = i
		local BGColor = (255 / i) * 0.3
		
		self:DrawGenericBackground( BorderSize, BorderSize, w, h, Color( 160, 160, 160, BGColor ))
		panel:DrawArrow( BorderSize, BorderSize )
		self:DrawGenericBackground( -BorderSize, BorderSize, w, h, Color( 160, 160, 160, BGColor ))
		panel:DrawArrow( -BorderSize, BorderSize )
		self:DrawGenericBackground( BorderSize, -BorderSize, w, h, Color( 160, 160, 160, BGColor ))
		panel:DrawArrow( BorderSize, -BorderSize )
		self:DrawGenericBackground( -BorderSize, -BorderSize, w, h, Color( 160, 160, 160, BGColor ))
		panel:DrawArrow( -BorderSize, -BorderSize )
		
		end

	self:DrawGenericBackground( -1, -1, w+2, h+2, Color(0, 0, 0, 255))
	panel:DrawArrow( -1, 0 )
	panel:DrawArrow( 1, 0 )
	panel:DrawArrow( 0, 1 )
	self:DrawGenericBackground( 0, 0, w, h, Color(200, 255, 200, 255))
	panel:DrawArrow( 0, 0 )

	DisableClipping( false )
	
	end


/*---------------------------------------------------------
	ScrollBar
---------------------------------------------------------*/
function SKIN:PaintVScrollBar( panel )
	local col = self.control_color_active
	self:DrawHorDoubleColourBackground( 2, 0, panel:GetWide()-4, panel:GetTall(), 3, col.r, col.g, col.b, 25/2, 75/2, 25/2 )
	surface.SetDrawColor( 0, 0, 0, 250 )
	surface.DrawOutlinedRect( 2, 0, panel:GetWide()-4, panel:GetTall() )

end

function SKIN:PaintScrollBarGrip( panel )
	local col = self.control_color_active
	self:DrawDoubleColourBackground( 1, 0, panel:GetWide()-2, panel:GetTall(), 3, col.r, col.g, col.b, 120/1.5, 120/1.5, 120/1.5 )
	--draw.RoundedBox( 6, 0, 0, panel:GetWide()-2, panel:GetTall(), Color( col.r/2, col.g/2, col.b/2, 100 ) )
	surface.SetDrawColor( 0, 0, 0, 250 )
	surface.DrawOutlinedRect( 1, 0, panel:GetWide()-2, panel:GetTall() )
end


/*---------------------------------------------------------
	Button
---------------------------------------------------------*/
function SKIN:PaintButton( panel )

	local w = panel:GetWide()
	local h = panel:GetTall()
	local x, y = panel:GetPos()

	if ( panel.m_bBackground ) then
	
		local col = self.control_color_dark
		local col2 = self.control_color_dark2
		local sine = 0.7
		local line = Color( 0, 0, 0, 255 )

		if ( panel:GetDisabled() ) then
			col = self.control_color_dark
			col2 = self.control_color_dark2

		elseif ( panel.Depressed ) then
			col = self.control_color_active2
			col2 = self.control_color_active
			sine = 0.5
			line = Color( 0, 150, 0, 255 )

		elseif ( panel.Hovered ) then
			col = self.control_color_highlight
			col2 = self.control_color_highlight2
			sine = math.Clamp(math.abs(math.sin(CurTime()*3)+1), 0.5, 1.13)
			line = Color( 0, 150, 0, 255 )
		end
	
		
	self:DrawDoubleColourBackground( 0, 0, w, h, 3, math.Clamp(col.r*sine, 0, 150), math.Clamp(col.b*sine, 0, 150), math.Clamp(col.g*sine, 0, 150), math.Clamp(col2.r*sine, 0, 175), math.Clamp(col2.g*sine, 0, 175), math.Clamp(col2.b*sine, 0, 175) )
	surface.SetDrawColor( line.r, line.g, line.b, 255 )
	surface.DrawOutlinedRect( 0, 0, w, h)
	end

end

function SKIN:PaintOverButton( panel )
	
	--draw.RoundedBox( 6, 1, 1, panel:GetWide()-2, panel:GetTall()-2, Color( 255, 255, 255, 35 ) )

end

/*---------------------------------------------------------
	Tab
---------------------------------------------------------*/
function SKIN:PaintTab( panel )

	// This adds a little shadow to the right which helps define the tab shape..
	--draw.RoundedBox( 4, 0, 0, panel:GetWide(), panel:GetTall() + 8, self.colTabShadow )
	
	if ( panel:GetPropertySheet():GetActiveTab() == panel ) then

		draw.RoundedBox( 4, 1, 0, panel:GetWide()-2, panel:GetTall() + 8, self.colTab )

	else

		local col = self.control_color_dark
		local col2 = self.control_color_dark2

		self:DrawDoubleColourBackground( 4, 1, panel:GetWide()-2, panel:GetTall() + 8, 9, col.r/1.3, col.b/1.3, col.g/1.3, col2.r/1.3, col2.g/1.3, col2.b/1.3 )
		--surface.SetDrawColor( 0, 0, 0, 255 )
		--surface.DrawOutlinedRect( 4, 1, panel:GetWide()-2, panel:GetTall() + 8)
	end
	
end
--derma.DefineSkin( "hgskin_black", "Black, grey, and red gradients tailored to match the current site.", SKIN ) 

derma.DefineSkin("nox", "Derma skin for NoX", SKIN, "Default")

function GM:ForceDermaSkin()
	return "nox"
end
