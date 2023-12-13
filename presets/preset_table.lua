local ent = {}

ent.rowsize = 5
ent.marginX = 0
ent.marginY = 0
ent.paddingX = 0
ent.paddingY = 0

function ent:AddChild(child)
    table.insert(self.children, child)
    child.father = self
    self:UpdatePlacement()
    return self
end

function ent:SetRowSize(size)
    self.rowsize = size
    self:UpdatePlacement()
end
function ent:GetRowSize()
    return self.rowsize
end

function ent:SetMargin(x, y)
    self.marginX = x
    self.marginY = y
    self:UpdatePlacement()
end
function ent:GetMargin()
    return self.marginX, self.marginY
end
function ent:SetMarginX(x)
    self.marginX = x
    self:UpdatePlacement()
end
function ent:GetMarginX()
    return self.marginX
end
function ent:SetMarginY(y)
    self.marginY = y
    self:UpdatePlacement()
end
function ent:GetMarginY()
    return self.marginY
end

function ent:SetPaddingX(x)
    self.paddingX = x
    self:UpdatePlacement()
end
function ent:SetPaddingY(y)
    self.paddingY = y
    self:UpdatePlacement()
end
function ent:SetPadding(x, y)
    self.paddingX = x
    self.paddingY = y
    self:UpdatePlacement()
end
function ent:GetPaddingX()
    return self.paddingX
end
function ent:GetPaddingY()
    return self.paddingY
end
function ent:GetPadding()
    return self.paddingX, self.paddingY
end

function ent:Lock()
    self.lock = true
end
function ent:Unlock()
    self.lock = false
end

function ent:UpdatePlacement()
    if self.lock then return end
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

            ----TODO: Fix this shit. Rn padding works like shit
            child:SetPos(
                ((self.sizeX-self.marginX/2) / self.rowsize * (x)) + self.marginX + x * self.paddingX,
                (offy) + self.marginY
            )
            _offy = math.max(child:GetSizeY()*1.1, _offy)
        end
        offy = offy + _offy
        y = y + 1
        _x = _x + self.rowsize
    end
end


return ent

