--- STEAMODDED HEADER
--- MOD_NAME: BalatrOverlay
--- MOD_ID: balover
--- MOD_AUTHOR: [cantlookback]
--- MOD_DESCRIPTION: Helpful game overlay
----------------------------------------------
------------MOD CODE -------------------------

local test_ref = love.draw

function love.draw(self)
    test_ref(self)
    love.graphics.print("Overlay for Balatro", 10, 10) -- Draw some text for example
end

----------------------------------------------
------------MOD CODE END----------------------