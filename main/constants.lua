
local function register(k, v) 
	local val
	if isFunction(v) then
		val = v(k)
	else 
		val = v
	end

	GLOB.constants[k] = val
	GLOB.inv_constants[val] = k
	_SetGlobal(k, val)
	return val, 1
end

table.each({
-- input
	mouse_press = hash,
	mouse_wheel_up = hash,
	mouse_button_left = hash,
	mouse_button_middle = hash,
	mouse_button_right = hash,

	touch = hash,
	touch_multi = hash,

	touch_down = hash,
	touch_drag = hash,
	touch_move = hash,
	touch_leave = hash,
	touch_enter = hash,
	touch_up = hash,
	input = hash,

-- module messages
	destroy = hash,
	initme = hash,
	upd = hash,
	
-- properties
	
	all = hash,

	tint = hash,
	tint_x = hash("tint.x"),
	tint_y = hash("tint.y"),
	tint_z = hash("tint.z"),
	tint_w = hash("tint.w"),

	scale = hash,
	scale_x = hash,
	scale_y = hash,
	scale_z = hash,
	font_color = hash,
	color = hash,
	color_r = hash,
	color_g = hash,
	color_b = hash,
	color_a = hash,
	alpha = hash,

	position = hash,
	position_x = hash,
	position_y = hash,
	position_z = hash,
	
	x = hash,
	y = hash,
	z = hash,

-- components
	c_sprite = hash('sprite'),
	c_label = hash('label'),
	c_shadow = hash('shadow'),
	c_collection = hash('collection'),
	c_game_object = hash,

-- other
	button = hash
	
}, register);


-- animation properties
GLOB.d_h_constants = {}
table.each({

	scale = 'scale',
	scale_x = 'scale.x',
	scale_y = 'scale.y',
	scale_z = 'scale.z',
	font_color = 'color',
	color = 'tint',
	position = 'position',
	position_x = 'position.x',
	position_y = 'position.y',
	position_z = 'position.z',
	x = 'position.x',
	y = 'position.y',
	z = 'position.z',
	color_r = 'tint.x',
	color_g = 'tint.y',
	color_b = 'tint.z',
	color_a = 'tint.w',
	alpha = 'tint.w'

} , function(k, v)

	local h = hash(v)
	GLOB.d_h_constants[k] = h
	GLOB.d_h_constants[hash(k)] = h

end)


_SetGlobal('V3', vmath.vector3)
_SetGlobal('V4', vmath.vector4)

