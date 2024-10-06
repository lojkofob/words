
local mesh = "#mesh"
local position = hash("position")
local thickness = 10
local min_segment_len = 100
local steps = 50

local function binomial(n, i)
    local result = 1
    for j = 1, i do
        result = result * (n - (i - j)) / j
    end
    return result
end
  
local function catmull_rom(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t
    return 0.5 * (
        (2 * p1) +
        (-p0 + p2) * t +
        (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
        (-p0 + 3 * p1 - 3 * p2 + p3) * t3
    )
end
 
local function normalize(v)
	local length = vmath.length(v)
	if length > 0 then
		return v / length
	else
		return V3(0, 0, 0)
	end
end
 

Factory.register('line_cap', c_game_object)

Module.register("Curve", {

	caps = {},

	generate_spline = function(self, points)
		local vertices = {}

		local previous_point = catmull_rom(points[1], points[2], points[3], points[4], -0.001)

		local previous_direction = V3(0,0,0)
		local prev_angle = 1000
		local prev_angle_d = 0

		function gen_vertex(i, j, t)
			local current_point = catmull_rom(points[i-1], points[i], points[i+1], points[i+2], t)

			local direction = current_point - previous_point
			local normal = normalize(V3(-direction.y, direction.x, 0)) * thickness
			local angle = math.atan2(direction.y, direction.x)
			local dangle = angle - prev_angle
			

			if (vmath.length(direction) > min_segment_len) or 
				dangle > 0.1 or
				math.abs(prev_angle_d) > 0.2 or (j < 2) or (j > steps - 2) then

				local top_vertex = current_point + normal
				local bottom_vertex = current_point - normal

				table.insert(vertices, top_vertex.x)
				table.insert(vertices, top_vertex.y)
				table.insert(vertices, top_vertex.z)

				table.insert(vertices, bottom_vertex.x)
				table.insert(vertices, bottom_vertex.y)
				table.insert(vertices, bottom_vertex.z)

				if math.abs(dangle) > 1 then
					self:set_line_cap(current_point)
				end

				previous_point = current_point
				previous_direction = direction
				prev_angle = angle
				
			end
			prev_angle_d = 50 * dangle * dangle + prev_angle_d * 0.2
		end
	
		for i = 2, #points - 2 do
			local m = steps
			if i == #points - 2 then m = steps - 1  end
			for j = 1, steps do
				local t = (j - 1) / m 
				gen_vertex(i,j, t)
			end
		end

		return vertices
	end,


	clear = function(self)
		 
		local buf = buffer.create(1, { { name = position, type=buffer.VALUE_TYPE_FLOAT32, count = 3 } })
		local stream = buffer.get_stream(buf, position)
		local res = go.get(mesh, "vertices")
		resource.set_buffer(res, buf)
			
		table.each(self.caps, function(k, v)
			v.visible = 0;
		end)
	end,

	set_line_cap = function(self, position)
		local cur = self.caps[self.cap_num]
		if cur and vmath.length(cur.position, position) < thickness * 0.2 then return end

		self.cap_num = self.cap_num + 1;
		local cap = self.caps[self.cap_num];
		if not cap then
			cap = GameObject.create('line_cap')
			self.caps[self.cap_num] = cap
			cap.size = V3(thickness*2,thickness*2,0)
			cap.color = V4(0.306, 0.549, 0.741, 1)		
		end
		cap.visible = 1;
		cap.position = position
	end,

	makeline = function(self, action)
		
		if Main.level then 
			local letters = Main.level.selectedStack;
			if letters and (#letters > 0) then 
				
				local p0 = letters[1].position + V3(0,0,20) 
				local mouse = V3(action.cam_pos.x, action.cam_pos.y, p0.z + 20)
				local p1 = (letters[2] or {}).position or mouse
				local points = { p0 }
				table.each(letters, function(k, l)
					table.insert(points, l.position + V3(0,0,20));
				end)
 
				table.insert(points, mouse);
				table.insert(points, mouse);
 
				self.cap_num = 0
				local vertices = self:generate_spline(points)

				-- print(#vertices / 6, self.cap_num)

				self:set_line_cap(mouse)

				for i = self.cap_num + 1, #self.caps do
					self.caps[i].visible = 0
				end
 
				local buf = buffer.create(#vertices / 3, { { name = position, type=buffer.VALUE_TYPE_FLOAT32, count = 3 } })
				local stream = buffer.get_stream(buf, position)
	
				for i = 1, #vertices do
					stream[i] = vertices[i]
				end
	
				local res = go.get(mesh, "vertices")
				resource.set_buffer(res, buf)
	
				return true
			end
		end

		
	end,

	updateline = function(self, action)
		if self:makeline(action) then
			self.has_points = true
		elseif self.has_points then
			self:clear()
			self.has_points = nil
		end  
	end
})
:on( touch_drag, function(self, action)
	self:updateline(action)
end)
:on( destroy, function(self, action)
	table.each(self.caps, function(k, v)
		v:remove()
	end)
	self.caps = {}
end)
:on( touch_up, function(self, action)
	setTimeout(function()
		self:updateline(action)	
	end, 0.01)
end)
:on( initme, function()
	msg.post(".", "acquire_input_focus")
end)




