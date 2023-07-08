local input = {}

local orig = {
	mousepressed = love.handlers['mousepressed'],
	mousereleased = love.handlers['mousereleased'],
	textinput = love.handlers['textinput'],
	keypressed = love.handlers['keypressed'],
	keyreleased = love.handlers['keyreleased'],
	mousemoved = love.handlers['mousemoved']
}

love.handlers['mousepressed'] = function(x, y, btn, d, e, f)
	if input.mousepressed and not input.mousepressed(x, y, btn, d, e ,f) then
		orig.mousepressed(x, y, btn, d, e, f)
	end
end
love.handlers['mousereleased'] = function(x, y, btn, d, e, f)
	if input.mousereleased and not input.mousereleased(x, y, btn, d, e ,f) then
		orig.mousereleased(x, y, btn, d, e, f)
	end
end
love.handlers['keypressed'] = function(key, b, c, d, e, f)
	if input.keypressed and not input.keypressed(key, b, c, d, e, f) then
		orig.keypressed(key, b, c, d, e, f)
	end
end
love.handlers['keyreleased'] = function(key, b, c, d, e, f)
	if input.keyreleased and not input.keyreleased(key, b, c, d, e, f) then
		orig.keyreleased(key, b, c, d, e, f)
	end
end
love.handlers['textinput'] = function(text, b, c, d, e, f)
	if input.textinput and not input.textinput(text, b, c, d, e, f) then
		orig.textinput(text, b, c, d, e, f)
	end
end
love.handlers['mousemoved'] = function(x, y, dx, dy, e, f)
	if input.mousemoved and not input.mousemoved(x, y, dx, dy, e, f) then
		orig.mousemoved(x, y, dx, dy, e, f)
	end
end

return input