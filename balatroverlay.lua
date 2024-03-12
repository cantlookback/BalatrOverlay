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
            love.graphics.print(combo_box, 500, 300)
            love.graphics.print(probabilities_box, 1650, 300)
            love.graphics.print("Straight-Flush: ", 1670, 330)
            love.graphics.print("Four of a kind: ", 1670, 360)
            love.graphics.print("Full House: ", 1670, 390)
            love.graphics.print("Flush: ", 1670, 420)
            love.graphics.print("Straight: ", 1670, 450)
            love.graphics.print("Three of a kind: ", 1670, 480)
            love.graphics.print("Two pairs: ", 1670, 510)
            love.graphics.print("Pair: ", 1670, 540)
        end

        if (combos ~= nil or combos == {}) then
            for i = 1, #combos do
                love.graphics.print(combos[i], 520, 300 + 20 * i)
            end
        end
        if (combos == {}) then
            love.graphics.print("High card", 520, 350)
        end
    end
end

function checkHand()
    if (G.STATE ~= G.STATES.MENU and G.hand.cards ~= nil) then
        -- ALSO ADD SPECIAL COMBOS LIKE FIVE_OF_A_KIND ETC.

        -- hasStraightFlush() --Put in hasStraight()??
        hasFlush()
        hasStraight()
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

    comboCounter = {
        ["Pair"] = {},
        ["Set"] = {}
    }

    for i = 1, #G.hand.cards do
        counter[G.hand.cards[i].base.value] = counter[G.hand.cards[i].base.value] + 1
    end

    for value, count in pairs(counter) do
        repeat
            if (count >= 5) then
                table.insert(combos, "Five of a kind: " .. value .. 's')
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

    local keys = {}
    for k in pairs(counter) do
        table.insert(keys, k)
    end

    table.sort(keys, sortByCardRank)

    for i = 1, #G.hand.cards do
        counter[G.hand.cards[i].base.value] = counter[G.hand.cards[i].base.value] + 1
    end

    local straightLength = 0
    local straight = {}

    for _, key in ipairs(keys) do
        if (straightLength == 5) then
            table.insert(combos, "Straight: " .. straight[1] .. ',' .. straight[2] .. ',' .. straight[3] .. ',' ..
                straight[4] .. ',' .. straight[5])
            break
        end
        if (counter[key] > 0) then
            straightLength = straightLength + 1
            if (key == "Jack" or key == "Queen" or key == "King" or key == "Ace") then
                table.insert(straight, string.sub(key, 1, 1))

            else
                table.insert(straight, key)
            end
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
    if (G.STATE ~= G.STATES.MENU and G.hand.cards ~= nil) then
        probabilities = {}
        cards = G.hand.cards
    end
end

local sec_ref = CardArea.align_cards
function CardArea.align_cards(self)
    sec_ref(self)

    combos = {}
    checkHand()
    calculate()
end

local card_ref = Card.click
function Card.click(self)

    if self.area and self.area:can_highlight(self) then

    end

    card_ref(self)
end

----------------------------------------------
------------MOD CODE END----------------------
