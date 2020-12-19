local constants = require('constants')

local schema = {}
schema.__index = schema

schema.types = {
	bool	= 1,
	int		= 2,
	float	= 3,
	string	= 4,
	table	= 5
}

function schema.int(required, nullable, min, max, allowed, forbidden)
	return {
		type = schema.types.int,
		required = required or false,
		nullable = nullable or false,
		min = min or constants.minint,
		max = max or constants.maxint,
		allowed = allowed,
		forbidden = forbidden
	}
end

function schema.float(required, nullable, min, max, allowed, forbidden)
	return {
		type = schema.types.float,
		required = required or false,
		nullable = nullable or false,
		min = min or -math.huge,
		max = max or math.huge,
		allowed = allowed,
		forbidden = forbidden
	}
end

function schema.string(required, nullable, allowed, forbidden)
	return {
		type = schema.types.string,
		required = required or false,
		nullable = nullable or false,
		allowed = allowed,
		forbidden = forbidden
	}
end

function schema.bool(required, nullable)
	return {
		type = schema.types.bool,
		required = required or false,
		nullable = nullable or false
	}
end

function schema.table(required, nullable)

end

function schema.new(t, strict)
	local s = {}
	s._schema = t or {}
	s._strict = strict or false
	setmetatable(s, schema)
	return s
end

function schema.is_valid_int(field_name, int_schema, value)
	local is_valid = true
	local errors = {}
	
	if value < int_schema.min then
		is_valid = false
		errors.insert(string.format('value out of bounds (less than min) for field: %q, where value: %d, min: %d', field_name, value, int_schema.min))
	end

	if value > int_schema.max then
		is_valid = false
		errors.insert(string.format('value out of bounds (greater than max) for field: %q, where value: %d, max: %d', field_name, value, int_schema.max))
	end

	if int_schema.allowed ~= nil then
	end
	

	return is_valid, errors
end

function schema.is_valid_float(float_schema, value)

end

function schema.is_valid_string(string_schema, value)

end

function schema.is_valid_bool(bool_schema, value)

end

function schema.is_valid_table(table_schema, tbl)
	local is_valid = true
	local errors = {}

	for field_name, field in pairs(table_schema) do
		local field_errors = {}

		if not field.nullable and tbl[field_name] == nil then
			if field.required then
				field_errors.insert(string.format('required field missing: %q', field_name))
			else
				field_errors.insert(string.format('non-nullable field is nil: %q', field_name))
			end
			
		end

		local type_validation_fn = type_validation_fn_map[field.type]
		local is_valid_type, type_errors = type_validation_fn(field, tbl[field_name])
		for _, v in pairs(type_errors) do
			field_errors.insert(v)
		end

		is_valid = is_valid and is_valid_type
		errors[field_name] = field_errors
		::continue::	
	end

	return is_valid, errors
end

local type_validation_fn_map = {
	[schema.types.int] = schema.is_valid_int,
	[schema.types.float] = schema.is_valid_float,
	[schema.types.string] = schema.is_valid_string,
	[schema.types.bool] = schema.is_valid_bool,
	[schema.types.table] = schema.is_valid_table,
}

function schema:is_valid()
	return schema.is_valid_table(self._schema, self)
end

function schema:validate()
	local is_valid, errors = self.is_valid()
	assert(is_valid)
end

return schema
