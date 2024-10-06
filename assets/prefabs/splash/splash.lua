_SetGlobal('Splash', class({ 

	hide = function(self)
		
		self.logo:animate( position_y, go.PLAYBACK_ONCE_FORWARD, 1000, go.EASING_INBACK, 0.9, 0)
		self.words_logo:animate( position_y, go.PLAYBACK_ONCE_FORWARD, -1000, go.EASING_INSINE, 0.9, 0)

		self.splashscreen
			:each(function(k, v)
				v:animate(alpha, go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 1, 0)
			end)
			:removeAfter(1)    
	end,

	show = function(self, callback)
		
		self.splashscreen = showWindow('splash', 50);
        table.merge(self, self.splashscreen.objects)

		setTimeout(function()
			self:hide()
			callback()
		end, 1)

	end

}));
