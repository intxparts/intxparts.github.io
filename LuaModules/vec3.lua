local vec3 = {}
vec3.__index = vec3

function vec3.new(x, y, z)
	local v = { x=x or 0, y=y or 0, z=z or 0}
	setmetatable(v, vec3)
	return v
end

function vec3.zero()
	return vec3.new(0, 0, 0)
end

function vec3.from_points(p1, p2)
	return vec3.new(
		p2.x - p1.x,
		p2.y - p1.y,
		p2.z - p1.z
	)
end

function vec3.dot(v1, v2)
	return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
end

function vec3.mag2(v)
	return vec3.dot(v, v)
end

function vec3.mag(v)
	return math.sqrt(vec3.mag2(v))
end

function vec3.scale(v, k)
	return vec3.new(v.x*k, v.y*k, v.z*k)
end

function vec3.cross(v1, v2)
	return vec3.new(
		v1.y*v2.z - v1.z*v2.y,
		v1.z*v2.x - v1.x*v2.z,
		v1.x*v2.y - v1.y*v2.x
	)
end

function vec3.add(v1, v2)
	return vec3.new(
		v1.x + v2.x,
		v1.y + v2.y,
		v1.z + v2.z
	)
end

function vec3.sub(v1, v2)
	return vec3.new(
		v1.x - v2.x,
		v1.y - v2.y,
		v1.z - v2.z
	)
end

function vec3.equals(v1, v2)
	return v1.x == v2.x and v1.y == v2.y and v1.z == v2.z
end

function vec3.tostring(v)
	return string.format('<%d, %d, %d>', v.x, v.y, v.z)
end

-- v1 = v1 + v2
function vec3._add(v1, v2)
	v1.x = v1.x + v2.x
	v1.y = v1.y + v2.y
	v1.z = v1.z + v2.z
	return v1
end

-- v1 = v1 - v2 
function vec3._sub(v1, v2)
	v1.x = v1.x - v2.x
	v1.y = v1.y - v2.y
	v1.z = v1.z - v2.z
	return v1
end

-- v1 = v1 * k
function vec3._scale(v, k)
	v.x = v.x * k
	v.y = v.y * k
	v.z = v.z * k
	return v
end

function vec3.set(v, x, y, z)
	v.x = x
	v.y = y
	v.z = z
end

return vec3
