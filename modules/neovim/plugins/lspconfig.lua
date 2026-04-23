local navic = require('nvim-navic')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').bashls.setup{
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    navic.attach(client, bufnr)
  end
}

require('lspconfig').pylsp.setup{
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    navic.attach(client, bufnr)
  end
}
require('lspconfig').terraformls.setup{
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    navic.attach(client, bufnr)
  end
}
