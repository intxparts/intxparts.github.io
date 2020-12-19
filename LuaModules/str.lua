local str = {}


function str.to_bool(s)
	if type(s) ~= 'string' then
		return nil
	end
	if s == 'false' then
		return false
	elseif s == 'true' then
		return true
	else
		return nil
	end
end


function str.to_int(s)
	local number = tonumber(s)
	if number == nil then
		return nil
	end

	return math.floor(number)
end


local function _get_sep_str(sep)
	if sep == nil then
		return ''
	elseif type(sep) == 'string' then
		return sep
	else
		return tostring(sep)
	end
end


function str.rep(s, n, sep)
	assert(type(s) == 'string')
	assert(type(n) == 'number')
	if n <= 1 then
		return s
	end

	local str_table = {}
	local i = 0
	while i < n do
		table.insert(str_table, s)
		i = i + 1
	end
	local result = table.concat(str_table, _get_sep_str(sep))
	return result
end


function str.last_index_of(s, e)
	assert(type(s) == 'string')
	if type(e) ~= 'string' then
		e = tostring(e)
	end
	local s_len = s:len()
	local e_len = e:len()
	if s_len < 1 or e_len < 1 or e_len > s_len then
		return -1
	end

	local i = s_len
	while i > 0 do
		local _idx = i - e_len + 1
		local _s = s:sub(_idx, i)
		if _s == e then
			return _idx
		end
		i = i - 1
	end
	
	return -1
end


function str.first_index_of(s, e)
	assert(type(s) == 'string')
	if type(e) ~= 'string' then
		e = tostring(e)
	end
	local s_len = s:len()
	local e_len = e:len()
	if s_len < 1 or e_len < 1 or e_len > s_len then
		return -1
	end
	
	local end_s = s_len + 1
	local i = 1
	while i < end_s do
		local _s = s:sub(i, i + e_len - 1)
		if _s == e then
			return i
		end
		i = i + 1
	end
	
	return -1
end


function str.join(t, sep)
	assert(type(t) == 'table')
	local str_table = {}
	for _, v in ipairs(t) do
		if type(v) == 'string' then
			table.insert(str_table, v)
		else
			table.insert(str_table, tostring(v))
		end
	end

	return table.concat(str_table, _get_sep_str(sep))
end


return str