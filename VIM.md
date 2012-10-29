- <Leader> tr Files in each tab
- <Leader>rt Source code browser (tree)
- Ctrl+t Fuzzy finder for files
NERDCommenter
- <Leader>cc Coment the current line or selected visual mode
- <Leader>c<space> Comment toggle
NarrowRegion
- :[range]NR[!] Narrows selected region
ZoomWindow
- <Leader>zw Zooms into the seledted file in a splited window
BufferGator
- <Leader>b Presents a catalog
- Ctrl+p Walk down the buffers
Vroom
- <Leader>r Run tests on the current file
- <Leader>R Run the closest test of the file

- <leader>ew expands to :e (directory of current file)/ (open in the current buffer)
- <leader>es expands to :sp (directory of current file)/ (open in a horizontal split)
- <leader>ev expands to :vsp (directory of current file)/ (open in a vertical split)
- <leader>et expands to :tabe (directory of current file)/ (open in a new tab)
- :w!! expands to %!sudo tee > /dev/null %. Write to the current file using sudo (if you forgot to run it with sudo), it will prompt for sudo password when writing
- <F4> toggles paste mode
- <leader>fef formats the entire file
- <leader>u converts the entire word to uppercace
- <leader>l converts the entire word to lowercase
- <leader>U converts the first char of a word to uppercase
- <leader>L converts the first char of a word to lowercase
- <leader>cd changes the path to the active buffer's file
- <leader>md creates the directory of the active buffer's file (For example, when editing a new file for which the path does not exist.)
- gw swaps the current word with the following word
- <leader>ul underlines the current line with =
- <leader>tw toggles wrap
- <leader>fc finds the next conflict marker (tested with Git conflicted files)
- Remap <Down> and <Up> to gj and gk (Wrapped text is not considered a single long line of text.)
- <leader>hs toggles highlight search
- <leader>= adjusts viewports to the same size (<C-w>=)
- <A-[ (<D-[ on MacVim) shifts current line or selected lines rightwards
- <A-] (<D-] on MacVim) shifts current line or selected lines leftwards
- <C-W>! invokes kwbd plugin; it closes all open buffers in the open windows but keeps the windows open
