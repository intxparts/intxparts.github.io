--[[
-- rect represents a rectangle defined by:
--      - top-left point (x, y)
--      - width (w)
--      - height (h)
--
--                 w
--      (x, y) --------- <- top
--             |       |
--             |       | h
--             |       |
--             --------- <- bottom
--
--             ^       ^
--             |       |
--            left    right
--
-- Note: rect follows the paradigm:
--          y + h = bottom
--          x + w = right
--]]

local rect = {}
rect.__index = rect

function rect.new(x, y, w, h)
	assert(w >= 0)
	assert(h >= 0)
	local r = {x=x,y=y,w=w,h=h}
	r.top = y
	r.bottom = y + h
	r.left = x
	r.right = x + w
	setmetatable(r, rect)
	return r
end

function rect.copy(r)
	return rect.new(r.x, r.y, r.w, r.h)
end

function rect.set(r, x, y, w, h)
	assert(w >= 0)
	assert(h >= 0)
	r.x = x
	r.y = y
	r.w = w
	r.h = h

	r.right = x + w
	r.left = x
	r.top = y
	r.bottom = y + h
end

function rect.set_height(r, h)
	assert(h >= 0)
	r.h = h
	r.bottom = r.y + h
end

function rect.set_width(r, w)
	assert(w >= 0)
	r.w = w
	r.right = r.x + w
end

function rect.set_x(r, x)
	r.x = x
	r.left = x
	r.right = x + r.w
end

function rect.set_y(r, y)
	r.y = y
	r.top = y
	r.bottom = y + r.h
end

function rect.set_left(r, v)
	r.left = v
	r.x = v
	r.right = x + r.w
end

function rect.set_right(r, v)
	local pos = v - r.w
	r.right = v
	r.left = pos
	r.x = pos
end

function rect.set_top(r, v)
	r.y = v
	r.top = v
	r.bottom = v + r.h
end

function rect.set_bottom(r, v)
	local pos = v - r.h
	r.bottom = v
	r.top = pos
	r.y = pos
end

function rect.contains_point(r, x, y)
	return (r.left <= x and x <= r.right) and
		   (r.top <= y and y <= r.bottom)
end

-- ignore points on the border
function rect.strictly_contains_point(r, x, y)
	return (r.left < x and x < r.right) and
		   (r.top < y and y < r.bottom)
end

function rect.has_y_collision(r1, r2)
	local self_bottom_between_y_bounds = r2.top <= r1.bottom and r1.bottom <= r2.bottom
	local self_top_between_y_bounds = r2.top <= r1.top and r1.top <= r2.bottom
	local other_bottom_between_y_bounds = r1.top <= r2.bottom and r2.bottom <= r1.bottom
	local other_top_between_y_bounds = r1.top <= r2.top and r2.top <= r1.bottom
	local has_y_col = self_top_between_y_bounds or self_bottom_between_y_bounds or other_bottom_between_y_bounds or other_top_between_y_bounds
	return has_y_col
end

function rect.has_x_collision(r1, r2)
	local self_left_between_x_bounds = r2.left <= r1.left and r1.left <= r2.right
	local self_right_between_x_bounds = r2.left <= r1.right and r1.right <= r2.right
	local other_left_between_x_bounds = r1.left <= r2.left and r2.left <= r1.right
	local other_right_between_x_bounds = r1.left <= r2.right and r2.right <= r1.right
	local has_x_col = self_left_between_x_bounds or self_right_between_x_bounds or other_left_between_x_bounds or other_right_between_x_bounds
	return has_x_col
end

function rect.collide(r1, r2)
	return rect.has_x_collision(r1, r2) and rect.has_y_collision(r1, r2)
end

return rect
