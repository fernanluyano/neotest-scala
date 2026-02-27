local plenary_path = vim.env.PLENARY_PATH or (vim.fn.stdpath("data") .. "/lazy/plenary.nvim")

vim.opt.rtp:prepend(plenary_path)
vim.opt.rtp:prepend(".")

vim.cmd("runtime plugin/plenary.vim")
