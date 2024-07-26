import "autotile"
import "bitstream"
import "base64"

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

removePlayer = function
	for x in range(0, tileDisp.extent[0]-1)
		for y in range(0, tileDisp.extent[1]-1)
			if tileDisp.cell(x,y) == PLAYER then
				tileDisp.setCell x, y, null
			end if
		end for
	end for
end function

showLevelCode = function
	text.row = 4
	text.column = 2
	print packLevel + " " * 8
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
					if curTool == PLAYER then removePlayer
					tileDisp.setCell col, row, curTool
				end if
				autotile.fixTiles
				while mouse.button; yield; end while
			end if
			showLevelCode
		end if
	end if
end function

packLevel = function
	// We'll compress the level as follows: 150 bits indicating rock/empty
	// (1 bit each for 15 x 10 locations); then one byte for the player location;
	// then for each of (BUBBLE, HEART, SHARK), write out a 4-bit count, followed
	// by the location of each.
	data = new bitstream.BitWriter
	playerPos = 255
	bubbles = []
	hearts = []
	sharks = []
	for y in range(0, tileDisp.extent[1]-1)
		for x in range(0, tileDisp.extent[0]-1)
			data.writeBit autotile.solid(x, y)
			pos = y * tileDisp.extent[0] + x
			if tileDisp.cell(x,y) == PLAYER then playerPos = pos
			if tileDisp.cell(x,y) == BUBBLE then bubbles.push(pos)
			if tileDisp.cell(x,y) == HEART then hearts.push(pos)
			if tileDisp.cell(x,y) == SHARK then sharks.push(pos)
		end for
	end for
	data.writeByte playerPos
	
	if bubbles.len > 15 then bubbles = bubbles[:15]
	data.writeBits bubbles.len, 4
	for pos in bubbles; data.writeByte pos; end for
	
	if hearts.len > 15 then hearts = hearts[:15]
	data.writeBits hearts.len, 4
	for pos in hearts; data.writeByte pos; end for
	
	if sharks.len > 15 then sharks = sharks[:15]
	data.writeBits sharks.len, 4
	for pos in sharks; data.writeByte pos; end for
	
	return base64.encode(data.getData)
end function

unpackLevel = function(levelCode)
	data = new bitstream.BitReader
	data.rawData = base64.decodeToRawData(levelCode)
	for y in range(0, tileDisp.extent[1]-1)
		for x in range(0, tileDisp.extent[0]-1)
			if data.readBit then idx = 12 else idx = null
			tileDisp.setCell x, y, idx
		end for
	end for
	playerPos = data.readByte
	cols = tileDisp.extent[0]
	tileDisp.setCell playerPos % cols, floor(playerPos / cols), PLAYER

	for i in range(1, data.readBits(4), 1)
		pos = data.readByte
		tileDisp.setCell pos % cols, floor(pos / cols), BUBBLE		
	end for

	for i in range(1, data.readBits(4), 1)
		pos = data.readByte
		tileDisp.setCell pos % cols, floor(pos / cols), HEART		
	end for

	for i in range(1, data.readBits(4), 1)
		pos = data.readByte
		tileDisp.setCell pos % cols, floor(pos / cols), SHARK		
	end for

	autotile.fixTiles
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
