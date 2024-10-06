 
_SetGlobal('Saveerr', class({ 

    new = function(callback)
        return { callback = callback}
    end,

	hide = function(self)
        self.bg2:animate(alpha, go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INSINE, 0.5, 0)

        self.wnd
            :animate(scale, go.PLAYBACK_ONCE_FORWARD, V3(0.7, 0.3, 1), go.EASING_INBACK, 0.4, 0.1)
            :animate(position_y, go.PLAYBACK_ONCE_FORWARD, 300, go.EASING_INBACK, 0.5, 0, 
            function()
                self.saveerr:remove()    
            end)
    
        self.callback()

        return self
	end,

	show = function(self)

        self.saveerr = showWindow('saveerr', 200)

        table.merge(self, self.saveerr.objects)

        self.bg2
            :animate(color, go.PLAYBACK_ONCE_FORWARD, V4(0.1,0.1,0.1,0.7), go.EASING_INSINE, 0.5, 0)
            .alpha = 0

        self.root
            :animate(scale, go.PLAYBACK_ONCE_FORWARD, V3(1, 1, 1), go.EASING_OUTBACK, 0.5, 0)
            .scale = 0.5

        self.button
            :set_state( button )
            :on(touch_down, function()
                self:hide()               
            end)
            .text = "Обновить";

        return self
    end 
}));
