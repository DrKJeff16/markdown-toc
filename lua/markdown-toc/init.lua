---@class MarkdownTOC
local M = {}

function M.load()
  require('markdown-toc.utils').load()
end

function M.setup(opts)
  require('markdown-toc.config').setup(opts)
end

return M
