

-- css
local selected = hash('letter_selected')
local unselected = hash('letter_unselected')
local failed = hash('letter_failed')
local success = hash('letter_success')
local solved = hash('letter_solved')



_SetGlobal('Level', class({

	new = function(self)

		Factory.register('letter', c_game_object)
		Factory.register('letter_bottom', c_game_object)

		self.level = showWindow('level', 0)

		Level.read_config(self)
		Level.fill_top(self)
		Level.fill_bottom(self)
		Level.init_controller(self)

		self.level.objects.title.text = "Уровень " .. self.level_index

		return self
	end,

	read_config = function(self)

		local path = "/res/levels/".. (((self.level_index - 1) % 3) + 1) ..".json";

		self.config = load_json(path);

		if not isTable(self.config) or not isTable(self.config.words) then
			fatal("bad config for level ", path)
			return
		end

		self.words_dict = {}

		self.words = table.map(self.config.words, function(k, word)
			local letters = {}
			local letters_list = {}
			word = utf8_to_upper(word)
			local len = utf8_len(word)
			for i = 1, len do
				local letter = utf8_sub(word, i)
				letters[letter] = (letters[letter] or 0) + 1
				table.insert(letters_list, letter)
			end
			local l = {
				text = word,
				len = len,
				letters = letters,
				letters_list = letters_list,
				index = k,
				solved = GLOB.PlayerState.w and table.contains(GLOB.PlayerState.w, k)
			}
			self.words_dict[word] = l;
			return l
		end)

		-- make all letters
		self.config.all_letters = {}

		table.each(self.words, function(k, word)
			table.each(word.letters, function(letter, count)
				if count > (self.config.all_letters[letter] or 0) then
					self.config.all_letters[letter] = count;
				end
			end)
		end)

		table.sort(self.words, function(a, b)
			return a.len < b.len
		end)


	end,

	fill_bottom = function(self)

		self.bottom_letters = {}
		
		table.each(self.config.all_letters, function(letter, c)
			for i=1,c do
				local letterObj = GameObject.create("letter_bottom", {
					text = letter,
					letter = letter,
					name = "bottom_letter_" .. letter,
					__selected = false,
					[ c_shadow ] = {
						color = V4(0.5, 0.5, 0.5, 1)
					}
				}, self.level.root);

				table.insert(self.bottom_letters, letterObj);
			end
		end)

		table.shuffle( self.bottom_letters );

		local bottom = self.level.objects.bottom
		bottom.color = V4(0.243, 0.29, 0.408, 1)

		local bottom_size, bottom_scale = self.bottom_size, self.bottom_scale
		local radius_x, radius_y = bottom_size.x / 2 - 10 * bottom_scale.x, bottom_size.y / 2 - 10 * bottom_scale.y;

		local center = bottom.position;
		local count = #self.bottom_letters

		table.each(self.bottom_letters, function(k, v)
			local angle = -(k - 1) * (2 * math.pi / count)
			local x = center.x + radius_x * math.cos(angle)
			local y = center.y + radius_y * math.sin(angle)
			v.scale = V3(0.001,0.001,1)
			v.position = V3(x, y, 0.99)
			v:animate(scale, go.PLAYBACK_ONCE_FORWARD, bottom_scale,  go.EASING_OUTBACK, 0.2, k/20 + 0.5)
		end)

		bottom.scale = V3(0.001,0.001,1)
		bottom:animate(scale, go.PLAYBACK_ONCE_FORWARD, bottom_scale,  go.EASING_OUTBACK, 0.2, 0.2)
	end,

	fill_top = function(self)
 
		local top = self.level.objects.top
		local mid = self.level.objects.mid
		local bottom = self.level.objects.bottom
		local grid_size = V3(110, 110, 0);

		mid.alpha = 0;
		top.alpha = 0;
		
		function update_layout(new_top_h)
			 
			local k = 0.22
			local top_y = top.y
			local top_h = top.size.y
			local bottom_y = bottom.y
			local bottom_h = bottom.size.y
			local delta_top_h = k * (new_top_h - top_h)
			local new_top_y = top_y - delta_top_h / 2
			local new_top_h = top_h + delta_top_h
			local new_bottom_y = bottom_y - delta_top_h / 2
			local new_bottom_h = bottom_h - delta_top_h * 0.8
	
			bottom.y = new_bottom_y
			top.y = new_top_y
			mid.y = (new_bottom_y + new_bottom_h / 2 + new_top_y - new_top_h / 2) * 0.45

			local top_scale = (new_top_h / top_h)
			local bottom_scale = (new_bottom_h / bottom_h)

			top.scale = V3(top_scale, top_scale, 1)
			bottom.scale = V3(bottom_scale, bottom_scale, 1)

			local letter_scale = new_top_h / #self.words / grid_size.x
			grid_size = grid_size * letter_scale

			return letter_scale
		end

		
		local letter_scale = update_layout(#self.words * grid_size.y)

		letter_scale = V3( letter_scale, letter_scale, 1 );
		
		self.bottom_scale = bottom.scale * 1
		self.bottom_size = bottom.size
		
		local center = top.position;
		local y = center.y + (#self.words - 1) * grid_size.y / 2;
		
		table.each(self.words, function(k, word)
			local x = center.x - (#word.letters_list - 1) * grid_size.x / 2;
			word.letterObjs = {}
			table.each(word.letters_list, function(k, letter)
				local letterObj = GameObject.create("letter", {
					text = letter,
					letter = letter,
					scale = letter_scale * 1,
					name = "top_letter_" .. letter,
					position = V3( x, y * 1.1 - 100, 0.001 ),
					alpha = 0,
					font_color = V4(1, 1, 1, 0)
				}, self.level.root);
				x = x + grid_size.x;				
				table.insert( word.letterObjs, letterObj )

				letterObj:animate(position_y, go.PLAYBACK_ONCE_FORWARD, y, go.EASING_INSINE, 0.3, 0.3)
						 :animate(alpha, go.PLAYBACK_ONCE_FORWARD, 1, go.EASING_INSINE, 0.3, 0.3)
						 
			end)
			y = y - grid_size.y;
		end)

		return self
	end,

	init_controller = function(self)

		local selectedStack = {}
		self.selectedStack = selectedStack;

		local grid_size = V3(110, 110, 0);
		
		local bottom = self.level.objects.bottom
		local bottom_scale = self.bottom_scale
		local selected_scale = bottom_scale * 0.8;
		
		grid_size.x = grid_size.x * selected_scale.x
		grid_size.y = grid_size.y * selected_scale.y
 
		table.merge( GLOB.states, {
			[ selected ] = { 
				[ color ] = V4(0.914, 0.435, 0.643, 1),
				[ font_color ] = V4(1, 1, 1, 1),
				[ scale ] = bottom_scale * 1.15
			},
			[ unselected ] = {
				[ color ] = V4(1, 1, 1, 1),
				[ font_color ] = V4(0.35, 0.35, 0.36, 1),
				[ scale ] = bottom_scale
			},
			[ failed ] = {
				[ color ] = V4(1, 0, 0, 1),
				[ font_color ] = V4(1, 1, 1, 1),
				[ scale ] = selected_scale * 1.1
			},			
			[ success ] = {
				[ color ] = V4(0.396, 0.741, 0.396, 1),
				[ font_color ] = V4(1, 1, 1, 1),
				[ scale ] = selected_scale * 1.1
			},
			[ solved ] = {
				[ color ] = V4(0.396, 0.741, 0.396, 1),
				[ font_color ] = V4(1, 1, 1, 1)
			}
		});
		-- 
		
		local y = self.level.objects.mid.y;

		function get_selected_word()
			return table.join(table.map( selectedStack, function (k, v) return v.letter; end), '')
		end

		function on_word_already_solved(word)
			table.each(word.letterObjs, function(k, v)
				v:animate(color, go.PLAYBACK_ONCE_PINGPONG, V4(1, 0.2, 0.2, 1), go.EASING_INOUTSINE, 0.6 )
				 :animate(scale, go.PLAYBACK_ONCE_PINGPONG, v.scale * 1.1, go.EASING_INOUTBACK, 0.6 )
			end)
		end

		function on_word_solved(word)
			
			table.each(selectedStack, function(k, v)
				local selectedObj = v.selectedObj
				local let = selectedObj.letter

				local top_letter = table.find(word.letterObjs, function(k, v)
					return v.letter == let and not v.solved
				end)

				top_letter.solved = true

				setTimeout(function()
					selectedObj
						:set_state(success, 1)
						:animate(scale, go.PLAYBACK_ONCE_FORWARD, top_letter.scale,  go.EASING_INOUTBACK, 0.3)
						:animate(position, go.PLAYBACK_ONCE_FORWARD, top_letter.position, go.EASING_INOUTSINE, 0.3, 0, function()
							top_letter:set_state(solved, 1)
								:animate(scale_y, go.PLAYBACK_ONCE_PINGPONG, 0, go.EASING_INOUTSINE, 0.1 )
							selectedObj:remove()
						end)
				end, k / 10)
				
				v.selectedObj = nil	
			end)

			
		end

		function on_word_fail()
			local x = -(#selectedStack - 1) * grid_size.x / 2
			table.each(selectedStack, function(k, v)
				local selectedObj = v.selectedObj 
				selectedObj.x = x
				selectedObj
					:set_state(failed, 1)
					:animate(position_x, go.PLAYBACK_LOOP_PINGPONG, x + 20, go.EASING_INOUTSINE, 0.2, 0.2)
				setTimeout(function()
					selectedObj
						:cancel_animations()
						:animate(scale, go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 0.1, k/20, function ()
							selectedObj:remove()
						end)					
				end, 0.6)
				x = x + grid_size.x;
				v.selectedObj = nil	
			end)
		end

		function check_word()
			local word = self.words_dict[get_selected_word()]

			if word then
				if word.solved then
					on_word_already_solved(word)
				else
					on_word_solved(word)
					word.solved = true

					if not GLOB.PlayerState.w then
						GLOB.PlayerState.w = {}
					end

					table.insert(GLOB.PlayerState.w, word.index)

					self.solved = (self.solved or 0) + 1
					if self.solved == #self.words then 
						self:on_complete()
					end
					
					Main:save_state()

				end				
			else
				on_word_fail(word)
			end
			table.each(self.bottom_letters, function(k, letterObj)
				letterObj.selected = 0
			end)
			
		end



		local on_stack_changed = function(letterObj)
			
			if letterObj.selected then
				letterObj.index = #selectedStack
				table.insert(selectedStack, letterObj)

				local letter = letterObj.letter
				letterObj.selectedObj = GameObject.create("letter", {
					text = letter,
					letter = letter,
					font_color = V4(00.35, 0.35, 0.36, 1),
					scale = V3(0.01,0.01,1),
					name = "mid_letter_" .. letter,
					y = y,
					x = (#selectedStack + 1) * grid_size.x / 2
				}, self.level.root)
				
				:animate(scale, go.PLAYBACK_ONCE_FORWARD, selected_scale, go.EASING_OUTBACK, 0.3, 0);
				
				-- print('------ 1 --------', letterObj.name, letterObj.selectedObj);

			elseif #selectedStack > 0 then
				local selectedObj = letterObj.selectedObj
				-- print('------ 0 --------', letterObj.name, letterObj.selectedObj);

				if selectedObj then
					selectedObj:animate(scale, go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 0.1, letterObj.index/20, function ()
									selectedObj:remove()
								end)
					letterObj.selectedObj = nil
				end
				table.removeObject(selectedStack, letterObj)
			end

			-- adjust x
			if not self.updtm then
				self.updtm = setTimeout(function()
					self.updtm = nil
					local x = -(#selectedStack - 1) * grid_size.x / 2
					table.each(selectedStack, function(k, v)
						v.selectedObj:animate(position_x, go.PLAYBACK_ONCE_FORWARD, x, go.EASING_INOUTSINE, 0.2 )
						x = x + grid_size.x;
					end)
				end, 0.001)
			end
			
		end

		table.each(self.words, function(k, word)
			if word.solved then
				self.solved = (self.solved or 0) + 1
				table.each(word.letterObjs, function(k, l)
					l:set_state(solved)
				end)
			end
		end)

		table.each(self.bottom_letters, function(k, letterObj)

			letterObj:set_state(unselected)

			ObjectDefineProperties( letterObj, 
				{
					selected = {
						get = function(this) return this.__selected end,
						set = function(this, value) 
							value = isset(value)
							if this.__selected ~= value then
 								this.__selected = value
								this:set_state(trn(value, selected, unselected), 1)
								on_stack_changed(this);
							end
						end
					}
				}
			);
			
			letterObj
				:on(touch_down, function(this, action)
					this.selected = 1
				end)
				:on(touch_drag, function(this, action)	
					this.selected = 1
					action.pass = 1
				end)
				:on(touch_enter, function(this, action)	
					
					if this.selected and #selectedStack > 1 and selectedStack[#selectedStack - 1] == this then
						selectedStack[#selectedStack].selected = 0
					else
						this.selected = 1
					end

				end)
				:on(touch_leave, function(this, action)	
					
				end)
				:on(touch_move, function(this, action)
					this.selected = 1
				end)
				:on(touch_up, function(this)
					check_word()
				end)
		end)
		
	end,

	remove = function(self)
		self.level:remove()
	end	

}));