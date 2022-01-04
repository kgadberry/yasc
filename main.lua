
	-- Requires LÖVE2D (love2d.org) or a compiled executable to run.
	
	-- Known caveats: 
	-- 1)	The method for updating the snake and checking collisions is pretty inefficient. Not sure how to fix.
	
-- Runs only once the game loads unless called externally.
function love.load()
	-- Load head images
	headUp = love.graphics.newImage("bin/headUp.png")
	headDown = love.graphics.newImage("bin/headDown.png")
	headLeft = love.graphics.newImage("bin/headLeft.png")
	headRight = love.graphics.newImage("bin/headRight.png")
	head = headRight -- Initial direction is East, so set head accordingly.
	-- Load the body and apple images.
	body = love.graphics.newImage("bin/body.png")
	apple = love.graphics.newImage("bin/apple.png")
	-- Load other images and media
	Hardpixel = love.graphics.newFont("bin/Hardpixel.otf", 72)
	HardpixelSmall = love.graphics.newFont("bin/Hardpixel.otf")
	
	-- New arrays for storing the position of the snake.
	coordinatesX = {}
	coordinatesY = {}
	headCoordinates = {}
	
	--Set global variables
	saveDirectory = "kdude63/Yet Another Snake Clone" -- Save data directory
	grid_X = 68 -- Set grid width
	grid_Y = 36 -- Set grid height
	gridScale = 12 -- Set grid unit size
	direction = "RIGHT" -- Set initial direction to East.
	length = 6 -- The number of blocks long the snake is.
	coordinatesX[1] = 20 -- Initial X coordinates of the snake.
	coordinatesY[1] = 20 -- Initial Y coordinates of the snake.
	headCoordinates = { coordinatesX[1], coordinatesY[1] } -- Initialize head coordinates.
	tickLength = 0.1 -- The time in seconds that it takes the snake to move one square.
	addLength = 3 -- Units to add to the snake with each apple.
	score = 0 -- The current score
	endGame = false -- A boolean showing whether the player has lost or not.
	isPaused = false -- Another boolean that says whether the game is paused or not.
	willCollide = false -- Probably don't need to put this here, since it's only going to be used by the move() function.
	changeDirection = false -- Need to prevent the snake from hitting itself in the opposite direction.
	directionQueue = false -- Need to prevent missed key presses.
	timePassed = 0 -- Time passed since last update
	
	-- Random grid coordinates chosen initially for the apple.
	appleCoordinates = { love.math.random(1, grid_X), love.math.random(1, grid_Y) }
	
	-- Do other things
	love.filesystem.setIdentity(saveDirectory) -- Set savegame directory.
	if love.filesystem.getInfo("hs.dat") then
		highScore = love.filesystem.read("hs.dat") -- Load highscore from hs.dat, if it exists.
	else 
		highScore = 0 -- If it doesn't exist, reset the highscore to zero.
	end
	-- Set values 1-2448 in the arrays to -1.
	for i=2, 2448 do
		coordinatesX[i] = -1
		coordinatesY[i] = -1
	end
end

-- Main game logic, update every tick.
function love.update(dt)
	timePassed = (timePassed + dt)
	if timePassed >= tickLength then
		update()
		timePassed = (timePassed - tickLength)
	end
end
function update()
	-- If current score is higher than highScore then update it.
	if score > tonumber(highScore) then 
		highScore = score 
	end
	
	-- Prevent missed key presses.
	if directionQueue ~= false and changeDirection == false then
		changeDirection = directionQueue
	end
	
	-- Fixing race conditions.
	if changeDirection ~= false then
		direction = changeDirection
		if direction == "LEFT" then
			head = headLeft
		elseif direction == "RIGHT" then
			head = headRight
		elseif direction == "UP" then
			head = headUp
		elseif direction == "DOWN" then
			head = headDown
		end
	end
	
	-- If game is running, check for keypresses and call the move() function.
	if endGame == false and isPaused == false then
		move(direction)
	end
	
	-- Detects collision with apples
	if headCoordinates[1] == (appleCoordinates[1]) and headCoordinates[2] == (appleCoordinates[2]) then
		appleCoordinates = { love.math.random(1,grid_X), love.math.random(1,grid_Y) }
		score = score + 100
		length = length + addLength
	end

end

-- Move the snake 1 tile in direction.
function move(direction)
		
	-- Set the coordinates of each body tile to the coordinates of the next one, starting at the tail and ending at the head.
	i = length
	repeat
		if direction == "LEFT" then
			if coordinatesX[1] - coordinatesX[i] == 1 and coordinatesY[1] == coordinatesY[i] then
				willCollide = true
			else
				willCollide = false
			end
		elseif direction == "RIGHT" then
			if coordinatesX[i] - coordinatesX[1] == 1 and coordinatesY[1] == coordinatesY[i] then
				willCollide = true
			else
				willCollide = false
			end
		elseif direction == "UP" then
			if coordinatesY[1] - coordinatesY[i] == 1 and coordinatesX[1] == coordinatesX[i] then
				willCollide = true
			else
				willCollide = false
			end
		elseif direction == "DOWN" then
			if coordinatesY[i] - coordinatesY[1] == 1 and coordinatesX[1] == coordinatesX[i] then
				willCollide = true
			else
				willCollide = false
			end
		end
		
		if willCollide == false then
			coordinatesX[i] = coordinatesX[i-1]
			coordinatesY[i] = coordinatesY[i-1]
			i = i - 1
		elseif willCollide == true then
			endGame = true
		end
		
	until i == 1 or endGame == true
	
	if willCollide == false then
		if direction == "LEFT" then
			if coordinatesX[1] == 0 then
				coordinatesX[1] = grid_X
			else
				coordinatesX[1] = coordinatesX[1] - 1
			end
		elseif direction == "RIGHT" then
			if coordinatesX[1] == (grid_X + 1) then
				coordinatesX[1] = 1
			else
				coordinatesX[1] = coordinatesX[1] + 1
			end
		elseif direction == "UP" then
			if coordinatesY[1] == 0 then
				coordinatesY[1] = grid_Y
			else
				coordinatesY[1] = coordinatesY[1] - 1
			end
		elseif direction == "DOWN" then
			if coordinatesY[1] == (grid_Y + 1) then
				coordinatesY[1] = 1
			else
				coordinatesY[1] = coordinatesY[1] + 1
			end
		end
	end
	
	-- Update head coordinates
	headCoordinates = { coordinatesX[1], coordinatesY[1] }
	changeDirection = false -- Reset so snake can change direction again.
	
end

-- Reset game if space is pressed on endgame.
-- Change direction of the snake relative to keypresses when not paused or ended.
function love.keypressed(key)
	if key == "space" then
		if endGame == true then
			saveHighscore()
			love.load()
		elseif isPaused == true then
			love.load()
		end
	end
	if isPaused == false and endGame == false then
		if key == "left" or key == "a" then
			if direction ~= "RIGHT" then
				if changeDirection == false then
					changeDirection = "LEFT"
				elseif directionQueue == false then
					directionQueue = "LEFT"
				end
			end
		elseif key == "right" or key == "d" then
			if direction ~= "LEFT" then
				if changeDirection == false then
					changeDirection = "RIGHT"
				elseif directionQueue == false then
					directionQueue = "RIGHT"
				end
			end
		elseif key == "up" or key == "w" then
			if direction ~= "DOWN" then
				if changeDirection == false then
					changeDirection = "UP"
				elseif directionQueue == false then
					directionQueue = "UP"
				end
			end
		elseif key == "down" or key == "s" then
			if direction ~= "UP" then
				if changeDirection == false then
					changeDirection = "DOWN"
				elseif directionQueue == false then
					directionQueue = "DOWN"
				end
			end
		end
	end
end

-- Pause or quit game based on pause and endgame states.
function love.keyreleased(key)
	if key == "escape" then 
		if isPaused == false and endGame == false then
			isPaused = true
		elseif isPaused == true then
			isPaused = false
		elseif endGame == true then 
			love.event.quit()
		end
	end
end

-- Draw sprites and text.
function love.draw()
	for i=2, length do
		love.graphics.draw(body, (coordinatesX[i]*gridScale), (coordinatesY[i]*gridScale))
	end
	love.graphics.draw(apple, (appleCoordinates[1]*gridScale), (appleCoordinates[2]*gridScale))
	love.graphics.draw(head, (headCoordinates[1]*gridScale), (headCoordinates[2]*gridScale))
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(HardpixelSmall)
	love.graphics.print("Score: " .. tostring(score), 5, 435)
	love.graphics.print("Highscore: " .. tostring(highScore), 5, 420)
	love.graphics.print("Press ESCAPE to pause, and use the arrow keys or WASD to move.", 5, 5)
	love.graphics.setFont(Hardpixel)
	if endGame == true then
		love.graphics.setColor(255, 255, 255)
		love.graphics.print("GAME OVER", 200, 100, 0, 1, 1)
		love.graphics.print("Press SPACE to restart.", 150, 250, 0, .6, .6)
		love.graphics.print("Press ESCAPE to quit.", 165, 300, 0, .6, .6)
	end
	if isPaused == true then
		love.graphics.setColor(255, 255, 255)
		love.graphics.print("PAUSED", 275, 140, 0, 1, 1)
		love.graphics.print("Press SPACE to restart.", 150, 250, 0, .6, .6)
	end
end

-- Saves current highscore to file.
function saveHighscore()
		f = love.filesystem.newFile("hs.dat")
		f:open("w")
		f:write(highScore, all)
end

-- Code to be run on game exit.
function love.quit()	
	saveHighscore()
end
