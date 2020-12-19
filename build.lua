local args = require('args')
local path = require('path')
local file = require('file')
local ose = require('os_ext')
local str = require('str')

local function print_help()
	local str_format = "%-15s | %-3s | %-25s | %-60s"
	print(string.format(str_format, "Argument", "Req", "Flags", "Description"))
	print(str.rep('-', 100))
	for i, v in ipairs(args._cmds) do
		local required_str = ' '
		if v.required then
			required_str = '.'
		end
		local flag_str = table.concat(v.flags, ",  ")
		print(string.format(str_format, v.name, required_str, flag_str, v.help))
	end
end


local function new_note(title)
    local date = os.date('*t')
    local year = tostring(date.year)
    local month = tostring(date.month)
    local day = tostring(date.day)
    if date.month < 10 then
        month = string.format('0%d', date.month)
    end
    if date.day < 10 then
        day = string.format('0%d', date.day)
    end
	local note_date_str = string.format('%s.%s.%s', year, month, day)
    local note_filename = string.format('notes_%s.md', note_date_str)
    local new_note = io.open(string.format('./notes/%s', note_filename),'w')
    new_note:write(string.format('# %s\n\n', title))
    new_note:write(string.format('*%s*\n\n', note_date_str))
    new_note:close()
    print(string.format('created new note: %s', note_filename))
end

local function fetch_title_from_file(file_path)
    local file = io.open(file_path, 'r')
    local title_line = file:read('l')
    file:close()
    local title_hash_pos = string.find(title_line, '#')
    if not title_hash_pos then
        return nil
    end
    local title = string.sub(title_line, title_hash_pos + 2, string.len(title_line) -  title_hash_pos + 1)
    return title
end

local function fetch_date_from_file_path(file_path)
    local pos = string.find(file_path, 'notes\\notes_')
    if pos == nil then return nil end
    local date = string.sub(file_path, pos + 12, string.len(file_path) - pos - 2)
    return date
end

local function generate_html_file(md_filepath, html_filepath, title)
    local command = string.format('pandoc -f gfm -t html -s -o %s %s --metadata pagetitle=%q -V "mainfont:Font-Regular.otf"', html_filepath, md_filepath, title)
    print(command)
    ose.run_command(command)
end


local function run_build()
    file.delete('.\\notes\\*.html')
    local include_subdir = false
    local note_file_list = path.list_files('notes', include_subdir)
    table.sort(note_file_list, function(i, j) return i > j end) -- order by most recent note
    file.copy('template-devNotes.md', 'devNotes.md')

    for k, v in ipairs(note_file_list) do
        local title = fetch_title_from_file(v)
        local date = fetch_date_from_file_path(v)
        local file_name_no_ext = string.sub(v, 1, string.len(v) - 3)
        local html_filepath = string.format('.\\%s.html', file_name_no_ext)
        local index_file = io.open('devNotes.md', 'a+')
        index_file:write(string.format('- %s [%s](%s)\n', date, title, html_filepath))
        index_file:close()
        local md_filepath = string.format('.\\%s', v)
        generate_html_file(md_filepath, html_filepath, title)
    end

    generate_html_file('index.md', 'index.html', 'Old Jim\'s General Store')
    generate_html_file('tools.md', 'tools.html', 'Old Jim\'s Toolbox')
    generate_html_file('games.md', 'games.html', 'Old Jim\'s Game Shelf')
	generate_html_file('devNotes.md', 'devNotes.html', 'Old Jim\'s Dev Notes')
end


args:add_command('new', 'string', {'-n', '--new'}, 1, false, 'Create new note')
args:add_command('build', 'string', {'-b', '--build'}, 0, false, 'Run the build')
args:add_command('help', 'boolean', {'-h', '--help', '/?' }, 0, false, 'Display all available commands.')

local result, data = pcall(function() return args:parse(arg) end)
if not result then
	print(data)
	return
end

if data['help'] then
	print_help()
	return
end

if data['new'] then
    new_note(data['new'][1])
end

if data['build'] then
    run_build()
end

