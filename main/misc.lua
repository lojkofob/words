
GLOB = {
	factories = {},
	input_objects = {},
	states = {},
	constants = {},
	inv_constants = {},
}

require('main.utf8')

function fatal(m) 
	if m then 
		error(m);
	end
	print(debug.traceback())
end

local function gsplit(text, pattern, plain)
	local splitStart, length = 1, #text
	return function ()
		if splitStart then
			local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
			local ret
			if not sepStart then
				ret = string.sub(text, splitStart)
				splitStart = nil
			elseif sepEnd < sepStart then
				-- Empty separator!
				ret = string.sub(text, splitStart, sepStart)
				if sepStart < length then
					splitStart = sepStart + 1
				else
					splitStart = nil
				end
			else
				ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
				splitStart = sepEnd + 1
			end
			return ret
		end
	end
end
 
function StringSplit(text, pattern, plain)
	local ret = {}
	for match in gsplit(text, pattern, plain) do
		table.insert(ret, match)
	end
	return ret
end

function StringTrim(input)
	return input:match("^%s*(.-)%s*$")
end



function _SetGlobal(name, val, replace)
	local arr = StringSplit(name, ';', 1)
	
	for kk, nm in pairs(arr) do

		local arr2 = StringSplit(nm, '.', 1)
		local key = StringTrim(arr2[#arr2])

		table.remove(arr2, #arr2) -- remove last element (key)

		local t = _G
		for k, v in pairs(arr2) do
			if type(t[v]) == "table" then t = t[v];
			else t[v] = {}; t = t[v]; end
		end
		local ex = t[key];
		if replace or ex == nil then
			t[key] = val
		else
			fatal("Failed to set global value '"..name.."': already exist. _G['"..name.."'] = " .. dump(ex))
		end
	end
end

_SetGlobal('nop', function() end)
_SetGlobal('isString', function(s) return type(s)=='string' end)
_SetGlobal('isTable', function(s) return type(s)=='table' end)
_SetGlobal('isFunction', function(s) return type(s)=='function' end)
_SetGlobal('isNumber', function(s) return type(s)=='number' end)
_SetGlobal('isNumeric', function(s) return type(s)=='number' end)
_SetGlobal('isNil', function(s) return type(s)=='nil' end)
_SetGlobal('isBool', function(s) return type(s)=='boolean' end)
_SetGlobal('isObject', function(t) return type(t) == "table" and #t <= 0 end)
_SetGlobal('isArray', function(t) return type(t) == "table" and  #t > 0 end)
_SetGlobal('isset', function(v) return not ((v == nil) or (v == '') or (v == 0)) end)


_SetGlobal('dump', function(v, l)
    local r = {}
    local function dump(v, n)
        local s = ''
        local t = type(v)
        if t == 'table' then if r[v] then return '{...}' end
            r[v] = true
            s = '{'
            local i = 0 local p = ' '
            for tk, tv in pairs(v) do
                if i > 0 then s = s..', ' end
                s = s .. tostring(tk) .. ' = ' .. dump(tv, n + 1)
                i = i + 1
            end
            if not l and i > 0 then s = s .. p end
            s = s .. '}'
        elseif t == 'string' then s = v --  formatString('%q', v)
        elseif t == 'number' or t == 'boolean' or t == 'nil' then s = tostring(v)
        else s = '(' .. tostring(v) .. ')'
        end
        return s
    end
    return dump(v, 0)
end)

_SetGlobal('func.call', function(f, ...)
if isFunction(f) then return f(...) end    
end);

-- Ternary method: local result = trn( a == b, "same", "not same" );
_SetGlobal('trn', function( condition, a, b ) if condition then return a else return b end end)


_SetGlobal('mergeInit', function(self, a) table.merge(self, a); return self; end)


_SetGlobal('setTimeout', function(callback, delay) return timer.delay(delay, false, callback) end)
_SetGlobal('setInterval', function(callback, delay) return timer.delay(delay, true, callback) end)
_SetGlobal('clearTimeout; clearInterval', function(handle) timer.cancel(handle) end)
 
_SetGlobal('disableInput', function(delay, callback) 
	GLOB.input_disabled = (GLOB.input_disabled or 0) + 1
	if delay then
		setTimeout(function()
			GLOB.input_disabled = GLOB.input_disabled - 1    
			if GLOB.input_disabled == 0 then
				GLOB.input_disabled = nil
			end
			func.call(callback)
		end, delay)
	else
		func.call(callback)
	end
end)


-------- class -----------------------------------------------------------------

_SetGlobal('SetMetatableProperties', function(mt, props)
	
	if mt.__props then 
		table.merge(mt.__props, props)
		return
	else
		mt.__props = props;
	end

	local oldindex = mt.__index or function(self,key)
		local v = rawget(self, key) 
		if v ~= nil then
			return v
		else
			return mt[key]
		end
	end

	local oldnewindex = mt.__newindex or function(self, key, value)
		rawset(self, key, value) 
	end

	mt.__index = function(self, key)
		
		local prop = mt.__props[key]
		if prop and prop.get then 
			return prop.get(self) 
		else
			return oldindex(self, key) 
		end
	end

	mt.__newindex = function(self, key, value)
		local prop = mt.__props[key]
		if prop and  prop.set then 
			prop.set(self, value)
		else
			oldnewindex(self, key, value) 
		end
	end
end)


_SetGlobal('ObjectDefineProperties', function(obj, props)
	if isTable(props) then
		local mt = getmetatable(obj)
		SetMetatableProperties(mt, props);
		setmetatable(obj, mt)
	end
end)
 
_SetGlobal('class', function(prototype, props, baseClass)
	prototype = prototype or {}
	if baseClass then
	   if not prototype.new then prototype.new = function(...) return baseClass(...) end end        
	   for k,v in pairs(baseClass) do if not prototype[k] then prototype[k]=v end end
	else
	   if not prototype.new then prototype.new = function(o) return o end end
	end

	local mt = { 
		__call = function(class,...)
			local obj = (class.new and class.new(...)) or {}
			setmetatable(obj, class) 
			return obj 
		end 
	};

	if props then
		SetMetatableProperties(prototype, props)
	else
		prototype.__index = prototype
	end

	setmetatable(prototype, mt)
	
	return prototype
	
end)

_SetGlobal('load_json', function(path)
	local res = sys.load_resource(path);
	if res then
		return json.decode(res);	
	end
end)



require 'main.table'
require 'main.constants'
require 'main.defold'

