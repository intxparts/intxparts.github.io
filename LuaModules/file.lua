local ose = require('os_ext')
local path = require('path')
local str = require('str')
local file = {}

function file.exists(file_path)
	return path.exists(file_path)
end

function file.copy(source_file_path, dest_directory, overwrite)
	-- TODO - handle not overwrite case here
	
	local result = nil
	if ose.is_windows then
		result = ose.run_command(string.format('copy /Y %q %q', source_file_path, dest_directory))
	else
		result = ose.run_command(string.format('cp -f %q %q', source_file_path, dest_directory))
	end
	for k, v in pairs(result) do
		print(k,v)
	end
end

function file.delete(file_path)
	local result = nil
	if ose.is_windows then
		result = ose.run_command(string.format('del /F %q', file_path))
	else
		result = ose.run_command(string.format('rm -f %q', file_path))
	end
	for k, v in pairs(result) do
		print(k,v)
	end
end

return file
