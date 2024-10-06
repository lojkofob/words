
-------- GameObject class -----------------------------------------------------------------

local factory_url = function(objname)
	return "/factories#"..objname.."_factory"
end

_SetGlobal('showWindow', function(name, z)
	Factory.register(name, c_collection)
	local obj = GameObject.create(name)
	obj.root.position = V3(0,0,z);
	return obj
end)

_SetGlobal('GameObjects', class(
	
	table.map({
		new = function(t)
			local self = { objects = {} }
			table.each(t, function(k, v)
				local o = GameObject(v)
				self.objects[o.name] = o
			end)
			if self.objects.root then
				self.root = self.objects.root;
			end
			return self
		end,
		each = function(self, f)
			for k, v in pairs(self.objects) do 
				f(k, v)
			end
			return self
		end,
		remove = 1, 
		removeAfter = 1,
		animate = 1,
		init = mergeInit
	}, function(key, method)
		if isFunction(method) then 
			return method 
		else
			return function(self, ...)
				for k, v in pairs(self.objects) do 
					v[key](v, ...)
				end
				return self;
			end
		end
	end)

));

local GameObjectProps = { 
	color = {
		get = function(self) 
			if self.c_sprite then
				return self.c_sprite.color
			elseif self.type == c_sprite then
				if self.__color == nil then 
					self.__color = go.get(self.url, tint)
				end
				return self.__color
			end
		end,
		set = function(self, value) 
			if self.c_sprite then
				self.c_sprite.color = value
			elseif self.type == c_sprite then
				self.__color = value
				sprite.set_constant(self.url, tint, value)
			end
		end
	},

	alpha = {
		get = function(self) 
			if self.c_sprite then
				return self.c_sprite.alpha
			elseif self.type == c_sprite then
				return self.color.w
			end
		end,
		set = function(self, value) 
			if self.c_sprite then
				self.c_sprite.alpha = value
			elseif self.type == c_sprite then
				local c = self.color
				c.w = value
				self.color = c
			end
		end
	},

	font_color = {
		get = function(self) 
			if self.c_label then
				return self.c_label.font_color
			elseif self.type == c_label then
				return go.get(self.url, color)
			end
		end,
		set = function(self, value) 
			if self.c_label then
				self.c_label.font_color = value
			elseif self.type == c_label then
				go.set(self.url, color, value)
			end
		end
	},

	img = {
		get = function(self) 
			if self.c_sprite then
				return self.c_sprite.img
			elseif self.type == c_sprite then
				return go.get(self.url, 'animation') 
			end
		end,
		set = function(self, value) 
			if self.c_sprite then
				self.c_sprite.img = value
			elseif self.type == c_sprite then
				msg.post(self.url, "play_animation", {id = hash(value)})  
			end			
		end
	},

	visible = {
		get = function(self) return self.__visible end,
		set = function(self,value)
			self.__visible = isset(value)
			msg.post(self.url, trn(self.__visible, "enable", "disable"))	
		end

	},
	

	inv_matrix_world = {
		get = function(self) 
			if not self.__inv_matrix_world then
				self.__inv_matrix_world = vmath.inv(self.matrix_world)
			end
			return self.__inv_matrix_world
		end
	},

	matrix_world = {
		get = function(self) 
			if self._dirty then
				self.__matrix_world = go.get_world_transform(self.url)
				self.__inv_matrix_world = nil
				self._dirty = nil
			end
			return self.__matrix_world
		end
	},
	
	position = {
		get = function(self) 
			if self.__position == nil then
				self.__position = go.get_position(self.url)
			end
			return self.__position
		end,
		set = function(self, value) 
			self.__position = value
			go.set_position(value, self.url)
			self._dirty = 1
		end
	},

	
	scale = {
		get = function(self) 
			if self.__scale == nil then
				self.__scale = go.get_scale(self.url)
			end
			return self.__scale
		end,
		set = function(self, value) 
			self.__scale = value
			go.set_scale(value, self.url); 
			self._dirty = 1			
		end
	},


	x = {
		get = function(self) return self.position.x end,
		set = function(self, value) local pos = self.position; pos.x = value; go.set_position(pos, self.url); self._dirty = 1 end
	},

	y = {
		get = function(self) return self.position.y end,
		set = function(self, value) local pos = self.position; pos.y = value; go.set_position(pos, self.url); self._dirty = 1 end
	},

	z = {
		get = function(self) return self.position.z end,
		set = function(self, value) local pos = self.position; pos.z = value; go.set_position(pos, self.url); self._dirty = 1 end
	},

	scale_x = {
		get = function(self) return self.scale.x end,
		set = function(self, value) local scale = self.scale; scale.x = value; go.set_scale(scale, self.url); self._dirty = 1 end
	},

	scale_y = {
		get = function(self) return self.scale.y end,
		set = function(self, value) local scale = self.scale; scale.y = value; go.set_scale(scale, self.url); self._dirty = 1 end
	},

	scale_z = {
		get = function(self) return self.scale.z end,
		set = function(self, value) local scale = self.scale; scale.z = value; go.set_scale(scale, self.url); self._dirty = 1 end
	},

	atlas = {
		get = function(self)
			if self.c_sprite then
				return self.c_sprite.atlas
			elseif self.type == c_sprite then
				if self.__atlas == nil then
					local atlas = go.get(self.url, "image")
					self.__atlas = resource.get_atlas(atlas)
				end
				return self.__atlas
			end
		end
	},

	frame = {
		get = function(self)
			if self.__frame == nil then
				local atlas = self.atlas
				self.__frame = false
				if atlas then
					local img = self.img;
					local f = table.find(atlas.animations, function(k, v)
						return hash(v.id) == img
					end)
					if f then
						self.__frame = f
					end
				end
			end
			return self.__frame
		end
	},
	
	size = {
		get = function(self)
			if self.c_sprite then
				local sz = self.c_sprite.size
				if sz then
					local scale = self.scale
					return V3(sz.x * scale.x, sz.y * scale.y, 0)
				end
			elseif self.type == c_sprite then
				local manual_size = go.get(self.url, "size")
				if manual_size then
					return manual_size
				else
					return self.image_size
				end
			end
			
		end,

		set = function(self, value)
			if self.c_sprite then
				self.c_sprite.size = value
			elseif self.type == c_sprite then
				go.set(self.url, "size", value)
			end
		end
	},

	image_size = {
		get = function(self)
			if self.__image_size == nil then
				local frame = self.frame
				if frame then
					self.__image_size = V3( frame.width, frame.height, 0 )
				else
					self.__image_size = false
				end
			end
			return self.__image_size
		end
	},

	text = {
		get = function(self) 
			if self.c_label then
				return self.c_label.text
			elseif self.type == c_label then
				return c_label.get_text(self.url)
			end
		end,
		
		set = function(self, value) 
			if self.c_label then
				self.c_label.text = value
			elseif self.type == c_label then
				label.set_text(self.url, value);
			end
		end
	},

	has_input = {
		get = function(self) return self.__has_input end,
		set = function(self, value) 
			if self.__has_input ~= isset(value)  then
				if value then
					self.__has_input = true
					table.insert(GLOB.input_objects, self);
					GLOB._io_dirty = 1
				else
					self.__has_input = nil
					table.removeObject(GLOB.input_objects, self);
					GLOB._io_dirty = 1
				end
			end
		end
	},
	
	-- like https://www.w3schools.com/jsref/prop_style_transition.asp
	transition = {
		get = function(self) return self.__transition end,
		set = function(self, value) self.__transition = value end
	},

	[ c_shadow ] = {
		get = function(self) return self:getComponent( c_shadow ) end,
		set = function(self, value)
			 local sh = self:getComponent( c_shadow )
			 if sh then
				sh:init(value)
			 end
		end
	},
	
};

-- hack for accept hashed properties ( for set_state with transitions )
table.merge(GameObjectProps, table.mapk(GameObjectProps, function(k, v) return hash(k), v end))
 
local function get_defold_const(k)
	return GLOB.d_h_constants[k] 
end

local _ptg_t = { 
	[color] = c_label, 
	[tint] = c_sprite, 
	[tint_x] = c_sprite,
	[tint_y] = c_sprite,
	[tint_z] = c_sprite,
	[tint_w] = c_sprite
};
 
local _c_t = {
	[ c_shadow ] = c_sprite,
	[ c_sprite ] = c_sprite,
	[ c_label ] = c_label
};

_SetGlobal('GameObject', class(
{
	new = function(_url, _type)

		_type = _type or c_game_object

		if isString(_url) then _url = go.get_id(_url) end 
		local _name = tostring(_url):match("([^%s/]+)]$")
		 
		local self = { url = _url, name = _name, type = _type, _components = {}, _dirty = 1, _states = {} }

		if _type == c_game_object then
			self.c_sprite = GameObject.getComponent(self, c_sprite);
			self.c_label = GameObject.getComponent(self, c_label);
		end

		return self;
	end,

	fire = function(self, e, ...)
		if e then
			local event = self._on[e];
			-- self:print("fire ", e)
			if event then return event(self, ...) end		
		else
			fatal("Fail to fire nil");
		end
	end,

	print = function(self, ...)
		print("[", self.name, "] ", ...)
		return self;
	end,

	on = function(self, action_id, callback)
		
		if not self._on then 
			self._on = {} 
		end	
		if isFunction(callback) then
			self._on[action_id] = callback;
		else
			self._on[action_id] = nil
		end

		self.has_input = not table.empty(self._on)

		return self;
	end,
	
	getUrlWithId = function(self, id)
		local url = msg.url(self.url)
		url.fragment = id;
		return url
	end, 
	
	getComponent = function(self, id)
		if not self._components then self._components = {} end
		if self._components[id] == nil then
			local c_url = GameObject.getUrlWithId(self, id);
			local type = _c_t[id]
			if type then
				if pcall(go.get, c_url, "size") then
					self._components[id] = GameObject(c_url, type)
				end	
			end
		end
		return self._components[id]
	end,

	playVFX = function(self, id)
		self.particles = self:getUrlWithId(id or "particles")
		particlefx.play(self.particles)
	end,

	getByUrl = function(url, type)
		if pcall(go.get, url, "position") then
			return GameObject(url, type)
		end
	end,

	create = function(objname, t, parent, ...) 
		
		local factory = GLOB.factories[objname]

		if not factory then 
			if not isString(objname) then 
				fatal("objname must be a string")
			else
				fatal("No factory for '".. objname .."': create it at main collection with url '"..factory_url(objname).."'. and call Factory.register"  )
			end
			return
		end
		local obj = factory:createGO(...);
		if obj then
			if isTable(t) then
				obj:init(t)
			end
			if parent then
				obj.parent = parent
				if not parent._childs then parent._childs = {} end
				table.insert(parent._childs, obj)
			end
		end
		return obj

	end,

	remove = function(self)
		go.delete(self.url);
		self.has_input = nil
		self.removed = 1
		if self.particles then
			particlefx.stop(self.particles)
		end
		table.each(self._childs, function(k, v)
			v.parent = nil
			v:remove()
		end)
		if self.parent then 
			table.removeObject(self.parent._childs, self)
		end
		self._childs = nil
	end,

	removeAfter = function(self, delay)
		setTimeout(function() self:remove() end, delay)		
	end,

	animate = function(self, prop, playback, value, ease, duration, delay, callback)
		prop = get_defold_const(prop)
		local component = _ptg_t[prop]
		if callback then 
			local o = callback
			callback = function(...)
				self:_invalidate_cache()
				o(...)
			end
		else
			callback = function()
				self:_invalidate_cache()
			end
		end

		local obj
		if component then
			obj = self:getComponent(component)
		else
			obj = self
		end

		if obj then
			go.animate(obj.url, prop, playback, value, ease, duration, delay or 0, callback)
			obj:_invalidate_cache()
		end
		
		return self
	end,

	_invalidate_cache = function(self)
		self.__position = nil
		self.__scale = nil
		self.__color = nil
		self._dirty = 1
		
		table.each(self._components, function(k, v)
			v:_invalidate_cache()
		end)
		
	end,

	cancel_animations = function(self)
		go.cancel_animations(self.url)
		return self
	end,

	hit_test = function(self, projected_pos)
		self._dirty = 1
		local self_size = self.size
		if self_size then
			projected_pos = self.inv_matrix_world * projected_pos
			local w2, h2 = self_size.x / 2, self_size.y / 2
			return (math.abs(projected_pos.x) < w2) and (math.abs(projected_pos.y) < h2)
		end
	end,

	init = mergeInit,

	add_state = function(self, s, t)
		self._states[s] = t
		return self
	end,
 

	set_state = function(self, s, transition)
		
		transition = transition or self.transition
		s = self._states[s] or GLOB.states[s] or s;
		-- self:print('set_state') pprint(s)
		if s then 
			if transition then 
				
				if isTable(transition) then
					table.each(s, function(k, v)
						local tt = transition[k] or transition[ all ] or transition or {}
						self:animate(k, tt.playback or go.PLAYBACK_ONCE_FORWARD, v, tt.easing or go.EASING_INOUTSINE, tt.duration or 0.5, tt.delay or 0)
					end)
				else
					table.each(s, function(k, v)
						self:animate(k, go.PLAYBACK_ONCE_FORWARD, v, go.EASING_INOUTSINE, 0.3, 0)
					end)
				end
				
			else
				self:init(s);
			end
		end
		return self;
	end
},
GameObjectProps));



-------- Factory class -----------------------------------------------------------------

_SetGlobal('Factory', class(
{
	new = function(objname, objtype)
		local o = {
			url = factory_url(objname),
			objname = objname,
			objtype = objtype
		}
		return o;
	end,

	register = function(objname, ...)		
		if not GLOB.factories[objname] then
			GLOB.factories[objname] = Factory(objname, ...);
		end
		return GLOB.factories[objname]
	end,

	createGO = function(self, ...)
		if self.objtype == c_collection then
			return GameObjects(collectionfactory.create(self.url, ...))
		elseif self.objtype == c_game_object then
			return GameObject(factory.create(self.url, ...))
		else
			fatal("No factory for create object with type ", self.objtype)
		end
	end
}));


------------- Module ---------------------------------------------------------------


_SetGlobal('Module', class({

	new = function(name, opts)
		opts = opts or {};
		opts.name = name;
		opts._on = {};
		return opts;
	end,

	fire = function(self, e, ...)
		if e then
			local event = self._on[e];
			-- self:print("fire ", e)
			if event then return event(self, ...) end		
		else
			fatal("Fail to fire nil");
		end
		return self
	end,

	print = function(self, ...)
		print("[", self.name, "] ", ...)
		return self
	end,

	init = function(self, script)
		self:fire(initme, script)
		return self
	end,

	update = function(self, ...)
		self:fire(upd, ...)
		return self
	end,

	input = function(self, script, action_id, action)
		self:fire(action_id, action)
		self:fire(input, action)		
		return self
	end,

	message = function(self, ...)
		self:fire(...)
		return self
	end,

	on = function(self, action_id, callback)

		if not self._on then
			self._on = {}
		end

		if isFunction(callback) then
			self._on[action_id] = callback;

		else
			self._on[action_id] = nil
		end

		return self
		
	end,

	register = function (module, t)
		if isString(module) then
			module = Module(module)
		end
		
		if not isObject(module) or not isString(module.name) then
			error("register_module: bad args")
			return
		end
	
		_SetGlobal(module.name, module)
	
		_G.on_input = function(script, action_id, action) 
			if action_id then
				if action then
					local camera = get_render_state().cameras.camera_world
					action.cam_pos = camera.inv_proj * V4(
						2 * action.screen_x / Screen.real_size.x - 1, 
						2 * action.screen_y / Screen.real_size.y - 1, 0, 1);
				end
		
				if action_id == touch then
					if action.pressed then
						script.is_dragging = true
						action_id = touch_down
					elseif action.released then
						script.is_dragging = false
						action_id = touch_up
					elseif (action.pressed == false and script.is_dragging and action.dx ~= 0 or action.dy ~= 0) then
						action_id = touch_drag
					end
				end
				module:input(script, action_id, action) 
			end
		end
		
		_G.on_message = function(script, message_id, message, sender)
			module:print(message_id, message)
			module:message(script, message_id, message, sender)
		end
	
		_G.update = function(script, dt) module:update(script, dt) end	

		_G.init = function(script)
			module:init(script)
		end

		_G.final = function(script)
			module:fire(destroy)
		end

		table.merge(module, t)
		
		return module
	
	end
}));

 

----------------- InputController ------------------------------------------------------


_SetGlobal('DefaultInputController', class({
	new = function(module)
		local dragged_obj;
		local move_obj;
  
		local pickNode = function(action)
			local pos = action.cam_pos

			if (GLOB._io_dirty) then
				table.sort(GLOB.input_objects, function(a, b)
					return a.z > b.z
				end)
				GLOB._io_dirty = nil
			end

			return table.find( GLOB.input_objects, function(k, v)
				return v:hit_test(pos)
			end)
		end
		
		module:on(touch_up, function(self, action)
			if GLOB.input_disabled then return end
			if down_obj and down_obj.removed then down_obj = nil end
			if down_obj then
				down_obj:fire(touch_up, action)
				down_obj = nil;
			end
		end)
		
		module:on(touch_down, function(self, action)
			if GLOB.input_disabled then return end
			if down_obj and down_obj.removed then down_obj = nil end
			if not down_obj then
				down_obj = pickNode(action)
				if down_obj then
					down_obj:fire(touch_down, action)
					if action.pass then
						down_obj = nil
					end
				end
			end
		end)
		
		module:on(touch_drag, function(self, action) 
			if GLOB.input_disabled then return end
			if down_obj and down_obj.removed then down_obj = nil end
			if move_obj and move_obj.removed then move_obj = nil end

			if down_obj then
				down_obj:fire(touch_drag, action)
			else
				-- action.pass = true
			end

			if action.pass then
				action.pass = nil

				local old_move_obj = move_obj
				local new_move_obj = pickNode(action)
 
				if new_move_obj then
					new_move_obj:fire(touch_enter, action)
					if not action.pass then
						new_move_obj:fire(touch_move, action)
						if not action.pass then
							if new_move_obj ~= old_move_obj then
								if old_move_obj then
									old_move_obj:fire(touch_leave, action)
								end
								move_obj = new_move_obj							
							end
						end
					end
				elseif old_move_obj then
					old_move_obj:fire(touch_leave, action)
					move_obj = nil
				end
			end
		end)
		
	end
}))

