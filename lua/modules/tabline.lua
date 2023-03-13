------------------------------------------------------------------------
--                              TabLine                               --
------------------------------------------------------------------------
local M = {}
local api = vim.api
local cmd = api.nvim_command
local icons = require('tables._icons')
-- Separators
local left_separator = ''
local right_separator = ''
-- Blank Between Components
local space = ' '

local TrimmedDirectory = function(dir)
	local home = os.getenv('HOME')
	local _, index = string.find(dir, home, 1)
	if index ~= nil and index ~= string.len(dir) then
		if string.len(dir) > 30 then
			dir = '..' .. string.sub(dir, 30)
		end
		return string.gsub(dir, home, '~')
	end
	return dir
end

local getTabLabel = function(n)
	local current_win = api.nvim_tabpage_get_win(n)
	local current_buf = api.nvim_win_get_buf(current_win)
	local file_name = api.nvim_buf_get_name(current_buf)
	if string.find(file_name, 'term://') ~= nil then
		return ' ' .. api.nvim_call_function('fnamemodify', { file_name, ':p:t' })
	end
	file_name = api.nvim_call_function('fnamemodify', { file_name, ':p:t' })
	if file_name == '' then
		return 'No Name'
	end
	local icon = icons.deviconTable[file_name]
	if icon ~= nil then
		return icon .. space .. file_name
	end
	return file_name
end

local set_colours = function()
	--SET TABLINE COLOURS
	cmd('hi TabLineSel gui=Bold guibg=#d7827e guifg=#e0def4')
	cmd('hi TabLineSelSeparator gui=bold guifg=#d7827e')
	cmd('hi TabLine guibg=#232136 guifg=#575279 gui=None')
	if vim.opt.background:get() == 'dark' then
		cmd('hi TabLineSeparator guifg=#232136')
	else
		cmd('hi TabLineSeperator guifg=#f5f4ed')
	end
	cmd('hi TabLineFill guibg=None gui=None')
end

function M.init()
	set_colours()
	local tabline = ''
	local tab_list = api.nvim_list_tabpages()
	local current_tab = api.nvim_get_current_tabpage()
	for _, val in ipairs(tab_list) do
		local file_name = getTabLabel(val)
		if val == current_tab then
			tabline = tabline .. '%#TabLineSelSeparator# ' .. left_separator
			tabline = tabline .. '%#TabLineSel# ' .. file_name
			tabline = tabline .. ' %#TabLineSelSeparator#' .. right_separator
		else
			tabline = tabline .. '%#TabLineSeparator# ' .. left_separator
			tabline = tabline .. '%#TabLine# ' .. file_name
			tabline = tabline .. ' %#TabLineSeparator#' .. right_separator
		end
	end
	tabline = tabline .. '%='
	-- Component: Working Directory
	local dir = api.nvim_call_function('getcwd', {})
	tabline = tabline
		.. '%#TabLineSeparator#'
		.. left_separator
		.. '%#Tabline# '
		.. TrimmedDirectory(dir)
		.. '%#TabLineSeparator#'
		.. right_separator
	return tabline
end

return M
