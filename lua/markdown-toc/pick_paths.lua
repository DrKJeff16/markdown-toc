---@class MarkdownTOC.PickPaths
local M = {}

---@param file1 string
---@param file2 string
---@return string relpath
function M.get_relative_path(file1, file2)
  local common_prefix, i = '', 1
  while
    i <= file1:len()
    and i <= file2:len()
    and file1:sub(i, i) == file2:sub(i, i)
  do
    common_prefix, i = common_prefix .. file1:sub(i, i), i + 1
  end

  return i > file1:len() and file2:sub(i)
    or ('../'):rep(select(2, file1:sub(i):gsub('/', ''))) .. file2:sub(i)
end

---@param callback fun(path: string)
function M.pick_git_file(callback)
  local builtin = require('telescope.builtin')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  if vim.fn.finddir('.git', vim.fn.getcwd() .. ';') == '' then
    builtin.find_files({
      prompt_title = 'Select a file from CWD',
      search_file = '*.md',
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          callback(selection.path)
        end)
        return true
      end,
    })
  else
    builtin.git_files({
      prompt_title = 'Select a file from your Git repository',
      use_git_root = false,
      git_command = {
        'git',
        'ls-files',
        '--exclude-standard',
        '--cached',
        '*.md',
      },
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          callback(selection.path)
          -- Do something with the relative path if needed
        end)
        return true
      end,
    })
  end
end

return M
