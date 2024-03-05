--- STEAMODDED HEADER
--- MOD_NAME: BalatrOverlay
--- MOD_ID: BalOver
--- MOD_AUTHOR: [cantlookback]
--- MOD_DESCRIPTION: Helpful game overlay
----------------------------------------------
------------MOD CODE -------------------------
local test_ref = love.draw

function love.draw(self)
    test_ref(self)
    if (size ~= nil) then
        love.graphics.print(size, 10, 10)
    end
end

local key_ref = love.keypressed
function love.keypressed(self, key, scancode, isrepeat)
    if key == "tab" then
        if G.STATE == G.STATES.SELECTING_HAND then
            size = 0
            
            for _, v in ipairs(G.deck.cards) do
                size = size + 1
            end
            
        end
    end
    key_ref(self, key, scancode, isrepeat)
end
----------------------------------------------
------------MOD CODE END----------------------