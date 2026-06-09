-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_compiler_latexmk = {
        options = {
          '-verbose',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
          '-shell-escape',
        },
        build_dir = 'build', -- Build artifacts directory
        out_dir = 'build', -- Output directory for PDF and aux files
        aux_dir = 'build', -- Auxiliary files directory
      }
      vim.g.vimtex_view_method = 'zathura'
    end,
  },
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
    config = function()
      require('typescript-tools').setup {
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        settings = {
          jsx_close_tag = {
            enable = true,
            filetypes = { 'javascriptreact', 'typescriptreact' },
          },
        },
      }
    end,
  },
  {
    'kylechui/nvim-surround',
    version = '^3.0.0', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    'whonore/Coqtail',
    ft = 'coq',
    -- The configuration below was extracted from the following repository:
    -- https://github.com/dpella/docker-nvim-haskell-latex-LLM/blob/44ed5706623f8d0e96669273088a77d517f83355/otherfiles/init.lua#L171
    -- TODO: Remove this configuration once the issue has been fixed upstream in the Coqtail repository.
    config = function()
      -- Workaround for Coqtail's CoqtailJoinspaces augroup using a
      -- non-bang `unlet b:_coqtail_save_js` on BufLeave, which errors
      -- with E108 when BufEnter never set the var (e.g. closing neo-tree
      -- and focusing a Rocq file). Replace it with an augroup using `unlet!`.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'coq',
        callback = function(args)
          pcall(vim.api.nvim_clear_autocmds, { group = 'CoqtailJoinspaces', buffer = args.buf })
          vim.cmd(string.format(
            [[
						augroup CoqtailJoinspacesFix
						  autocmd! * <buffer=%d>
						  autocmd BufEnter <buffer=%d>
						        \ if !exists('b:_coqtail_save_js')
						        \ |   let b:_coqtail_save_js = &js
						        \ | endif
						        \ | let &joinspaces = get(g:, 'coqtail_joinspaces', 0)
						  autocmd BufLeave <buffer=%d>
						        \ let &joinspaces = get(b:, '_coqtail_save_js', 1)
						        \ | unlet! b:_coqtail_save_js
						augroup END
					]],
            args.buf,
            args.buf,
            args.buf
          ))
        end,
      })
    end,
  },
  -- coq-lsp conflicts with Coqtail because Coqtail always loads automatically.
  -- I haven’t found a way to disable Coqtail when using coq-lsp, so I’m not enabling
  -- coq-lsp until a solution is found that allows both plugins to coexist in a simple way.
  -- {
  --   'tomtomjhj/coq-lsp.nvim',
  --   ft = 'coq',
  --   dependencies = { 'neovim/nvim-lspconfig' },
  --   init = function()
  --     -- Prevent Coqtail from loading
  --     -- vim.g.loaded_coqtail = 1
  --     -- vim.g['coqtail#supported'] = 0
  --   end,
  --   config = function()
  --     require('coq-lsp').setup {
  --       coq_lsp_args = { '--bt' },
  --     }
  --   end,
  -- },
}
