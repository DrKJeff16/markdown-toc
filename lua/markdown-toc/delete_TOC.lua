--[[


- [What is markdown-toc?](<#what-is-markdown-toc?>)
  - [Markdown-TOC TOC](<#markdown-toc-toc>)
  - [✨ Features](<#✨-features>)
  - [⚡️ Requirements](<#⚡️-requirements>)
  - [📦 Installation](<#📦-installation>)
  - [⚙️ Configuration](<#⚙️-configuration>)
  - [🚀 Usage](<#🚀-usage>)
  - [Plugins that work well with Buffer Vacuum](<#plugins-that-work-well-with-buffer-vacuum>)




- [Layer 7](<Layer 7.md#layer-7>)
  - [Summary](<Layer 7.md#summary>)
  - [SMTP (Simple Mail Transfer Protocol)](<Layer 7.md#smtp-(simple-mail-transfer-protocol)>)
  - [POP3 (Post Office Protocol version 3)](<Layer 7.md#pop3-(post-office-protocol-version-3)>)
  - [IMAP4 (Internet Message Access Protocol version 4)](<Layer 7.md#imap4-(internet-message-access-protocol-version-4)>)
  - [FTP (File Transfer Protocol)](<Layer 7.md#ftp-(file-transfer-protocol)>)
  - [HTTP (HyperText Transfer Protocol)](<Layer 7.md#http-(hypertext-transfer-protocol)>)
  - [DNS (Domain Name System)](<Layer 7.md#dns-(domain-name-system)>)
  - [DHCP (Dynamic Host Configuration Protocol)](<Layer 7.md#dhcp-(dynamic-host-configuration-protocol)>)
  - [SNMP](<Layer 7.md#snmp>)

--]]

---@class MarkownTOC.Delete
local M = {}

---@param line string
---@return boolean valid
local function is_valid_heading(line)
  -- Check if the line matches the pattern
  local heading_name, file_path, heading_link = line:match(
    '^%s*[%-%*]%s+%[%s*(.-)%s*%]%s*%(<%s*(.-)%s*#%s*(.-)%s*>%s*%)%s*$'
  )
  return heading_name ~= nil and file_path ~= nil and heading_link ~= nil
end

function M.delete_TOC()
  local cursor_line = vim.fn.line('.')
  local top_line, bottom_line = cursor_line, cursor_line
  for line_num = cursor_line - 1, 1, -1 do -- Delete matching lines above the cursor
    if not is_valid_heading(vim.fn.getline(line_num)) then
      break -- Stop iterating if the line doesn't match the pattern
    end
    top_line = line_num
  end

  -- Delete matching lines below the cursor
  for line_num = cursor_line + 1, vim.fn.line('$') do
    if not is_valid_heading(vim.fn.getline(line_num)) then
      break -- Stop iterating if the line doesn't match the pattern
    end
    bottom_line = line_num
  end

  vim.fn.deletebufline(vim.api.nvim_get_current_buf(), top_line, bottom_line)
  -- Insert the new heading line
  -- vim.fn.setline(vim.fn.line('.'), new_toc)
end

-- Example usage:
-- delete_matching_lines()

return M
