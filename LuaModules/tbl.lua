local tbl = {}

local function tbl_clone(t)
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = v
	end
	return copy
end

local function tbl_transform(t, callable)
	local r = {}
	for k, v in pairs(t) do
		r[k] = callable(v)
	end
	return r
end

local function tbl_apply(t, callable)
	for k, v in pairs(t) do
		t[k] = callable(v)
	end
	return t
end

local function tbl_filter(t, callable)
	local r = {}
	for k, v in pairs(t) do
		if callable(k, v) then
			table.insert(r, v)
		end
	end
	return r
end

local function tbl_any(t, callable)
	for k, v in pairs(t) do
		if callable(k, v) then
			return true
		end
	end

	return false
end

local function tbl_all(t, callable)
	for k, v in pairs(t) do
		if not callable(k, v) then
			return false
		end
	end
	return true
end

local function tbl_reduce(t, callable, first)
	local acc = first
	local initial_value_given = first and true or false
	for _, v in pairs(t) do
		if initial_value_given then
			acc = callable(acc, v)
		else
			acc = v
		end
	end
	return acc
end

local function tbl_contains_value(t, value)
	for _, v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

local function tbl_contains_key(t, key)
	for k, _ in pairs(t) do
		if k == key then
			return true
		end
	end
	return false
end

local function tbl_count(t, callable)
	if not callable then
		callable = function() return true end
	end

	local count = 0
	for k, v in pairs(t) do
		if callable(k, v) then
			count = count + 1
		end
	end
	return count
end

local function tbl_deep_equal(t1, t2)
	local include_all_tbl_values = function() return true end
	if tbl_count(t1, include_all_tbl_values) ~= tbl_count(t2, include_all_tbl_values) then
		return false
	end
	for k, t1_k in pairs(t1) do
		t1_k_type = type(t1_k)
		if t1_k_type ~= type(t2[k]) then
			return false
		end

		if t1_k_type == 'table' then
			if not tbl_deep_equal(t1_k, t2[k]) then
				return false
			end
		-- elseif t1_k_type == 'function' or
		--     t1_k_type == 'userdata' or
		--     t1_k_type == 'thread' then
		--     goto next_property_continue
		else
			if t1_k ~= t2[k] then
				return false
			end
		end
		-- ::next_property_continue::
	end
	return true
end

tbl.filter = tbl_filter
tbl.all = tbl_all
tbl.any = tbl_any
tbl.transform = tbl_transform
tbl.apply = tbl_apply
tbl.clone = tbl_clone
tbl.reduce = tbl_reduce
tbl.count = tbl_count
tbl.contains_key = tbl_contains_key
tbl.contains_value = tbl_contains_value
tbl.deep_equal = tbl_deep_equal

return tbl
