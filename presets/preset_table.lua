local ent = {}

ent.rowsize = 5
ent.marginX = 0
ent.marginY = 0

function ent:AddChild(child)
    table.insert(self.children, child)
    child.father = self
    self:UpdatePlacement()
    return self
end

function ent:SetRowSize(size)
    self.rowsize = size
end
function ent:GetRowSize()
    return self.rowsize
end

function ent:SetMargin(x, y)
    self.marginX = x
    self.marginY = y
end
function ent:GetMargin()
    return self.marginX, self.marginY    
end
function ent:SetMarginX(x)
    self.marginX = x
end
function ent:GetMarginX()
    return self.marginX
end
function ent:SetMarginY(y)
    self.marginY = y
end
function ent:GetMarginY()
    return self.marginY
end

function ent:UpdatePlacement()
    local offy = 0
    local y = 0
    local _x = 0
    while true do
        local _offy = 0
        if not (self.children[_x + 1]) then
            break
        end
        for x = 0, self.rowsize-1 do
            local child = self.children[_x + x + 1]
            if not child then
                break
            end

            child:SetPos(
                ((self.sizeX-self.marginX/2) / self.rowsize * (x)) - (child:GetSizeX() / 2) + self.marginX,
                (offy) - (child:GetSizeY() / 2) + self.marginY
            )
            _offy = math.max(child:GetSizeY()*1.1, _offy)
        end
        offy = offy + _offy
        y = y + 1
        _x = _x + self.rowsize
    end
end


return ent

