local os_ext = {}


os_ext.platforms = {
	unix = 'unix',
	windows = 'windows'
}


os_ext.path_separator = package.config:sub(1, 1)


local _separator_platform_table = {
	['/'] = os_ext.platforms.unix,
	['\\'] = os_ext.platforms.windows
}


os_ext.platform = _separator_platform_table[os_ext.path_separator]
os_ext.is_windows = os_ext.platform == os_ext.platforms.windows
os_ext.is_unix = os_ext.platform == os_ext.platforms.unix


-- Returns a table of results from a command string being invoked
function os_ext.run_command(command)
	assert(type(command) == 'string')
	local idx = 1
	local results = {}
	local pfile = io.popen(command)
	for line in pfile:lines() do
		results[idx] = line
		idx = idx + 1
	end
	pfile:close()
	return results
end


return os_ext
