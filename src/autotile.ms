
nonSolidIndexes = []

solid = function(x,y)
	if x < 0 then x = 0
	if x >= tileDisp.extent[0] then x = tileDisp.extent[0] - 1
	if y < 0 then y = 0
	if y >= tileDisp.extent[1] then y = tileDisp.extent[1] - 1
	index = tileDisp.cell(x,y)
	return index != null and nonSolidIndexes.indexOf(index) == null
end function

fixTile = function(x,y)
	if not solid(x,y) then return
	N = solid(x, y+1)
	S = solid(x, y-1)
	E = solid(x+1, y)
	W = solid(x-1, y)
	NE = solid(x+1, y+1)
	SE = solid(x+1, y-1)
	NW = solid(x-1, y+1)
	SW = solid(x-1, y-1)
	NESW = N*1000 + E*100 + S*10 + W
	if NESW == 0000 then
		idx = 36
	else if NESW == 0001 then
		idx = 35
	else if NESW == 0010 then
		idx = 3
	else if NESW == 0100 then
		idx = 33
	else if NESW == 1000 then
		idx = 25
	else if NESW == 0101 then
		idx = 34
	else if NESW == 1010 then
		idx = 14
	else if NESW == 0011 then
		if SW then idx = 2 else idx = 7
	else if NESW == 0110 then
		if SE then idx = 0 else idx = 4
	else if NESW == 1100 then
		if NE then idx = 22 else idx = 37
	else if NESW == 1001 then
		if NW then idx = 24 else idx = 40
	else if NESW == 0111 then
		idx = [8, 6, 5, 1][SW * 2 + SE]
	else if NESW == 1110 then
		idx = [48, 26, 15, 11][NE * 2 + SE]
	else if NESW == 1101 then
		idx = [41, 39, 38, 23][NW * 2 + NE]
	else if NESW == 1011 then
		idx = [51, 29, 18, 13][NW * 2 + SW]
	else if NESW == 1111 then
		idx = [
		   52, 42, 31, 50,
		   32, 20, 30, 28,
		   43, 19,  9, 17,
		   49, 16, 27, 12,
		][NW*8 + SW*4 + SE*2 + NE]
	else
		idx = 120
	end if
	tileDisp.setCell x, y, idx
end function

fixTiles = function
	for x in range(0,tileDisp.extent[0]-1)
		for y in range(0,tileDisp.extent[1]-1)
			fixTile x,y
		end for
	end for
end function


trackAndApplyMouse = function
	prevX = null; prevY = null
	tileX = floor((mouse.x + tileDisp.scrollX) / tileDisp.cellSize)
	tileY = floor((mouse.y + tileDisp.scrollY) / tileDisp.cellSize)
	set = not solid(tileX, tileY)
	while mouse.button
		yield
		tileX = floor((mouse.x + tileDisp.scrollX) / tileDisp.cellSize)
		tileY = floor((mouse.y + tileDisp.scrollY) / tileDisp.cellSize)
		if tileX == prevX and tileY == prevY then continue
		if set then
			tileDisp.setCell tileX, tileY, 12
		else
			tileDisp.setCell tileX, tileY, null
		end if
		fixTiles
		prevX = tileX
		prevY = tileY
	end while
end function

if locals == globals then
	clear
	display(7).color = color.gray
	text.color = color.orange
	
	display(5).mode = displayMode.tile
	tileDisp = display(5)
	tileDisp.tileSet = file.loadImage("../images/Cliff.png")
	tileDisp.tileSetTileSize = 16
	tileDisp.cellSize = 64
	tileDisp.extent = [15,10]
	tileDisp.overlap = -1
	tileDisp.clear
	
	for x in range(0,14)
		for y in range(0,9)
			if rnd < 0.5 then tileDisp.setCell x, y, 12
		end for
	end for
	fixTiles
	
	while true
		yield
		if mouse.button then
			trackAndApplyMouse
		end if
	end while
end if