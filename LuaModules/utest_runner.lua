local path = require('path')
local utest = require('utest')
local timer = require('timer')
local args = require('args')
local str = require('str')

local function run_files(files)
	for _, f in pairs(files) do
		if not string.match(f, '.lua') then
			goto continue_files
		end

		if not path.exists(f) then
			print(string.format('provided file path %q does not exist', f))
			return
		end
		-- might need to wrap this in pcall
		dofile(f)
		::continue_files::
	end
end

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

args:add_command('files',       'string',  {'-f', '--files'},       '+',   false, 'Run specific unit test files.')
args:add_command('directories', 'string',  {'-d', '--directories'}, '+',   false, 'Run all unit test files in a set of directories.')
args:add_command('include_tags','string',  {'-it','--include-tags'},'+',   false, 'Include only the tests with the provided tags.')
args:add_command('exclude_tags','string',  {'-et','--exclude-tags'},'+',   false, 'Exclude tests with the provided tags.')
args:add_command('help',        'boolean', {'-h', '--help', '/?' },  0,    false, 'Display all available commands.')
args:add_command('verbose',     'boolean', {'-v', '--verbose'},      0,    false, 'Show all test output')

local result, data = pcall(function() return args:parse(arg) end)
if not result then
	print(data)
	return
end

if data['help'] then
	print_help()
	return
end

if data['files'] then
	run_files(data['files'])
end

if data['directories'] then
	for _, d in pairs(data['directories']) do
		if not path.exists(d) then
			print(string.format('provided directory path %q does not exist', d))
			return
		end
		local files = path.list_files(d, true)
		run_files(files)
	end
end

local include_tags = nil
if data['include_tags'] then
	include_tags = data['include_tags']
end

local exclude_tags = nil 
if data['exclude_tags'] then
	exclude_tags = data['exclude_tags']
end

local test_report = nil
local function test_runner()
	test_report = utest:run(include_tags, exclude_tags)
end

print('running unit tests...')
local time_start = timer.ctime(test_runner)

local has_errors = false
for _i, group_report in pairs(test_report.group_reports) do
	if data['verbose'] then
		print(group_report.description)
	end
	for _j, test_report in pairs(group_report.details) do
		if test_report.result then
			if data['verbose'] then
				print('.', test_report.description)
			end
		else
			has_errors = true
			print('x', test_report.description, test_report.errors)
		end
	end
end

print('\n~- Test Summary -~')
print(test_report.summary.total, ' tests run total')
print(test_report.summary.passed, ' tests passed')
print(test_report.summary.failed, ' tests failed')
print(string.format('%.6f seconds to execute', time_start))

if has_errors then
	os.exit(false)
end
