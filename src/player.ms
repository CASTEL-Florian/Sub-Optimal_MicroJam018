import "mathUtil"

playerStartX = 5
playerStartY = 5
playerX = 5
playerY = 4
playerHP = 3
moveDuration = 0.5

isMoving = false
stoppedByWall = false
currentMovementTime = 0
startX = playerX
startY = playerY
destX = playerX
destY = playerY
targetX = playerX
targetY = playerY

isBlinking = false
blinkDuration = 0.5
blinkCount = 2
currentBlinkTime = 0

submarine = new Sprite
submarine.image = file.loadImage("/usr/images/submarine.png")

circleScale = 4
circleUp = new Sprite
circleDown = new Sprite
circleLeft = new Sprite
circleRight = new Sprite
circleUp.image = file.loadImage("/usr/images/circle.png")
circleDown.image = file.loadImage("/usr/images/circle.png")
circleLeft.image = file.loadImage("/usr/images/circle.png")
circleRight.image = file.loadImage("/usr/images/circle.png")
circles = [circleUp, circleDown, circleLeft, circleRight]

colisionSound = file.loadSound("/usr/sounds/collision.wav")

movementSounds = [file.loadSound("/usr/sounds/move1.wav"), file.loadSound("/usr/sounds/move2.wav"), file.loadSound("/usr/sounds/move3.wav"), file.loadSound("/usr/sounds/move4.wav"), file.loadSound("/usr/sounds/move5.wav")]
lastPlayedSound = 0

submarine.scale = [3,3]

maxOxygen = 10
currentOxygen = maxOxygen

needAfterMoveCheck = false

resetPlayer = function()
    player.playerX = player.playerStartX
	player.playerY = player.playerStartY
	player.playerHP = 3
	player.currentOxygen = player.maxOxygen
	player.isMoving = false
    player.isBlinking = false
    player.blinkDuration = 0.5
    player.blinkCount = 2
    player.currentBlinkTime = 0
	player.stoppedByWall = false
	player.currentMovementTime = 0
	player.startX = playerX
	player.startY = playerY
	player.destX = playerX
	player.destY = playerY
	player.targetX = playerX
	player.targetY = playerY
	player.needAfterMoveCheck = false
    submarine.tint = color.white
	submarine.scale = [3,3]
end function


// Function to move the player
movePlayer = function(dx, dy, tiles)
	player.targetX = playerX + dx * playerHP
	player.targetY = playerY + dy * playerHP

	player.destX = player.targetX
	player.destY = player.targetY

	
	// Check for wall collision
	for x in range(targetX, playerX)
		for y in range(targetY, playerY)
			if x == playerX and y == playerY then 
				break
			end if
			if tiles.cell(x,y) == null then
				continue
			end if
            
			if targetX == playerX then
				player.destY = y - sign(targetY - playerY)
			else
				player.destX = x - sign(targetX - playerX)
			end if
		end for
	end for
    
	if destY != playerY or destX != playerX then
		player.startX = playerX
		player.startY = playerY
		player.currentMovementTime = 0
		player.isMoving = true
		player.stoppedByWall = false
		// Consume oxygen
		player.currentOxygen = currentOxygen - 1
		if currentOxygen < 0 then currentOxygen = 0
		needAfterMoveCheck = true

		// Play one random movement sound
		random = rnd
		random = floor(random * 4)
		lastPlayedSound
		if random >= lastPlayedSound then random += 1
		player.lastPlayedSound = random
		movementSounds[random].play


	end if
end function

handleSmoothMovement = function()
	if (targetX - startX) * player.submarine.scale[0] < 0 then player.submarine.scale = [-player.submarine.scale[0], player.submarine.scale[1]]

	player.currentMovementTime += deltaTime

	if not stoppedByWall then
		t = currentMovementTime / moveDuration
		t = -(cos(pi * t) - 1) / 2  // Ease in-out function
		player.playerX = startX + (targetX - startX) * t
		player.playerY = startY + (targetY - startY) * t

		if (destX != targetX and (destX - startX) * (destX - playerX) < 0) or (destY != targetY and (destY - startY) * (destY - playerY) < 0) then
			player.playerHP -= 1
			player.playerX = destX
			player.playerY = destY
			player.stoppedByWall = true
            player.isBlinking = true
            player.currentBlinkTime = 0
			player.colisionSound.play()
			startScreenShake(2.5, 0.5)
		end if
	end if
	
	if currentMovementTime >= moveDuration then
		player.isMoving = false
		player.playerX = destX
		player.playerY = destY
		player.needAfterMoveCheck = true
	end if
end function

handleRotation = function()
    targetRotation = 0
    rotationSpeed = 4
    
    if playerX != destX then
        // Tilt forward when moving left or right
        targetRotation = -7 * sign(destX - playerX)
    end if
    
    // Smoothly interpolate current rotation to target rotation
    currentRotation = submarine.rotation
    submarine.rotation = currentRotation + (targetRotation - currentRotation) * rotationSpeed * deltaTime
end function

handleInput = function(tiles)
	// Use key.axis, to support gamepads too!
	if key.axis("Vertical") > 0.5 then
		movePlayer 0, 1, tiles
	else if key.axis("Vertical") < -0.5 then
		movePlayer 0, -1, tiles
	else if key.axis("Horizontal") < -0.5 then
		movePlayer -1, 0, tiles
	else if key.axis("Horizontal") > 0.5 then
		movePlayer 1, 0, tiles
	else if key.pressed("r") then
		player.currentOxygen = 0
	end if
	
	if mouse.button then
		dx = mouse.x - (playerX + 0.5) * tileSize
		dy = mouse.y - (playerY + 0.5) * tileSize
		if abs(dx) > abs(dy) then
			movePlayer sign(dx), 0, tiles
		else
			movePlayer 0, sign(dy), tiles
		end if
		while mouse.button; yield; end while
	end if
end function

// Function to draw movement indicators
drawMovementIndicators = function(tiles)
	directions = [[0, 1], [0, -1], [-1, 0], [1, 0]]
	k = 0
	for dir in directions
		dx = dir[0]
		dy = dir[1]
		targetX = playerX + dx * playerHP
		targetY = playerY + dy * playerHP
		willCollide = false
		
		for x in range(targetX, playerX)
			for y in range(targetY, playerY)
				if x == playerX and y == playerY then
					break
				end if
				if tiles.cell(x,y) != null then
					willCollide = true
					break
				end if
			end for
			if willCollide then break
		end for
		
		if willCollide then
			circles[k].tint = color.red
		else
			circles[k].tint = color.white
		end if
		circles[k].x = targetX * tileSize + tileSize/2
		circles[k].y = targetY * tileSize + tileSize/2
		circles[k].scale = [circleScale, circleScale]
		k += 1
	end for
end function

hideMovementIndicators = function
	for k in range(3)
		circles[k].scale = [0, 0]
	end for
end function


handleBlink = function()
    player.currentBlinkTime += deltaTime
    t = (2 * blinkCount - 1) * player.currentBlinkTime / blinkDuration

    if floor(t) % 2 == 0 then
        submarine.tint = color.red
    else
        submarine.tint = color.white
    end if

	if currentBlinkTime >= blinkDuration then 
        player.isBlinking = false
        player.submarine.tint = color.white
    end if

end function