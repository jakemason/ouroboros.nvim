"if exists("g:loaded_ouroboros")
"    finish
"endif
let g:loaded_ouroboros = 1

" This forces a reload of the plugin when we source it.
" Helps development times tremendously
lua<<EOF
require('plenary.reload').reload_module('ouroboros', true)
EOF

echo "Ouroboros loaded"

lua ouroboros = require("ouroboros")

command! -nargs=0 Ouroboros lua ouroboros.list_files()
