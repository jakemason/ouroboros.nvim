let g:ouroboros_debug = get(g:, 'ouroboros_debug', 0)

" This forces a reload of the plugin when we source it.
" Helps development times tremendously


lua<<EOF
-- uncomment below to allow "source %" to reload the plugin during development
-- require('plenary.reload').reload_module('ouroboros', true)
EOF

lua ouroboros = require("ouroboros")

command! -buffer -nargs=0 Ouroboros lua ouroboros.switch()
