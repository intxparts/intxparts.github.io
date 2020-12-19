local utest = {}

local function tbl_contains_value(t, val)
	for _, v in pairs(t) do
		if v == val then
			return true
		end
	end
	return false
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

local function test_report(description, result, errors)
	return {
		description = description,
		result = result,
		errors = errors
	}
end

local function test_summary_report()
	return {
		total = 0,
		passed = 0,
		failed = 0
	}
end

local function group_test_report(description)
	return {
		description = description,
		summary = test_summary_report(),
		details = {}
	}
end

local function full_test_report()
	return {
		summary = test_summary_report(),
		group_reports = {}
	}
end

utest._current = {
	groups = {},
	tests = {} -- support for tests outside of groups
}

function utest:group(description, fn, tags)
	assert(type(fn) == 'function')
	local child = {
		description = description,
		fn = fn,
		parent = self._current,
		before_eaches = {},
		befores = {},
		tests = {},
		after_eaches = {},
		afters = {},
		tags = tags or {},
	}

	table.insert(self._current.groups, child)
	self._current = child
	local result, message = pcall(fn)
	self._current = child.parent

end

function utest:test(description, fn)
	assert(type(fn) == 'function')
	local test = {
		description = description,
		fn = fn
	}
	table.insert(self._current.tests, test)
end

function utest:before(fn)
	assert(type(fn) == 'function')
	table.insert(self._current.befores, fn)
end

function utest:after(fn)
	assert(type(fn) == 'function')
	table.insert(self._current.afters, fn)
end

function utest:before_each(fn)
	assert(type(fn) == 'function')
	table.insert(self._current.before_eaches, fn)
end

function utest:after_each(fn)
	assert(type(fn) == 'function')
	table.insert(self._current.after_eaches, fn)
end

local function group_has_any_matching_tags(group_tags, tags)
	for _, t in pairs(tags) do
		if tbl_contains_value(group_tags, t) then
			return true
		end
	end
	return false
end

local function group_has_no_matching_tags(group_tags, tags)
	for _, t in pairs(tags) do
		if tbl_contains_value(group_tags, t) then
			return false
		end
	end
	return true
end

function utest:run(include_tags, exclude_tags)
	local report = full_test_report()
	local sa_group = group_test_report('standalone tests ->')

	for _i, t in pairs(self._current.tests) do
		local result, errors = pcall(t.fn)

		report.summary.total = report.summary.total + 1
		sa_group.summary.total = sa_group.summary.total + 1

		table.insert(sa_group.details, test_report(t.description, result, errors))

		if result then
			report.summary.passed = report.summary.passed + 1
			sa_group.summary.passed = sa_group.summary.passed + 1
		else
			report.summary.failed = report.summary.failed + 1
			sa_group.summary.failed = sa_group.summary.failed + 1
		end
	end
	table.insert(report.group_reports, sa_group)

	local groups = self._current.groups
	if include_tags then
		groups = tbl_filter(groups, function(_, g)
			return group_has_any_matching_tags(g.tags, include_tags)
		end)
	end
	if exclude_tags then
		groups = tbl_filter(groups, function(_, g)
			return group_has_no_matching_tags(g.tags, exclude_tags)
		end)
	end
	for _i, v in pairs(groups) do

		local group_report = group_test_report(v.description)

		for _j, b in pairs(v.befores) do
			local result, message = pcall(b)
		end

		for _j, t in pairs(v.tests) do
			for _k, be in pairs(v.before_eaches) do
				local result, message = pcall(be)
			end

			report.summary.total = report.summary.total + 1
			group_report.summary.total = group_report.summary.total + 1

			local result, errors = pcall(t.fn)

			table.insert(group_report.details, test_report(t.description, result, errors))

			if result then
				report.summary.passed = report.summary.passed + 1
				group_report.summary.passed = group_report.summary.passed + 1
			else
				report.summary.failed = report.summary.failed + 1
				group_report.summary.failed = group_report.summary.failed + 1
			end

			for _k, ae in pairs(v.after_eaches) do
				local result, message = pcall(ae)
			end
		end

		table.insert(report.group_reports, group_report)
		for _j, a in pairs(v.afters) do
			local result, message = pcall(a)
		end
	end
	return report
end

return utest
