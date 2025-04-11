function! airline#extensions#tabline#formatters#custom#format(bufnr, buffers)
  let l:bt = getbufvar(a:bufnr, '&buftype')
  if l:bt ==# 'terminal'
    return 'term'
  endif
  return fnamemodify(bufname(a:bufnr), ':t')
endfunction

