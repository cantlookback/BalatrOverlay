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

    -- Desired dimensions (1920x1080 in this case)
    local desiredWidth = 1920
    local desiredHeight = 1080

    -- Get the current window size
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Calculate the scaling factor
    local scaleX = windowWidth / desiredWidth
    local scaleY = windowHeight / desiredHeight
    local scale = math.min(scaleX, scaleY) -- Use the smaller scale factor to ensure everything fits

    -- Calculate the offsets
    local xoffset = (windowWidth - desiredWidth * scale) / 2
    local yoffset = (windowHeight - desiredHeight * scale) / 2

    love.graphics.print(scale, 10, 30)
    love.graphics.print(xoffset, 10, 50)
    love.graphics.print(yoffset, 10, 70)
    love.graphics.print(windowWidth, 10, 90)
    love.graphics.print(windowHeight, 10, 110)
    
    if (G.hand ~= nil) then
        -- Display overlay boxes
        local combo_box = "----------------------------\n" .. "|                           |\n" ..
                              "|                           |\n" .. "|                           |\n" ..
                              "|                           |\n" .. "|                           |\n" ..
                              "|                           |\n" .. "|                           |\n" ..
                              "|                           |\n" .. "|                           |\n" ..
                              "|                           |\n" .. "|                           |\n" ..
                              "|                           |\n" .. "----------------------------\n"

        local probabilities_box = "----------------------------\n" .. "|                           |\n" ..
                                      "|                           |\n" .. "|                           |\n" ..
                                      "|                           |\n" .. "|                           |\n" ..
                                      "|                           |\n" .. "|                           |\n" ..
                                      "|                           |\n" .. "|                           |\n" ..
                                      "|                           |\n" .. "|                           |\n" ..
                                      "|                           |\n" .. "|                           |\n" ..
                                      "|                           |\n" .. "|                           |\n" ..
                                      "|                           |\n" .. "----------------------------\n"

        -- Insert other states too
        if (G.STATE ~= G.STATES.SHOP and G.STATE ~= G.STATES.BLIND_SELECT) then
            love.graphics.print(combo_box, 500 * scale + xoffset, 300 * scale + yoffset, 0, scale, scale)
            love.graphics.print(probabilities_box, 1650 * scale + xoffset, 300 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Straight-Flush: ", 1670 * scale + xoffset, 330 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Four of a kind: ", 1670 * scale + xoffset, 360 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Full House: ", 1670 * scale + xoffset, 390 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Flush: ", 1670 * scale + xoffset, 420 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Straight: ", 1670 * scale + xoffset, 450 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Three of a kind: ", 1670 * scale + xoffset, 480 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Two pairs: ", 1670 * scale + xoffset, 510 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Pair: ", 1670 * scale + xoffset, 540 * scale + yoffset, 0, scale, scale)
        end

        if (combos ~= nil or combos == {}) then
            for i = 1, #combos do
                love.graphics.print(combos[i], 520 * scale + xoffset, (300 + 20 * i) * scale + yoffset, 0, scale, scale)
            end
        end
        if (combos == {}) then
            love.graphics.print("High card", 520 * scale + xoffset, 350 * scale + yoffset, 0, scale, scale)
        end
    end

    
end

function checkHand()
    if (G.STATE ~= G.STATES.MENU and G.hand.cards ~= nil) then
        -- Add Flush House and check Flush Five

        hasFlush()
        hasStraight() --Straight, Straight-Flush (No Royal Flush)
        hasPairs() -- Two pair, Set, Full House, Four+Five of a kind
    end
end

function hasPairs()
    local counter = {
        ["Ace"] = 0,
        ["King"] = 0,
        ["Queen"] = 0,
        ["Jack"] = 0,
        ["10"] = 0,
        ["9"] = 0,
        ["8"] = 0,
        ["7"] = 0,
        ["6"] = 0,
        ["5"] = 0,
        ["4"] = 0,
        ["3"] = 0,
        ["2"] = 0
    }

    local suitsCounter = {
        ["Ace"] = {},
        ["King"] = {},
        ["Queen"] = {},
        ["Jack"] = {},
        ["10"] = {},
        ["9"] = {},
        ["8"] = {},
        ["7"] = {},
        ["6"] = {},
        ["5"] = {},
        ["4"] = {},
        ["3"] = {},
        ["2"] = {}
    }

    local comboCounter = {
        ["Pair"] = {},
        ["Set"] = {}
    }

    local suits = {"Hearts", "Diamonds", "Spades", "Clubs"}

    for i = 1, #G.hand.cards do
        counter[G.hand.cards[i].base.value] = counter[G.hand.cards[i].base.value] + 1
        table.insert(suitsCounter[G.hand.cards[i].base.value], G.hand.cards[i].base.suit)
    end

    for value, count in pairs(counter) do
        repeat
            if (count >= 5) then
                local suitCounter = 0
                for i = 1, #suits do
                    for i = 1, #suitsCounter[value] do
                        if (suitsCounter[value][i] == suits[i]) then
                            suitCounter = suitCounter + 1
                        end
                    end
                    if (suitCounter == 5) then
                        break
                    else 
                        suitCounter = 0
                    end
                end
                if (suitCounter >= 5) then
                    table.insert(combos, "Flush Five: " .. value .. 's')
                else
                    table.insert(combos, "Five of a kind: " .. value .. 's')
                end
            end
            if (count >= 4) then
                table.insert(combos, "Four of a kind: " .. value .. 's')
            end
            if (count >= 3) then
                table.insert(comboCounter["Set"], value)

            end
            if (count >= 2) then
                table.insert(comboCounter["Pair"], value)
            end
        until true
    end

    for i = 1, #comboCounter["Set"] do
        for j = 1, #comboCounter["Pair"] do
            if (comboCounter["Set"][i] ~= comboCounter["Pair"][j]) then
                table.insert(combos, "Full House: " .. "3x" .. comboCounter["Set"][i] .. " + " .. "2x" ..
                    comboCounter["Pair"][j])
            end
        end
    end
    for i = 1, #comboCounter["Set"] - 1 do
        if (#comboCounter["Set"][i] ~= #comboCounter["Set"][i + 1]) then
            table.insert(combos, "Full House: " .. "3x" .. comboCounter["Set"][i] .. " + " .. "2x" ..
                comboCounter["Set"][i + 1])
        end
    end

    for i = 1, #comboCounter["Pair"] - 1 do
        if (comboCounter["Pair"][i] ~= comboCounter["Pair"][i + 1]) then
            table.insert(combos, "Two pair: " .. "2x" .. comboCounter["Pair"][i] .. " + " .. "2x" ..
                comboCounter["Pair"][i + 1])
        end
    end

end

function hasFlush()
    local counter = {
        ["Spades"] = 0,
        ["Clubs"] = 0,
        ["Diamonds"] = 0,
        ["Hearts"] = 0
    }

    for i = 1, #G.hand.cards do
        counter[G.hand.cards[i].base.suit] = counter[G.hand.cards[i].base.suit] + 1
    end

    for value, count in pairs(counter) do
        if (count >= 5) then
            table.insert(combos, "Flush: " .. value)
        end
    end
end

local cardRanks = {
    ["Ace"] = 13,
    ["King"] = 12,
    ["Queen"] = 11,
    ["Jack"] = 10,
    ["10"] = 9,
    ["9"] = 8,
    ["8"] = 7,
    ["7"] = 6,
    ["6"] = 5,
    ["5"] = 4,
    ["4"] = 3,
    ["3"] = 2,
    ["2"] = 1
}

local function sortByCardRank(a, b)
    return cardRanks[a] > cardRanks[b]
end

function hasStraight()
    local counter = {
        ["Ace"] = 0,
        ["King"] = 0,
        ["Queen"] = 0,
        ["Jack"] = 0,
        ["10"] = 0,
        ["9"] = 0,
        ["8"] = 0,
        ["7"] = 0,
        ["6"] = 0,
        ["5"] = 0,
        ["4"] = 0,
        ["3"] = 0,
        ["2"] = 0
    }

    local counterSuits = {
        ["Ace"] = {},
        ["King"] = {},
        ["Queen"] = {},
        ["Jack"] = {},
        ["10"] = {},
        ["9"] = {},
        ["8"] = {},
        ["7"] = {},
        ["6"] = {},
        ["5"] = {},
        ["4"] = {},
        ["3"] = {},
        ["2"] = {}
    }

    local suits = {"Spades", "Hearts", "Clubs", "Diamonds"}

    local keys = {}
    for k in pairs(counter) do
        table.insert(keys, k)
    end

    table.sort(keys, sortByCardRank)

    for i = 1, #G.hand.cards do
        counter[G.hand.cards[i].base.value] = counter[G.hand.cards[i].base.value] + 1
        table.insert(counterSuits[G.hand.cards[i].base.value], G.hand.cards[i].base.suit)
    end

    local straightLength = 0
    straight = {}
    local suitCount = 0

    for _, key in ipairs(keys) do
        if (straightLength == 5) then
            for i = 1, #suits do
                for j = 1, #straight do
                    for k = 1, #counterSuits[straight[j]] do
                        repeat
                            if (counterSuits[straight[j]][k] == suits[i]) then
                                suitCount = suitCount + 1
                                break
                            end
                        until true
                    end
                end
                if (suitCount >= 5) then
                    table.insert(combos,
                        "Straight-Flush: " .. straight[1] .. ',' .. straight[2] .. ',' .. straight[3] .. ',' ..
                            straight[4] .. ',' .. straight[5])
                    table.remove(straight, 1)
                    straightLength = straightLength - 1
                    suitCount = 0
                else
                    suitCount = 0
                end
            end
            if (straightLength == 5) then
                table.insert(combos, "Straight: " .. straight[1] .. ',' .. straight[2] .. ',' .. straight[3] .. ',' ..
                    straight[4] .. ',' .. straight[5])
                table.remove(straight, 1)
                straightLength = straightLength - 1
            end
        end
        if (counter[key] > 0) then
            straightLength = straightLength + 1
            table.insert(straight, key)
        else
            straightLength = 0
            straight = {}
        end
        if (straightLength == 4 and key == "2" and counter["Ace"] > 0) then
            table.insert(straight, "A")
            table.insert(combos, "Straight: " .. straight[1] .. ',' .. straight[2] .. ',' .. straight[3] .. ',' ..
                straight[4] .. ',' .. straight[5])
        end
    end
end

function calculate()
    if (G.STATE ~= G.STATES.MENU and handCards ~= nil and deckCards ~= nil) then

    end
end

function pairProb()

end

local sec_ref = CardArea.align_cards
function CardArea.align_cards(self)
    sec_ref(self)

    -- local handCards = G.hand.cards
    -- local deckCards = G.deck.cards

    probabilities = {}
    combos = {}

    checkHand()
end

local card_ref = Card.click
function Card.click(self)

    if self.area and self.area:can_highlight(self) then
        calculate()
    end

    card_ref(self)
end

----------------------------------------------
------------MOD CODE END----------------------
