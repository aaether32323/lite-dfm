" Remember user's default values.
let s:laststatus_default = &laststatus
let s:ruler_default = &ruler
let s:number_default = &number
let s:foldcolumn_default = &foldcolumn
let s:numberwidth_default = &numberwidth


" See if running CLI or GUI Vim.
let s:context = has('gui_running') ? 'gui' : 'cterm'


" Retrieves the color for a provided scope and swatch in the current context.
function! s:LoadColor(scope, swatch)
  let scopeColor = synIDattr(hlID(a:scope), a:swatch, s:context)
  return scopeColor < 0 ? 'none' : scopeColor
endfunction


" Generates a highlight command for the provided scope, foreground, and
" background.
function! s:Highlight(scope, fg, bg)
  return 'highlight ' . a:scope . ' ' . s:context . 'fg=' . a:fg . ' ' . s:context . 'bg=' . a:bg
endfunction


" Generate a highlight string to hides the given scope by setting its
" foreground and background the match the normal background.
function! s:Hide(scope)
  return s:Highlight(a:scope, s:NormalBG, s:NormalBG)
endfunction


" Generate a highlight string to restore the given scope to its original
" foreground and background values.
function! s:Restore(scope)
  return s:Highlight(a:scope, s:[a:scope . 'FG'], s:[a:scope . 'BG'])
endfunction

function! s:ForEachWindow(cmd)
  let currwin=winnr()
  execute 'windo ' . a:cmd
  execute currwin . 'wincmd w'
endfunction

" Load all necessary colors and assign them to script-wide variables
function! LoadDFMColors()
  let s:NormalBG = s:LoadColor('Normal', 'bg')
  let s:LineNrFG = s:LoadColor('LineNr', 'fg')
  let s:LineNrBG = s:LoadColor('LineNr', 'bg')
  let s:NonTextFG = s:LoadColor('NonText', 'fg')
  let s:NonTextBG = s:LoadColor('NonText', 'bg')
  let s:FoldColumnFG = s:LoadColor('FoldColumn', 'fg')
  let s:FoldColumnBG = s:LoadColor('FoldColumn', 'bg')
  if (exists('g:lite_dfm_normal_bg_' . s:context))
    " Allow users to manually specify the color used to hide UI elements
    let s:NormalBG = has('gui_running') ? g:lite_dfm_normal_bg_gui : g:lite_dfm_normal_bg_cterm
  endif
endfunction


" Function to enter DFM
function! LiteDFM()
  let s:lite_dfm_on = 1
  set noruler
  set number
  set laststatus=0
  execute s:ForEachWindow('set numberwidth=10 foldcolumn=12')
  execute s:Hide('LineNr')
  execute s:Hide('NonText')
  execute s:Hide('FoldColumn')
endfunction


" Function to close DFM
function! LiteDFMClose()
  let s:lite_dfm_on = 0
  let &ruler = s:ruler_default
  let &number = s:number_default
  let &laststatus = s:laststatus_default
  execute s:ForEachWindow('set numberwidth=' . s:numberwidth_default . ' foldcolumn=' . s:foldcolumn_default)
  execute s:Restore('LineNr')
  execute s:Restore('NonText')
  execute s:Restore('FoldColumn')
endfunction


" Function to toggle DFM
function! LiteDFMToggle()
  if !exists('s:lite_dfm_on')
    let s:lite_dfm_on = 0
  endif
  if s:lite_dfm_on
    call LiteDFMClose()
  else
    call LiteDFM()
  endif
endfunction


" Load colors and do so again whenever the colorscheme changes
call LoadDFMColors()
augroup dfm_events
  autocmd!
  autocmd ColorScheme call LoadDFMColors()
augroup END


" Map function calls to commands
command! LiteDFM call LiteDFM()
command! LiteDFMClose call LiteDFMClose()
command! LiteDFMToggle call LiteDFMToggle()
