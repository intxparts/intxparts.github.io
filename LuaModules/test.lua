local dbg = require('debugger')
dbg.auto_where = 2
local args = require('args')

args:add_command('new', 'string', {'-n', '--new'}, 1, false, 'Create new note')

--dbg()

local result, data = pcall(function() return args:parse(arg) end)
if not result then
	print(data)
	return
end

if data['new'] then
    print(data['new'])
    for k,v in pairs(data['new']) do
        print(k,v)
    end
end