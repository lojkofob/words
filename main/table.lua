
-------- table -----------------------------------------------------------------


_SetGlobal('table.each', function(t, f)
	if type(t) == "table" then 
		if #t > 0 then for k, v in ipairs(t) do f(k, v) end 
		else for k, v in pairs(t) do f(k, v) end end
	end
	return t
end);

_SetGlobal('table.contains', function(t, el) 
	if type(t) == "table" then 
		if #t > 0 then for k, v in ipairs(t) do if v == el then return true end end
		else for k, v in pairs(t) do if v == el then return true end end end
	end
	return false
end);


_SetGlobal('table.find', function(t, f) 
	if type(t) == "table" then 
		if #t > 0 then for k, v in ipairs(t) do if f(k,v) then return v, k end end
		else for k, v in pairs(t) do if f(k,v) then return v, k end end end
	end	
end);


_SetGlobal('table.indexOf', function(t, el) 
	if type(t) == "table" then 
		if #t > 0 then for k, v in ipairs(t) do if v == el then return k end end
		else for k, v in pairs(t) do if v == el then return k end end end
	end
	return -1
end);

_SetGlobal('table.removeObject', function(t, el) 
	if type(t) == "table" then 
		if #t > 0 then for k, v in ipairs(t) do if v == el then table.remove(t, k) end end
		else for k, v in pairs(t) do if v == el then t[k] = nil end end end
	end
	return -1
end);

_SetGlobal('table.map', function(t, f)
	local lt = {}
	if type(t) == "table" then
		if #t > 0 then for k, v in ipairs(t) do table.insert(lt, f(k, v)) end
		else for k, v in pairs(t) do lt[k] = f(k, v) end end    
	end
	return lt
end);


_SetGlobal('table.mapk', function(t, f)
	local lt = {}
	if type(t) == "table" then
		if #t > 0 then for k, v in ipairs(t) do table.insert(lt, f(k, v)) end
		else for k, v in pairs(t) do local kk, vv = f(k, v) lt[kk] = vv end end    
	end
	return lt
end);


_SetGlobal('table.merge', function(t1, t2)
	if type(t1) == "table" and type(t2) == "table" then 
	if #t1 > 0 then
	if #t2 > 0 then for k, v in ipairs(t2) do table.insert(t1, v) end
	else for k, v in pairs(t2) do table.insert(t1, v) end end
	else
	if #t2 > 0 then for k, v in ipairs(t2) do t1[k] = v end
	else for k, v in pairs(t2) do t1[k] = v end end
	end    
	end
	return t1
end);

_SetGlobal('table.clone', function(obj, seen)
	if type(obj) == "table" then
	local s = seen or {}
	if seen and seen[obj] then return seen[obj] end
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	if next(obj) == nil then
	elseif #obj > 0 then 
	for k, v in ipairs(obj) do res[k] = table.clone(v, s) end
	else
	for k, v in pairs(obj) do res[k] = table.clone(v, s) end
	end
	return res
	end
	return obj
end)

_SetGlobal('table.shuffle', function(t) 
	local size = #t
	if size > 1 then
		for i = size, 2, -1 do
			local j = math.random(1, i)
			t[i], t[j] = t[j], t[i]
		end
	end
	return t
end);

_SetGlobal('table.empty', function(t) return next(t) == nil end);

_SetGlobal('table.filter', function(t, f)
	local lt = {}
	if type(t) == "table" then
	if #t > 0 then 
	for k, v in ipairs(t) do if f(k, v) then table.insert(lt, v) end end
	else 
	for k, v in pairs(t) do if f(k, v) then lt[k] = v end end
	end
	end
	return lt
end);

_SetGlobal('table.getTable', function(obj, path, auto_create)
	if isObject(obj) then
	local arr = path;
	if isString(path) then
	arr = path:split('.', 1)
	end    
	local t = obj
	for k, v in ipairs(arr) do
	if type(t[v]) == "table" then 
	t = t[v]
	else
	if auto_create then
	t[v] = {} 
	t = t[v]
	else 
	return nil 
	end
	end
	end
	return t
	end
end);

_SetGlobal('table.getValue', function(obj, path)
	if isObject(obj) then
	local arr = path
	if isString(path) then arr = path:split('.', 1) end
	local key = arr[#arr]
	table.remove(arr, #arr)
	local t = table.getTable(obj, arr, false)
	if t then return t[key] end
	end
end);


_SetGlobal('table.join', function(t, sep)
	sep = sep or ', '
	local result = nil;
	table.each(t, function(k, v)
		if result then
			result = result .. sep
		else
			result = ''
		end
		result = result .. tostring(v)
	end)
	return result or '';
end);

_SetGlobal('table.setValue', function(obj, path, val)
	if isObject(obj) then
	local arr = path
	if isString(path) then arr = path:split('.', 1) end
	local key = arr[#arr]
	table.remove(arr, #arr)
	local t = table.getTable(obj, arr, true)
	if t then t[key] = val end
	end
end);

_SetGlobal('table.len', function(t)
	if type(t) == "table" then 
	local len = #t
	if len == 0 then 
	for k, v in pairs(t) do len = len + 1 end 
	end
	return len
	end
	return 0
end);

_SetGlobal('table.count', function(t, f)
	local res = 0
	if type(t) == "table" then
	if #t > 0 then for k, v in ipairs(t) do if f(k, v) then res = res + 1 end end
	else for k, v in pairs(t) do if f(k, v) then res = res + 1 end end end
	end
	return res
end)

_SetGlobal('table.reduce', function(t, f, acc)
	table.each(t, function(k, v) f(acc, k, v) end)
	return acc
end);