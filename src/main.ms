tileSize = 64
deltaTime = 1/60
import "tileUtil"
import "player"
import "heart"
import "bubble"
import "shark"
import "levels"
import "levelEditor"

// Initialize display and globals
gfx.clear
text.clear

lastTime = 0

// Restart
isRestarting = false
currentRestartTime = 0
Sound.stopAll


display(2).mode = displayMode.sprite
overlay = display(2)
overlay.clear

text.color = "#AAAACC"

display(4).mode = displayMode.pixel
gfx = display(4)

display(5).mode = displayMode.sprite
disp = display(5)
disp.clear
disp.scrollX = 0
disp.scrollY = 0

display(6).mode = displayMode.tile
tiles = display(6)
tiles.clear

tiles.scrollX = 0
tiles.scrollY = 0
levelEditor.tileDisp = tiles
autotile.tileDisp = tiles

display(7).mode = displayMode.solidColor
display(7).color = color.rgb(53,74,178)

backgroundMusic = file.loadSound("/usr/sounds/background.wav")
backgroundMusic.loop = true
backgroundMusic.play

deathSound = file.loadSound("/usr/sounds/drowning.wav")
sharkAttackSound = file.loadSound("/usr/sounds/sharkAttack.wav")

oxygenText = new Sprite
oxygenText.image = file.loadImage("/usr/images/oxygen.png")
oxygenText.x = 60
oxygenText.y = 450
oxygenText.scale = [4, 4]

thanksText = new Sprite
thanksText.image = file.loadImage("/usr/images/thanks.png")
thanksText.x = 480
thanksText.y = 320
thanksText.scale = [6, 6]

overlayImage = new Sprite
overlayImage.image = file.loadImage("/usr/images/overlay.png")
overlayImage.scale = [8.5,8.5]
overlay.sprites.push overlayImage
overlayImage.tint = color.rgb(0,38,80)


hearts = []
heartScale = 4
for i in range(7)
	h =  new Sprite
	h.x = 60 + i * 80
	h.y = 590
	h.image = file.loadImage("/usr/images/heart.png")
	hearts.push h
end for

// Collectables
collectables = []

// Sharks
sharks = []
sharkAttacking = null

// Screen shake
shakeIntensity = 0
shakeDecay = 0
shakeDuration = 0
shakeTimer = 0



loadLevel = function(levelNumOrCode)
	showThanks = false
	if levelNumOrCode isa number and levelNumOrCode > 0 then
		if levelNumOrCode == levels.levelList.len then showThanks = true
		levelNumOrCode = levels.levelList[levelNumOrCode-1]
	end if
	tiles.clear
	
	tiles.tileSetTileSize = 16
	tiles.cellSize = 64
	tiles.extent = [15,10]
	levelEditor.unpackLevel levelNumOrCode
	if tiles.tileSet.name == "Abyss.png" then
		display(7).color = color.rgb(29,26,89)
	else
		display(7).color = color.rgb(53,74,178)
	end if
	
	disp.sprites = []
	globals.collectables = []
	globals.sharks = []

	for x in range(0, tiles.extent[0]-1)
		for y in range(0, tiles.extent[1]-1)
			c = tiles.cell(x,y)
			if c == levelEditor.PLAYER then
				player.playerStartX = x
				player.playerStartY = y
			else if c == levelEditor.BUBBLE then
				item = new bubble.Bubble
				item.init
				item.setPos x, y
				collectables.push item
			else if c == levelEditor.HEART then
				item = new heart.Heart
				item.init
				item.setPos x, y
				collectables.push item
			else if c == levelEditor.SHARK then
				sh = new shark.Shark
				sh.init
				sh.setPos x, y
				sharks.push sh
			end if
			if autotile.nonSolidIndexes.indexOf(c) != null then
				tiles.setCell x, y, null
			end if
		end for
	end for

	if showThanks then disp.sprites.push thanksText
	for circle in player.circles
		globals.disp.sprites.push circle
	end for
	disp.sprites.push player.submarine
	player.resetPlayer
	
	for h in hearts
		globals.disp.sprites.push h
	end for
	for collectable in collectables
		collectable.reset
		globals.disp.sprites.push collectable.sprite
	end for
	for sh in globals.sharks
		sh.reset
		globals.disp.sprites.push sh.sprite
	end for
	sharkAttacking = null
	disp.sprites.push oxygenText
end function


// Function to draw the game state
drawGame = function
	gfx.clear
	
	// Draw player
	player.submarine.x = (player.playerX + 0.5) * tileSize
	player.submarine.y = (player.playerY + 0.5) * tileSize + sin(2 * time) * 3 * tileSize / 64
	
	// Draw HP
	for i in range(hearts.len - 1)
		hearts[i].scale = [0,0]
	end for
	if player.playerHP > 0 then
		for i in range(player.playerHP - 1)
			hearts[hearts.len - 1 - i].scale = [heartScale, heartScale]
		end for
	end if
	
	// Draw oxygen meter
	gfx.color = color.white
	for i in range(9)
		gfx.fillRect 50, 200 + i * 22, 20, 18
	end for
	gfx.color = color.aqua
	oxygenHeight = 200 * (player.currentOxygen / player.maxOxygen)
	filledRectangles = player.currentOxygen
	
	if filledRectangles > 0 then
		for i in range(filledRectangles - 1)
			gfx.fillRect 50, 200 + i * 22, 20, 18
		end for
	end if
	
	// Draw movement indicators
	if not player.isMoving and not player.isBlinking and not isRestarting and not player.needAfterMoveCheck and sharkAttacking == null then 
		player.drawMovementIndicators(tiles)
	else
		player.hideMovementIndicators
	end if
	
	if isRestarting then
		oxygenText.scale = [0,0]
	else
		oxygenText.scale = [4,4]
	end if
	
	// Draw level display
	text.row = 25
	text.column = 59
	if currentLevelIndex > 0 then
		print "Level: " + currentLevelIndex + " "
	end if
end function


computeDeltaTime = function
	if time == lastTime then return
	globals.deltaTime = (time - lastTime)
	globals.lastTime = time
end function



// Function to restart the level with fade effect
restartLevel = function
	player.isBlinking = true
	player.blinkDuration = 0.7
	player.blinkCount = 4
	player.currentBlinkTime = 0
	globals.isRestarting = true
	globals.currentRestartTime = 0
	deathSound.play
end function


handleRestart = function
	if currentRestartTime < 1 and currentRestartTime + deltaTime >= 1 then 
		gfx.clear color.black
		loadLevel currentLevelIndex
	end if
	globals.currentRestartTime += deltaTime
	t = -abs(currentRestartTime - 1) + 1
	drawGame
	gfx.clear color.rgba(0, 0, 0, 255 * t)
	if currentRestartTime >= 2 then
		globals.isRestarting = false
	end if
end function


checkCollectableCollisions = function
	for collectable in collectables
		if collectable.checkCollision(player.playerX, player.playerY) then
			collectable.collect
			if collectable isa heart.Heart then
				player.playerHP += 1
			end if
			if collectable isa bubble.Bubble then
				player.currentOxygen = player.maxOxygen
			end if
		end if
	end for
end function

startScreenShake = function(intensity, duration)
	globals.shakeIntensity = intensity
	globals.shakeDuration = duration
	globals.shakeDecay = intensity / duration
	globals.shakeTimer = 0
end function

updateScreenShake = function
	if shakeTimer < shakeDuration then
		globals.shakeTimer += deltaTime
		// Calculate current intensity
		currentIntensity = shakeIntensity - (shakeDecay * shakeTimer)
		
		// Generate random offsets
		offsetX = (rnd - 0.5) * 2 * currentIntensity
		offsetY = (rnd - 0.5) * 2 * currentIntensity
		
		// Apply shake to displays
		disp.scrollX = offsetX
		disp.scrollY = offsetY
		tiles.scrollX = offsetX
		tiles.scrollY = offsetY
		gfx.scrollX = offsetX
		gfx.scrollY = offsetY
	else
		// Reset scroll when shake is done
		disp.scrollX = 0
		disp.scrollY = 0
		tiles.scrollX = 0
		tiles.scrollY = 0
		gfx.scrollX = 0
		gfx.scrollY = 0
	end if
end function

updateGame = function
	computeDeltaTime
	
	if not player.isMoving and not player.isBlinking and not isRestarting and not player.needAfterMoveCheck and sharkAttacking == null then 
		player.handleInput tiles
	else
		if player.isMoving then player.handleSmoothMovement
		if player.isBlinking then player.handleBlink
	end if
	
	player.handleRotation
	
	if not (player.playerHP <= 0 or player.currentOxygen <= 0) then 
		checkCollectableCollisions
		
		if player.needAfterMoveCheck and not player.isMoving then
			// check if the player is out of the grid
			extents = tiles.extent
			if player.playerX < 0 or player.playerX >= extents[0] or player.playerY < 0 or player.playerY >= extents[1] then
				// load the next level
				globals.currentLevelIndex += 1
				if currentLevelIndex > levels.levelList.len then globals.currentLevelIndex = 1
				player.submarine.scale = [0, 0]
				restartLevel
			end if
			
			for shark in sharks
				if shark.canSeePlayer(player.playerX, player.playerY, tiles) then
					shark.attackPlayer player.playerX, player.playerY
					sharkAttackSound.play
					globals.sharkAttacking = shark
					break
				end if
			end for
			player.needAfterMoveCheck = false
		end if
	end if
	
	if sharkAttacking != null then
		sharkAttacking.updateAttack deltaTime
		if not sharkAttacking.isAttacking then
			player.playerHP = 0
			player.colisionSound.play
			globals.sharkAttacking = null
			startScreenShake 8, 0.8
		end if
	end if
	
	for shark in sharks
		shark.animate deltaTime
	end for
	
	for collectable in collectables
		collectable.animate
	end for
	
	updateScreenShake
	
	drawGame
	
	if (player.playerHP <= 0 or player.currentOxygen <= 0) and not isRestarting then
		restartLevel
	end if
	if isRestarting then handleRestart
end function

if globals.hasIndex("customLevelCode") then
	currentLevelIndex = -1
	levels.loadFromCode customLevelCode
else
	currentLevelIndex = 1
end if
loadLevel currentLevelIndex
// Main game loop
while true
	updateGame
	yield
end while