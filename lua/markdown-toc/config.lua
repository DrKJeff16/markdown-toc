---@class MarkdownTOC.Config
local M = {}

---@class MarkdownTOCOpts
local defaults = {
  -- Set to display a dropdown to allow you to select the heading level
  ask_for_heading_level = false,

  -- The heading level to match (i.e the number of "#"s to match to)
  heading_level_to_match = -1,

  -- TOC default string
  -- The first %s is for indenting/tabs
  -- The sencond %s is for the original headings text
  -- The third %s is for the markdown files path that the TOC is being generated
  -- from
  -- The forth %s is for the target heading using the markdown rules
  toc_format = '%s- [%s](<%s#%s>)',
}

M.options = {} ---@type MarkdownTOCOpts

---@param opts? MarkdownTOCOpts
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})
  M.options.heading_level_to_match = M.options.heading_level_to_match > 6 and 6
    or M.options.heading_level_to_match
end

---@param opts? MarkdownTOCOpts
function M.extend(opts)
  M.options = vim.tbl_deep_extend('force', M.options, opts or {})
end

return M
