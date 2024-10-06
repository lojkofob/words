 
_SetGlobal('Congrat', class({

    new = function(level, callback)
        return {
            level = level,
            callback = callback
        }
    end,

    hide = function(self)
        self.title:animate( position_y, go.PLAYBACK_ONCE_FORWARD, 1000, go.EASING_INBACK, 0.4, 0)
        self.title2:animate( position_y, go.PLAYBACK_ONCE_FORWARD, 1500, go.EASING_INBACK, 0.4, 0)
        self.bg2:animate(alpha, go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 0.3, 0)
        self.button:animate( position_y, go.PLAYBACK_ONCE_FORWARD, -1000, go.EASING_INBACK, 0.4, 0, function()
            self.congrat:remove()
        end)        
        self.callback()
    end,

    show = function(self)
         
        self.congrat = showWindow('congrat', 100)

        table.merge(self, self.congrat.objects)

        self.title.text = "Уровень " .. self.level .. " пройден"
    
        local y = self.title.y; self.title.y = self.title.y + 100
        self.title:animate( position_y, go.PLAYBACK_ONCE_FORWARD, y, go.EASING_OUTBACK, 0.6, 0)
    
        y = self.title2.y; self.title2.y = self.title2.y + 50
        self.title2:animate( position_y, go.PLAYBACK_ONCE_FORWARD, y, go.EASING_OUTBACK, 0.4, 0)
    
        y = self.button.y; self.button.y = self.button.y - 100
        self.button:set_state( button )
            :animate( position_y, go.PLAYBACK_ONCE_FORWARD, y, go.EASING_OUTBACK, 0.5, 0)
        
        self.button
            :on(touch_down, function()
                self:hide()
            end)
            .text = "Уровень " .. (self.level + 1);
    
        self.bg2.alpha = 0
        self.bg2:animate(alpha, go.PLAYBACK_ONCE_FORWARD, 1, go.EASING_LINEAR, 0.3, 0)
    
        self.root:playVFX()


    end
}));