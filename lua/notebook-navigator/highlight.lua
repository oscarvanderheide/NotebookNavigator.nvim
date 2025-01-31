local core = require "notebook-navigator.core"
local utils = require "notebook-navigator.utils"

local highlight = {}

highlight.minihipatterns_spec = function(cell_markers, hl_group)
  local notebook_cells = {
    pattern = function(buf_id)
      local cell_marker = utils.get_cell_marker(buf_id, cell_markers)
      if cell_marker then
        local regex_cell_marker = string.gsub("^" .. cell_marker, "%%", "%%%%")
        return regex_cell_marker
      else
        return nil
      end
    end,
    group = "",
    extmark_opts = {
      virt_text = {
        {
          function()
            local marker_length = #utils.get_cell_marker(buf_id, cell_markers) or 0
            local description_length = 10 -- Adjust this based on actual description length
            local line_length = 80 - marker_length - description_length
            return string.rep("─", line_length)
          end,
          hl_group,
        },
      },
      line_hl_group = hl_group,
      hl_eol = true,
    },
  }
  return notebook_cells
end

highlight.setup_autocmd_syntax_highlights = function(cell_markers, hl_group)
  vim.api.nvim_create_augroup("NotebookNavigator", { clear = true })

  -- Create autocmd for every language
  for ft, marker in pairs(cell_markers) do
    local syntax_rule = [[ /^\s*]] .. marker .. [[.*$/]]
    local syntax_cmd = "syntax match CodeCell" .. syntax_rule
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft,
      group = "NotebookNavigator",
      command = syntax_cmd,
    })
  end
  vim.api.nvim_set_hl(0, "CodeCell", { link = hl_group })
  vim.api.nvim_exec_autocmds("FileType", { group = "NotebookNavigator" })
end

return highlight
