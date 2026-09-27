---@param callback fun(value: string)
---@param prompt_bufnr integer
local function select_number(callback, prompt_bufnr)
  local actions = require('telescope.actions')
  actions.select_default:replace(function()
    local selection = require('telescope.actions.state').get_selected_entry()
    actions.close(prompt_bufnr)
    callback(selection.value)
    -- print(vim.inspect(selection.value))
  end)
end

---@param callback fun(value: string|integer)
---@param opts? table
return function(callback, opts)
  opts = opts or require('telescope.themes').get_dropdown({})

  require('telescope.pickers')
    .new(opts, {
      prompt_title = 'Select the level of headings to generate (-1 for all)',
      finder = require('telescope.finders').new_table({
        results = {
          { title = 'All', value = -1 },
          { title = 'One', value = 1 },
          { title = 'Two', value = 2 },
          { title = 'Three', value = 3 },
          { title = 'Four', value = 4 },
          { title = 'Five', value = 5 },
          { title = 'Six', value = 6 },
        },
        entry_maker = function(entry)
          return {
            display = entry.title,
            ordinal = entry.title .. entry.value,
            value = entry.value,
          }
        end,
      }),
      sorter = require('telescope.config').values.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        select_number(callback, prompt_bufnr)
        return true
      end,
    })
    :find()
end
