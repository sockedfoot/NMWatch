_addon.version = '1.0'
_addon.name = 'NMWatch'
_addon.author = 'sockfoot/bismarck'
_addon.commands = {'nmw', 'nmwatch'}

texts = require('texts')
require('strings')
--config = require('config')

refresh_time_in_seconds = 5
color = 123

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

windower.register_event('addon command', function(...)
    command = arg

    if command[1] == 'add' then
		if command[2] == 'ph' then
      		if command[3] and command[4] then
      			add_ph(command[3],command[4])
      		else
      			report('Invalid syntax, use: //nmw add ph <match> <last two of hex ID>')
      			report('e.g. for Bugbear Bondman: //nmw add ph Bondman 9a')
      			report('<match> is case-sensitive and the <hex ID> needs to have lowercase letters if applicable')
      		end

  		elseif command[2] == 'nm' then
  			if command[3] then
  				add_nm(command[3])
  			else		
  				report('Invalid syntax, use: //nmw add nm <nm name>')
  				report('Can be full name or a match, is case-sensitive')
  				report('e.g. for Bugbear Strongman (use quotes on names with >1 word): //nmw add nm "Bugbear Strongman"')
  			end
      	end
    elseif command[1] == 'reload' then
      	windower.send_command('lua r nmwatch')
  	elseif command[1] == 'clear' then
  		ph = {}
  		nm = {}
	elseif command[1] == 'help' then
		help()
    elseif command[1] == 'list' then
	  	list()
    end
end)

function report(msg)
	windower.add_to_chat(color,'NMWatch: '..msg)
end

windower.add_to_chat(color,'NMWatch Loaded!')

function help()
	report('Use //nmw <commands> to interface')
	report('Commands: add ph, add nm, list, clear, reload, help')
	report('add ph <match> <last two of hex ID>')
	report('add nm <nm name>')
end

help()

function add_ph(match, hex)
	ph[#ph+1] = {wc=match,id=hex,found=0}
	report(match..' has been added to PH #'..#ph+1)
end

function add_nm(match)
	nm[#nm+1] = {name=match,found=0}
	report(match..' has been add to NM #'..#nm+1)
end



function list()
	for k,v in ipairs(ph) do
		report('NMWatch: PH #'..k..': '..v.wc..' (id: '..v.id..')')
	end

	for k,v in ipairs(nm) do
		report('MNWatch: NM #'..k..': '..v.name)
	end
end

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
	report(name..' (id: '..id..') found!')
	windower.play_sound(windower.addon_path..'sounds/RAWR.wav')
end

function found_nm(name, found)
	report(name..' found!')
	windower.play_sound(windower.addon_path..'sounds/RAWR.wav')
end

function do_stuff()
	find_mobs()

	co = coroutine.schedule(do_stuff,refresh_time_in_seconds)
end



do_stuff()