local timer = {}
timer.__index = timer

function timer.ctime(callable)
	local t_start = os.clock()
	callable()
	local t_end = os.clock()
	return t_end - t_start
end

function timer.time(callable)
	local t_start = os.time()
	callable()
	local t_end = os.time()
	return os.difftime(t_end, t_start)
end

return timer
