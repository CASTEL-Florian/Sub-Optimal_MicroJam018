tileSize = 64
deltaTime = 1/60
import "tileUtil"
import "player"
import "levels"

// Initialize display and globals
gfx.clear
text.clear

lastTime = 0

// Restart
isRestarting = false
currentRestartTime = 0



display(3).mode = displayMode.sprite
overlay = display(3)

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



loadLevel = function(level)
	tiles.clear
	display(7).color = level.bgColor
	tileUtil.loadFromFile level.file, globals.tiles
	globals.tileSize = globals.tiles.cellSize[0]
	globals.disp.sprites = []
	globals.collectables = level.collectables
	globals.sharks = level.sharks

	if level.thanksText then globals.disp.sprites.push thanksText
	for circle in player.circles
		globals.disp.sprites.push circle
	end for
	for h in hearts
		globals.disp.sprites.push h
	end for
	globals.disp.sprites.push player.submarine
	for collectable in collectables
		globals.disp.sprites.push collectable.sprite
		collectable.reset
	end for
	for sh in globals.sharks
		globals.disp.sprites.push sh.sprite
		sh.reset
	end for
	player.playerStartX = level.playerStartPos[0]
	player.playerStartY = level.playerStartPos[1]
	player.resetPlayer
	sharkAttacking = null
	globals.disp.sprites.push oxygenText
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
	if currentRestartTime < 1 and currentRestartTime + globals.deltaTime >= 1 then 
		loadLevel currentLevel
	end if
	globals.currentRestartTime += globals.deltaTime
	t = -abs(currentRestartTime - 1) + 1
	gfx.clear color.black
	drawGame
	gfx.color = color.rgba(0, 0, 0, 255 * t)
	gfx.fillRect 0, 0, gfx.width, gfx.height
	if currentRestartTime >= 2 then
		globals.isRestarting = false
	end if
end function


checkCollectableCollisions = function
	for collectable in collectables
		if collectable.checkCollision(player.playerX, player.playerY) then
			collectable.collect
			if collectable isa levels.heart.Heart then
				player.playerHP += 1
			end if
			if collectable isa levels.bubble.Bubble then
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

currentLevelIndex = 0
currentLevel = levels.levelList[0]
loadLevel currentLevel
// Main game loop
while true
	computeDeltaTime
	
	if not player.isMoving and not player.isBlinking and not isRestarting and not player.needAfterMoveCheck and sharkAttacking == null then 
		player.handleInput(tiles)
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
				if globals.currentLevelIndex >= levels.levelList.len then globals.currentLevelIndex = 0
				currentLevel = levels.levelList[globals.currentLevelIndex]
				player.submarine.scale = [0, 0]
				restartLevel
			end if


			for shark in sharks
				if shark.canSeePlayer(player.playerX, player.playerY, tiles) then
					shark.attackPlayer(player.playerX, player.playerY)
					sharkAttackSound.play
					sharkAttacking = shark
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
			sharkAttacking = null
			startScreenShake(8, 0.8)
		end if
	end if

	for shark in sharks
		shark.animate(deltaTime)
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
	yield
end while