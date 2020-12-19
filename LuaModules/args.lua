local args = {}
args.__index = args
args._cmds = {}
args._i = 1

local valid_arg_types = {'string', 'number', 'boolean'}

local function str_to_bool(s)
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

local function str_to_int(s)
	local number = tonumber(s)
	if number == nil then
		return nil
	end

	return math.floor(number)
end

local function tbl_contains_value(t, val)
	for _, v in pairs(t) do
		if v == val then
			return true
		end
	end
	return false
end

local function tbl_count(t)
	local i = 0
	for _k, _v in pairs(t) do
		i = i + 1
	end
	return i
end

function args:add_command(cmd_name, type_info, flags, nargs, required, help, default)
	assert(type(cmd_name) == 'string')
	assert(type(type_info) == 'string')
	assert(tbl_contains_value(valid_arg_types, type_info), 'invalid argument type')
	assert(type(nargs) == 'string' or type(nargs) == 'number')
	assert(flags ~= nil and type(flags) == 'table', 'flags must be a valid table')
	assert(type(required) == 'boolean')
	assert(type(help) == 'string')
	local cmd = {
		name = cmd_name,
		type_info = type_info,
		flags = flags,
		nargs = nargs,
		required = required,
		help = help,
		default = default
	}
	assert(self._cmds[self._i] == nil)
	self._cmds[self._i] = cmd
	self._i = self._i + 1
end

local function cmd_type_mismatch_error(input, cmd)
	error(
		string.format(
			'expected value: %d to be of type %q for command %q',
			input,
			cmd.type_info,
			cmd.name
		)
	)
end

local function get_arg_converter_fn(type_info_str)
	if type_info_str == 'number' then
		return tonumber
	elseif type_info_str == 'integer' then
		return str_to_int
	elseif type_info_str == 'string' then
		return function(x) return x end
	elseif type_info_str == 'boolean' then
		return str_to_bool
	else
		return function(x) return nil end
	end
end

local function collect_cmd_args(cmd_flags, i, inputs, matching_cmd, cmds)
	local min_required_nargs = 0
	local max_nargs = 256
	-- check matching_cmd.nargs
	if type(matching_cmd.nargs) == 'string' then
		if matching_cmd.nargs == '+' then
			min_required_nargs = 1
		elseif matching_cmd.nargs == '*' then
			min_required_nargs = 0
		else
			error(string.format('invalid nargs field: %q provided for %q', matching_cmd.nargs, matching_cmd.name))
		end
	elseif type(matching_cmd.nargs) == 'number' then
		assert(
			matching_cmd.nargs > -1,
			string.format('invalid nargs value provided for command: %q. nargs must be a whole number', matching_cmd.name)
		)
		min_required_nargs = matching_cmd.nargs
		max_nargs = matching_cmd.nargs
	end
	local converter_fn = get_arg_converter_fn(matching_cmd.type_info)
	local cmd_args = {}
	local num_args = 0
	-- process up until the next command is identified
	local num_inputs = tbl_count(inputs)
	while num_args < max_nargs and i < num_inputs and cmd_flags[inputs[i]] == nil and inputs[i] ~= nil do
		local value = converter_fn(inputs[i])
		if not value then cmd_type_mismatch_error(inputs[i], matching_cmd) end
		local next = num_args + 1
		cmd_args[next] = value
		num_args = next
		i = i + 1
	end

	if max_nargs == 0 then
		cmds[matching_cmd.name] = true
		return i
	end

	print(num_args)
	assert(min_required_nargs <= num_args and num_args <= max_nargs, string.format('invalid number of arguments provided for command: %q', matching_cmd.name))
	if num_args > 0 then
		cmds[matching_cmd.name] = cmd_args
	else
		if type(matching_cmd.default) ~= matching_cmd.type_info then
			error(
				string.format(
					'default argument %q type does not match the specified type: %q',
					tostring(matching_cmd.default),
					matching_cmd.type_info
				)
			)
		end
		cmds[matching_cmd.name] = { matching_cmd.default }
	end

	-- return the previous idx so that the next cmd_flag can be properly processed
	return i - 1
end

function args:parse(inputs)
	assert(type(inputs) == 'table')
	-- build a lookup table
	-- flag -> argument_idx
	local cmd_flags = {}
	for i, c in ipairs(self._cmds) do
		for _, f in pairs(c.flags) do
			cmd_flags[f] = i
		end
	end

	local cmds = {}
	local i = 1
	local num_inputs = tbl_count(inputs) + 1
	while i < num_inputs do
		local matching_cmd_idx = cmd_flags[inputs[i]]
		if matching_cmd_idx then
			i = collect_cmd_args(cmd_flags, i+1, inputs, self._cmds[matching_cmd_idx], cmds)
		end
		i = i + 1
	end
	for _, cmd in pairs(self._cmds) do
		if cmd.required then
			assert(cmds[cmd.name] ~= nil, string.format('missing required command %q', cmd.name))
		end
	end

	return cmds
end

return args
