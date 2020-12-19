local dyn_array = {}


local err_idx_out_bounds = 'index out of bounds'
local err_idx_invalid = 'index invalid, must be an int'


function dyn_array.__index(t, k)
--	print('indexing table with key', k)
	if type(k) == 'number' then
		assert(math.floor(k) == k, err_idx_invalid)
		assert(0 < k and k <= t._len, err_idx_out_bounds)
		return rawget(t, k)
	else
		return dyn_array[k]
	end
end


function dyn_array.__newindex(t, k, v)
--	print('new index table with key, value', k, v)
	assert(false, '__newindex not supported, use insert* functions')
end


function dyn_array:length()
	return self._len
end


function dyn_array.new(t)
	local _t = t or {}
	local a = { _len = #_t }
	for i=1, a._len do
		rawset(a, i, t[i])
	end
	setmetatable(a, dyn_array)
	return a
end


function dyn_array:insert(e)
	self._len = self._len + 1
	rawset(self, self._len, e)
end


function dyn_array:insert_at(e, i)
	assert(1 <= i and i <= self._len, err_idx_out_bounds)
	for j = self._len, i, -1 do
		rawset(self, j+1, rawget(self, j))
	end
	rawset(self, i, e)
	self._len = self._len + 1
end


function dyn_array:insert_range_at(arr, idx)
	assert(getmetatable(arr) == dyn_array)
	assert(1 <= idx and idx <= self._len, err_idx_out_bounds)
	for j = idx, self._len do
		local new_idx = j + arr._len
		rawset(self, new_idx, rawget(self, j))
	end

	for j = 1, arr._len do
		local new_idx = idx + j - 1
		rawset(self, new_idx, rawget(arr, j))
	end
	self._len = self._len + arr._len
end


function dyn_array:index_of(e, start_idx, end_idx)
	local s_idx = start_idx or 1
	local e_idx = end_idx or self._len
	assert(1 <= s_idx and s_idx <= e_idx, err_idx_out_bounds)
	assert(s_idx <= e_idx and e_idx <= self._len, err_idx_out_bounds)

	for j = s_idx, e_idx do
		if rawget(self, j) == e then
			return j
		end
	end
	return -1
end


function dyn_array:contains(e)
	local idx = self:index_of(e, 1, self._len)
	return idx ~= -1
end


function dyn_array:last_index_of(e, start_idx, end_idx)
	local s_idx = start_idx or 1
	local e_idx = end_idx or self._len
	assert(1 <= s_idx and s_idx <= e_idx, err_idx_out_bounds)
	assert(s_idx <= e_idx and e_idx <= self._len, err_idx_out_bounds)

	for j = e_idx, s_idx, -1 do
		if rawget(self, j) == e then
			return j
		end
	end
	return -1
end


function dyn_array:clone()
	local a = dyn_array.new()
	for j = 1, self._len do
		rawset(a, j, rawget(self, j))
	end
	a._len = self._len
	return a
end


function dyn_array:remove_at(i)
	assert(1 <= i and i <= self._len, err_idx_out_bounds)
	for j = i, self._len do
		rawset(self, j, rawget(self, j+1))
	end
	self._len = self._len - 1
end


function dyn_array:remove(e)
	local found = false
	for j = 1, self._len do
		if not found and rawget(self, j) == e then
			found = true
		end

		if found then
			rawset(self, j, rawget(self, j+1))
		end
	end
	if found then
		self._len = self._len - 1
	end
end


function dyn_array:remove_range_at(start_idx, remove_count)
	if remove_count == 0 then
		return
	end
	local s_idx = start_idx
	local e_idx = s_idx + remove_count - 1
	assert(1 <= s_idx and s_idx <= e_idx, err_idx_out_bounds)
	assert(s_idx <= e_idx and e_idx <= self._len, err_idx_out_bounds)
	
	for i = s_idx, self._len do
		rawset(self, i, rawget(self, i + remove_count))
	end

	self._len = self._len - remove_count
end


function dyn_array:clear()
	for j = 1, self._len do
		rawset(self, j, nil)
	end
	self._len = 0
end


function dyn_array:reverse()
	local length = self._len
	local half_len = length / 2
	for j = 1, half_len do
		local swap_idx = length + 1 - j
		local tmp = rawget(self, j)
		rawset(self, j, rawget(self, swap_idx))
		rawset(self, swap_idx, tmp)
	end
end


return dyn_array
