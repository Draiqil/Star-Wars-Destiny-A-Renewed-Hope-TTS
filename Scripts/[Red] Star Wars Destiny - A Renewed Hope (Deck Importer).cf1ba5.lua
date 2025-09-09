--[[ SWD ARH DB Deck Importer by Draiqil --]]

deckID = nil
defaultCardBack = "https://steamusercontent-a.akamaihd.net/ugc/102850418890247821/C495C2DA41D081A5CD513AC62BE8F69775DC5ADB/"
pendingWebRequests = 0

function onLoad()

-- Note: All GUIDs automatically update when the objects spawn.

local publishDisclaimer = {
    function_owner = self,
    click_function = "doNothing",
    label = "Deck must be published!",
    tooltip = "",
    position = {-1.75, 0.1, 1.5},
    scale = {0.5, 1, 1},
    color = {0, 1, 0, 0},
    font_size = 75*3,
    font_color = {1, 1, 1, 1},
    width = 2100,
    height = 300 }

	local DeckIDInputField = {
    input_function = "tdeckID",
    function_owner = self,
    position = {-1.75, 0.1, 1},
    scale = {0.5, 1, 1},
    height = 600,
	width = 1750,
    font_size = 500,
    tooltip = "Enter the ID of the deck from ARH db.",
    alignment = 3,
	validation = 2,
    value = "" }

	local loadDeckButton = {
    function_owner = self,
    click_function = "loadDeck",
    label = "Import Deck",
    tooltip = "Click to import deck",
    position = {-1.75, 0.1, 2.2},
    scale = {0.5, 1, 1},
    color = {0, 0, 0, 1},
    font_size = 75*3,
    font_color = {1, 1, 1, 1},
    width = 2100,
    height = 300 }

local loadTutorialButton = {
    function_owner = self,
    click_function = "loadTutorial",
    label = "Tutorial",
    tooltip = "Click to view a brief tutorial example of how to use this importer!",
    position = {-1.75, 0.1, 2.8}, 
    scale = {0.4, 0.6, 0.6},
    color = {0, 0, 0, 1},
    font_size = 75*2,
    font_color = {1, 1, 1, 1},
    width = 2100,
    height = 300 }

  self.createButton(loadDeckButton)
  self.createButton(loadTutorialButton)
  self.createButton(publishDisclaimer)
  self.createInput(DeckIDInputField)


SWDARHISTHEBEST = Global.getTable("SWDARHISTHEBEST")
ttsDeckInfo = Global.getTable("ttsDeckInfo")

end

  bagTemplateJSON = {
    Name = "Bag",
    Transform = {
      posX = 0.0, posY = 2.0, posZ = 0.0, 
	  rotX = 0.0, rotY = 0.0, rotZ = 0.0,
      scaleX = 1.0, scaleY = 1.0, scaleZ = 1.0
    },
    Nickname = "Deck Name",
    Description = "Imported from https://db.swdrenewedhope.com/",
    ColorDiffuse = {
      r = 0.0,
      g = 1.0,
      b = 0.0
    },
    Locked = false,
    Grid = false,
    Snap = false,
    Autoraise = true,
    Sticky = false,
    Tooltip = true,
    MaterialIndex = -1,
    MeshIndex = -1,
    LuaScript = "",
    LuaScriptState = "",
    ContainedObjects = nil,
    GUID = "777777"
  }

function tdeckID(_, _, value, _)
  deckID = value
end

function loadDeck()
	if deckID then
		if #deckID < 5 then -- This is an invalid number or a public deck.
			WebRequest.get("http://db.swdrenewedhope.com/api/public/decklist/" .. deckID .. ".json",
                    function(webRequestInfo) loadDeckCallback(webRequestInfo) end)
		else
			WebRequest.get("http://db.swdrenewedhope.com/api/public/deck/" .. deckID .. ".json",
                    function(webRequestInfo) loadDeckCallback(webRequestInfo) end)
		end

	else end
end

function loadDeckCallback(webRequestInfo)
  local deckInfo
  if webRequestInfo.is_done == true then
    if webRequestInfo then
      deckInfo = JSON.decode(webRequestInfo.text)

      if deckInfo then
		print("Deck loading...")
        spawnLoadedDeck(deckInfo["name"], deckInfo["slots"], function(success, err)
			if not success then
				print ("error") return 

			elseif success then
				print("Deck loaded!")
					end
				end)
			end
		end
	end
end

function spawnLoadedDeck(deckName, deckSlots, onDone)
  onDone = onDone or function() end

  local spawnParams = {}
  local nonDeckCardInfo, deckCardInfo = {}, {}
  local spawnSuccessful = true
  local cardInfo

  if deckSlots then
    for cardCode, slotData in pairs(deckSlots) do
      cardInfo = getCardInfo(cardCode)
      if cardInfo then
        if cardInfo.type == "Character" or cardInfo.type == "Battlefield" or cardInfo.type == "Plot" then
          table.insert(nonDeckCardInfo, { Code = cardCode, Data = slotData, Info = cardInfo })
        else
          table.insert(deckCardInfo,     { Code = cardCode, Data = slotData, Info = cardInfo })
        end
      else
        printToAll("Failed to find card with code " .. cardCode .. ".", {1,0,0})
      end
    end
  else
    printToAll("No cards found in deck.", {1,0,0})
    onDone(false, "no deckSlots")
    return false
  end

  bagTemplateJSON.Nickname = deckName
  bagTemplateJSON.ContainedObjects = {}   -- reset
  pendingWebRequests = 0

  addNonDeckCardsToBagJSON(playerColor, nonDeckCardInfo) 
  addDeckToBagJSON(playerColor, deckCardInfo) 

  spawnParams.position = { -5, 0, -10 }
  spawnParams.rotation = { 0, 0, 0 }

  local function finalize()
    spawnParams.json = JSON.encode(bagTemplateJSON)
    spawnParams.callback_function = function(_obj)
      onDone(spawnSuccessful)
    end
    spawnObjectJSON(spawnParams)
  end

  if pendingWebRequests == 0 then
    finalize()
  else
    Wait.condition(
      finalize,
      function() return pendingWebRequests == 0 end
    )
  end
end

  function loadTutorial() -- Add private deck example

	for _,button in ipairs(self.getButtons()) do
		if button.label == "Tutorial" then self.removeButton(button.index) end
	end

  self.addDecal({
    name     = "tutorialExamplePublic",
    url      = "https://steamusercontent-a.akamaihd.net/ugc/9767813159518328322/868E21CF14E37FFEDF0799CB4143EC1A1064063B/",
    position = {0, 0.5, -3.4}, 
    rotation = {150, 0, 180}, 
    scale    = {8, 1, 2}  
  })

  self.addDecal({
    name     = "tutorialExamplePrivate",
    url      = "https://steamusercontent-a.akamaihd.net/ugc/11670559983945343364/C185EF961BFB2C7DC574468209741AE997528B27/",
    position = {0, 1.5, -3.6},  
    rotation = {150, 0, 180},  
    scale    = {4, 0.8, 2}
  })

  end

function doNothing() end

function getCardInfo(cardCode)
  local returnValue = nil
  for i in ipairs(SWDARHISTHEBEST) do
    if SWDARHISTHEBEST[i]["code"] == cardCode then
      returnValue = SWDARHISTHEBEST[i]
      break
    end
  end
  return returnValue
end

function addNonDeckCardsToBagJSON(playerColor, nonDeckCardInfo)
  local normalCardRotY, battlefieldRotY = 0.0, 270.0
  if playerColor == "Red" then normalCardRotY, battlefieldRotY = 180.0, 90.0 end

  local function addCopies(curCard, copies)
    local cardName = curCard.Info.cardname
    local cardDescription = (curCard.Data.dice == 2)
      and ("elite " .. curCard.Info.set .. " " .. curCard.Info.number)
      or  (curCard.Info.set .. " " .. curCard.Info.number)

    local cardID     = curCard.Info.ttscardid
    local cardDeckID = string.sub(cardID, 1, -3)
    local isBF       = (curCard.Info.type == "Battlefield")
    local actualRotY = isBF and battlefieldRotY or normalCardRotY
    local cardSideways = isBF

    local ttsDeckImage, ttsBackImage, ttsDeckWidth, ttsDeckHeight = nil, nil, 0, 0
    for _, ttsDeck in pairs(ttsDeckInfo) do
      if ttsDeck.ttsdeckid == cardDeckID then
        ttsDeckImage  = ttsDeck.deckimage
        ttsBackImage  = ttsDeck.backimage
        ttsDeckWidth  = ttsDeck.deckwidth
        ttsDeckHeight = ttsDeck.deckheight
        break
      end
    end

    if not ttsDeckImage then
      printToAll("Missing ttsDeckInfo for deckID "..tostring(cardDeckID)..
                 " (from card "..tostring(curCard.Code or cardID)..")", {1,0,0})
    end

    for _ = 1, (tonumber(copies) or 0) do
      local cardJSON = {
        Name = "Card",
        Transform = {
          posX = 0.0, posY = 0.0, posZ = 0.0,
          rotX = 0.0, rotY = actualRotY, rotZ = 0.0,
          scaleX = 1.42, scaleY = 1.00, scaleZ = 1.42
        },
        Nickname = cardName,
        Description = cardDescription,
        ColorDiffuse = { r = 0.713235259, g = 0.713235259, b = 0.713235259 },
        Locked = false, Grid = false, Snap = true, Autoraise = true, Sticky = true, Tooltip = true,
        CardID = cardID,
        SidewaysCard = cardSideways,
        CustomDeck = {},
        LuaScript = "",
        LuaScriptState = "",
        GUID = "700000"
      }

      if ttsDeckImage and ttsBackImage then
        cardJSON.CustomDeck[tostring(cardDeckID)] = {
          FaceURL = ttsDeckImage, BackURL = ttsBackImage,
          NumWidth = ttsDeckWidth, NumHeight = ttsDeckHeight,
          BackIsHidden = true, UniqueBack = true
        }
      elseif ttsDeckImage then
        cardJSON.CustomDeck[tostring(cardDeckID)] = {
          FaceURL = ttsDeckImage,
          BackURL = "https://steamusercontent-a.akamaihd.net/ugc/1738926104371934193/C495C2DA41D081A5CD513AC62BE8F69775DC5ADB/",
          NumWidth = ttsDeckWidth, NumHeight = ttsDeckHeight,
          BackIsHidden = true, UniqueBack = false
        }
      end

      table.insert(bagTemplateJSON.ContainedObjects, cardJSON)
    end
  end

  for _, curCard in pairs(nonDeckCardInfo) do
    local qty = tonumber(curCard.Data.quantity) or 1

    if qty > 1 then
      -- async path only when we might need to clamp to 1
      pendingWebRequests = pendingWebRequests + 1
      local url = "http://db.swdrenewedhope.com/api/public/card/" .. curCard.Code .. ".json"
      WebRequest.get(url, function(wr)
        local finalQty = qty
        -- decode safely; ALWAYS reach the decrement
        if wr and not wr.is_error and wr.text and wr.text ~= "" then
          local ok, data = pcall(function() return JSON.decode(wr.text) end)
          if ok and data and data.is_unique == true then finalQty = 1 end
        else
          -- log and keep original qty
          printToAll("Lookup failed for code "..tostring(curCard.Code), {1,0,0})
        end

        addCopies(curCard, finalQty)
        pendingWebRequests = pendingWebRequests - 1  -- once per request
      end)
    else
      addCopies(curCard, 1)
    end
  end
end

function addDeckToBagJSON(playerColor, deckCardInfo)
  local deckJSON = nil
  local cardJSON = nil
  local cardName = nil
  local cardDescription = nil
  local cardID = 0
  local cardDeckID = 0
  local actualRotY = 0.0
  local ttsDeckImage = nil
  local ttsDeckWidth = 0
  local ttsDeckHeight = 0

  -- For the red player, rotate the cards.
  if playerColor == "Red" then
    actualRotY = 180.0
  end

  deckJSON = {
    Name = "Deck",
    Transform = {
      posX = 0.0,
      posY = 0.0,
      posZ = 0.0,
      rotX = 0.0,
      rotY = actualRotY,
      rotZ = 180.0,
      scaleX = 1.42,
      scaleY = 1.00,
      scaleZ = 1.42
    },
    Nickname = "",
    Description = "",
    ColorDiffuse = {
      r = 0.713235259,
      g = 0.713235259,
      b = 0.713235259
    },
    Locked = false,
    Grid = false,
    Snap = false,
    Autoraise = true,
    Sticky = true,
    Tooltip = true,
    SidewaysCard = false,
    DeckIDs = {},
    CustomDeck = {},
    LuaScript = "",
    LuaScriptState = "",
    ContainedObjects = {},
    GUID = "800000"
  }

  for _,curCard in pairs(deckCardInfo) do
    for cardCopy=1,curCard.Data.quantity do
      cardName = curCard.Info.cardname
      cardDescription = curCard.Info.set .. " " .. curCard.Info.number
      cardID = curCard.Info.ttscardid
      cardDeckID = string.sub(cardID, 1, -3)
      cardJSON = {
        Name = "Card",
        Transform = {
          posX = 0.0,
          posY = 0.0,
          posZ = 0.0,
          rotX = 0.0,
          rotY = actualRotY,
          rotZ = 0.0,
          scaleX = 1.42,
          scaleY = 1.00,
          scaleZ = 1.42
        },
        Nickname = cardName,
        Description = cardDescription,
        ColorDiffuse = {
          r = 0.713235259,
          g = 0.713235259,
          b = 0.713235259
        },
        Locked = false,
        Grid = false,
        Snap = true,
        Autoraise = true,
        Sticky = true,
        Tooltip = true,
        CardID = cardID,
        SidewaysCard = false,
        CustomDeck = nil,
        LuaScript = "",
        LuaScriptState = "",
        GUID = "700000"
      }

      table.insert(deckJSON.DeckIDs, cardID)

      if deckJSON.CustomDeck[tostring(cardDeckID)] == nil then
        ttsDeckImage = nil
        ttsDeckWidth = 0
        ttsDeckHeight = 0

        for _,ttsDeck in pairs(ttsDeckInfo) do
          if ttsDeck.ttsdeckid == cardDeckID then
            ttsDeckImage = ttsDeck.deckimage
            ttsDeckWidth = ttsDeck.deckwidth
            ttsDeckHeight = ttsDeck.deckheight
			ttsBackImage = ttsDeck.backimage
            break
          end
        end
		
        if ttsDeckImage and ttsBackImage then
          deckJSON.CustomDeck[tostring(cardDeckID)] = {
            FaceURL = ttsDeckImage,
            BackURL = ttsBackImage,
            NumWidth = ttsDeckWidth,
            NumHeight = ttsDeckHeight,
            BackIsHidden = true,
            UniqueBack = true
          }

		elseif ttsDeckImage and not ttsBackImage then
          deckJSON.CustomDeck[tostring(cardDeckID)] = {
            FaceURL = ttsDeckImage,
            BackURL = "https://steamusercontent-a.akamaihd.net/ugc/1738926104371934193/C495C2DA41D081A5CD513AC62BE8F69775DC5ADB/",
            NumWidth = ttsDeckWidth,
            NumHeight = ttsDeckHeight,
            BackIsHidden = true,
            UniqueBack = false
          }
      end
	end

      table.insert(deckJSON.ContainedObjects, cardJSON)
    end
  end

  table.insert(bagTemplateJSON.ContainedObjects, deckJSON)
end