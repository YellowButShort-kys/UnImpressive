---@enum ui_piece
---@alias ui_piece_id
---| 'preset_button'
---| 'preset_dropdown'
---| 'preset_scroll'
---| 'preset_table'


local cwd = ...

local ui = {}

local hub = {}
local tree_hub = {}

local CursorLink = {}

local ui_lib = {}

local unique_names = {}

local base = {__index = require(cwd..".base")}

--local input = require(cwd.."io")

local main = require(cwd..".blank")
setmetatable(main, base)
main:__precreate()
main:onCreate()
table.insert(tree_hub, main)



---Creates the UI Piece from the "name" and ties it to the "father". Additional arguments are passed to :onCreate()
---@param name ui_piece_id
---@param father ui_piece?
---@return ui_piece
function ui.CreateUI(name, father, ...)
    assert(ui_lib[name], "Incorrect UI name: "..name)

    local ent = {}
    setmetatable(ent, {__index = ui_lib[name]})
    table.insert(hub, ent)
    ent:__precreate()
    ent:onInit(father and father.__type ~= "ui_piece" and father or ..., ...)
    if not ent.Detached then
        ent:SetFather(father and father.__type == "ui_piece" and father or main)
    end
    ent:onCreate(father and father.__type ~= "ui_piece" and father or ..., ...)

    return ent
end

---Creates blank UI. Think of it as a canvas. It is not tied to the main piece, so it can be safely used with camera and what not. Use it as a father for other pieces
---@return ui_piece
function ui.CreateBlank()
    local blank = setmetatable({}, {__index = main})
    blank:__precreate()
    blank:onCreate()
    table.insert(tree_hub, blank)
    return blank
end

---Compiles the UI piece to be later created. Does not add it to the main library (can't be created via CreateUI)
---<br>Simply store the function and run when needed with specified father if neccessary
---@param code table
---@return fun(father: ui_piece, ...)
function ui.Compile(code)
    assert(type(code)=="table", "Expected table, got: "..type(code))
    setmetatable(code, base)
    
    ---@param father ui_piece?
    ---@return ui_piece
    local a = function(father, ...)
        local ent = {}
        setmetatable(ent, {__index = code})
        table.insert(hub, ent)
        ent:__precreate()
        ent:onInit(father and father.__type ~= "ui_piece" and father or ..., ...)
        if not ent.Detached then
            ent:SetFather(father or main)
        end
        ent:onCreate(father and father.__type ~= "ui_piece" and father or ..., ...)
        return ent
    end

    return a
end

require(cwd..".base").CreateUI = function(self, name, ...)
    return ui.CreateUI(name, self, ...)
end

---Returns an UI Piece with an unique id that was set using :SetUniqueName(). 
---@param id any
---@return ui_piece 
function ui.GetUnique(id)
    return unique_names[id]
end

---Draws the default UI Piece. Every UI Piece that is not connected to others is connected to it.
function ui.Draw()
    main:Draw()
end

local clickproxy = {}
function ui.Update(dt)
    for _, var in ipairs(hub) do
        if var.Update then
            var:Update(dt)
        end
    end
end

local function HiddenIteration(folder, tbl)
    local files = love.filesystem.getDirectoryItems(folder)
    for k, file in ipairs(files) do
        if love.filesystem.getInfo(folder.."/"..file)["type"] == "directory" then
            HiddenIteration(folder.."/"..file, tbl)
        end

        if love.filesystem.getInfo(folder.."/"..file)["type"] == "file" then
            table.insert(tbl, folder.."/"..file)
        end
    end

    return tbl
end
local function IterateThroughFolder(folder, search_folder)
    if not love.filesystem.getInfo(folder) then error(folder.."  --> No such was directory found") end

    local tbl = {}

    local files = love.filesystem.getDirectoryItems(folder)
    for k, file in ipairs(files) do
        if search_folder then
            if love.filesystem.getInfo(folder.."/"..file)["type"] == "directory" then
                table.insert(tbl, folder.."/"..file)
            end
        else
            if love.filesystem.getInfo(folder.."/"..file)["type"] == "directory" then
                HiddenIteration(folder.."/"..file, tbl)
            end

            if love.filesystem.getInfo(folder.."/"..file)["type"] == "file" then
                table.insert(tbl, folder.."/"..file)
            end
        end
    end

    return tbl
end

function ui.LoadFolder(path)
    for _, var in ipairs(IterateThroughFolder(path)) do
        local piece = require(var:sub(0, -5))
        ui_lib[piece.id or var:match('[^/]+$'):sub(0, -5)] = piece
    end

    
    for _, var in pairs(ui_lib) do
        setmetatable(var, base)
        var:__init(unique_names, CursorLink)
        var:Init(ui)
    end
end


for _, var in ipairs(IterateThroughFolder(cwd:gsub("%.", "%/").."/presets")) do
    local check, piece = pcall(require, (var:sub(0, -5)))
    if check then
        ui_lib[piece.id or var:match('[^/]+$'):sub(0, -5)] = piece
    end
end

-----------------------------------------------------------------------------------------------------
----------------------------------------------- INPUT -----------------------------------------------
-----------------------------------------------------------------------------------------------------

local input = require(cwd..".io")
local function mpiter(ent, x, y, btn)
    if not ent.disable then
        local res = false
        for _, var in ipairs(ent.children) do
            local lres = mpiter(var, x, y, btn)
            res = res or lres
        end
        if res then
            return true
        end
        if ent.Clickable then
            if x > ent.absposX and x < ent.absposX + ent.sizeX and y > ent.absposY and y < ent.absposY + ent.sizeY then
                ent:onPress(x, y, btn)
                clickproxy[ent] = true
                return true
            else
                clickproxy[ent] = false
            end
        end
    end
    return false
end
function input.mousepressed(x, y, btn)
    for _, var in ipairs(tree_hub) do
        mpiter(var, x, y, btn)
    end
end


local function mriter(ent, x, y, btn)
    if not ent.disable then
        local res = false
        for _, var in ipairs(ent.children) do
            local lres = mriter(var, x, y, btn)
            res = res or lres
        end
        if res then
            return true
        end

        if ent.Clickable and clickproxy[ent] then
            if x > ent.absposX and x < ent.absposX + ent.sizeX and y > ent.absposY and y < ent.absposY + ent.sizeY then
                ent:onClick(x, y, btn)
                return true
            else                
                ent:onFailedClick(x, y, btn)
            end
            ent:onRelease(x, y)
            clickproxy[ent] = false
        end
    end

    return false
end
function input.mousereleased(x, y, btn)
    for _, var in ipairs(tree_hub) do
        mriter(var, x, y, btn)
    end
end




local function mmiter(ent, x, y)
    if not ent.disable then
        for _, var in ipairs(ent.children) do
            mmiter(var, x, y)
        end

        if ent.onHover and not ent.disable then  
            if x > ent.absposX and x < ent.absposX + ent.sizeX and y > ent.absposY and y < ent.absposY + ent.sizeY then
                if not ent.__hover then
                    ent.__hover = true
                    ent:onHover()
                end
            else
                if ent.__hover then
                    ent.__hover = false
                    if ent.onLeave then
                        ent:onLeave()
                    end
                end
            end
        end
    end
end
function input.mousemoved(x, y, dx, dy)
    for _, var in ipairs(tree_hub) do
        mmiter(var, x, y)
    end
    for _, var in ipairs(hub) do
        if var.CursorLink then
            var:SetPos(x, y)
        end
    end
    for _, var in ipairs(hub) do
        if var.onMouseMove then
            var:onMouseMove(x, y, dx, dy)
        end
    end
end

function input.wheelmoved(x, y)
    for _, var in ipairs(hub) do
        if var.onScroll and not var.disable and var.scrollable then
            var:onScroll(x, y)
        end
    end
end

return ui