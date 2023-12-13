---@class ui_piece
local base = {}

base.posX = 0
base.posY = 0
base.absposX = 0
base.absposY = 0
base.sizeX = love.graphics.getWidth()
base.sizeY = love.graphics.getHeight()
base.scale = 1
base.disable = false
base.paddingX = 0
base.paddingY = 0
base.Clickable = true
base.IgnoreScissors = true
base.DeepDisable = true
base.__type = "ui_piece"

local proxy --i'm genius

function base:__init(p)
    proxy = p
end
function base:__precreate()
    self.children = {}
end
function base:Init()
end

---
function base:SetPos(x, y)
    self.posX = x
    self.posY = y or x

    self:UpdateAbsolutePos()

    return self
end
function base:SetDPos(dx, dy)
    self.posX = self.posX + dx
    self.posY = self.posY + dy or dx

    self:UpdateAbsolutePos()
    return self
end
function base:GetPos()
    return self.posX, self.posY
end

function base:SetUniqueName(str)
    assert(not proxy[str], "Duplicating Unique Name!: "..str)
    proxy[str] = self
    return self
end

function base:UpdateAbsolutePos()
    local offx, offy
    if self.father then
        offx, offy = self.father:GetAbsolutePos()
    else
        offx, offy = 0, 0
    end
    self.absposX = self.posX + offx
    self.absposY = self.posY + offy
    for _, var in ipairs(self.children) do
        var:UpdateAbsolutePos()
    end
    return self
end
function base:GetAbsolutePos()
    return self.absposX, self.absposY
end

function base:SetSizeX(x)
    self.sizeX = x
    return self
end
function base:SetSizeY(y)
    self.sizeY = y
    return self
end
function base:SetSize(x, y)
    self.sizeX = x
    self.sizeY = y or x
    return self
end

function base:GetSizeX()
    return self.sizeX
end
function base:GetSizeY()
    return self.sizeY
end
function base:GetWidth()
    return self.sizeX
end
function base:GetHeight()
    return self.sizeY
end
function base:GetSize()
    return self.sizeX, self.sizeY
end


function base:SetX(x)
    self.posX = x

    self:UpdateAbsolutePos()
    return self
end
function base:SetDX(x)
    self.posX = self.posX + x

    self:UpdateAbsolutePos()
    return self
end
function base:GetX()
    return self.posX
end

function base:SetPadding(x, y)
    self.paddingX = x
    self.paddingY = y
    return self
end
function base:SetPaddingX(x)
    self.paddingX = x
    return self
end
function base:SetPaddingY(y)
    self.paddingY = y
    return self
end

function base:SetY(y)
    self.posY = y

    self:UpdateAbsolutePos()
    return self
end
function base:SetDY(y)
    self.posY = self.posY + y

    self:UpdateAbsolutePos()
    return self
end
function base:GetY()
    return self.posY
end

function base:SetScale(s)
    self.scale = s
    return self
end
function base:GetScale()
    return self.scale
end

local _d = {
    1, 2, 3, 4, 5, 6, 7, 8, 9,
    West = 1, NorthWest = 2, North = 3, NorthEast = 4, East = 5, SouthEast = 6, South = 7, SouthWest = 8, Center = 9,
    W = 1, NW = 2, N = 3, NE = 4, E = 5, SE = 6, S = 7, SW = 8, C = 9
}
local _df = {}
---Docks the ui_piece to the suplied direction. It changes the position once and needs to be called again when position needs to be updated
---West/W/1, NorthWest/NW/2, North/N/3, NorthEast/NE/4, East/E/5, SouthEast/SE/6, South/S/7, SouthWest/SW/8, Center/C/9
---@param direction number|string
function base:Dock(direction)
    self.docking = _d[direction]
    self.posX, self.posY = _df[self.docking](self.sizeX, self.sizeY, self.father.sizeX, self.father.sizeY)
    self:UpdateAbsolutePos()
end

function base:AddChild(child)
    table.insert(self.children, child)
    child.father = self
    return self
end
function base:SetFather(father)
    father:AddChild(self)
    return self
end
function base:GetFather()
    return self.father
end
function base:GetChildren()
    return self.children
end

function base:Enable()
    self.disable = false
    if self.onEnable then
        self:onEnable()
    end
    if self.DeepDisable then
        for _, var in ipairs(self.children) do
            var:Enable()
        end
    end
    return self
end
function base:Disable()
    self.disable = true
    if self.onDisable then
        self:onDisable()
    end
    if self.DeepDisable then
        for _, var in ipairs(self.children) do
            var:Disable()
        end
    end
    return self
end
function base:Toggle()
    self.disable = not self.disable
    return self
end

function base:IsHovered()
    return self.__hover or false
end

function base:EnableCursorLink()
    self.CursorLink = true
end
function base:DisableCursorLink()
    self.CursorLink = nil
end

--DEBUG_WIREFRAME = true
function base:Draw()
    if not self.disable then
        love.graphics.push("all")
        love.graphics.translate(self.posX, self.posY)
        love.graphics.scale(self.scale)
        if not self.IgnoreScissors then
            love.graphics.intersectScissor(self.absposX, self.absposY, self.sizeX, self.sizeY)
        end
        self:Paint()
        if DEBUG_WIREFRAME then
            love.graphics.push("all")
            love.graphics.origin()
            love.graphics.translate(self.absposX, self.absposY)
            love.graphics.line(0, 0, self.sizeX, 0, self.sizeX, self.sizeY, 0, self.sizeY, 0, 0)
            love.graphics.line(0, 0, self.sizeX, self.sizeY)
            love.graphics.line(self.sizeX, 0, 0, self.sizeY)
            love.graphics.pop()
        end
        for _, var in ipairs(self.children) do
            --love.graphics.intersectScissor(self.paddingX, self.paddingY, self.sizeX-self.paddingX, self.sizeY-self.paddingY)
            love.graphics.push("all")
            var:Draw()
            love.graphics.pop()
        end
        love.graphics.pop()
    end
end
function base:Paint()
end
function base:Update(dt)

end
function base:_Update(dt)
    self:Update(dt)
    for _, var in ipairs(self.children) do
        var:_Update(dt)
    end
end


function base:Remove()
    for _, var in ipairs(self.children) do
        var:Remove()
    end
    for _, var in ipairs(self.father.children) do
        if var == self then
            table.remove(self.father.children, _)
            break
        end
    end
    self = nil
end

function base:CheckCollision(x, y)
    return x > self.absposX and x < self.absposX + self.sizeX and y > self.absposY and y < self.absposY + self.sizeY
end

function base:onInit()
end
function base:onCreate()
end
function base:onPress()
end
function base:onClick()
end
function base:onFailedClick()
end
function base:onRelease()
end
function base:onRemove()
end

-----------------------DOCKING CONVERSION FUNCTIONS------------------------

--West = 1, NorthWest = 2, North = 3, NorthEast = 4, East = 5, SouthEast = 6, South = 7, SouthWest = 8, Center = 9

_df[1] = function(x, y, fx, fy)
    return 0, fy/2 - y/2
end
_df[2] = function(x, y, fx, fy)
    return 0, 0
end
_df[3] = function(x, y, fx, fy)
    return fx/2 - x/2, 0
end
_df[4] = function(x, y, fx, fy)
    return fx-x, 0
end
_df[5] = function(x, y, fx, fy)
    return fx-x, fy/2 - y/2
end
_df[6] = function(x, y, fx, fy)
    return fx-x, fy-y
end
_df[7] = function(x, y, fx, fy)
    return fx/2 - x/2, fy-y
end
_df[8] = function(x, y, fx, fy)
    return 0, fy-y
end
_df[9] = function(x, y, fx, fy)
    return fx/2-x/2, fy/2-y/2
end





return base