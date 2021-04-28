local Tables = {}

local green     = "#2bbb4f"	--> "#6ed57e"
local violet    = "#986fec"
local blue      = "#4799eb"	--> "#03353e"
local yellow    = "#fff94c"	--> "#ffd55b"
local black     = "#000000"
local red       = "#e27d60"

Tables.getModeColor = {
     ['n']    =  green,
     ['v']    =  blue,
     ['V']    =  blue,
     ['i']    =  violet,
     ['ic']   =  violet,
     ['c']    =  red,
     ['t']    =  yellow,
     ['r']    =  yellow,
     ['R']    =  yellow
}

Tables.getFileIcon = {
     typescript = ' ' ,
     python     = ' ' ,
     html       = ' ' ,
     css        = ' ' ,
     javascript = ' ' ,
     jsx        = ' ' ,
     markdown   = ' ' ,
     sh         = ' ',
     vim        = ' ',
     rust       = ' ',
     cpp        = ' ',
     c          = ' ',
     go         = ' ',
     lua        = ' ',
     conf       = ' ',
	 txt	    = ' '
}

Tables.modes = {
     ['n']   = ' ',
     ['v']   = ' ',
     ['V']   = ' ',
     ['i']   = ' ',
     ['ic']  = '',
     ['c']   = ' ',
     ['r']   = 'Prompt',
     ['t']   = 'T',
     ['R']   = ' ',
     ['^V']  = ' '
}

return Tables
