----------------------	Sassilization--	By Sassafrass / Spacetech / LuaPineapple--------------------local tex = Material("sassilization/hud2.png")local texw, texh = 1024, 256local totalWidth, totalHeight, u, v, uw, vh, w, h, x, y, x1, y1, textX, textY, textWidth, textHeight, miracleSize, cornerSizefunction GM:DrawCreedBar( le, sw, sh, scale )	cornerSize = 16	miracleSize = 48		local numMiracles = 7		totalWidth = cornerSize * 2 + numMiracles * miracleSize + 2 * (numMiracles-1)	totalHeight = 60		x, y = sw * 0.5 - totalWidth * scale * 0.5, sh - totalHeight * scale --screen x, screen y		--draw left edge	u, v = 0 / texw, 224 / texh --U, V Coord	uw, vh = 32, 16 --U width, V height	w, h = cornerSize, totalHeight * scale - cornerSize * scale --width, height	x1, y1 = x, y + cornerSize * scale	surface.DrawTexturedRectUVEx( x1, y1, w * scale, h * scale, u, v, u + uw / texw, v + vh / texh )		--draw left corner	u, v = 0 / texw, 192 / texh --U, V Coord	uw, vh = 32, 32 --U width, V height	w, h = cornerSize, cornerSize --width, height	x1, y1 = x, y	surface.DrawTexturedRectUVEx( x1, y1, w * scale, h * scale, u, v, u + uw / texw, v + vh / texh )		--draw top edge	u, v = 32 / texw, 193 / texh --U, V Coord	uw, vh = 48, 32 --U width, V height	w, h = totalWidth - cornerSize * 2, cornerSize --width, height	x1, y1 = x + cornerSize * scale, y	surface.DrawTexturedRectUVEx( x1, y1, w * scale, h * scale, u, v, u + uw / texw, v + vh / texh )		--draw right corner	u, v = 80 / texw, 192 / texh --U, V Coord	uw, vh = 32, 32 --U width, V height	w, h = cornerSize, cornerSize --width, height	x1, y1 = x + totalWidth * scale - cornerSize * scale, y	surface.DrawTexturedRectUVEx( x1, y1, w * scale, h * scale, u, v, u + uw / texw, v + vh / texh )		--draw right edge	u, v = 80 / texw, 224 / texh --U, V Coord	uw, vh = 32, 16 --U width, V height	w, h = cornerSize, totalHeight * scale - cornerSize * scale --width, height	x1, y1 = x + totalWidth * scale - cornerSize * scale, y + cornerSize * scale	surface.DrawTexturedRectUVEx( x1, y1, w * scale, h * scale, u, v, u + uw / texw, v + vh / texh )		u, v = 208 / texw, 112 / texh	uw, vh = 80, 80	w, h = miracleSize, miracleSize	x1, y1 = x + cornerSize * scale, y + 8 * scale	for i = 1, numMiracles do		surface.DrawTexturedRectUVEx( x1, y1, w * scale, h * scale, u, v, u + uw / texw, v + vh / texh )		x1 = x1 + miracleSize * scale + 2 * scale	end	end