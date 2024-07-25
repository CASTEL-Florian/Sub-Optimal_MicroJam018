import "autotile"

// Constants
DRAW = 36
CLEAR = 86
HEART = 54
SHARK = 65
BUBBLE = 76
PLAYER = 87

// Utility functions

getTileForIndex = function(tileIndex)
	if tileDisp.tileSetTileSize isa number then
		tw = tileDisp.tileSetTileSize
		th = tileDisp.tileSetTileSize
	else
		tw = tileDisp.tileSetTileSize[0]
		th = tileDisp.tileSetTileSize[1]
	end if		
	columns = tileDisp.tileSet.width / tw
	rows = tileDisp.tileSet.height / th
	row = rows - floor(tileIndex / columns)
	col = tileIndex % columns
	return tileDisp.tileSet.getImage(col*tw, row*th-th, tw, th)
end function

drawTools = function(selected)
	text.row = 25
	text.column = 55
	print "Tool Mode:"
	
	x = 775; y = 540
	gfx.fillRect x-3, y-54-3, 54*3+6, 54*2+3, color.gray
	for item in [DRAW, CLEAR, HEART, SHARK, BUBBLE, PLAYER]
		toolButtonPos[item] = {"x": x, "y": y}
		if item == selected then
			gfx.fillRect x-3, y-3, 54, 54, color.yellow
		end if
		icon = toolIcons[item]
		gfx.drawImage icon, x, y, 48, 48
		if item == selected then
			gfx.drawRect x-3, y-3, 54, 54, color.white
		end if
		x += 54
		if x + 48 > 950 then
			x = 775
			y -= 54
		end if
	end for
end function

toolHit = function(pos)
	for kv in toolButtonPos
		tool = kv.key
		button = kv.value
		if button.x < pos.x < button.x + 48 and
		   button.y < pos.y < button.y + 48 then return tool
	end for
	return null
end function

handleInput = function
	if mouse.button then
		tool = toolHit(mouse)
		if tool != null then
			globals.curTool = tool
			drawTools curTool
			while mouse.button; yield; end while
		end if
		col = (mouse.x + tileDisp.scrollX) / tileDisp.cellSize
		row = (mouse.y + tileDisp.scrollY) / tileDisp.cellSize
		if 0 <= col < tileDisp.extent[0] and 0 <= row < tileDisp.extent[1] then
			if curTool == DRAW then
				autotile.trackAndApplyMouse
			else if curTool == CLEAR then
				tileDisp.setCell col, row, CLEAR
				autotile.trackAndApplyMouse
			else
				if tileDisp.cell(col,row) == curTool then
					tileDisp.setCell col, row, null
				else
					tileDisp.setCell col, row, curTool
				end if
				autotile.fixTiles
				while mouse.button; yield; end while
			end if
		end if
	end if
end function

// Setup

clear

display(7).color = color.gray

display(6).mode = displayMode.tile
tileDisp = display(6)
tileDisp.tileSet = file.loadImage("../images/Cliff.png")
tileDisp.tileSetTileSize = 16
tileDisp.cellSize = 48
tileDisp.extent = [15,10]
tileDisp.scrollX = -20
tileDisp.scrollY = -(620 - tileDisp.extent[1] * tileDisp.cellSize)
tileDisp.clear 12
autotile.tileDisp = tileDisp
autotile.nonSolidIndexes = [HEART, SHARK, BUBBLE, PLAYER]

gfx.clear color.clear
gfx.drawRect -tileDisp.scrollX-4, -tileDisp.scrollY-4,
    tileDisp.extent[0] * tileDisp.cellSize + 8,
    tileDisp.extent[1] * tileDisp.cellSize + 8, "#AAAAFF", 8

text.color = color.silver


toolIcons = {}
toolButtonPos = {}
for item in [DRAW, CLEAR, HEART, SHARK, BUBBLE, PLAYER]
	toolIcons[item] = getTileForIndex(item)
end for
curTool = DRAW
drawTools curTool

// Main Loop

while not key.pressed("escape")
	handleInput
	yield
end while
key.clear