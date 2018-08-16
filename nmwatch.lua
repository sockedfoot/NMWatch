-- NM/PH Watcher
-- Sockfoot/Bismarck
-- 8/15/2018

texts = require('texts')
require('strings')

refresh_time_in_seconds = 5

ph = {
	[1] = {
		wc="Bondman", -- case sensitive but only needs to match, not full name
		id="95", -- last two of ID in hex, use lowercase letters (if any)
		found=0
	},
	[2] = {
		wc="Bondman",
		id="9a",
		found=0
	},
}

nm = {
	[1] = {
		name="Bugbear Strongman", --name only
		found=0,
	}
}

function file_unload(file) -- unset binds, etc
  coroutine.close(co)
end

windower.add_to_chat(0,'NMWatch Loaded!')

function num2hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end

function find_mobs()
	mobs = windower.ffxi.get_mob_array()

	for k,v in pairs(mobs) do
		for key,val in ipairs(ph) do
			if v.name:find(val.wc) and (num2hex(v.id):sub(-2) == val.id) then
				if (v.hpp == 100) and val.found == 0 then
					found_ph(v.name,val.id)
					val.found = 1
				elseif v.hpp == 0 then val.found = 0
				end
			end
		end

		for ke, va in ipairs(nm) do
			if v.name:contains(va.name) then
				if v.hpp == 100 and va.found == 0 then
					found_nm(v.name)
					va.found = 1
				elseif v.hpp == 0 then va.found = 0
				end
			end
		end
	end
end

function found_ph(name, id, found)
	windower.add_to_chat(0,name..' (id: '..id..') found!')
	windower.play_sound(windower.addon_path..'sounds/RAWR.wav')
end

function found_nm(name, found)
	windower.add_to_chat(0,name..' found!')
	windower.play_sound(windower.addon_path..'sounds/RAWR.wav')
end

function do_stuff()
	find_mobs()

	co = coroutine.schedule(do_stuff,refresh_time_in_seconds)
end



do_stuff()