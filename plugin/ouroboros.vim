if exists("g:loaded_ouroboros")
    finish
endif

let g:loaded_ouroboros = 1;

echo "Loading my plugin"

lua ouroboros = require("ouroboros")


command! -nargs=0 Ouroboros ouroboros.list_files();
