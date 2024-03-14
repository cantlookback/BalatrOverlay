--- STEAMODDED HEADER
--- MOD_NAME: BalatrOverlay
--- MOD_ID: balover
--- MOD_AUTHOR: [cantlookback]
--- MOD_DESCRIPTION: Helpful game overlay
----------------------------------------------
------------MOD CODE -------------------------
local load_ref = love.resize
function love.resize(self, w, h)
    local desiredWidth = 1920
    local desiredHeight = 1080

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local scaleX = windowWidth / desiredWidth
    local scaleY = windowHeight / desiredHeight
    scale = math.min(scaleX, scaleY)

    xoffset = (windowWidth - desiredWidth * scale) / 2
    yoffset = (windowHeight - desiredHeight * scale) / 2
    quad = love.graphics.newQuad(72, 0, 72, 95, 497, 475)
    load_ref(self, w, h)
end

local test_ref = love.draw
function love.draw(self)
    test_ref(self)

    if (G.hand ~= nil and scale ~= nil) then
        -- Display overlay boxes and data

        if (not G.deck_preview and not G.OVERLAY_MENU and G.STATE ~= G.STATES.GAME_OVER and G.STATE ~=
            G.STATES.NEW_ROUND and G.STATE ~= G.STATES.SHOP and G.STATE ~= G.STATES.BLIND_SELECT and G.STATE ~=
            G.STATES.ROUND_EVAL) then

            -- Boxes
            love.graphics.setColor(1, 1, 1, 0.5)
            -- Combo box
            love.graphics.draw(G.ASSET_ATLAS["centers"].image, quad, 500 * scale + xoffset, 300 * scale + yoffset, 0,
                scale * 3.5, scale * 3)

            -- Probabilities box
            love.graphics.draw(G.ASSET_ATLAS["centers"].image, quad, 1650 * scale + xoffset, 300 * scale + yoffset, 0,
                scale * 3.5, scale * 3)

            -- Evaluate box
            love.graphics.draw(G.ASSET_ATLAS["centers"].image, quad, 800 * scale + xoffset, 300 * scale + yoffset, 0,
                scale * 5, scale)

            -- Data
            love.graphics.setColor(0, 0, 0, 1)
            -- Combos
            if (combos ~= nil) then
                for i = 1, #combos do
                    love.graphics.print(combos[i], 510 * scale + xoffset, (300 + 20 * i) * scale + yoffset, 0, scale,
                        scale)
                end
            end

            -- Probabilities
            love.graphics.print("Straight-Flush: ", 1670 * scale + xoffset, 320 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Four of a Kind: ", 1670 * scale + xoffset, 350 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Full House: ", 1670 * scale + xoffset, 380 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Flush: ", 1670 * scale + xoffset, 410 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Straight: ", 1670 * scale + xoffset, 440 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Three of a Kind: ", 1670 * scale + xoffset, 470 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Two Pair: ", 1670 * scale + xoffset, 500 * scale + yoffset, 0, scale, scale)
            love.graphics.print("Pair: ", 1670 * scale + xoffset, 530 * scale + yoffset, 0, scale, scale)

            -- Evaluate hand
            if (hand_chips ~= nil) then
                love.graphics.print(hand_chips * mult .. " Chips", 860 * scale + xoffset, 325 * scale + yoffset, 0,
                    scale * 2, scale * 2)
            end

        end
    end

end

function checkHand()
    if (G.STATE ~= G.STATES.MENU and G.hand.cards ~= nil) then
        -- Add Flush House and check Flush Five

        hasFlush()
        hasStraight() -- Straight, Straight-Flush (No Royal Flush)
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
                    table.insert(combos, "Five of a Kind: " .. value .. 's')
                end
            end
            if (count >= 4) then
                table.insert(combos, "Four of a K0ind: " .. value .. 's')
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

    for i = 1, #comboCounter["Set"] do
        table.insert(combos, "Three of a Kind: " .. "3x" .. comboCounter["Set"][i])
    end

    for i = 1, #comboCounter["Pair"] - 1 do
        if (comboCounter["Pair"][i] ~= comboCounter["Pair"][i + 1]) then
            table.insert(combos, "Two Pair: " .. "2x" .. comboCounter["Pair"][i] .. " + " .. "2x" ..
                comboCounter["Pair"][i + 1])
        end
    end

    if (#combos == 0 and #comboCounter["Pair"] > 0) then
        table.insert(combos, "Pair: " .. "2x" .. comboCounter["Pair"][1])
    end

    if (#combos == 0) then
        if (counter["Ace"] > 0) then
            table.insert(combos, "High Card: " .. "Ace")
            return true
        end
        if (counter["King"] > 0) then
            table.insert(combos, "High Card: " .. "King")
            return true
        end
        if (counter["Queen"] > 0) then
            table.insert(combos, "High Card: " .. "Queen")
            return true
        end
        if (counter["Jack"] > 0) then
            table.insert(combos, "High Card: " .. "Jack")
            return true
        end
        for key, value in pairs(counter) do
            if (value > 0) then
                table.insert(combos, "High Card: " .. key)
                break
            end
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

function evaluatePlay()
    text, disp_text, poker_hands, scoring_hand, non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

    G.GAME.hands[text].played = G.GAME.hands[text].played + 1
    G.GAME.hands[text].played_this_round = G.GAME.hands[text].played_this_round + 1
    G.GAME.last_hand_played = text
    set_hand_usage(text)
    G.GAME.hands[text].visible = true

    -- Add all the pure bonus cards to the scoring hand
    local pures = {}
    for i = 1, #G.play.cards do
        if next(find_joker('Splash')) then
            scoring_hand[i] = G.play.cards[i]
        else
            if G.play.cards[i].ability.effect == 'Stone Card' then
                local inside = false
                for j = 1, #scoring_hand do
                    if scoring_hand[j] == G.play.cards[i] then
                        inside = true
                    end
                end
                if not inside then
                    table.insert(pures, G.play.cards[i])
                end
            end
        end
    end
    for i = 1, #pures do
        table.insert(scoring_hand, pures[i])
    end
    table.sort(scoring_hand, function(a, b)
        return a.T.x < b.T.x
    end)

    local percent = 0.3
    local percent_delta = 0.08

    if not G.GAME.blind:debuff_hand(G.play.cards, poker_hands, text) then
        mult = mod_mult(G.GAME.hands[text].mult)
        hand_chips = mod_chips(G.GAME.hands[text].chips)

        if G.GAME.first_used_hand_level and G.GAME.first_used_hand_level > 0 then
            level_up_hand(G.deck.cards[1], text, nil, G.GAME.first_used_hand_level)
            G.GAME.first_used_hand_level = nil
        end

        local hand_text_set = false
        for i = 1, #G.jokers.cards do
            -- Calculate the joker effects
            local effects = eval_card(G.jokers.cards[i], {
                cardarea = G.jokers,
                full_hand = G.play.cards,
                scoring_hand = scoring_hand,
                scoring_name = text,
                poker_hands = poker_hands,
                before = true
            })
            if effects.jokers then
                percent = percent + percent_delta
                if effects.jokers.level_up then
                    level_up_hand(G.jokers.cards[i], text)
                end
            end
        end

        mult = mod_mult(G.GAME.hands[text].mult)
        hand_chips = mod_chips(G.GAME.hands[text].chips)

        local modded = false

        mult, hand_chips, modded = G.GAME.blind:modify_hand(G.play.cards, poker_hands, text, mult, hand_chips)
        mult, hand_chips = mod_mult(mult), mod_chips(hand_chips)

        for i = 1, #scoring_hand do
            -- Add cards played to list
            if scoring_hand[i].ability.effect ~= 'Stone Card' then
                G.GAME.cards_played[scoring_hand[i].base.value].total =
                    G.GAME.cards_played[scoring_hand[i].base.value].total + 1
                G.GAME.cards_played[scoring_hand[i].base.value].suits[scoring_hand[i].base.suit] = true
            end
            -- If card is debuffed
            if scoring_hand[i].debuff then
                G.GAME.blind.triggered = true
            else
                -- Check for play doubling
                local reps = {1}

                -- From Red seal
                local eval = eval_card(scoring_hand[i], {
                    repetition_only = true,
                    cardarea = G.play,
                    full_hand = G.play.cards,
                    scoring_hand = scoring_hand,
                    scoring_name = text,
                    poker_hands = poker_hands,
                    repetition = true
                })
                if next(eval) then
                    for h = 1, eval.seals.repetitions do
                        reps[#reps + 1] = eval
                    end
                end
                -- From jokers
                for j = 1, #G.jokers.cards do
                    -- calculate the joker effects
                    local eval = eval_card(G.jokers.cards[j], {
                        cardarea = G.play,
                        full_hand = G.play.cards,
                        scoring_hand = scoring_hand,
                        scoring_name = text,
                        poker_hands = poker_hands,
                        other_card = scoring_hand[i],
                        repetition = true
                    })
                    if next(eval) and eval.jokers then
                        for h = 1, eval.jokers.repetitions do
                            reps[#reps + 1] = eval
                        end
                    end
                end
                for j = 1, #reps do
                    percent = percent + percent_delta

                    -- calculate the hand effects
                    local effects = {eval_card(scoring_hand[i], {
                        cardarea = G.play,
                        full_hand = G.play.cards,
                        scoring_hand = scoring_hand,
                        poker_hand = text
                    })}
                    for k = 1, #G.jokers.cards do
                        -- calculate the joker individual card effects
                        local eval = G.jokers.cards[k]:calculate_joker({
                            cardarea = G.play,
                            full_hand = G.play.cards,
                            scoring_hand = scoring_hand,
                            scoring_name = text,
                            poker_hands = poker_hands,
                            other_card = scoring_hand[i],
                            individual = true
                        })
                        if eval then
                            table.insert(effects, eval)
                        end
                    end
                    scoring_hand[i].lucky_trigger = nil

                    for ii = 1, #effects do
                        -- If chips added, do chip add event and add the chips to the total
                        if effects[ii].chips then
                            if effects[ii].card then
                                ass = 1 -- ASS 
                            end
                            hand_chips = mod_chips(hand_chips + effects[ii].chips)
                        end

                        -- If mult added, do mult add event and add the mult to the total
                        if effects[ii].mult then
                            mult = mod_mult(mult + effects[ii].mult)
                        end

                        -- Any extra effects
                        if effects[ii].extra then
                            local extras = {
                                mult = false,
                                hand_chips = false
                            }
                            if effects[ii].extra.mult_mod then
                                mult = mod_mult(mult + effects[ii].extra.mult_mod);
                                extras.mult = true
                            end
                            if effects[ii].extra.chip_mod then
                                hand_chips = mod_chips(hand_chips + effects[ii].extra.chip_mod);
                                extras.hand_chips = true
                            end
                            if effects[ii].extra.swap then
                                local old_mult = mult
                                mult = mod_mult(hand_chips)
                                hand_chips = mod_chips(old_mult)
                                extras.hand_chips = true;
                                extras.mult = true
                            end
                        end

                        -- If x_mult added, do mult add event and mult the mult to the total
                        if effects[ii].x_mult then
                            mult = mod_mult(mult * effects[ii].x_mult)
                        end

                        -- calculate the card edition effects
                        if effects[ii].edition then
                            hand_chips = mod_chips(hand_chips + (effects[ii].edition.chip_mod or 0))
                            mult = mult + (effects[ii].edition.mult_mod or 0)
                            mult = mod_mult(mult * (effects[ii].edition.x_mult_mod or 1))
                        end
                    end
                end
            end
        end

        local mod_percent = false
        for i = 1, #G.hand.cards do
            if mod_percent then
                percent = percent + percent_delta
            end
            mod_percent = false

            -- Check for hand doubling
            local reps = {1}
            local j = 1
            while j <= #reps do

                -- calculate the hand effects
                local effects = {eval_card(G.hand.cards[i], {
                    cardarea = G.hand,
                    full_hand = G.play.cards,
                    scoring_hand = scoring_hand,
                    scoring_name = text,
                    poker_hands = poker_hands
                })}

                for k = 1, #G.jokers.cards do
                    -- calculate the joker individual card effects
                    local eval = G.jokers.cards[k]:calculate_joker({
                        cardarea = G.hand,
                        full_hand = G.play.cards,
                        scoring_hand = scoring_hand,
                        scoring_name = text,
                        poker_hands = poker_hands,
                        other_card = G.hand.cards[i],
                        individual = true
                    })
                    if eval then
                        mod_percent = true
                        table.insert(effects, eval)
                    end
                end

                if reps[j] == 1 then
                    -- Check for hand doubling

                    -- From Red seal
                    local eval = eval_card(G.hand.cards[i], {
                        repetition_only = true,
                        cardarea = G.hand,
                        full_hand = G.play.cards,
                        scoring_hand = scoring_hand,
                        scoring_name = text,
                        poker_hands = poker_hands,
                        repetition = true,
                        card_effects = effects
                    })
                    if next(eval) and (next(effects[1]) or #effects > 1) then
                        for h = 1, eval.seals.repetitions do
                            reps[#reps + 1] = eval
                        end
                    end

                    -- From Joker
                    for j = 1, #G.jokers.cards do
                        -- calculate the joker effects
                        local eval = eval_card(G.jokers.cards[j], {
                            cardarea = G.hand,
                            full_hand = G.play.cards,
                            scoring_hand = scoring_hand,
                            scoring_name = text,
                            poker_hands = poker_hands,
                            other_card = G.hand.cards[i],
                            repetition = true,
                            card_effects = effects
                        })
                        if next(eval) then
                            for h = 1, eval.jokers.repetitions do
                                reps[#reps + 1] = eval
                            end
                        end
                    end
                end

                for ii = 1, #effects do
                    -- if this effect came from a joker
                    if effects[ii].card then
                        mod_percent = true
                    end

                    -- If hold mult added, do hold mult add event and add the mult to the total

                    if effects[ii].h_mult then
                        mod_percent = true
                        mult = mod_mult(mult + effects[ii].h_mult)
                    end

                    if effects[ii].x_mult then
                        mod_percent = true
                        mult = mod_mult(mult * effects[ii].x_mult)
                    end

                    if effects[ii].message then
                        mod_percent = true
                    end
                end
                j = j + 1
            end
        end
        -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        -- Joker Effects
        -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        percent = percent + percent_delta
        for i = 1, #G.jokers.cards + #G.consumeables.cards do
            local _card = G.jokers.cards[i] or G.consumeables.cards[i - #G.jokers.cards]
            -- calculate the joker edition effects
            local edition_effects = eval_card(_card, {
                cardarea = G.jokers,
                full_hand = G.play.cards,
                scoring_hand = scoring_hand,
                scoring_name = text,
                poker_hands = poker_hands,
                edition = true
            })
            if edition_effects.jokers then
                edition_effects.jokers.edition = true
                if edition_effects.jokers.chip_mod then
                    hand_chips = mod_chips(hand_chips + edition_effects.jokers.chip_mod)
                end
                if edition_effects.jokers.mult_mod then
                    mult = mod_mult(mult + edition_effects.jokers.mult_mod)
                end
                percent = percent + percent_delta
            end

            -- calculate the joker effects
            local effects = eval_card(_card, {
                cardarea = G.jokers,
                full_hand = G.play.cards,
                scoring_hand = scoring_hand,
                scoring_name = text,
                poker_hands = poker_hands,
                joker_main = true
            })

            -- Any Joker effects
            if effects.jokers then
                local extras = {
                    mult = false,
                    hand_chips = false
                }
                if effects.jokers.mult_mod then
                    mult = mod_mult(mult + effects.jokers.mult_mod);
                    extras.mult = true
                end
                if effects.jokers.chip_mod then
                    hand_chips = mod_chips(hand_chips + effects.jokers.chip_mod);
                    extras.hand_chips = true
                end
                if effects.jokers.Xmult_mod then
                    mult = mod_mult(mult * effects.jokers.Xmult_mod);
                    extras.mult = true
                end

                percent = percent + percent_delta
            end

            -- Joker on Joker effects
            for _, v in ipairs(G.jokers.cards) do
                local effect = v:calculate_joker{
                    full_hand = G.play.cards,
                    scoring_hand = scoring_hand,
                    scoring_name = text,
                    poker_hands = poker_hands,
                    other_joker = _card
                }
                if effect then
                    local extras = {
                        mult = false,
                        hand_chips = false
                    }
                    if effect.mult_mod then
                        mult = mod_mult(mult + effect.mult_mod);
                        extras.mult = true
                    end
                    if effect.chip_mod then
                        hand_chips = mod_chips(hand_chips + effect.chip_mod);
                        extras.hand_chips = true
                    end
                    if effect.Xmult_mod then
                        mult = mod_mult(mult * effect.Xmult_mod);
                        extras.mult = true
                    end
                    percent = percent + percent_delta
                end
            end

            if edition_effects.jokers then
                if edition_effects.jokers.x_mult_mod then
                    mult = mod_mult(mult * edition_effects.jokers.x_mult_mod)
                end
                percent = percent + percent_delta
            end
        end

        mult = mod_mult(nu_mult or mult)
        hand_chips = mod_chips(nu_chip or hand_chips)

    else
        mult = mod_mult(0)
        hand_chips = mod_chips(0)

        -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        -- Joker Debuff Effects
        -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        for i = 1, #G.jokers.cards do

            -- calculate the joker effects
            local effects = eval_card(G.jokers.cards[i], {
                cardarea = G.jokers,
                full_hand = G.play.cards,
                scoring_hand = scoring_hand,
                scoring_name = text,
                poker_hands = poker_hands,
                debuffed_hand = true
            })

            -- Any Joker effects
            if effects.jokers then
                card_eval_status_text(G.jokers.cards[i], 'jokers', nil, percent, nil, effects.jokers)
                percent = percent + percent_delta
            end
        end
    end

    for i = 1, #G.jokers.cards do
        -- calculate the joker after hand played effects
        local effects = eval_card(G.jokers.cards[i], {
            cardarea = G.jokers,
            full_hand = G.play.cards,
            scoring_hand = scoring_hand,
            scoring_name = text,
            poker_hands = poker_hands,
            after = true
        })
        if effects.jokers then
            card_eval_status_text(G.jokers.cards[i], 'jokers', nil, percent, nil, effects.jokers)
            percent = percent + percent_delta
        end
    end
end

local draw_ref = G.FUNCS.draw_from_discard_to_deck
function G.FUNCS.draw_from_discard_to_deck(self, e)
    draw_ref(self, e)
    mult = 0
    hand_chips = 0
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

    card_ref(self)
    if (#G.hand.highlighted ~= 0) then
        evaluatePlay()
    end

end

----------------------------------------------
------------MOD CODE END----------------------
