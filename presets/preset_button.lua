local ent = {}

ent.sizeX = 0
ent.sizeY = 0

function ent:Paint()
    if self.Texture then
        love.graphics.draw(self.Texture)
    end
end

function ent:SetTexture(texture)
    if type(texture) == "string" then
        texture = love.graphics.newImage(texture)
    end
    self.Texture = texture
end

function ent:onClick(x, y)
    if type(self.reaction) == "function" then
        self.reaction(self, x, y)
    else
        if self:GetFather().React then
            self:GetFather():React(self.reaction or self, x, y)
        end
    end
end

function ent:SetCustomReaction(reaction)
    self.reaction = reaction
end


return ent