local M = {}

local server_configs = {}

local function merge_tables(...)
  local args = { ... }
  local result = {}

  for _, arg in ipairs(args) do
    for k, v in pairs(arg) do
      result[k] = v
    end
  end

  return result
end

M.add_server = function(server_config)
  -- vim.lsp.ClientConfig
  table.insert(server_configs, server_config)
end

M.start_servers = function()
  for i, server_config in ipairs(server_configs) do
    local name = server_config.name or ('server-' .. i)
    local filetypes = server_config.filetypes or '*'
    local root_markers = server_config.root_markers or {}
    local on_file_type = server_config.on_file_type

    if on_file_type == nil then
      return
    end

    local root_dir = server_config.root_dir or vim.fs.root(0, root_markers)

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup(name, {}),
      pattern = filetypes,
      callback = function(arg)
        local on_file_type_config = on_file_type({
          root_dir = root_dir,
        })

        if on_file_type_config == nil then
          return
        end

        local merged_config = merge_tables({
          name = name,
          filetypes = filetypes,
          root_markers = root_markers,
          root_dir = root_dir,
        }, on_file_type_config)

        vim.lsp.start(merged_config)
        -- local client_id = vim.lsp.start(merged_config, opts)
        -- local client = vim.lsp.get_client_by_id(client_id)
      end,
    })
  end
end

return M
