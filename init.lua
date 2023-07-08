---@enum ui_piece



local cwd = ...

local ui = {}

local hub = {}

local ui_lib = {}

local unique_names = {}

local base = {__index = require(cwd..".base")}

local input = require(cwd.."io")

local main = require(cwd..".blank")
setmetatable(main, base)
main:__precreate()
main:onCreate()



---Creates the UI Piece from the "name" and ties it to the "father". Additional arguments are passed to :onCreate()
---@param name string
---@param father ui_piece?
---@return ui_piece
function ui.CreateUI(name, father, ...)
    assert(ui_lib[name], "Incorrect UI name: "..name)

    local ent = {}
    setmetatable(ent, {__index = ui_lib[name]})
    table.insert(hub, ent)
    ent:__precreate()
    if not ent.Detached then
        ent:SetFather(father or main)
    end
    ent:onCreate(...)

    return ent
end

---Compiles the UI piece to be later created, does not add it to the main library (can't be created via CreateUI)
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
        if not ent.Detached then
            ent:SetFather(father or main)
        end
        ent:onCreate(...)
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
        var:__init(unique_names)
        var:Init(ui)
    end
end


for _, var in ipairs(IterateThroughFolder(cwd:gsub("%.", "%/").."/presets")) do
    local check, piece = pcall(require, (var:sub(0, -5)))
    if check then
        ui_lib[piece.id or var:match('[^/]+$'):sub(0, -5)] = piece
    end
end

function input.mousepressed(x, y, btn)
    for _, var in ipairs(hub) do
        if var.Clickable and not var.disable then
            if x > var.absposX and x < var.absposX + var.sizeX and y > var.absposY and y < var.absposY + var.sizeY then
                var:onPress(x, y, btn)
                clickproxy[var] = true
                return true
            else
                clickproxy[var] = false
            end
        end
    end
end

function input.mousereleased(x, y, btn)
    for _, var in ipairs(hub) do
        if var.Clickable and not var.disable and clickproxy[var] then
            if x > var.absposX and x < var.absposX + var.sizeX and y > var.absposY and y < var.absposY + var.sizeY then
                var:onClick(x, y, btn)
                return true
            else
                var:onFailedClick(x, y, btn)
            end
            var:onRelease(x, y)
            clickproxy[var] = false
        end
    end
end

function input.mousemoved(x, y)
    for _, var in ipairs(hub) do
        if var.onHover and not var.disable then  
            if x > var.absposX and x < var.absposX + var.sizeX and y > var.absposY and y < var.absposY + var.sizeY then
                if not var._hover then
                    var._hover = true
                    var:onHover()
                end
            else
                if var._hover then
                    var._hover = false
                    if var.onLeave then
                        var:onLeave()
                    end
                end
            end
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