vim.filetype.add({
  pattern = {
    [".*/profiles/.*%.yml%.age"] = "yaml",
    [".*/config%.d/.*%.conf%.age"] = "sshconfig",
  },
})

vim.keymap.set("n", "<localleader>d", "<cmd>%!chezmoi decrypt<cr>", { desc = "age | Decrypt buffer" })
vim.keymap.set("n", "<localleader>e", "<cmd>%!chezmoi encrypt<cr>", { desc = "age | Encrypt buffer" })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.age",
  callback = function(ev)
    local first = vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1] or ""
    if not first:match("^%-%-%-%-%-BEGIN AGE ENCRYPTED FILE") then
      vim.notify("Refusing to write plaintext to a .age file", vim.log.levels.ERROR)
      error("plaintext in .age file")
    end
  end,
})
