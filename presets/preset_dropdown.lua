local ent = {}

ent.sizeX = 70
ent.sizeY = 25

function ent:Paint()
    love.graphics.setColor(love.math.colorFromBytes(251, 252, 253))
    love.graphics.rectangle("fill", 0, 0, self.sizeX, self.sizeY, 1)

    love.graphics.setColor(love.math.colorFromBytes(220, 221, 222))
    love.graphics.rectangle("line", 0, 0, self.sizeX, self.sizeY, 1)
    love.graphics.line(26, 2, 26, self.sizeY-4)
end

function ent:AddEntry(type, name)
    local entry
    if type == "Check" then
        entry = self:NewCheckEntry()
    end
    assert(entry, "Incorrect entry type!")
    entry:SetText(name)
    entry:SetPos(4, 4)
    self:SetSizeX(math.max(self:GetSizeX(), entry:GetSizeX()+8))
    return entry
end


----------------------------------------------------------------


local check_entry = {}
check_entry.sizeX = 64
check_entry.sizeY = 20
check_entry.Texture = love.graphics.newImage("assets/menu/icon_check.png")
check_entry.toggled = false
function check_entry:Paint()
    if self.toggled then
        love.graphics.setColor(love.math.colorFromBytes(206, 229, 252))
        love.graphics.rectangle("fill", 0, 0, 20, 20)
        love.graphics.setColor(love.math.colorFromBytes(100, 165, 230))
        love.graphics.rectangle("line", 0, 0, 20, 20)
        love.graphics.draw(self.Texture, 5, 6)
    end
    if self.text then
        love.graphics.print(self.text, 31, 6)
    end
end

function check_entry:onClick()
    self.toggled = not self.toggled
    self:onStateChange(self.toggled)
end
function check_entry:GetState()
    return self.toggled
end
function check_entry:SetText(str)
    self.text = str
end
function check_entry:onStateChange(state)
end


----------------------------------------------------------------



function ent:Init(ui)
    ent.NewCheckEntry = ui.Compile(check_entry)
end



return ent