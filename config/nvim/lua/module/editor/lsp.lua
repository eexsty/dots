return {
    packer = {
        "neovim/nvim-lspconfig",
        "folke/lsp-colors.nvim",
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    },
    data = function()
        return {
            lspconfig = require("lspconfig"),
            lsp_colors = require("lsp-colors"),
            lsp_lines = require("lsp_lines"),
        }
    end,
    depends = {
        "shortcuts.lsp",
        "language.rust",
        "language.lua",
        "language.scala",
    },
    exec = function(root, shortcuts, rust, lua, scala)
        root.lsp_colors.setup({})
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        capabilities.offsetEncoding = "utf-8"
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        local on_attach = shortcuts.on_attach
        local lsp = {
            rust,
            lua,
            "tsserver",
            "vuels",
            "cssls",
            "cssmodules_ls",
            "eslint",
            "html",
            "jsonls",
            "pyright",
            "astro",
            "clangd",
            "svelte",
        }
        for _, lang in ipairs(lsp) do
            if type(lang) == "string" then
                root.lspconfig[lang].setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                    flags = {
                        debounce_text_changes = 150,
                    },
                })
            else
                local lsp = {
                    on_attach = on_attach,
                    capabilities = capabilities,
                    settings = lang.lsp.settings,
                    flags = {
                        debounce_text_changes = 150,
                    },
                }
                for k, v in pairs(lang.lsp.root or {}) do
                    lsp[k] = v
                end
                root.lspconfig[lang.lsp.name].setup(lsp)
            end
        end
        scala.init(capabilities)
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
        vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { update_in_insert = true })
        vim.o.updatetime = 250
        vim.wo.signcolumn = "yes"
        root.lsp_lines.setup()
    end,
}
