print('words game')
print('https://t.me/eshpengler')
print('https://github.com/lojkofob/words.git')


table.merge( GLOB.states, {
    [ button ] = { 
       [ color ] = V4(0.396, 0.741, 0.396, 1),
       [ font_color ] = V4(1, 1, 1, 1),

       [ c_shadow ] = {
            [ color ] = V4(0.314, 0.533, 0.325, 1)
       }
    }
});


GLOB.PlayerState = {
    l = 1
};

GLOB.session_num = 0;

Module.register('Main', {

    startLevel = function(self)
            
        if self.level then
            self.level:remove()
        end
        
        self.level = Level({ 
            level_index = GLOB.PlayerState.l,
            on_complete = function(level)
                self.level = nil
                disableInput(2, function()
                    level:remove()
                end)
                local lev = GLOB.PlayerState.l 

                GLOB.PlayerState.l = GLOB.PlayerState.l + 1;
                GLOB.PlayerState.w = nil

                setTimeout( function()
                    self.congrat = Congrat(lev, function ()
                        self:startLevel()
                        self.congrat = nil
                    end):show()

                end, 1)
                
            end
        });
        
    -- setTimeout(function() self.level:on_complete() end, 2)
    
    end,
 
    get_session_num = function(self)
        if html5 then
            local snum = html5.run("localStorage.getItem('session_num')")
            if isset(snum) and isString(snum) then
                snum = tonumber(snum)
                if snum and snum > 0 then
                    return snum
                end
            end
        end
        return GLOB.session_num
    end,

    set_session_num = function(self, snum)
        if html5 then
            html5.run("localStorage.setItem('session_num', '"..snum.."')")
        end
        GLOB.session_num = snum
    end,

    check_state = function(self)
         
        local sess = self:get_session_num()

        if html5 then
            if GLOB.session_num > 0 then 
                if sess > GLOB.session_num then
                    Saveerr(function()
                        html5.run("window.location.reload()")
                    end):show()
                    return
                end
            else 
                window.set_listener(function(w, event)
                    if event == window.WINDOW_EVENT_FOCUS_GAINED then
                        self:check_state()
                    end
                end)
            end
 
        end
        
        if GLOB.session_num == 0 then
            self:set_session_num(sess + 1)
        end

        local state = self:load_state()
        if state and (state.l or 0) > 0 then
            GLOB.PlayerState = state
        end
        if not self.level then
            self:startLevel()
        end

    end,
 
    load_state = function(self)
        return sys.load(sys.get_save_file("sys_save_load", "ps")) 
    end,
 
    save_state = function(self)
        local filename = sys.get_save_file("sys_save_load", "ps")
        sys.save(filename, GLOB.PlayerState)
    end 

}):on(initme, function(self, script)
    self.splash = Splash()
    self.splash:show(function()
        self.input_controller = DefaultInputController(self);
        self.splash = nil
        self:check_state()
    end) 
        
    msg.post(".", "acquire_input_focus")
end)
