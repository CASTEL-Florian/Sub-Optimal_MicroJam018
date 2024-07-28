import "importUtil"
ensureImport "autotile"
ensureImport "bitstream"
ensureImport "base64"
ensureImport "qa"
ensureImport "textUtil"

// Constants
DRAW = 36
CLEAR = 86
HEART = 54
SHARK = 65
BUBBLE = 76
PLAYER = 87

autotile.nonSolidIndexes = [HEART, SHARK, BUBBLE, PLAYER]

// TextButton class
TextButton = {}
TextButton.row = 0
TextButton.column = 0
TextButton.width = 8
TextButton.caption = "Button"
TextButton.action = null

TextButton.make = function(row, column, caption, width=8)
	tb = new self
	tb.row = row
	tb.column = column
	tb.caption = caption
	tb.width = width
	return tb
end function

TextButton.draw = function(pressed=false)
	if pressed then text.color = "#A0A0E0" else text.color = color.silver
	text.row = self.row
	text.column = self.column
	s = self.caption
	which = 0
	while s.len < self.width-2
		if which then s = " " + s else s += " "
		which = not which
	end while
	textUtil.drawButton s
end function

TextButton.isMouseOver = function
	if textUtil.textRow(mouse.y) != self.row then return false
	col = textUtil.textCol(mouse.x)
	return self.column <= col < self.column + self.width
end function

TextButton.trackMouse = function
	pressed = false
	while mouse.button
		nowOver = self.isMouseOver
		if nowOver != pressed then
			pressed = nowOver
			self.draw pressed
		end if
		yield
	end while
	self.draw false
	return pressed
end function

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

getLevelCode = function
	screen = textUtil.getContent; state = textUtil.getState
	dlog = textUtil.Dialog.make("Level Code")
	code = packLevel
	dlog.width = 50
	if code.len > 46 then dlog.width = code.len + 4
	msg = []
	if env.device.platform == "WebGL" then
		msg.push "Write down, screen shot, or OCR the following code:"
		msg.push ""
		msg.push code
		msg.push ""
		msg.push "(This would be easier in the desktop build.)"
		msg.push "Then press Return:"
	else
		msg.push "Select and then Copy the following code:"
		msg.push ""
		msg.push code
		msg.push ""
		msg.push ""
		msg.push "Then press Return:"
	end if
	dlog.msgLines = msg
	dlog.okBtn.visible = false
	dlog.height = msg.len + 3
	dlog.draw
	text.row = 10; text.column = 30; input
	textUtil.setContent screen; textUtil.setState state
end function

applyLevelCode = function
	screen = textUtil.getContent; state = textUtil.getState
	dlog = textUtil.Dialog.make("Apply Code")
	code = packLevel
	dlog.width = 50
	if code.len > 46 then dlog.width = code.len + 4
	msg = []
	if env.device.platform == "WebGL" then
		msg.push "Enter (type) level code:"
		msg.push ""
		msg.push ""
		msg.push ""
		msg.push "(This would be easier in the desktop build.)"
	else
		msg.push "Enter (type or paste) level code:"
		msg.push ""
		msg.push ""
		msg.push ""
	end if
	dlog.msgLines = msg
	dlog.okBtn.visible = false
	dlog.height = msg.len + 3
	dlog.draw
	text.row = 12; text.column = 11; code = input
	textUtil.setContent screen; textUtil.setState state
	if code then unpackLevel code
end function

prepButtons = function
	globals.buttons = []
	text.row = 18
	text.column = 55
	print "Tile Set:"
	buttons.push TextButton.make(16, 55, "1", 5)
	buttons[-1].action = function
		tileDisp.tileSet = file.loadImage("../images/Cliff.png")
	end function
	buttons.push TextButton.make(16, 61, "2", 5)
	buttons[-1].action = function
		tileDisp.tileSet = file.loadImage("../images/Abyss.png")
	end function
	
	text.row = 13
	text.column = 55
	print "Level Code:"
	buttons.push TextButton.make(11, 56, "Get", 9)
	buttons[-1].action = @getLevelCode
	buttons.push TextButton.make(9, 56, "Apply", 9)
	buttons[-1].action = @applyLevelCode
	
	buttons.push TextButton.make(5, 56, "Test", 9)
	buttons[-1].action = function
		globals.customLevelCode = packLevel
		env.shell = "/usr/src/levelEditor"
		run "main"
	end function
	
	for b in buttons
		b.draw
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
			return
		end if
		
		for b in buttons
			if b.isMouseOver then
				if b.trackMouse then b.action
				return
			end if
		end for

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
	// by the location of each.  Finally, two bits to represent the tile set.
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
	
	whichTileSet = 0
	if tileDisp.tileSet.name == "Abyss.png" then whichTileSet = 1
	data.writeBits whichTileSet, 2
	
	return base64.encode(data.getData)
end function

unpackLevel = function(levelCode)
	qa.assert levelCode isa string
	data = new bitstream.BitReader
	data.rawData = base64.decodeToRawData(levelCode)

	// todo: load correct tile set
	tileDisp.tileSet = file.loadImage("../images/Cliff.png")

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

	whichTileSet = data.readBits(2)
	if whichTileSet == 1 then
		tileDisp.tileSet = file.loadImage("../images/Abyss.png")
	else
		tileDisp.tileSet = file.loadImage("../images/Cliff.png")
	end if

	autotile.fixTiles
end function

if locals == globals then
	// Setup
	Sound.stopAll
	text.backColor = color.clear
	text.color = color.silver
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
	
	gfx.clear color.clear
	x0 = -tileDisp.scrollX
	y0 = -tileDisp.scrollY
	x1 = x0 + tileDisp.extent[0] * tileDisp.cellSize
	y1 = y0 + tileDisp.extent[1] * tileDisp.cellSize
	gfx.drawRect x0-4, y0-4, x1-x0+8, y1-y0+8, "#AAAAFF", 8
	for x in range(x0, x1, tileDisp.cellSize)
		gfx.line x, y0, x, y1, "#AAAAAA"
	end for
	for y in range(y0, y1, tileDisp.cellSize)
		gfx.line x0, y, x1, y, "#AAAAAA"
	end for	
	
	toolIcons = {}
	toolButtonPos = {}
	for item in [DRAW, CLEAR, HEART, SHARK, BUBBLE, PLAYER]
		toolIcons[item] = getTileForIndex(item)
	end for
	curTool = DRAW
	drawTools curTool
	prepButtons

	if globals.hasIndex("customLevelCode") then
		unpackLevel customLevelCode
	end if
	
	// Main Loop
	
	while not key.pressed("escape")
		handleInput
		yield
	end while
	key.clear
	env.shell = ""
	globals.remove "customLevelCode"
end if
