local old_textsize = surface.GetTextSize
function surface.GetTextSize( t )
	return old_textsize( string.gsub( t, "&", "^" ) )
end

local vguiCursor = "none"
local lastCursor = "none"

function SetWorldCursor( name )
	
	vguiCursor = name
	
end
function GetWorldCursor()
	
	return vguiCursor
	
end

local textureCorner = surface.GetTextureID("gui/corner16")

function draw.OutlinedBox(border, x, y, w, h, color, borderColor, borderSize)
	x = math.Round(x)
	y = math.Round(y)
	w = math.Round(w)
	h = math.Round(h)
	
	--if (color) then
		--draw.RoundedBox(border, x, y, w, h, color)
	--end
	
	if (color) then
		surface.SetDrawColor(color)
		surface.SetTexture(textureCorner)

		surface.DrawTexturedRectRotated(x +border /2, y +border /2, border, border, 0)
		surface.DrawTexturedRectRotated(x +w -border /2, y +border /2, border, border, 270)
		surface.DrawTexturedRectRotated(x +w -border /2, y +h -border /2, border, border, 180)
		surface.DrawTexturedRectRotated(x +border /2, y + h -border /2, border, border, 90)
	end

	if (borderSize) then
		surface.SetDrawColor(borderColor)
		
		surface.DrawRect(x, 				 y +border, 		borderSize, 		h -border *2 +1) -- Left
		surface.DrawRect(x +border, 		 y, 				w -border *2, 		borderSize) 	 -- Top
		surface.DrawRect(w -borderSize +x, 	 y +border, 		borderSize, 		h -border *2) 	 -- Right
		surface.DrawRect(x +border, 		 h -borderSize +y, 	w -border *2, 		borderSize) 	 -- Bottom
	else
		if (borderColor) then
			surface.SetDrawColor(borderColor)
			
			surface.DrawLine(x +border -1, y, 		x +w -border, y)
			surface.DrawLine(x +border -1, y +h -1, x +w -border, y +h -1)
		
			surface.DrawLine(x, y +border -1, x, y +h -border)
			surface.DrawLine(x +w -1, y +border -1, x +w -1, y +h -border)
		end
	end
end

function draw.SimpleRect(x, y, w, h, col)
	surface.SetDrawColor(col)
	surface.DrawRect(x, y, w, h)
end

function draw.SimpleOutlined(x, y, w, h, col)
	surface.SetDrawColor(col)
	surface.DrawOutlinedRect(x, y, w, h)
end

function draw.DoubleOutlined(x, y, w, h, col)
	surface.SetDrawColor(col)
	surface.DrawOutlinedRect(x, y, w, h)
	surface.DrawOutlinedRect(x +1, y +1, w -2, h -2)
end

function draw.Texture(x, y, w, h, color, texture)
	surface.SetDrawColor(color)
	surface.SetTexture(texture)
	surface.DrawTexturedRect(x, y, w, h)
end

function draw.Material(x, y, w, h, color, material)
	surface.SetDrawColor(color)
	surface.SetMaterial(material)
	surface.DrawTexturedRect(x, y, w, h)
end

function draw.DrawTextureRotated(x, y, w, h, color, texture, rotated)
	surface.SetDrawColor(color)
	surface.SetTexture(texture)
	surface.DrawTexturedRectRotated(x, y, w, h, rotated)
end

function util.GetTextSize(font, text)
	surface.SetFont(font)

	return surface.GetTextSize(text)
end