local ent = {}
ent.offy = 0
ent.offx = 0
ent.scrollable = true
ent.scrollmulti = 1

function ent:onScroll(x, y)
    self.offy = self.offy + (y*self.scrollmulti)
    self.offx = self.offx + (x*self.scrollmulti)
end

function ent:GetScroll()
    return self.offx, self.offy
end
function ent:GetScrollX()
    return self.offx
end
function ent:GetScrollY()
    return self.offy
end

function ent:ResetScroll()
    self.offy = 0
    self.offx = 0
end

function ent:Draw()
    if not self.disable then
        love.graphics.push("all")
        love.graphics.translate(self.posX, self.posY)
        love.graphics.scale(self.scale)
        if not self.IgnoreScissors then
            love.graphics.intersectScissor(self.absposX, self.absposY, self.sizeX, self.sizeY)
        end
        self:Paint()
        if DEBUG_WIREFRAME then
            love.graphics.line(0, 0, self.sizeX, 0, self.sizeX, self.sizeY, 0, self.sizeY, 0, 0)
            love.graphics.line(0, 0, self.sizeX, self.sizeY)
            love.graphics.line(self.sizeX, 0, 0, self.sizeY)
        end
        love.graphics.translate(self.offx, self.offy)
        for _, var in ipairs(self.children) do
            --love.graphics.intersectScissor(self.paddingX, self.paddingY, self.sizeX-self.paddingX, self.sizeY-self.paddingY)
            love.graphics.push("all")
            var:Draw()
            love.graphics.pop()
        end
        love.graphics.pop()
    end
end

return ent