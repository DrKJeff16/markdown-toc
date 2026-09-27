local config = require('markdown-toc.config')
local select_heading_level = require('markdown-toc.select_heading_level')
local pick_git_file = require('markdown-toc.pick_paths').pick_git_file
local delete_TOC = require('markdown-toc.delete_TOC').delete_TOC

---@class MarkdownTOC.Utils
local M = {}

---@param filepath string
---@return string|nil|? content
function M.read_file(filepath)
  local file = io.open(filepath, 'r')
  if file then
    local content = file:read('*all') --[[@as string|nil|?]]
    file:close()
    return content
  end
end

---@param content string
---@param filepath string
---@param heading_level_to_match integer
function M.process_heading(content, filepath, heading_level_to_match)
  local lines = {} ---@type string[]
  for line in content:gmatch('[^\r\n]+') do
    table.insert(lines, line)
  end

  local output = {} ---@type string[]
  local bufnr = vim.api.nvim_get_current_buf()
  local expandtab = vim.api.nvim_get_option_value('expandtab', { buf = bufnr })
  for _, line in ipairs(lines) do
    local heading_level, heading_text = line:match('^(#+)%s*(.+)') ---@type string|nil|?, string|nil|?
    if heading_level and heading_text then
      local heading_anchor = heading_text:gsub('%s+', '-'):lower()

      --[[ 
      --  This little block of code gave a lot of probles but for anyone interested
      --  the reason why you have to add '%EF%B8%8F' for cases where the string has 
      --  the unicode character U+FE0F is because of unicode variations which take up two
      --  character spaces compared to the usual one. You need to do this becacuase it
      --  some emojis are built on top of "plain text" emojis, like the heart which
      --  can be rendered as either a red heart ❤️ which is the VS16 variation or it can
      --  be rendered as normal character ❤ which is the VS15 selector. 
      --
      --  For some reason on GitHub if the emojis has a VS16 selector then the
      --  heading anchor needs to have '%EF%B8%8F' wherever the emojis appears
      --
      --  If you ever want to see how this works and that the emojis do actually
      --  take up two charcters go into github and edit a file on github that
      --  has an emoji with a VS16 variation and when you use backspace it will
      --  first become the VS15 variation before you then need to hit backspace
      --  to delete the emoji
      --]]

      if heading_anchor:find('[\u{FE0F}]') then
        heading_anchor = heading_anchor
          :gsub('[\u{FE0F}]', '')
          :gsub('[\u{1F600}-\u{1F64F}]', function()
            return '%EF%B8%8F'
          end, 1)
      end
      if
        heading_level_to_match == -1
        or heading_level:len() <= heading_level_to_match
      then
        table.insert(
          output,
          config.options.toc_format:format(
            not expandtab and ('\t'):rep(heading_level:len() - 1)
              or (' '):rep(
                (heading_level:len() - 1)
                  * vim.api.nvim_get_option_value('tabstop', { buf = bufnr })
              ),
            heading_text,
            require('markdown-toc.pick_paths').get_relative_path(
              vim.api.nvim_buf_get_name(bufnr),
              filepath
            ),
            heading_anchor:gsub('[\u{1F600}-\u{1F64F}]', '')
          )
        )
      end
    end
  end

  delete_TOC()

  local row = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]
  vim.api.nvim_buf_set_lines(
    bufnr,
    row - 1,
    row - 1,
    false,
    vim.split(table.concat(output, '\n'), '\n')
  )
end

---@param filepath string
---@param heading_level_to_match? integer
function M.generate_toc_from_file(filepath, heading_level_to_match)
  local content = M.read_file(filepath)
  if not content then
    vim.notify('battery.nvim - failed to read the file.', vim.log.levels.ERROR)
  elseif heading_level_to_match then
    M.process_heading(content, filepath, heading_level_to_match)
  else
    heading_level_to_match = config.options.heading_level_to_match
    if config.options.ask_for_heading_level then
      select_heading_level(function(heading_level)
        M.process_heading(content, filepath, heading_level)
      end)
    else
      M.process_heading(content, filepath, heading_level_to_match)
    end
  end
end

function M.pick_file_with_telescope(args)
  pick_git_file(function(filepath)
    M.generate_toc_from_file(
      filepath,
      args ~= nil and tonumber(args, 10) or nil
    )
  end)
end

function M.load()
  vim.api.nvim_create_user_command('GenerateTOC', function(opts)
    M.pick_file_with_telescope(opts.args)
  end, { nargs = '?' })

  vim.api.nvim_create_user_command('DeleteTOC', function()
    delete_TOC()
  end, {})
end

return M
