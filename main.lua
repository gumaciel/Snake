require("collision");
local lg = love.graphics;
local la = love.audio;
local lk = love.keyboard;

local width = love.graphics.getWidth();
local height = love.graphics.getHeight();

function love.load(...)
	snake = {sec = 0, velocity = 10, sound = {eat = la.newSource("data/fx/eat.wav"), wall = la.newSource("data/fx/wall.wav"), walk = {[1] = la.newSource("data/fx/1.wav"), [2] = la.newSource("data/fx/2.wav")};};};
	if #snake == 0 then
		table.insert(snake, #snake+1, 
			{
				x = 400, 
				y = 400, 
				w = 20, 
				h = 20, 
				directionX = true,
				directionY = true,
				absolute = "x",
				id = "head",
				nextpos = {[1] = nil, [2] = nil;};
			}
		);
	end
	apple = {
		[1] = {
			x = 560,
			y = 400,
			w = 20,
			h = 20;
		}
	}
	i = 20
end
local pause = false
local gameoverbool = false
score = {}

function love.update(dt)
	function gameover(...)
		snake.sound.wall:play()
		table.insert(score, #score+1, #snake)
		for i = 1, #snake do
			table.remove(snake, 1)
		end
		xrand = math.random(0, 39)
		yrand = math.random(0, 29)
		table.insert(snake, #snake+1, 
			{
				x = xrand*20, 
				y = yrand*20, 
				w = 20, 
				h = 20, 
				directionX = true,
				directionY = true,
				absolute = "x",
				id = "head",
				nextpos = {[1] = nil, [2] = nil;};
			}
		);
		pause = true
		gameoverbool = true
	end
	function love.keypressed(key, unicode) 
		if key == "p" then 
			if pause and not gameoverbool then
				pause = false
			else 
				pause = true
			end
		end
		if key == "return" then
			if gameoverbool then
				gameoverbool = false
				pause = false
			end
		end
	end

	local restart = false
	if not pause then
		if #snake ~= 0 then
			snake.sec = snake.sec - snake.velocity * dt;
			for i = #snake, 1, -1 do
				if #snake > 4 then
					for j=i-2, 1, -1 do
						if checkCollision(snake[i].x, snake[i].y, snake[i].w, snake[i].h, snake[j].x, snake[j].y, snake[j].w, snake[j].h) then
							gameover()
							restart = true
							break
						end
					end
				end
				if restart then
					restart = false
					break
				end

				if snake[i].id == "head" then
					function mov()
						if lk.isDown("s", "down") then
							if #snake > 1 then
								if not checkCollision(snake[i].x, snake[i].y + 20, snake[i].w, snake[i].h, snake[i-1].x, snake[i-1].y, snake[i-1].w, snake[i-1].h) then
									if not (snake[i-1].lastmove == "up") then
										snake[i].directionY = false;
										snake[i].absolute = "y";
									end
								end
							else
								snake[i].directionY = false;
								snake[i].absolute = "y";
							end
						end

						if lk.isDown("w", "up") then
							if #snake > 1 then
								if not checkCollision(snake[i].x, snake[i].y - 20, snake[i].w, snake[i].h, snake[i-1].x, snake[i-1].y, snake[i-1].w, snake[i-1].h) then
									if not (snake[i-1].lastmove == "down") then
										snake[i].directionY = true;
										snake[i].absolute = "y";
									end
								end
							else
								snake[i].directionY = true;
								snake[i].absolute = "y";
							end
						end

						if lk.isDown("a", "left") then
							if #snake > 1 then
								if not checkCollision(snake[i].x - 20, snake[i].y, snake[i].w, snake[i].h, snake[i-1].x, snake[i-1].y, snake[i-1].w, snake[i-1].h) then
									if not (snake[i-1].lastmove == "right") then
										snake[i].directionX = false;
										snake[i].absolute = "x";
									end
								end
							else
								snake[i].directionX = false;
								snake[i].absolute = "x";
							end
						end
						if lk.isDown("d", "right") then
							if #snake > 1 then
								if not checkCollision(snake[i].x + 20, snake[i].y, snake[i].w, snake[i].h, snake[i-1].x, snake[i-1].y, snake[i-1].w, snake[i-1].h) then
									if not (snake[i-1].lastmove == "left") then
										snake[i].directionX = true;
										snake[i].absolute = "x";
									end
								end
							else
								snake[i].directionX = true;
								snake[i].absolute = "x";
							end	
						end
					end				
					mov()

					if #apple == 1 and #snake < 1200 then
						if checkCollision(snake[i].x, snake[i].y, snake[i].w, snake[i].h, apple[1].x, apple[1].y, apple[1].w, apple[1].h) then
							snake[i].id = "body"
							snake[i].lastmove = snake[i].nextpos[1];
							table.insert(snake, #snake+1, 
								{
									x = apple[1].x, 
									y = apple[1].y,
									w = snake[i].w, 
									h = snake[i].h, 
									directionX = snake[i].directionX,
									directionY = snake[i].directionY,
									absolute = snake[i].absolute,			
									id = "head",
									nextpos = {[1] = nil, [2] = nil},
									lastmove = nil;
								}
							);
							snake.sound.eat:play()
							excp = {x = {}, y = {};};
							for i=1, #snake do
								table.insert(excp.x, i, snake[i].x)
								table.insert(excp.y, i, snake[i].y)
							end
							repeatnotgo = true
							attempt = 1
							while true do
								print(attempt)
								attempt = attempt + 1
								x, y = math.random(0, 39), math.random(0, 29)
								for ix=1,#excp.x do
									for iy=1,#excp.y do
										if x == excp.x[ix]/20 and y == excp.y[iy]/20 then
											repeatnotgo = true
											break
										else
											repeatnotgo = false
										end
									end
									if repeatnotgo then
										break
									end
								end
								if not repeatnotgo then
									break
								end
							end

							x,y = x * 20, y * 20
							if x == 0 then
								x = 20;
							end
							if y == 0 then
								y = 20;
							end

							table.remove(apple, #apple)
							table.insert(apple, #apple+1, {x = x, y = y , w = 20, h = 20})
						end
					end

					if snake.sec < 0 then
						if snake[i].absolute == "x" then
							if snake[i].directionX then
								if snake[i].x < width then
									snake[i].x = snake[i].x + snake[i].w
									table.insert(snake[i].nextpos, 1, "right")
								end
							elseif not snake[i].directionX then
								if snake[i].x > - 20 then
									snake[i].x = snake[i].x - snake[i].w
									table.insert(snake[i].nextpos, 1, "left")
								end
							end

							snake.sound.walk[1]:setVolume(0.3)
							snake.sound.walk[1]:play()
						elseif snake[i].absolute == "y" then
							if snake[i].directionY then
								if snake[i].y > - 20 then
									snake[i].y = snake[i].y - snake[i].h
									table.insert(snake[i].nextpos, 1, "up")
								end
							elseif not snake[i].directionY then
								if snake[i].y < height then
									snake[i].y = snake[i].y + snake[i].h
									table.insert(snake[i].nextpos, 1, "down")
								end
							end
							snake.sound.walk[2]:setVolume(0.3)
							snake.sound.walk[2]:play()
						end
						if #snake>1 then
							snake[i-1].lastmove = nil
						end
						if #snake[i].nextpos >= 3 then 
							table.remove(snake[i].nextpos, 3)
						end
						if snake[i].x/20 < 0 or snake[i].x/20 > 39 or snake[i].y/20 < 0 or snake[i].y/20 > 29 then
							gameover()
							break
						end							
					end
				elseif snake[i].id == "body" then
					if snake.sec < 0 then
						if snake[i+1].nextpos[2] == "right" then
							snake[i].x = snake[i].x + snake[i].w
							table.insert(snake[i].nextpos, 1, "right")
							table.remove(snake[i+1].nextpos, 2)
						end
						if snake[i+1].nextpos[2] == "left" then
							table.insert(snake[i].nextpos, 1, "left")
							snake[i].x = snake[i].x - snake[i].w		
							table.remove(snake[i+1].nextpos, 2)
						end
						if snake[i+1].nextpos[2] == "up" then
							table.insert(snake[i].nextpos, 1, "up")
							snake[i].y = snake[i].y - snake[i].h		
							table.remove(snake[i+1].nextpos, 2)
						end
						if snake[i+1].nextpos[2] == "down" then
							table.insert(snake[i].nextpos, 1, "down")
							snake[i].y = snake[i].y + snake[i].h		
							table.remove(snake[i+1].nextpos, 2)
						end
					end
					if #snake[i].nextpos >= 3 then 
						table.remove(snake[i].nextpos, 3)
					end
				end
			end
			if snake.sec < 0 then
				snake.sec = 1
			end
		end
	end
end
function love.draw(...)
	love.graphics.setBackgroundColor(1, 5, 1, 0.1);

	love.graphics.setColor(1, 255, 20);
	for i,snake in ipairs(snake) do
		love.graphics.rectangle("fill", snake.x, snake.y, snake.w, snake.h);
	end
	if #apple == 1 then 
		lg.rectangle("line", apple[1].x, apple[1].y, apple[1].w, apple[1].h)
	end
	love.graphics.setColor(255, 255, 255);

	love.graphics.setColor(100, 250, 200, 0.5);
	for i=0, width, 20 do
		lg.rectangle("fill", i, 0, 1, height);
	end
	for j=0, height, 20 do
		lg.rectangle("fill", 0, j, width, 1);
	end
	love.graphics.setColor(255, 255, 255);
	
	if pause and not gameoverbool then
		lg.print("PAUSED, press 'p' to unpause", width/2, height/2)
	end

	if gameoverbool == true then
		lg.print("Press Enter(return) to restart", width/2, (height/2) - 20)
		lg.print("Score = " .. score[#score], width/2, height/2)
		lg.print("HighScore = " .. math.max(unpack(score)), width/2, (height/2) + 20)
	end
	if lk.isDown("tab") then
		lg.print("FPS = " .. love.timer.getFPS(), 0, height - 20);
	end
	lg.print("Actual Score = " .. tostring(#snake), 0, 0)
end