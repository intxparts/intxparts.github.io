--
--  Original code written by rxi:
--      https://github.com/rxi/classic
--
--  Modifications:
--      - style: renamed variables to be consistent with the codebase
--

local obj = {}
obj.__index = obj

function obj:new()
end

function obj:extend()
	local cls = {}
	for k, v in pairs(self) do
		if string.find(k, "__") == 1 then
			cls[k] = v
		end
	end
	cls.__index = cls
	cls.base = self
	setmetatable(cls, self)
	return cls
end

function obj:impl(...)
	for _, cls in pairs({...}) do
		for k, v in pairs(cls) do
			if self[k] == nil and type(v) == "function" then
				self[k] = v
			end
		end
	end
end

function obj:is(T)
	local mt = getmetatable(self)
	while mt do
		if mt == T then
			return true
		end
		mt = getmetatable(mt)
	end
	return false
end

function obj:__tostring()
	return "obj"
end

--
-- Enables using class object as a function that forwards the arguments to its
-- new constructor.
--
function obj:__call(...)
	local o = setmetatable({}, self)
	o:new(...)
	return o
end
