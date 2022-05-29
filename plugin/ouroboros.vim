if exists("g:loaded_ouroboros")
    finish
endif

let g:loaded_ouroboros = 1;

echo "Loading my plugin"

command! -nargs=0 Ouroboros lua require("ouroboros").list_files();
