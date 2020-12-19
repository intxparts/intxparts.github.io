local os_ext = require('os_ext')
local str = require('str')
local path = {}


local _windows_invalid_path_chars = {
	'"',
	'<',
	'>',
	'|',
	'\0'
}


for i = 1, 31 do
	table.insert(_windows_invalid_path_chars, string.char(i))
end


-- returns windows specific cmd string to list all files in the root_directory
-- with the option to also include subdirectories
local function _wincmd_listfiles(root_directory, include_subdirectories)
	-- /b  removes header/extraneous information
	-- /a-d  defines usage of attribute -d (anything not a directory)
	local command = string.format('dir "%s" /b /a-d', root_directory)
	if include_subdirectories then
		command = command .. ' /s'
	end
	return command
end


local function _unixcmd_listfiles(root_directory, include_subdirectories)
	local depth = ''
	if not include_subdirectories then
		depth = '-maxdepth 7'
	end
	local command = string.format('find "%s" %s -type f', root_directory, depth)
	return command
end


-- returns windows specific cmd string to list all directories in the root_directory
-- with the option to also include subdirectories
local function _wincmd_listdir(root_directory, include_subdirectories)
	-- /b  removes header/extraneous information
	-- /ad  defines usage of attribute directory
	local command = string.format('dir "%s" /b /ad', root_directory)
	if include_subdirectories then
		command = command .. ' /s'
	end
	return command
end


local function _unixcmd_listdir(root_directory, include_subdirectories)
	local depth = ''
	if not include_subdirectories then
		depth = '-maxdepth 7'
	end
	local command = string.format('find "%s" "%s" -type d', root_directory, depth)
	return command
end


-- returns path string of the current (present) working directory
function path.get_cwd()
	local result = nil
	if os_ext.is_windows then
		result = os_ext.run_command('cd')
	else
		result = os_ext.run_command('pwd')
	end
	return result[1]
end


-- returns whether the target_path exists or not
function path.exists(target_path)
	assert(type(target_path) == 'string')
	local result = nil
	if os_ext.is_windows then
		result = os_ext.run_command(string.format('if exist "%s" (echo true) else (echo false)', target_path))[1] == 'true'
	else
		result = os_ext.run_command(string.format('if test -f "%s"; then echo true; else echo false; fi', target_path))[1] == 'true' or
			os_ext.run_command(string.format('if test -d "%s"; then echo true; else echo false; fi', target_path))[1] == 'true'
	end
	return result
end


-- need to potentially add filtering
function path.list_files(root_directory, include_subdirectories)
	assert(type(root_directory) == 'string')
	assert(path.exists(root_directory), 'directory does not exist')

	local command = nil
	if os_ext.is_windows then
		local command = _wincmd_listfiles(root_directory, include_subdirectories)
		local files = os_ext.run_command(command)
		-- when /s (include subdirectories) is not used, dir
		-- does not include the directory path in the output
		if not include_subdirectories then
			local is_path_escaped = root_directory:sub(-1, -1) == os_ext.path_separator
			if not is_path_escaped then
				root_directory = root_directory .. os_ext.path_separator
			end
			for k, _ in pairs(files) do
				files[k] = root_directory .. files[k]
			end
		end
		return files
	else
		command = _unixcmd_listfiles(root_directory, include_subdirectories)
		return os_ext.run_command(command)
	end
end


-- need to potentially add filtering
function path.list_dir(root_directory, include_subdirectories)
	assert(type(root_directory), 'string')
	assert(path.exists(root_directory), 'directory does not exist')

	if os_ext.is_windows then
		local command = _wincmd_listdir(root_directory, include_subdirectories)
		local folders = os_ext.run_command(command)
		-- when /s (include subdirectories) is not used, dir
		-- does not include the directory path in the output
		if not include_subdirectories then
			local is_path_escaped = root_directory:sub(-1, -1) == os_ext.path_separator
			if not is_path_escaped then
				root_directory = root_directory .. os_ext.path_separator
			end
			for k, _ in pairs(folders) do
				folders[k] = root_directory .. folders[k]
			end
		end
		return folders
	else
		local command = _unixcmd_listdir(root_directory, include_subdirectories)
		return os_ext.run_command(command)
	end
end


local function _has_invalid_chars(str)
	local char = nil
	if os_ext.is_windows then
		for i = 1, string.len(str) do
			char = str:sub(i, i)
			for _, c in pairs(_windows_invalid_path_chars) do
				if char == c then
					return true
				end
			end
		end 
	else
		-- TODO add linux
		assert(true == false)
	end
	return false
end


return path
