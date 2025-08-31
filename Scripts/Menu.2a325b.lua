--[[

CREDITS [In no particular order]

Agent of Zion
AceJon - Primary maintainer for the ARH community 2021-2025
AgentElrond
Draiqil

]]--

function onLoad()
  self.setPosition({0,-4,0})
  math.randomseed(os.time()) math.random() math.random() math.random()

  allExpansionLegendaries  = {}
  allExpansionRares        = {}
  allExpansionUncommons    = {}
  allExpansionCommons      = {}
  expansions               = { 'AW', 'SoR', 'EaW', 'LEG', 'WotF', 'AtG', 'CONV', 'SoH', 'CM', 'FA', 'RM', 'HS', 'UH', 'SA'}

  draftOriginDeckZone      = nil
  rivalsDummyCardGuid      = '72db11'
  rivalsDummyCard          = getObjectFromGUID(rivalsDummyCardGuid) rivalsDummyCard.setLock(true) rivalsDummyCard.interactable = false
  rivalsDeckZoneGuid       = '2410f1'
  rivalsDeckGuid           = 'fd83c6'
  alliesDeckGuid           = 'bd365e'
  cubeBoardGuid            = 'c51c41'
  cubeDeckZoneGuid         = 'b9d302'
  cubeBoard                = getObjectFromGUID(cubeBoardGuid)
  cubeBoard.interactable   = false
  cubeDeckZone             = getObjectFromGUID(cubeDeckZoneGuid)
  cubeDeck                 = nil
  cubeCompatibilityMode    = false
  packSelections           = { 'RM', 'RM', 'RM', 'RM', 'RM', 'RM', 'RM', 'RM' }
  packSelectButtons        = nil
  numPacksPerPlayer        = 6
  rivalsExpansion          = nil
  nextExpansionIndex       = {}
  rivalsExpansionPacks     = {}

  Global.setVar("rivalsDeckZoneGuid", rivalsDeckZoneGuid)

  blueBoardsPrefab         = nil
  redBoardsPrefab          = nil
  blueResourceZone         = nil
  blueBattlefieldZone      = nil
  blueMatZone              = nil
  redResourceZone          = nil
  redBattlefieldZone       = nil
  redMatZone               = nil

  setupObject = getObjectFromGUID('771f25')
  dataObject = getObjectFromGUID('409015')

  Global.UI.setAttribute("main_menu_panel", "active", true)
  red                      = nil
  blue                     = nil
end

function setupStandard()
    Global.setVar("Mode", "Standard")
    Global.setVar("mainMenuPanelOpen", false) Global.UI.setAttribute("main_menu_panel", "active", false)
	Wait.frames(function() startLuaCoroutine(self, 'setupStandardCoroutine') end, 5)
end

function setupStandardCoroutine()
  local obj_parameters = {}
  local seatData = Global.getTable("seatData")

  local matObject
  for _,someSeat in pairs(seatData) do
    matObject = getObjectFromGUID(someSeat.matGuid)
    if matObject then
      matObject.destruct() end -- Destruct all draft mats.
  end

  -- Scale all hand zones down so they don't grab cards.
  for i,someSeat in pairs(seatData) do
    local handTransform = Player[i].getHandTransform()
    handTransform.scale.x = 0.01 handTransform.scale.y = 0.01 handTransform.scale.z = 0.01
    Player[i].setHandTransform(handTransform)
  end

  -- Adjust the red and blue hand zones to be usable.
  local handTransform = Player["Red"].getHandTransform()
  handTransform.position.x = -1.70 handTransform.position.y = 4.60 handTransform.position.z = (-20.00)
  handTransform.rotation.x = 0.00 handTransform.rotation.y = 0.00 handTransform.rotation.z = 0.00
  handTransform.scale.x = 25.00 handTransform.scale.y = 6.65 handTransform.scale.z = 4.00
  Player["Red"].setHandTransform(handTransform)

  handTransform = Player["Blue"].getHandTransform()
  handTransform.position.x = 1.70 handTransform.position.y = 4.60 handTransform.position.z = 20.00
  handTransform.rotation.x = 0.00 handTransform.rotation.y = 180.00 handTransform.rotation.z = 0.00
  handTransform.scale.x = 25.00 handTransform.scale.y = 6.65 handTransform.scale.z = 4.00
  Player["Blue"].setHandTransform(handTransform)

  if #getSeatedPlayers() <= 2 then
	for _,player in ipairs(Player.getPlayers()) do playerChanged = false
		if player.color ~= "Red" and player.color ~= "Blue" then
			if not Player["Red"].seated then player.changeColor("Red") playerChanged = true
			elseif not Player["Blue"].seated and playerChanged == false then player.changeColor("Blue") end
			end		
	end
		else print("The current system can only handle 2 seated players before setup.")
	end

  Global.call("handleNormalGameStarted")

  -- Create a scripting zone for resources.
  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.position = {-23.00, -4.00, 0.32}
  obj_parameters.rotation = {0.00, 0.00, 0.00}
  obj_parameters.scale = {5.50, 5.10, 8.00}
  blueResourceZone = spawnObject(obj_parameters)
  -- Create a scripting zone for the battlefield.
  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.position = {-18.39, -4.00, 0.27}
  obj_parameters.rotation = {0.00, 0.00, 0.00}
  obj_parameters.scale = {4.60, 5.10, 3.40}
  blueBattlefieldZone = spawnObject(obj_parameters)
  -- Create a scripting zone for the mat.
  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.position = {4.82, -4.00, 10.20}
  obj_parameters.rotation = {0.00, 0.00, 0.00}
  obj_parameters.scale = {41.22, 1.00, 12.46}
  blueMatZone = spawnObject(obj_parameters)

  if Global.getVar("boardStyle") == "board_super_black" then
    blueBoardsPrefab = setupObject.takeObject({position={-20.85, -3.00, 10.05}, rotation={0,180,0}, guid=Global.getVar("blueBoardsBlackGuid"), flip=false, smooth=false})
  else
    blueBoardsPrefab = setupObject.takeObject({position={-20.85, -3.00, 10.05}, rotation={0,180,0}, guid=Global.getVar("blueBoardsTransparentGuid"), flip=false, smooth=false})
  end
  blueBoardsPrefab.use_gravity = false
  blueBoardsPrefab.interactable = false
  blueBoardsPrefab.setLock(true)
  blueBoardsPrefab.setName("Blue")
  blueBoardsPrefab.tooltip = false
  blueBoardsPrefab.setLuaScript(modernBoardsScript)
  blueBoardsPrefab.createButton({
    click_function="blueClaimBattlefield", function_owner=Global,
    position={2.56, 0.14, 6.89}, width=1400, height=720, font_size=72, color={0,0,0,0}
  })

  -- Create a scripting zone for resources.
  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.position = {23.00, -4.00, -0.32}
  obj_parameters.rotation = {0.00, 0.00, 0.00}
  obj_parameters.scale = {5.50, 5.10, 8.00}
  redResourceZone = spawnObject(obj_parameters)
  -- Create a scripting zone for the battlefield.
  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.position = {18.39, -4.00, -0.27}
  obj_parameters.rotation = {0.00, 0.00, 0.00}
  obj_parameters.scale = {4.60, 5.10, 3.40}
  redBattlefieldZone = spawnObject(obj_parameters)
  -- Create a scripting zone for the mat.
  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.position = {-4.82, -4.00, -10.20}
  obj_parameters.rotation = {0.00, 0.00, 0.00}
  obj_parameters.scale = {41.22, 1.00, 12.46}
  redMatZone = spawnObject(obj_parameters)

  if Global.getVar("boardStyle") == "board_super_black" then
    redBoardsPrefab = setupObject.takeObject({position={20.85, -3.00, -10.05}, rotation={0,0,0}, guid=Global.getVar("redBoardsBlackGuid"), flip=false, smooth=false})
  else
    redBoardsPrefab = setupObject.takeObject({position={20.85, -3.00, -10.05}, rotation={0,0,0}, guid=Global.getVar("redBoardsTransparentGuid"), flip=false, smooth=false})
  end
  redBoardsPrefab.use_gravity = false
  redBoardsPrefab.interactable = false
  redBoardsPrefab.setLock(true)
  redBoardsPrefab.setName("Red")
  redBoardsPrefab.tooltip = false
  redBoardsPrefab.setLuaScript(modernBoardsScript)
  redBoardsPrefab.createButton({
    click_function="redClaimBattlefield", function_owner=Global,
    position={2.56, 0.14, 6.89}, width=1400, height=720, font_size=72, color={0,0,0,0}
  })

  coroutine.yield(0)
  coroutine.yield(0)

  Wait.time(movePlayerBoards, 0.5)

  setupObject.destruct()
  self.destruct()

  return 1
end

-- The below script gets applied during runtime.
modernBoardsScript = [=[
function onload()
  -- Load inside the script since global images do not work for players who join late.
  local resourceAssets = {
    { name = "blue_battlefield_claim", url = "https://steamusercontent-a.akamaihd.net/ugc/952959000918851189/EE82D1A6844C4548CDA3AA486D91D00BE7FFE048/" },
	{ name = "red_battlefield_claim", url = "https://steamusercontent-a.akamaihd.net/ugc/952959000918850667/5CBF41F8886AC21025405DE4568BE998F478165E/" },
    { name = "ingame_gui_background", url = "https://steamusercontent-a.akamaihd.net/ugc/948454725666385380/A47369F346253BDE02F44153C4940D47AA0E6E67/" },
    { name = "ingame_blue_panel_overlay", url = "https://steamusercontent-a.akamaihd.net/ugc/948454725666384731/E921F14A80CFA7C3BC20C7D7C61D7319443D0169/" },
    { name = "ingame_red_panel_overlay", url = "https://steamusercontent-a.akamaihd.net/ugc/948454725666389779/69DCF9BD43E89F93351F7F2F8E87D5CFFD7E3EF7/" },
    { name = "", url = "https://steamusercontent-a.akamaihd.net/ugc/948454725666387411/82FAD658AECC1F80A3413BEB32A2971FF168E4BF/" },
    { name = "ingame_gui_resource", url = "https://steamusercontent-a.akamaihd.net/ugc/948454725666388925/ACEB3703278FB7DFB707BFE2DE931571529BD372/" },
    { name = "ingame_gui_pass", url = "https://steamusercontent-a.akamaihd.net/ugc/948454725666388357/43FDE0C7B097A67D681F9D35D91535A8EA66F3EE/" },
    { name = "ingame_gui_shuffle", url = "https://steamusercontent-a.akamaihd.net/ugc/948454725666389375/842D3237A768D7171668FCD28264F81C30BFEE0D/" },
    { name = "ingame_gui_discard", url = "https://steamusercontent-a.akamaihd.net/ugc/948454725666386672/85210903AED7A7F638BA6784A45A042013DD28FC/" },
  }
  self.UI.setCustomAssets(resourceAssets)

  tokenplayerone = Global.getTable('tokenplayerone')
  tokenplayertwo = Global.getTable('tokenplayertwo')

  if self.getName() == 'Blue' then owner = 'Blue'
  else owner = 'Red'end

  if owner == 'Blue' then
    self.UI.setXml([[
<Button
  id="blue_claim_button"
  visibility="Blue"
  active="true"
  position="-255 690 -3"
  rotation="0 0 0"
  scale="3.5 3.5"
  fontSize="20"
  width="80"
  height="40"
  image="blue_battlefield_claim"
  raycastTarget="false"
></Button>
<Panel
   id="blue_panel"
   visibility="Blue"
   active="false"
   position="0 -300 -5"
   rotation="0 0 0"
   scale="5.46 5.46"
   rectAlignment="MiddleCenter"
   width="80"
   height="96"
   image="ingame_gui_background"
   raycastTarget="false"
>
<Image
   offsetXY="0 34"
   width="80"
   height="24"
   image="ingame_blue_panel_overlay"
   raycastTarget="false"
></Image>

<Text
   id="blue_panel_red_cards"
   scale="0.3 0.3"
   offsetXY="-6 39"
   fontStyle="Bold"
   fontSize="36"
   color="#FFFFFF"
>0</Text>

<Text
   id="blue_panel_blue_cards"
   scale="0.3 0.3"
   offsetXY="-6 29"
   fontStyle="Bold"
   fontSize="36"
   color="#FFFFFF"
>0</Text>

<Text
   id="blue_panel_red_resources"
   scale="0.3 0.3"
   offsetXY="24 39"
   fontStyle="Bold"
   fontSize="36"
   color="#FFFFFF"
>0</Text>

<Text
   id="blue_panel_blue_resources"
   scale="0.3 0.3"
   offsetXY="24 29"
   fontStyle="Bold"
   fontSize="36"
   color="#FFFFFF"
>0</Text>

<Button
   offsetXY="33 42"
   width="5"
   height="5"
   onClick="Global/guiToggle"
   image="ingame_gui_maximize"
></Button>

<Button
   offsetXY="-18 7"
   width="28"
   height="28"
   onClick="Global/guiResource"
   image="ingame_gui_resource"
></Button>

<Button
   offsetXY="18 7"
   width="28"
   height="28"
   onClick="Global/guiPass"
   image="ingame_gui_pass"
></Button>

<Button
   offsetXY="-18 -28"
   width="28"
   height="28"
   onClick="Global/guiShuffle"
   image="ingame_gui_shuffle"
></Button>

<Button
   offsetXY="18 -28"
   width="28"
   height="28"
   onClick="Global/guiDiscard"
   image="ingame_gui_discard"
   fontSize="32"
   textColor="#000000"
></Button> </Panel>
]])
  else
    self.UI.setXml([[
<Button
  id="red_claim_button"
  visibility="Red"
  active="true"
  position="-255 690 -3"
  rotation="0 0 0"
  scale="3.5 3.5"
  fontSize="20"
  width="80"
  height="40"
  image="red_battlefield_claim"
  raycastTarget="false"
></Button>
<Panel
   id="red_panel"
   visibility="Red"
   active="false"
   position="0 -300 -5"
   rotation="0 0 0"
   scale="5.46 5.46"
   rectAlignment="MiddleCenter"
   width="80"
   height="96"
   image="ingame_gui_background"
   raycastTarget="false"
>
<Image
   offsetXY="0 34"
   width="80"
   height="24"
   image="ingame_red_panel_overlay"
   raycastTarget="false"
></Image>
<Text
   id="red_panel_blue_cards"
   scale="0.3 0.3"
   offsetXY="-6 39"
   fontStyle="Bold"
   fontSize="36"
   color="#FFFFFF"
>0</Text>
<Text
   id="red_panel_red_cards"
   scale="0.3 0.3"
   offsetXY="-6 29"
   fontStyle="Bold"
   fontSize="36"
   color="#FFFFFF"
>0</Text>
<Text
   id="red_panel_blue_resources"
   scale="0.3 0.3"
   offsetXY="24 39"
   fontStyle="Bold"
   fontSize="36"
   color="#FFFFFF"
>0</Text>
<Text
   id="red_panel_red_resources"
   scale="0.3 0.3"
   offsetXY="24 29"
   fontStyle="Bold"
   fontSize="36"
   color="#FFFFFF"
>0</Text>
<Button
   offsetXY="33 42"
   width="5"
   height="5"
   onClick="Global/guiToggle"
   image="ingame_gui_maximize"
></Button>
<Button
   offsetXY="-18 7"
   width="28"
   height="28"
   onClick="Global/guiResource"
   image="ingame_gui_resource"
></Button>
<Button
   offsetXY="18 7"
   width="28"
   height="28"
   onClick="Global/guiPass"
   image="ingame_gui_pass"
></Button>
<Button
   offsetXY="-18 -28"
   width="28"
   height="28"
   onClick="Global/guiShuffle"
   image="ingame_gui_shuffle"
></Button>
<Button
   offsetXY="18 -28"
   width="28"
   height="28"
   onClick="Global/guiDiscard"
   image="ingame_gui_discard"
   fontSize="32"
   textColor="#000000"
></Button> </Panel>
]])
  end

  resourceSpawnIndex = 0
  discardCounter = 0
end

function passButton()
  if owner == 'Blue' then broadcastToAll('Blue passes!', {0.1,0.5,1.0})
  else broadcastToAll('Red passes!', {0.8,0.1,0.1}) end
end

function resourceSpawned(newResource)
  newResource.setName("Resource")
  newResource.tooltip = false
end

function spawnResource(clickType)

  if clickType == '-1' then
  local zoneObject = nil
  local zonePosition = {}
  local spawnReference = {x=0, y=0, z=0}
  local obj_parameters = {}
  local custom = {}
  local token = nil
  local xFactor = 1
  local zFactor = 1

  if owner == 'Blue' then
    zoneObject = Global.getVar("blueResourceZone")
    if (zoneObject != nil) then
      zonePosition = zoneObject.getPosition()
      spawnReference = {x = (zonePosition.x + 1.54), y = (zonePosition.y - 1.00), z = (zonePosition.z + 1.29)}
    end

    xFactor = (-1)
    zFactor = (-1)
  else
    zoneObject = Global.getVar("redResourceZone")
    if (zoneObject != nil) then
      zonePosition = zoneObject.getPosition()
      spawnReference = {x = (zonePosition.x - 1.54), y = (zonePosition.y - 1.00), z = (zonePosition.z - 1.29)}
    end

    xFactor = 1
    zFactor = 1
  end

  obj_parameters.type = 'Custom_Token'
  obj_parameters.callback_function = resourceSpawned
  obj_parameters.position = {}
  obj_parameters.position.x = (spawnReference.x + (xFactor * (resourceSpawnIndex % 4)))
  obj_parameters.position.y = spawnReference.y
  obj_parameters.position.z = (spawnReference.z + (zFactor * math.floor(resourceSpawnIndex / 4)))
  obj_parameters.rotation = {0,0,0}

  custom.image = tokenplayerone.resource
  custom.thickness = 0.1
  custom.merge_distance = 5.0
  custom.stackable = false

  token = spawnObject(obj_parameters)
  token.setCustomObject(custom)
  token.scale {0.23, 1.00, 0.23}

  resourceSpawnIndex = (resourceSpawnIndex + 1) -- This is how it determines incremental spawn margin of resources.
  if resourceSpawnIndex >= 20 then
    resourceSpawnIndex = 0
  	end
  end
end

function randomDiscard()
  local handObjects = Player[owner].getHandObjects()
  local numHandObjects = #handObjects
  local discardPosition = {}
  local cardChoice = nil

  if numHandObjects > 0 then
    cardChoice = math.random(numHandObjects)

    if owner == 'Blue' then
      discardPosition.x = (-26.29)
      discardPosition.y = 2.20
      discardPosition.z = (6.59 + discardCounter)
    else
      discardPosition.x = 26.29
      discardPosition.y = 2.20
      discardPosition.z = ((-6.59) - discardCounter)
    end

    -- Teleport first to avoid the hand zone grabbing the card back.
    handObjects[cardChoice].setPosition(discardPosition)
    -- Now move fast with no collision using smooth motion so that the card will fall.
    discardPosition.y = (discardPosition.y - 0.20)
    handObjects[cardChoice].setPositionSmooth(discardPosition, false, true)

    discardCounter = (discardCounter + 1)
    if discardCounter >= 5 then
      discardCounter = 0
    end
  end
end

function shuffleHand()
  local handObjects = Player[owner].getHandObjects()
  local numHandObjects = #handObjects
  local cardPositions = {}

  if numHandObjects > 0 then
    for i, v in pairs(handObjects) do
        cardPositions[i] = v.getPosition()
    end
    local handObjectsShuffled = shuffleTable(handObjects)
    local cardPositionsShuffled = shuffleTable(cardPositions)
    for i, v in pairs(handObjectsShuffled) do
        v.setPosition(cardPositionsShuffled[i])
    end
  end
end

function shuffleTable(t)
    for i = #t, 2, -1 do
        local n = math.random(i)
        t[i], t[n] = t[n], t[i]
    end
    return t
end

function onDrop(playerColor)
  local objectPosition = self.getPosition()
  local battlefieldZone = nil
  local resourceZone = nil
  local matZone = nil

  -- Update zones to match the board position.

  if (owner == 'Blue') then
    battlefieldZone = Global.getVar("blueBattlefieldZone")
    resourceZone = Global.getVar("blueResourceZone")
    matZone = Global.getVar("blueMatZone")

    if battlefieldZone != nil then
      battlefieldZone.setPosition({x = (objectPosition.x + 2.43), y = (objectPosition.y + 1.50), z = (objectPosition.z - 9.73)})
    end

    if resourceZone != nil then
      resourceZone.setPosition({x = (objectPosition.x - 2.18), y = (objectPosition.y + 1.50), z = (objectPosition.z - 9.68)})
    end

    if matZone != nil then
      matZone.setPosition({x = (objectPosition.x + 25.64), y = (objectPosition.y + 2.50), z = (objectPosition.z + 0.20)})
    end
  else
    battlefieldZone = Global.getVar("redBattlefieldZone")
    resourceZone = Global.getVar("redResourceZone")
    matZone = Global.getVar("redMatZone")

    if battlefieldZone != nil then
      battlefieldZone.setPosition({x = (objectPosition.x - 2.43), y = (objectPosition.y + 1.50), z = (objectPosition.z + 9.73)})
    end

    if resourceZone != nil then
      resourceZone.setPosition({x = (objectPosition.x + 2.18), y = (objectPosition.y + 1.50), z = (objectPosition.z + 9.68)})
    end

    if matZone != nil then
      matZone.setPosition({x = (objectPosition.x - 25.64), y = (objectPosition.y + 2.50), z = (objectPosition.z - 0.20)})
    end
  end
end

function handlePossibleDiceSpawn(params)
  local cardSet = ''
  local cardNumber = ''
  local position = self.getPosition()
  local owningPlayerColor = params.owningPlayerColor
  local object = params.cardObject
  local obj_parameters = {}
  local custom = {}
  local SWDARHISTHEBEST = Global.getTable("SWDARHISTHEBEST")

  obj_parameters.type = 'Custom_Dice'
  obj_parameters.scale = {1.7,1.7,1.7}
  obj_parameters.position = {object.getPosition()[1],object.getPosition()[2]+1,object.getPosition()[3]}
  obj_parameters.rotation = {0,object.getRotation()[2]+180,0}

  if ((object.getVar("spawned") ~= true) and
      (object.tag == 'Card') and
      (Global.getVar("loadDelayFinished") == true)) then
    local cardFound = false
    local isDiceCard = false
    local isCharacterCard = false
    local cardDescription = object.getDescription()
    local cardDescriptionLength = 0
    local testCardType = nil
    local dataTableIndex = 1
    local isElite = false
	local rotationZ = object.getRotation().z

    if cardDescription != nil then
      cardDescriptionLength = string.len(cardDescription)
      if string.sub(cardDescription, 1, 5) == 'elite' then
        isElite = true
      end
    end

    -- If there is text past "elite", or the card is not elite and there is text at all, the card uses the new format.
    if (((isElite == true) and (cardDescriptionLength > 5)) or
        ((isElite == false) and (cardDescriptionLength > 0))) then
      -- This is a new card export.  Extract the set and number.
      local setCharIndex = 1
      local numberCharIndex = 1
      if (isElite == true) then
        setCharIndex = 7
      else
        setCharIndex = 1
      end

      -- Do a plain search.
      numberCharIndex = (string.find(cardDescription, ' ', setCharIndex, true) + 1)
      cardSet = string.sub(cardDescription, setCharIndex, (numberCharIndex - 2))
      -- Leaving out the third argument takes a substring to the end of the string.
      cardNumber = string.sub(cardDescription, numberCharIndex)

      -- Find the card by its set and number.
      for i in ipairs(SWDARHISTHEBEST) do
        testCardType = SWDARHISTHEBEST[i]["type"]

        if ((SWDARHISTHEBEST[i]["set"] == cardSet) and
            (SWDARHISTHEBEST[i]["number"] == cardNumber) and
            ((testCardType == 'Upgrade') or (testCardType == 'Downgrade') or (testCardType == 'Plot') or (testCardType == 'Character') or (testCardType == 'Support') or (testCardType == 'Battlefield'))) then
          cardFound = true
          dataTableIndex = i

          if (SWDARHISTHEBEST[i]["diceimage"] != nil) then
            isDiceCard = true
          end

          break
        end
      end

      local diceSpawnDebug = Global.getVar("diceSpawnDebug")

      if (cardFound == false) then
        if diceSpawnDebug == true then
          printToAll("Error, card " .. cardSet .. " " .. cardNumber .. " not found (make sure it is not a support).", {1,0,0})
        end
      end
    else
      -- This may be an old card export.  Do nothing.
    end

    if (cardFound == true) then
      -- For character cards, spawn the dice on the table for ease of rollout.
      zOffset = 0
      if (SWDARHISTHEBEST[dataTableIndex]["type"] == 'Character') then
        isCharacterCard = true
        if (owner == 'Blue') then
          zOffset = (-6)
        else
          zOffset = 5
        end
      end

      object.setVar("spawned", true)
      if (isDiceCard == true) then
        obj_parameters.position[3] = (obj_parameters.position[3] + zOffset)
        local dice = spawnObject(obj_parameters)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        dice.setCustomObject(custom)
      end

      if ((cardSet == 'EaW') and (cardNumber == '10')) then
        -- For EaW Seventh Sister, spawn an ID9 Seeker Droid die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/869614883116891249/E95F6BDCAD82D95AEEFF7798BA2EB89013F1C530/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

     elseif ((cardSet == 'WotF') and (cardNumber == '128')) then
        -- For WotF Ammo Reserves, spawn 3 damage tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.damageone
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end

      elseif ((cardSet == 'CONV') and (cardNumber == '18')) then
        -- For CONV Captain Phasma, spawn 2 First Order Stormtrooper dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/940587492855532900/1228C3F5E9F9ADF45DC65F9E14C5448B0A7006B1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/940587492855532900/1228C3F5E9F9ADF45DC65F9E14C5448B0A7006B1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AW') and (cardNumber == '99')) then
        -- For AW Backup Muscle, spawn 3 damage tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}

        for i=1,3 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.damageone
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end

      elseif ((cardSet == 'LEG') and (cardNumber == '70')) then
        -- For LEG Modified HWK-290, spawn 2 damage tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}

        for i=1,2 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.damageone
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end

      elseif ((cardSet == 'SoR') and (cardNumber == '124')) then
        -- For SoR Air Superiority, spawn 3 shield tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}

        for i=1,3 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.shield
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end

      elseif ((cardSet == 'CONV') and (cardNumber == '31')) then
        -- For CONV Megablaster Troopers, spawn a First Order Stormtrooper die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/940587492855532900/1228C3F5E9F9ADF45DC65F9E14C5448B0A7006B1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '85')) then
        -- For AF Anakin's Spirit, spawn a Darth Vader die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/937205659715959521/EEB265C565C4D19B03B95E29E3383255D154DE5D/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '90')) then
        -- For AF Senate Guard, spawn a Stun Baton die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910157197472462168/B3286FC5C47D12E529035AE6246DF9EB43A98F0D/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '18')) then
        -- For AF Morgan Elspeth, spawn a Thrawn die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/771720478341861471/B936B387387095363632D20FE9A437EC52896F78/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '37')) then
        -- For AF Cumulus-Class Corsair, spawn a Snub Fighter die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/hdcWOIe.png"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '58')) then
        -- For AF Jan Dodonna, spawn a Rebel Trooper die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/147885549582781089/21E1106177BD4C9C67CAACA5FFC310E4A3B39C31/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'DoP') and (cardNumber == '23')) then
        -- For DoP Executor, spawn a Planetary Bombardment die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910172009674812868/54D81E914D64B52CB27DD8EE91F1B2FF74C9F31C/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'DoP') and (cardNumber == '56')) then
        -- For DoP Aayla, spawn a Clone Trooper die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910157197472418178/7C0B5FF88FF25AACA93F475486ADB0C41FA6758F/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'DoP') and (cardNumber == '116')) then
        -- For DoP Jawa Trade Route, spawn a Jawa Scavenger die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/866244165279375107/78A625BE6D642B8F8DE5DCC602DC05FFBC549368/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'DoP') and (cardNumber == '33')) then
        -- For DoP Rook Kast, spawn Mando Commando and Maul dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/948453532242773388/D3672474872AF3718C016EE0ED82EE3F6DEBEFE6/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/771720478341846336/2BD67269B1D301F475942CF572E6812F3AF98727/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '25')) then
        -- For SA Star Destroyer, spawn 3 TIE Fighter dice on the card.
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "http://i.imgur.com/EyA8opr.jpg"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "http://i.imgur.com/EyA8opr.jpg"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+2, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "http://i.imgur.com/EyA8opr.jpg"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '47')) then
        -- For SA Big Rey, spawn Luke & Leia dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/257091088004693948/C3986CEC4CDD4F70FB3443F041B97029E0BFC2C4/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665906525/FA09A4229B293A483BE7E61F425F039FD32C99F1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '46')) then
        -- For SA Little Rey, spawn Big Rey, Luke & Leia dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/257091088004693948/C3986CEC4CDD4F70FB3443F041B97029E0BFC2C4/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665906525/FA09A4229B293A483BE7E61F425F039FD32C99F1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+2, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/Acly8BM.png"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '5')) then
        -- For SA Snoke, spawn Citadel Lab dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/5IpkCCs.png"
        extradice.setCustomObject(custom)

      elseif ((cardSet == 'SA') and (cardNumber == '6')) then
        -- For SA Citadel Lab, spawn Snoke Lab dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/6Aa7jH1.png"
        extradice.setCustomObject(custom)

      elseif ((cardSet == 'SA') and (cardNumber == '55')) then
        -- For Jedi Temple Guards, make it elite.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/tFVFtMl.png"
        extradice.setCustomObject(custom)

      elseif ((cardSet == 'SA') and (cardNumber == '63')) then
        -- For SA Tallissan, spawn A-Wing dice on the card.
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/934964008673137645/2460E379D583CB6ACE6103EAD12601FEDE413A48/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '69')) then
        -- For SA Venator, spawn 2 ARC-170 dice on the card.
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/948454029952543079/F680053EC03D7D1DF28D2E891A92236E10B7CF20/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/948454029952543079/F680053EC03D7D1DF28D2E891A92236E10B7CF20/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '101')) then
        -- For SA Tusken Camp, spawn 2 Tusken Raider dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/194046562282923028/7D7DC21B0F1EF2458857FA71648AAD7FA95913C0/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/194046562282923028/7D7DC21B0F1EF2458857FA71648AAD7FA95913C0/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '1')) then
        -- For RES Allya, spawn a Nightsister die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/194046562282917283/7BC2002A4274F4AF6C429256B5BB7F1B34BDB6C8/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '25')) then
        -- For RES ISB Central Office, spawn an ISB Agent die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://drive.google.com/uc?id=1iE1GdTIc5nbuQdTfpBfJI_9p8Sb2tG6s"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '26')) then
        -- For RES Pre-Mor Enforcers, spawn a Conscript Squad die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/949605779489070002/508DC7B151C3C66CD421CBB1E573166460BF8EBA/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '49')) then
        -- For RES Desperate Power, spawn a Force Retaliation die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/FyShEtk.png"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '105')) then
        -- For RES Going Somewhere, Solo? spaw a Greedo and a Han Solo die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910157197472405292/985BD94742BE2FE3891CA1C988B8244D805BA7A6/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/771720478341882755/66F677DD426228E54F0D768DDFCAB03E117D3192/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]


      elseif ((cardSet == 'UH') and (cardNumber == '4')) then
        -- For UH Ren, spawn a Servant of the darkside die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/869614971447060228/C85E02EF69DD550F2CC533307AD77CA8BCDCE44F/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'UH') and (cardNumber == '68')) then
        -- For UH The Bad Batch spaw a Clone Trooper and a Rebel Engineer die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910157197472418178/7C0B5FF88FF25AACA93F475486ADB0C41FA6758F/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/952969527667705761/79E1A1F84406DE5C07021C7FAF771C7BE8F69154/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

	  elseif ((cardSet == 'RM') and (cardNumber == '60')) then
        -- For RED Redemption, spawn a Medical Droid die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/858354911724420112/984FA39EC5929853F0C047FFF70FAE9D1FCCF425/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

		obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/858354911724420112/984FA39EC5929853F0C047FFF70FAE9D1FCCF425/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

	  elseif ((cardSet == 'RM') and (cardNumber == '3')) then
        -- For RED Maul 3A, spawn Maul 3B.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665912771/B520C11D5753DAE3B5455576138FA8DEF5584208/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

	   elseif ((cardSet == 'RM') and (cardNumber == '5')) then
        -- For RED Savage 4A, spawn Savage 4B.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665924865/D0CB98B795A6D75799BC24A508D19CD2C4D58D1F/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

	  elseif ((cardSet == 'RM') and (cardNumber == '12')) then
        -- For RED Watch Your Career With Great Interest, spawn Vader 10B.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665890223/25CA88EAB9BA70883B8965011A0FD15ACC889F53/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

	  elseif ((cardSet == 'RM') and (cardNumber == '95')) then
        -- For RED The Ultimate Heist, spawn Master of Pirates 92B.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226666159528/4B0F30C9946F8613850FEF6B157E6A6FBAB7C182/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

	  elseif ((cardSet == 'RM') and (cardNumber == '91')) then
        -- For RED Hondo Ohnaka, spawn a Pirate Loyalist die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665917819/ACF3309D19EE7E9768FFC8CCEE7008D69900941E/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

		obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665917819/ACF3309D19EE7E9768FFC8CCEE7008D69900941E/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

	  elseif ((cardSet == 'RM') and (cardNumber == '26')) then
        -- For RED Blizzard, spawn an extra die.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665885478/CDC41216758A6B0519A5C8981B38AF01112674D9/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'CONV') and (cardNumber == '172')) then
        -- For CONV Sonic Detonators, spawn 6 resource tokens on the card.
        local spawnXOffset = -1.7
        local spawnZOffset = -1.72

        if owningPlayerColor == "Red" then
           spawnXOffset = -1.16
           spawnZOffset = 1.03
        end

        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = { object.getPosition()[1]+spawnXOffset+(i*0.7), object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset }
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
        for i=1,3 do
          obj_parameters.position = { object.getPosition()[1]+spawnXOffset+(i*0.7), object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset+0.70 }
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
    --  elseif ((cardSet == 'AoN') and (cardNumber == '17')) then
        -- For AoN LR-57 Combat Droid, spawn 1 resource token on the card.
      --  obj_parameters.type = 'Custom_Token'
      --  obj_parameters.rotation = {3.87674022, 0, 0.239081308}
      --  obj_parameters.scale = {0.227068469, 1, 0.227068469}
      --  obj_parameters.position = {object.getPosition()[1]-0.8,object.getPosition()[2]+0.2,object.getPosition()[3]-0.8}
      --  local token = spawnObject(obj_parameters)
      --  local custom = {}
      --  custom.image = tokenplayerone.resource
      --  custom.thickness = 0.1
      --  custom.merge_distance = 5.0
      --  custom.stackable = false
      --  token.setCustomObject(custom)


    elseif ((cardSet == 'HS') and (cardNumber == '77')) then
     -- For HS Whistling birds spawn a resource token on the card.
      obj_parameters.type = 'Custom_Token'
      obj_parameters.rotation = {3.87674022, 0, 0.239081308}
      obj_parameters.scale = {0.227068469, 1, 0.227068469}
      obj_parameters.position = {object.getPosition()[1]-0.8,object.getPosition()[2]+0.2,object.getPosition()[3]-0.8}
      local token = spawnObject(obj_parameters)
      local custom = {}
      custom.image = tokenplayerone.resource
      custom.thickness = 0.1
      custom.merge_distance = 5.0
      custom.stackable = false
      token.setCustomObject(custom)



      elseif ((cardSet == 'SoH') and (cardNumber == '71')) then
        -- For SoH Three Lessons, spawn 3 resource tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      elseif ((cardSet == 'SoH') and (cardNumber == '5')) then
        -- For SoH Old Daka, spawn a SoH Nightsister Zombie.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
      elseif ((cardSet == 'FA') and (cardNumber == '63')) then
        -- For Merrin, spawn a SoH Nightsister Zombie.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  
		Global.call("spawnCard")
		elseif ((cardSet == 'RM') and (cardNumber == '9')) then
        -- For Chant of Resurrection, spawn 3 SoH Nightsister Zombie.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '16')) then
        -- For General Veers, spawn a Snowtrooper.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "15017",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '25')) then
        -- For 501st Assault Team, spawn a E-Web Emplacement.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "02005",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '48')) then
        -- For You Will Go To The Dagobah System, spawn a Jedi Trials.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "12065",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '52')) then
        -- For Admiral Ackbar , spawn a X-Wing.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "08086",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

                                 elseif ((cardSet == 'RM') and (cardNumber == '52')) then
                                     -- For Admiral Ackbar , spawn a X-Wing.
                                     local spawnXOffset = -7.0
                                     local spawnZOffset = 2.3

                                     if owningPlayerColor == "Red" then
                                        spawnXOffset = 7.0
                                        spawnZOffset = -2.3
                                     end

                                     Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                cardCode = "08086",
                                                                spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })


	  elseif ((cardSet == 'RM') and (cardNumber == '53')) then
        -- For Bothan Spy , spawn a Death Star Plans then kill him.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "12126",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })


                                 elseif ((cardSet == 'HS') and (cardNumber == '98')) then
                                     -- For Greef Karga , spawn a Bounty Board.
                                     local spawnXOffset = -7.0
                                     local spawnZOffset = 2.3

                                     if owningPlayerColor == "Red" then
                                        spawnXOffset = 7.0
                                        spawnZOffset = -2.3
                                     end

                                     Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                cardCode = "09047",
                                                                spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

                                elseif ((cardSet == 'AF') and (cardNumber == '48')) then
                                    -- For Cere Junda , spawn a Jedi Archives.
                                    local spawnXOffset = -7.0
                                    local spawnZOffset = 2.3

                                    if owningPlayerColor == "Red" then
                                       spawnXOffset = 7.0
                                       spawnZOffset = -2.3
                                    end

                                    Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                               cardCode = "23053",
                                                               spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                               spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })


                                                              elseif ((cardSet == 'HS') and (cardNumber == '104')) then
                                                                -- For Ugly , spawn Outdated Tech.
                                                                local spawnXOffset = -7.0
                                                                local spawnZOffset = 2.3

                                                                if owningPlayerColor == "Red" then
                                                                   spawnXOffset = 7.0
                                                                   spawnZOffset = -2.3
                                                                end

                                                                Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                                           cardCode = "12148",
                                                                                           spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                                           spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })





      elseif ((cardSet == 'FA') and (cardNumber == '83')) then
        -- For Extremist Campaign, Spawn associated cards
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "02112",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "02112",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "03137",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "03137",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "08038",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "08038",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })


	  elseif ((cardSet == 'RM') and (cardNumber == '2')) then
		-- For Kylo Ren Driven By Fear, Spawn associated cards
		local spawnXOffset = -7.0
		local spawnZOffset = 2.3

		if owningPlayerColor == "Red" then
			spawnXOffset = 7.0
			spawnZOffset = -2.3
		end

		Global.call("spawnCard", { playerColor = owningPlayerColor,
                                 cardCode = "01082",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owningPlayerColor,
                                 cardCode = "01082",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owningPlayerColor,
                                 cardCode = "02071",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owningPlayerColor,
                                 cardCode = "02071",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
      elseif ((cardSet == 'SoH') and (cardNumber == '93')) then
        -- For SoH Chief Chirpa, spawn a SoH Ewok Warrior.
        local spawnXOffset = -7.0
        local spawnZOffset = 0.0

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11095",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

                                 elseif ((cardSet == 'UH') and (cardNumber == '73')) then
									print("owningPlayerColor is: ", owningPlayerColor)
                                             -- For UH Padme Amidala spawn Diplomatic Immunity
                                             local spawnXOffset = -7.0
                                             local spawnZOffset = 0.0

                                             if owningPlayerColor == "Red" then
                                                spawnXOffset = 7.0
                                             end

                                             Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                        cardCode = "01050",
                                                                        spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                        spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })



                       elseif ((cardSet == 'UH') and (cardNumber == '33')) then
                                   -- For UH Pre Viszla spawn HS Darksaber
                                   local spawnXOffset = -7.0
                                   local spawnZOffset = 0.0

                                   if owningPlayerColor == "Red" then
                                      spawnXOffset = 7.0
                                   end

                                   Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                              cardCode = "17105",
                                                              spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                              spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })


      elseif ((cardSet == 'SoH') and (cardNumber == '105')) then
        -- For SoH Chief Chirpa's Hut, spawn a SoH Ewok Warrior.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11095",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

        elseif ((cardSet == 'RES') and (cardNumber == '16')) then
         -- For RES Linus Mosk, spawn 2x Measure for Measure, 2x Fresh Supplies and 2x Seizing Territory.
         local spawnXOffset = -7.0
         local spawnZOffset = 2.3

         if owningPlayerColor == "Red" then
            spawnXOffset = 7.0
            spawnZOffset = -2.3
         end

         Global.call("spawnCard", { playerColor = owningPlayerColor,
                                    cardCode = "09127",
                                    spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                    spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
          Global.call("spawnCard", { playerColor = owningPlayerColor,
                                     cardCode = "09127",
                                     spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                     spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

         Global.call("spawnCard", { playerColor = owningPlayerColor,
                                    cardCode = "09126",
                                    spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                    spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "09126",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

         Global.call("spawnCard", { playerColor = owningPlayerColor,
                                    cardCode = "11129",
                                    spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                    spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11129",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

      elseif ((cardSet == 'CM') and (cardNumber == '146')) then
        -- For CM Z-6 Jetpack, spawn 1 resource token on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        obj_parameters.position = {object.getPosition()[1]-1.5+0.7,object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+0.7}
        local token = spawnObject(obj_parameters)
        local custom = {}
        custom.image = tokenplayerone.resource
        custom.thickness = 0.1
        custom.merge_distance = 5.0
        custom.stackable = false
        token.setCustomObject(custom)
      elseif ((cardSet == 'CM') and
              ((cardNumber == '113') or (cardNumber == '125') or (cardNumber == '142'))) then
        -- For CM Seeking Knowledge, CM Tactical Delay, or CM Improvised Explosive, spawn 2 resource tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,2 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      elseif ((cardSet == 'CM') and
              ((cardNumber == '33') or (cardNumber == '154'))) then
        -- For CM Merchant Freighter or CM TIE Bomber, spawn 3 resource tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      else
        -- Nothing needs done here.
      end

      if (isDiceCard == true) then
        if (isElite == true) then
          obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, (object.getPosition()[3] + 1 + zOffset)}
          local dice = spawnObject(obj_parameters)
          dice.setCustomObject(custom)
        end
      end
    end

    -- For character cards, create XML GUI when the dice spawn.
    if (isCharacterCard == true) then
      -- Since attaching the GUI directly to the card would cause the GUI to rotate when the card rotates, use a GUI holder object.
      obj_parameters.type = 'BlockSquare'
      obj_parameters.position = {object.getPosition()[1], 0.02, object.getPosition()[3]}
      if (owner == 'Blue') then
        obj_parameters.rotation = {0, 0, 0}
      else
        obj_parameters.rotation = {0, 180, 0}
      end
      obj_parameters.scale = {1, 1, 1}
      obj_parameters.sound = false
      -- Note that both the character card and the GUI holder objects have scripts.
      obj_parameters.callback_function = function(newObject) initGUIHolder(object, newObject) end

      local cardGUIObject = spawnObject(obj_parameters)
    end
  else
    local linkedGUIHolder = object.getVar("linkedGUIHolder")

    -- If a GUI holder was linked and hidden, show it.
    if (linkedGUIHolder != nil) then
      -- Update the position.
      local cardPosition = object.getPosition()
      linkedGUIHolder.setPosition({x = cardPosition.x, y = 0.02, z = cardPosition.z})

      if ((linkedGUIHolder.UI.getAttribute("card_gui", "active") == "False") or
          (linkedGUIHolder.UI.getAttribute("card_gui", "active") == "false")) then
        linkedGUIHolder.UI.setAttribute("card_gui", "active", true)
        linkedGUIHolder.UI.setAttribute("opponent_card_gui", "active", true)

        -- Update the visibility to match the prefab owner.
        if (owner == 'Blue') then
          linkedGUIHolder.setRotation({0, 0, 0})
        else
          linkedGUIHolder.setRotation({0, 180, 0})
        end
        linkedGUIHolder.UI.setAttribute("card_gui", "visibility", owner)
        if (owner == 'Blue') then
          linkedGUIHolder.UI.setAttribute("opponent_card_gui", "visibility", 'Red|Grey|Black')
        else
          linkedGUIHolder.UI.setAttribute("opponent_card_gui", "visibility", 'Blue|Grey|Black')
        end
      end
    end
  end
end

function initGUIHolder(cardObject, holderObject)
  -- Set shield and damage values.
  -- TODO is there a way to save/load variables on objects like this?
  holderObject.setVar("shields", 0)
  holderObject.setVar("damage", 0)
  holderObject.setVar("owner", owner)

  holderObject.setLuaScript(Global.getVar("characterGUILuaScript"))
  Wait.time(function() finishInitGUIHolder(cardObject, holderObject) end, 0.2)

  cardObject.setVar("linkedGUIHolder", holderObject)
end

function finishInitGUIHolder(cardObject, holderObject)
  holderObject.UI.setAttribute("card_gui", "visibility", owner)
  holderObject.UI.setAttribute("card_gui", "active", true)
  if (owner == 'Blue') then
    holderObject.UI.setAttribute("opponent_card_gui", "visibility", 'Red|Grey|Black')
  else
    holderObject.UI.setAttribute("opponent_card_gui", "visibility", 'Blue|Grey|Black')
  end
  holderObject.UI.setAttribute("opponent_card_gui", "active", true)
end
]=]


function classicMenu(player)
	if print then printToAll("The legacy menu has been functionally removed. The UI will be updated in the future.", {1,0,0}) return end	
end

function generatePacksAwakenings(buttonObject, playerColor) generatePacks(playerColor, 'AW') end
function generatePacksSpirit(buttonObject, playerColor) generatePacks(playerColor, 'SoR') end
function generatePacksEmpire(buttonObject, playerColor) generatePacks(playerColor, 'EaW') end
function generatePacksLegacies(buttonObject, playerColor) generatePacks(playerColor, 'LEG') end
function generatePacksWay(buttonObject, playerColor) generatePacks(playerColor, 'WotF') end
function generatePacksAcross(buttonObject, playerColor) generatePacks(playerColor, 'AtG') end
function generatePacksConvergence(buttonObject, playerColor) generatePacks(playerColor, 'CONV') end
function generatePacksSpark(buttonObject, playerColor) generatePacks(playerColor, 'SoH') end
function generatePacksCovert(buttonObject, playerColor) generatePacks(playerColor, 'CM') end
function generatePacksFA(buttonObject, playerColor) generatePacks(playerColor, 'FA') end
function generatePacksRM(buttonObject, playerColor) generatePacks(playerColor, 'RM') end
function generatePacksHS(buttonObject, playerColor) generatePacks(playerColor, 'HS') end
function generatePacksUH(buttonObject, playerColor) generatePacks(playerColor, 'UH') end
function generatePacksSA(buttonObject, playerColor) generatePacks(playerColor, 'SA') end
function generateMixedPacks(buttonObject, playerColor) generatePacks(playerColor, 'Mixed') end

function readyForRivals()
  rivalsDummyCard.destruct()
  startLuaCoroutine(self, 'spawnRivalsCards')
end

function draftReadyForDeal()
  -- Make the table of pack selections available so the main game script can use it.
  Global.setTable("packSelections", packSelections)
  -- Set up a table of expansion indices for dealing cards.
  Global.setTable("nextExpansionIndex", nextExpansionIndex)
  -- Make the table of packs available so the main game script can use it.
  Global.setTable("rivalsExpansionPacks", rivalsExpansionPacks)
  -- Set whether the cube compatibility mode is active.
  Global.setVar("cubeCompatibilityMode", cubeCompatibilityMode)

  -- Deal cards.
  printToAll("Dealing cards...", {1,1,1})
  Global.call("draftReadyForDeal")

  -- The menu is no longer needed.
  self.destruct()
end

function draftZoneReady()
	if not draftOriginDeckZone then printToAll("Draft origin zone missing; aborting.", {1,0,0}) return end

  local rarity
  local index

  cardPulledCount = 0

  -- Move the script zone for the draft origin deck.
  draftOriginDeckZone.setPosition({6,2,-0.5})

  startLuaCoroutine(self, 'generateCardsCoroutine')
end

function spawnRivalsCards()
  coroutine.yield(0)

  -- Pull the Rivals deck.
  -- TODO NEXT make this configurable instead of only getting the Allies of Necessity deck.
  --setupObject.takeObject({position={14,2.0,-0.9}, rotation={0,0,0}, guid=rivalsDeckGuid, flip=false, smooth=false})
  setupObject.takeObject({position={14,2.0,-0.9}, rotation={0,0,0}, guid=alliesDeckGuid, flip=false, smooth=false})

  -- Create a script zone for the dummy card plus the cube deck.  This is created under the table to avoid a white flash.
  local obj_parameters = {}

  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.scale = { 5.0, 5.0, 6.0 }
  obj_parameters.position = { 6.000,-4.000, 0.500 }
  obj_parameters.rotation = { 0.000, 0.000, 0.000 }
  draftOriginDeckZone = spawnObject(obj_parameters)
  if not draftOriginDeckZone then print("Failed to spawn draft origin zone") end

  -- Sleep briefly to let the draft zone spawn.
  Wait.time(draftZoneReady, 0.2)

  return 1
end

function setupDraftNormal(player, _, _)
  self.setPosition({0,1,0})
  Global.setVar("Mode", "Normal Draft")
  setupPacksMenu(player)
end

function setupDraftWinchester(player, value, id)
  Global.setVar("Mode", "Winchester Draft")
  setupPacksMenu(player)
end

function setupDraftCube(player, value, id)
  Global.setVar("Mode", "Cube Draft")
  setupCubeMenu(player)
end

function setupSealed(player, value, id)
  Global.setVar("Mode", "Normal Sealed")
  setupPacksMenu(player)
end

function setupCubeMenu(player)
  -- Move the cube board and cube deck zone up.
  Global.setVar("limited_panel", false) Global.UI.setAttribute("limited_panel", "active", false)


  cubeBoard.setPosition({-9.5,1,0})
  cubeDeckZone.setPosition({-9.5,1,0})

  self.clearButtons()

  self.createButton({
    label='Back',click_function="closeCubeMenu",function_owner=self,
    position={1.3,0.1,1.6},width = 400, height = 150, font_size = 100
  })

  self.createButton({
    label='Process Cube', click_function="processCube", function_owner=self,
    position={0,0.1,0}, width=1400, height=500, font_size=200
  })
end

function closeCubeMenu()
  -- Hide the cube board and cube deck zone.
  cubeBoard.setPosition({-9.5,-4,0})
  cubeDeckZone.setPosition({-9.5,-4,0})

  mainMenu()
end

function processCube(buttonObject, playerColor)
  -- Zoom camera back out to the normal perspective for that player.
  --zoomCameraBackOut(playerColor)

  -- Delay slightly so camera movement does not feel too sudden.
  Wait.time(function() processCubeAfterDelay(playerColor) end, 0.2)
end

function processCubeAfterDelay(playerColor)
  -- Move player mats up before things start dropping on them.
  Global.call("moveAllMatsUp")

  cubeDeck = nil
  local scriptZoneObjects = cubeDeckZone.getObjects()
  for i,curDeck in ipairs(scriptZoneObjects) do
    if curDeck.tag == "Deck" then
      cubeDeck = curDeck
      break
    end
  end

  -- Make sure the cube has enough cards.
  if cubeDeck != nil then
    local seatedPlayers = getSeatedPlayers()
    local numSeatedPlayers = 0
    for i,somePlayer in pairs(seatedPlayers) do
      numSeatedPlayers = numSeatedPlayers + 1
    end

    -- Each player will need 6 packs of 5 cards each.
    local cubeCards = #(cubeDeck.getObjects())
    local minCubeCards = (numSeatedPlayers * 6 * 5)
    if cubeCards < minCubeCards then
      printToAll("Error, for " .. numSeatedPlayers .. " player(s), the cube must contain at least " .. minCubeCards .. " cards.", {1,0,0})
      return
    end
  end

  if cubeDeck != nil then
    -- Spawn the "please wait" message board.
    Global.call("showPleaseWait")

    -- Get the rotation of the cube deck.
    cubeDeckRotation = cubeDeck.getRotation()

    -- Flip the deck upside down if needed.
    if ((cubeDeckRotation.z < 160) or (cubeDeckRotation.z > 200)) then
      cubeDeck.setRotation({0, 0, 180})
    end

    -- Process the cube cards and create packs.
    createCubePacks()

    self.setPosition({0, -4, 0})

    rivalsExpansion = 'Cube'

    -- Delete the cube board and cube deck zone.
    cubeBoard.destruct()
    cubeDeckZone.destruct()

    -- Go ahead and move the dummy card so that other cards will fall on top of it.
    -- The move is done with no collision, and it is done fast.  Also, clone the
    -- dummy card, so that if the cube is dealt out entirely, what is left will
    -- still be a deck.
    rivalsDummyCard.setLock(false)
    rivalsDummyCard.clone({position={6,6,-0.9}})
    rivalsDummyCard.clone({position={6,7,-0.9}})
    rivalsDummyCard.setLock(true)

    Global.call("initBoards")

    -- The cube is moved after a small delay since otherwise it ends up crooked, probably because of the dummy cards.
    -- TODO scan and remove this move instead?
    Wait.time(handleCubeMove, 0.5)

    printToAll("Processing cube...", {1,1,1})
  else
    printToAll("Error, please put a deck in the cube zone.", {1,0,0})
  end
end

function handleCubeMove()
  -- To fix a strange bug where other people hosting the mod fail to move the cube deck, teleport it first.
  local cubeDeckPosition = cubeDeck.getPosition()
  cubeDeck.setPosition({x = cubeDeckPosition.x, y = (cubeDeckPosition.y + 4), z = cubeDeckPosition.z})

  -- Move the cube without collision and move it fast.
  cubeDeck.drag = 0.001
  cubeDeck.angular_drag = 0.001
  cubeDeck.dynamic_friction = 0.8
  cubeDeck.bounciness = 0
  cubeDeck.interactable = false
  cubeDeck.setPositionSmooth({6,3,-0.9}, false, true)

  Wait.time(readyForRivals, 1.0)
end

function createCubePacks()
  local SWDARHISTHEBEST = Global.getTable("SWDARHISTHEBEST")
  local cubeObjects = cubeDeck.getObjects()

  expansionLegendaries['Cube']   = {}
  expansionRares['Cube']         = {}
  expansionUncommons['Cube']     = {}
  expansionCommons['Cube']       = {}

  -- Process the cube to create lists of cards by rarity.
  for _,cubeCard in ipairs(cubeObjects) do
    local cubeCardDescription = cubeCard.description

    for _,curCard in ipairs(SWDARHISTHEBEST) do
      local setAndNumber = (curCard["set"] .. ' ' .. curCard["number"])

      if cubeCardDescription and cubeCardDescription ~= '' then
        if (cubeCardDescription == setAndNumber) then
          local rarity = curCard["rarity"]

          if "Legendary" == rarity then
            table.insert(expansionLegendaries['Cube'], setAndNumber)
          elseif "Rare" == rarity then
            table.insert(expansionRares['Cube'], setAndNumber)
          elseif "Uncommon" == rarity then
            table.insert(expansionUncommons['Cube'], setAndNumber)
          elseif "Common" == rarity then
            table.insert(expansionCommons['Cube'], setAndNumber)
          else end break
        end
      else
        cubeCompatibilityMode = true
        if cubeCard.nickname == curCard["cardname"] then
          local rarity = curCard["rarity"]

          if "Legendary" == rarity then
            table.insert(expansionLegendaries['Cube'], cubeCard.nickname)
          elseif "Rare" == rarity then
            table.insert(expansionRares['Cube'], cubeCard.nickname)
          elseif "Uncommon" == rarity then
              table.insert(expansionUncommons['Cube'], cubeCard.nickname)
          elseif "Common" == rarity then
            table.insert(expansionCommons['Cube'], cubeCard.nickname)
          else end break
        end
      end
    end
  end

  local expansionDiceCards  = {}
  local expansionUncommons  = {}
  local expansionCommons    = {}

  local diceCards          = {}
  local uncommonCards      = {}
  local commonCards        = {}

  -- Combine the legendaries and rares.
  local numLegendaries = #(expansionLegendaries['Cube'])
  local numRares = #(expansionRares['Cube'])
  for legendaryIndex=1,numLegendaries do
    table.insert(diceCards, expansionLegendaries['Cube'][legendaryIndex])
  end
  for rareIndex=1,numRares do
    table.insert(diceCards, expansionRares['Cube'][rareIndex])
  end

  -- Make a copy of the uncommon and common tables.
  local numUncommons = #(expansionUncommons['Cube'])
  local numCommons = #(expansionCommons['Cube'])
  for uncommonIndex=1,numUncommons do
    table.insert(uncommonCards, expansionUncommons['Cube'][uncommonIndex])
  end
  for commonIndex=1,numCommons do
    table.insert(commonCards, expansionCommons['Cube'][commonIndex])
  end

  -- Randomize the dice cards.
  local totalDiceCards = (numLegendaries + numRares)
  local diceCardsLeftToRandomize = totalDiceCards
  for i=1,totalDiceCards do
    local randomIndex = math.random(1,diceCardsLeftToRandomize)
    table.insert(expansionDiceCards, table.remove(diceCards, randomIndex))
    diceCardsLeftToRandomize = diceCardsLeftToRandomize - 1
  end

  -- Randomize the uncommon cards.
  local totalUncommonCards = #(expansionUncommons['Cube'])
  local uncommonCardsLeftToRandomize = totalUncommonCards
  for i=1,totalUncommonCards do
    local randomIndex = math.random(1,uncommonCardsLeftToRandomize)
    table.insert(expansionUncommons, table.remove(uncommonCards, randomIndex))
    uncommonCardsLeftToRandomize = uncommonCardsLeftToRandomize - 1
  end

  -- Randomize the common cards.
  local totalCommonCards = #(expansionCommons['Cube'])
  local commonCardsLeftToRandomize = totalCommonCards
  for i=1,totalCommonCards do
    local randomIndex = math.random(1,commonCardsLeftToRandomize)
    table.insert(expansionCommons, table.remove(commonCards, randomIndex))
    commonCardsLeftToRandomize = commonCardsLeftToRandomize - 1
  end

  -- Determine how many packs can be created.  Note that this may require substituting commons for uncommons or similar.
  local numCubePacks = math.floor((totalDiceCards + totalUncommonCards + totalCommonCards) / 5)

  local numDiceCardsLeft   = totalDiceCards
  local numUncommonsLeft   = totalUncommonCards
  local numCommonsLeft     = totalCommonCards
  local nextDiceCardIndex  = 1
  local nextUncommonIndex  = 1
  local nextCommonIndex    = 1

  -- At this point, all cards have been processed and randomized, so packs can be created.
  rivalsExpansionPacks['Cube'] = {}
  nextExpansionIndex['Cube'] = 1
  for packIndex = 1,numCubePacks do
    -- The packs are created in reverse order so that dice cards end up on top of decks.
    for cardIndex=1,3 do
      if numCommonsLeft > 0 then
        table.insert(rivalsExpansionPacks['Cube'], expansionCommons[nextCommonIndex])
        nextCommonIndex = nextCommonIndex + 1
        numCommonsLeft = numCommonsLeft - 1
      elseif numUncommonsLeft > 0 then
        -- Substitute uncommons for commons.
        table.insert(rivalsExpansionPacks['Cube'], expansionUncommons[nextUncommonIndex])
        nextUncommonIndex = nextUncommonIndex + 1
        numUncommonsLeft = numUncommonsLeft - 1
      elseif numDiceCardsLeft > 0 then
        -- Substitute rares/legendaries for uncommons.
        table.insert(rivalsExpansionPacks['Cube'], expansionDiceCards[nextDiceCardIndex])
        nextDiceCardIndex = nextDiceCardIndex + 1
        numDiceCardsLeft = numDiceCardsLeft - 1
      else
        printToAll("Error, not enough cards in cube.", {1,0,0})
        Global.call("cleanupTable")
        return
      end
    end

    if numUncommonsLeft > 0 then
      table.insert(rivalsExpansionPacks['Cube'], expansionUncommons[nextUncommonIndex])
      nextUncommonIndex = nextUncommonIndex + 1
      numUncommonsLeft = numUncommonsLeft - 1
    elseif numCommonsLeft > 0 then
      -- Substitute commons for uncommons.
      table.insert(rivalsExpansionPacks['Cube'], expansionCommons[nextCommonIndex])
      nextCommonIndex = nextCommonIndex + 1
      numCommonsLeft = numCommonsLeft - 1
    elseif numDiceCardsLeft > 0 then
      -- Substitute rares/legendaries for commons.
      table.insert(rivalsExpansionPacks['Cube'], expansionDiceCards[nextDiceCardIndex])
      nextDiceCardIndex = nextDiceCardIndex + 1
      numDiceCardsLeft = numDiceCardsLeft - 1
    else
      printToAll("Error, not enough cards in cube.", {1,0,0})
      Global.call("cleanupTable")
      return
    end

    if numDiceCardsLeft > 0 then
      table.insert(rivalsExpansionPacks['Cube'], expansionDiceCards[nextDiceCardIndex])
      nextDiceCardIndex = nextDiceCardIndex + 1
      numDiceCardsLeft = numDiceCardsLeft - 1
    elseif numUncommonsLeft > 0 then
      -- Substitute uncommons for rares/legendaries.
      table.insert(rivalsExpansionPacks['Cube'], expansionUncommons[nextUncommonIndex])
      nextUncommonIndex = nextUncommonIndex + 1
      numUncommonsLeft = numUncommonsLeft - 1
    elseif numCommonsLeft > 0 then
      -- Substitute commons for uncommons.
      table.insert(rivalsExpansionPacks['Cube'], expansionCommons[nextCommonIndex])
      nextCommonIndex = nextCommonIndex + 1
      numCommonsLeft = numCommonsLeft - 1
    else
      printToAll("Error, not enough cards in cube.", {1,0,0})
      Global.call("cleanupTable")
      return
    end
  end
end

function setupPacksMenu(player)
  local Mode = Global.getVar("Mode")

  if Mode == "Winchester Draft" or Mode == "Normal Sealed" then numPacksPerPlayer = 8
  else numPacksPerPlayer = 6 end

  Global.call("setOpenMenuWithParams", { whichMenu = MENU_NONE } )
  player.lookAt({ position={0,0,0}, pitch=62, yaw=180, distance=20})

  packSelectButtons = nil

  self.clearButtons()

  self.createButton({
    label='Awakenings', click_function="generatePacksAwakenings", function_owner=self,
    position={-1.0,0.1,-1}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Spirit of Rebellion',click_function="generatePacksSpirit",function_owner=self,
    position={-1.0,0.1,-0.7}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Empire at War',click_function="generatePacksEmpire",function_owner=self,
    position={-1.0,0.1,-0.4}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Legacies',click_function="generatePacksLegacies",function_owner=self,
    position={-1.0,0.1,-0.1}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Way of The Force',click_function="generatePacksWay",function_owner=self,
    position={-1.0,0.1,0.2}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Across the Galaxy',click_function="generatePacksAcross",function_owner=self,
    position={-1.0,0.1,0.5}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Convergence',click_function="generatePacksConvergence",function_owner=self,
    position={-1.0,0.1,0.8}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Spark of Hope',click_function="generatePacksSpark",function_owner=self,
    position={-1.0,0.1,1.1}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Covert Missions',click_function="generatePacksCovert",function_owner=self,
    position={-1.0,0.1,1.4}, width=600, height=100, font_size=60, color={0.727, 0.727, 0.727, 1}})

  self.createButton({
    label='Faltering Alliegences',click_function="generatePacksFA",function_owner=self,
    position={1,0.1,-1}, width=600, height=100, font_size=60, color="Blue" })

  self.createButton({
    label='Redemption',click_function="generatePacksRM",function_owner=self,
    position={1,0.1,-0.7}, width=600, height=100, font_size=60, color="Blue"})

  self.createButton({
    label='High Stakes',click_function="generatePacksHS",function_owner=self,
    position={1,0.1,-0.4}, width=600, height=100, font_size=60, color="Blue" })

  self.createButton({
    label='Unlikely Heroes',click_function="generatePacksUH",function_owner=self,
    position={1,0.1,-0.1}, width=600, height=100, font_size=60, color="Blue" })

  self.createButton({
    label='Seeking Answers',click_function="generatePacksSA",function_owner=self,
    position={1,0.1,0.2}, width=600, height=100, font_size=60, color="Blue" })

  self.createButton({
    label='Mix',click_function="mixExpansionsMenu",function_owner=self,
    position={0,0.1,1.8}, width=320, height=100, font_size=60}) end

function mixExpansionsMenu()
  local offsetX = (-1.62)
  local offsetY = (0.1)
  local offsetZ = (-1.2)

  self.clearButtons()

  -- Create buttons for each expansion.
  for i=1,numPacksPerPlayer do
    self.createButton({
      label='AW', click_function="packAW"..i, function_owner=self,
      position={ offsetX + 0.0, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='SoR',click_function="packSoR"..i,function_owner=self,
      position={ offsetX + 0.25, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='EaW',click_function="packEaW"..i,function_owner=self,
      position={ offsetX + 0.5, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='LEG',click_function="packLEG"..i,function_owner=self,
      position={ offsetX + 0.75, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='WotF',click_function="packWotF"..i,function_owner=self,
      position={ offsetX + 1.0, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='AtG',click_function="packAtG"..i,function_owner=self,
      position={ offsetX + 1.25, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='CONV',click_function="packCONV"..i,function_owner=self,
      position={ offsetX + 1.50, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='SoH',click_function="packSoH"..i,function_owner=self,
      position={ offsetX + 1.75, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='CM',click_function="packCM"..i,function_owner=self,
      position={ offsetX + 2.0, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='FA',click_function="packFA"..i,function_owner=self,
      position={ offsetX + 2.25, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={0,0,0}, font_color={1,1,1}
    })

    self.createButton({
      label='RED',click_function="packRM"..i,function_owner=self,
      position={ offsetX + 2.50, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={1,1,1}, font_color={0,0,0}
    })

    self.createButton({
      label='HS',click_function="packHS"..i,function_owner=self,
      position={ offsetX + 2.75, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={1,1,1}, font_color={0,0,0}
    })

    self.createButton({
      label='UH',click_function="packUH"..i,function_owner=self,
      position={ offsetX + 3.0, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={1,1,1}, font_color={0,0,0}
    })

    self.createButton({
      label='SA',click_function="packSA"..i,function_owner=self,
      position={ offsetX + 3.25, offsetY, (offsetZ + (i*0.3)) }, width=120, height=120, font_size=33, color={1,1,1}, font_color={0,0,0}
    })

  end

  -- Create buttons that just act as labels.
  for i=1,numPacksPerPlayer do
    self.createButton({
      label=i, click_function="", function_owner=self,
      position={-2.0, 0.1, ((-1.2)+(i*0.3))}, width=0, height=0, font_size=100, color={0,0,0}, font_color={1,1,1}
    })
  end

  self.createButton({
    label='Play',click_function="generateMixedPacks",function_owner=self,
    position={0.0,0.1,1.2}, width=400, height=150, font_size=100
  })


self.createButton({
    label='Back',click_function="setupPacksMenu",function_owner=self,
    position={0.0,0.1,1.5}, width=400, height=150, font_size=100
})

  -- Get all the buttons for quick access later.
  packSelectButtons = self.getButtons()
end

function generatePacks(_, expansions)
print(expansions)
  -- Move player mats up before things start dropping on them.
  Global.call("moveAllMatsUp")

  local Mode = Global.getVar("Mode")

  if Mode == "Winchester Draft" then
    local seatedPlayers = getSeatedPlayers()
    local numSeatedPlayers = 0
    for i,somePlayer in pairs(seatedPlayers) do
      numSeatedPlayers = numSeatedPlayers + 1
    end

    if numSeatedPlayers <= 2 then
      local firstPlayerToAssign = nil local secondPlayerToAssign = nil
      local blueUsed = false local greenUsed = false
      local colorChangeNeeded = false

      for _,somePlayer in pairs(seatedPlayers) do
        if somePlayer == "Blue" then blueUsed = true
        elseif somePlayer == "Green" then greenUsed = true
        else
          if firstPlayerToAssign == nil then
            firstPlayerToAssign = somePlayer
            colorChangeNeeded = true
          else
            secondPlayerToAssign = somePlayer
            colorChangeNeeded = true
          end
        end
      end

      -- If either or both players are not blue/green, change their color(s).

      if firstPlayerToAssign then
        if blueUsed == false then
          Player[firstPlayerToAssign].changeColor("Blue") blueUsed = true
        else
          Player[firstPlayerToAssign].changeColor("Green") -- If blue is used, then green must not be used, otherwise firstPlayerToAssign would be nil.
          greenUsed = true
        end
      end

      if secondPlayerToAssign then
        -- If neither player was blue or green, the first player got assigned to blue, so this one should be green.
        Player[secondPlayerToAssign].changeColor("Green")
        greenUsed = true
      end

      if colorChangeNeeded == true then
        printToAll("Winchester draft only uses the Blue and Green seats.", {1,1,1})
      end
    else
      printToAll("Error, Winchester draft only supports 2 seated players.", {1,0,0})

      return
    end
  end

  self.setPosition({0, -4, 0})
  rivalsExpansion = expansions

  -- Spawn the "please wait" message board.
  Global.call("showPleaseWait")

  -- Spawn boards and get ready to continue setup.
  Global.call("initBoards")
  Wait.time(readyForRivals, 0.2)
end

function generateBoxes()
  -- Generate 2 boxes for each expansion.
  for i,curExpansion in ipairs(expansions) do
    for boxIndex=1,2 do
      rivalsExpansionPacks[curExpansion] = {}
      generateBox(curExpansion)
    end

    -- At this point, 2 boxes have been generated for the current expansion.  Prepare for dealing this expansions's packs.
    nextExpansionIndex[curExpansion] = 1
  end
end

function generateBox(whichExpansion) -- This doesn't work for CM+. Need to rewrite so that for fan sets it instead chooses 3 random cards that use dice and otherwise all cards are equally tabled
  local expansionDiceCards  = {}
  local expansionUncommons  = {}
  local expansionCommons    = {}
  local boxDiceCards = {}
  local randomIndex = 1
  local numBoxLegendaries = 0

  -- Prevent duplicate legendaries inside a box.
  for legendaryIndex=1,6 do
    local isDuplicate = true
    while isDuplicate == true do
      randomIndex = math.random(1, #(allExpansionLegendaries[whichExpansion]))
      isDuplicate = false
      for previousLegendaryIndex=1,numBoxLegendaries do
        if allExpansionLegendaries[whichExpansion][randomIndex] == boxDiceCards[previousLegendaryIndex] then
          isDuplicate = true
        end
      end
    end
    table.insert(boxDiceCards, allExpansionLegendaries[whichExpansion][randomIndex])
    numBoxLegendaries = numBoxLegendaries + 1
  end

  -- Rares can have duplicates inside a box.
  for rareIndex=1,30 do
    randomIndex = math.random(1, #(allExpansionRares[whichExpansion]))
    table.insert(boxDiceCards, allExpansionRares[whichExpansion][randomIndex])
  end

  -- At this point, there are 36 dice cards that need randomized.
  local diceCardsLeftToRandomize = 36
  for i=1,36 do
    randomIndex = math.random(1,diceCardsLeftToRandomize)
    table.insert(expansionDiceCards, table.remove(boxDiceCards, randomIndex))
    diceCardsLeftToRandomize = diceCardsLeftToRandomize - 1
  end

  -- Uncommons can have duplicates inside a box.
  for uncommonIndex=1,36 do
    randomIndex = math.random(1, #(allExpansionUncommons[whichExpansion]))
    table.insert(expansionUncommons, allExpansionUncommons[whichExpansion][randomIndex])
  end

  -- Commons can have duplicates inside a box.
  for commonIndex=1,108 do
    randomIndex = math.random(1, #(allExpansionCommons[whichExpansion]))
    table.insert(expansionCommons, allExpansionCommons[whichExpansion][randomIndex])
  end

  -- At this point, a box has been generated for the requested expansion.  Save the 36 packs.
  local nextDiceCardIndex = 1
  local nextUncommonIndex = 1
  local nextCommonIndex = 1
  for packIndex = 1,36 do
    -- The packs are created in reverse order so that dice cards end up on top of decks.
    table.insert(rivalsExpansionPacks[whichExpansion], expansionCommons[nextCommonIndex])
    nextCommonIndex = nextCommonIndex + 1
    table.insert(rivalsExpansionPacks[whichExpansion], expansionCommons[nextCommonIndex])
    nextCommonIndex = nextCommonIndex + 1
    table.insert(rivalsExpansionPacks[whichExpansion], expansionCommons[nextCommonIndex])
    nextCommonIndex = nextCommonIndex + 1

    table.insert(rivalsExpansionPacks[whichExpansion], expansionUncommons[nextUncommonIndex])
    nextUncommonIndex = nextUncommonIndex + 1

    table.insert(rivalsExpansionPacks[whichExpansion], expansionDiceCards[nextDiceCardIndex])
    nextDiceCardIndex = nextDiceCardIndex + 1
  end
end

function generateCardsCoroutine()
  local Mode = Global.getVar("Mode")
  local expansionPacksNeeded     = {}

  for _,curExpansion in pairs(expansions) do
    expansionPacksNeeded[curExpansion]    = 0
    allExpansionLegendaries[curExpansion] = {}
    allExpansionRares[curExpansion]       = {}
    allExpansionUncommons[curExpansion]   = {}
    allExpansionCommons[curExpansion]     = {}
  end

  -- Set up local cube variables as well.
  expansionPacksNeeded['Cube']            = 0

  if (rivalsExpansion ~= 'Mixed') then
    -- Set all pack selections to the same expansion.
    for i=1,numPacksPerPlayer do
      packSelections[i] = rivalsExpansion
    end
  end

  -- Determine how many cards from each expansion are needed.
  for i=1,numPacksPerPlayer do
    expansionPacksNeeded[packSelections[i]] = expansionPacksNeeded[packSelections[i]]+1
  end

  -- Generate tables for cards in each expansion.
  local SWDARHISTHEBEST = Global.getTable("SWDARHISTHEBEST")
  for index,curCard in ipairs(SWDARHISTHEBEST) do
    local cardSet = curCard["set"]
    local rarity = curCard["rarity"]

    if allExpansionLegendaries[cardSet] and "Legendary" == rarity then
      table.insert(allExpansionLegendaries[cardSet], curCard["set"] .. ' ' .. curCard["number"])
    elseif allExpansionRares[cardSet] and "Rare" == rarity then
      table.insert(allExpansionRares[cardSet], curCard["set"] .. ' ' .. curCard["number"])
    elseif allExpansionUncommons[cardSet] and "Uncommon" == rarity then
      table.insert(allExpansionUncommons[cardSet], curCard["set"] .. ' ' .. curCard["number"])
    elseif allExpansionCommons[cardSet] and "Common" == rarity then
      table.insert(allExpansionCommons[cardSet], curCard["set"] .. ' ' .. curCard["number"])
    end
  end

  local seatedPlayers = getSeatedPlayers()
  local numSeatedPlayers = 0
  for playerIndex,somePlayer in pairs(seatedPlayers) do
    numSeatedPlayers = numSeatedPlayers + 1
  end

  -- Generate 2 boxes for each expansion.
  generateBoxes()

  coroutine.yield(0)

  --   -- Clone the Rivals deck for all players. TODO include option for Rivals starter, and provide graphical option instead of spawning both
  local scriptZoneObjects = getObjectFromGUID(rivalsDeckZoneGuid).getObjects()
  local rivalsDeck = nil
  for i,curDeck in ipairs(scriptZoneObjects) do
    if curDeck.tag == "Deck" then
      rivalsDeck = curDeck
      break
    end
  end

  if rivalsDeck ~= nil then
    local seatData = Global.getTable("seatData")

    for i,somePlayer in pairs(seatedPlayers) do
      local clonePosition = nil

      if ((Mode == "Normal Draft") or (Mode == "Cube Draft")) then
        -- For normal draft or cube draft, clone on the Rivals deck holder.
        clonePosition = getObjectFromGUID(seatData[somePlayer].rivalsDeckHolderGuid).getPosition()
      else
        -- For Winchester or sealed, clone on top of the deck area.
        clonePosition = getObjectFromGUID(seatData[somePlayer].scriptZoneGuid).getPosition()
      end
      clonePosition.y = 1.5

      local newRivalsDeck = rivalsDeck.clone({position=clonePosition})

      -- Update the Rival deck rotation to be correct for each seat.
      local rivalsDeckRotation = getObjectFromGUID(seatData[somePlayer].scriptZoneGuid).getRotation()

      if ((Mode == "Normal Draft") or (Mode == "Cube Draft")) then
        -- For normal draft or cube draft, rotate the Rivals deck to be face up.
        rivalsDeckRotation.y = rivalsDeckRotation.y+180
      else
        -- For sealed and Winchester, flip the Rivals deck over.
        rivalsDeckRotation.x = rivalsDeckRotation.x+180
      end

      newRivalsDeck.setRotation(rivalsDeckRotation)
    end

    -- After a delay, destruct the Rivals deck.
    Wait.time(function() destructRivalsDeck(rivalsDeck) end, 0.2)
  else
    -- This should never happen.
    printToAll("Error, Rivals deck not found.", {1,0,0})
  end

  draftReadyForDeal()

  return 1
end

function destructRivalsDeck(rivalsDeck)
  rivalsDeck.destruct()
end

function updatePackChoices(clickedPackIndex, clickedExpansionOffset)
  packSelections[clickedPackIndex] = allExpansions[clickedExpansionOffset+1]

  local clickedPackOffset = (clickedPackIndex-1)

  for expansionOffset=0,(#allExpansions-1) do
    local editButtonParameters = {}

    -- Change button colors to reflect the new selection.  Unlike Lua arrays, button indices start at 0.

    editButtonParameters.index = ((clickedPackOffset * #allExpansions) + expansionOffset)
    if clickedExpansionOffset == expansionOffset then
      editButtonParameters.color = {1,1,1}
      editButtonParameters.font_color = {0,0,0}
    else
      editButtonParameters.color = {0,0,0}
      editButtonParameters.font_color = {1,1,1}
    end
    self.editButton(editButtonParameters)
  end
end

-- Unfortunately, there seems to be no way to identify which button was clicked without using a million functions here or doing dynamic function generation.

function packAW1() updatePackChoices(1, 0) end
function packAW2() updatePackChoices(2, 0) end
function packAW3() updatePackChoices(3, 0) end
function packAW4() updatePackChoices(4, 0) end
function packAW5() updatePackChoices(5, 0) end
function packAW6() updatePackChoices(6, 0) end
function packAW7() updatePackChoices(7, 0) end
function packAW8() updatePackChoices(8, 0) end
function packSoR1() updatePackChoices(1, 1) end
function packSoR2() updatePackChoices(2, 1)end
function packSoR3() updatePackChoices(3, 1) end
function packSoR4() updatePackChoices(4, 1) end
function packSoR5() updatePackChoices(5, 1) end
function packSoR6() updatePackChoices(6, 1) end
function packSoR7() updatePackChoices(7, 1) end
function packSoR8() updatePackChoices(8, 1) end
function packEaW1() updatePackChoices(1, 2) end
function packEaW2() updatePackChoices(2, 2) end
function packEaW3() updatePackChoices(3, 2) end
function packEaW4() updatePackChoices(4, 2) end
function packEaW5() updatePackChoices(5, 2) end
function packEaW6() updatePackChoices(6, 2) end
function packEaW7() updatePackChoices(7, 2) end
function packEaW8() updatePackChoices(8, 2) end
function packLEG1() updatePackChoices(1, 3) end
function packLEG2() updatePackChoices(2, 3) end
function packLEG3() updatePackChoices(3, 3) end
function packLEG4() updatePackChoices(4, 3) end
function packLEG5() updatePackChoices(5, 3) end
function packLEG6() updatePackChoices(6, 3) end
function packLEG7() updatePackChoices(7, 3) end
function packLEG8() updatePackChoices(8, 3) end
function packWotF1() updatePackChoices(1, 4) end
function packWotF2() updatePackChoices(2, 4) end
function packWotF3() updatePackChoices(3, 4) end
function packWotF4() updatePackChoices(4, 4) end
function packWotF5() updatePackChoices(5, 4) end
function packWotF6() updatePackChoices(6, 4) end
function packWotF7() updatePackChoices(7, 4) end
function packWotF8() updatePackChoices(8, 4) end
function packAtG1() updatePackChoices(1, 5) end
function packAtG2() updatePackChoices(2, 5) end
function packAtG3() updatePackChoices(3, 5) end
function packAtG4() updatePackChoices(4, 5) end
function packAtG5() updatePackChoices(5, 5) end
function packAtG6() updatePackChoices(6, 5) end
function packAtG7() updatePackChoices(7, 5) end
function packAtG8() updatePackChoices(8, 5) end
function packCONV1() updatePackChoices(1, 6) end
function packCONV2() updatePackChoices(2, 6) end
function packCONV3() updatePackChoices(3, 6) end
function packCONV4() updatePackChoices(4, 6) end
function packCONV5() updatePackChoices(5, 6) end
function packCONV6() updatePackChoices(6, 6) end
function packCONV7() updatePackChoices(7, 6) end
function packCONV8() updatePackChoices(8, 6) end
function packSoH1() updatePackChoices(1, 7) end
function packSoH2() updatePackChoices(2, 7) end
function packSoH3() updatePackChoices(3, 7) end
function packSoH4() updatePackChoices(4, 7) end
function packSoH5() updatePackChoices(5, 7) end
function packSoH6() updatePackChoices(6, 7) end
function packSoH7() updatePackChoices(7, 7) end
function packSoH8() updatePackChoices(8, 7) end
function packCM1() updatePackChoices(1, 8) end
function packCM2() updatePackChoices(2, 8) end
function packCM3() updatePackChoices(3, 8) end
function packCM4() updatePackChoices(4, 8) end
function packCM5() updatePackChoices(5, 8) end
function packCM6() updatePackChoices(6, 8) end
function packCM7() updatePackChoices(7, 8) end
function packCM8() updatePackChoices(8, 8) end
function packFA1() updatePackChoices(1, 9) end
function packFA2() updatePackChoices(2, 9) end
function packFA3() updatePackChoices(3, 9) end
function packFA4() updatePackChoices(4, 9) end
function packFA5() updatePackChoices(5, 9) end
function packFA6() updatePackChoices(6, 9) end
function packFA7() updatePackChoices(7, 9) end
function packFA8() updatePackChoices(8, 9) end
function packRM1() updatePackChoices(1, 10) end
function packRM2() updatePackChoices(2, 10) end
function packRM3() updatePackChoices(3, 10) end
function packRM4() updatePackChoices(4, 10) end
function packRM5() updatePackChoices(5, 10) end
function packRM6() updatePackChoices(6, 10) end
function packRM7() updatePackChoices(7, 10) end
function packRM8() updatePackChoices(8, 10) end
function packHS1() updatePackChoices(1, 11) end
function packHS2() updatePackChoices(2, 11) end
function packHS3() updatePackChoices(3, 11) end
function packHS4() updatePackChoices(4, 11) end
function packHS5() updatePackChoices(5, 11) end
function packHS6() updatePackChoices(6, 11) end
function packHS7() updatePackChoices(7, 11) end
function packHS8() updatePackChoices(8, 11) end
function packUH1() updatePackChoices(1, 12) end
function packUH2() updatePackChoices(2, 12) end
function packUH3() updatePackChoices(3, 12) end
function packUH4() updatePackChoices(4, 12) end
function packUH5() updatePackChoices(5, 12) end
function packUH6() updatePackChoices(6, 12) end
function packUH7() updatePackChoices(7, 12) end
function packUH8() updatePackChoices(8, 12) end
function packSA1() updatePackChoices(1, 13) end
function packSA2() updatePackChoices(2, 13) end
function packSA3() updatePackChoices(3, 13) end
function packSA4() updatePackChoices(4, 13) end
function packSA5() updatePackChoices(5, 13) end
function packSA6() updatePackChoices(6, 13) end
function packSA7() updatePackChoices(7, 13) end
function packSA8() updatePackChoices(8, 13) end

function spawnSetupButtonAfterDelay(playerColor)
  startLuaCoroutine(self, 'spawnSetupCoroutine')
end


characterPlaymatScript = [[
function onload()
  tokenplayerone = Global.getTable('tokenplayerone')
  tokenplayertwo = Global.getTable('tokenplayertwo')
  spawndamage = {}
  damagetoken = {}
  spawnshield = {}
  shieldtoken = {}

  for i = 1, 5 do
      local buttonNum = tostring(i)
      local funcName = "spawnDamage" .. tostring(i)
      local params = { click_function = funcName
                      , function_owner = self
                      , label = ' '
                      , position = {-1.65,0,-1.70+0.30*i}
                      , width = 100
                      , height = 100
                      , font_size = 50 }
      local func = function()
        local position = self.getPosition()
        local moving = setSpawnPositions({4.50, -4.65, 0.8, 0})
        position = {(position[1]+moving[1]+moving[4]*i),(position[2]+0.2),(position[3]+moving[2]+moving[3]*i)}
        if spawndamage[i] == nil then
          if damagetoken[i] ~= nil then damagetoken[i].destruct() end
          damagetoken[i] = spawnToken(position, '1')
          spawndamage[i] = 'one'
          damagetoken[i].interactable = false
          return
        elseif spawndamage[i] == 'one' then
          if damagetoken[i] ~= nil then damagetoken[i].destruct() end
          damagetoken[i] = spawnToken(position, '2')
          spawndamage[i] = 'three'
          damagetoken[i].interactable = false
          return
        elseif spawndamage[i] == 'three' then
          if damagetoken[i] ~= nil then damagetoken[i].destruct() end
          spawndamage[i] = nil
          return
        end
      end
      self.setVar(funcName, func)
      self.createButton(params)
  end

  for i = 1, 3 do
      local buttonNum = tostring(i)
      local funcName = "spawnShield" .. tostring(i)
      local params = { click_function = funcName
                      , function_owner = self
                      , label = ' '
                      , position = {-1.30+0.35*i,0,-1.72}
                      , width = 100
                      , height = 100
                      , font_size = 50 }
      local func = function()
        if spawnshield[i] ~= true then
          if shieldtoken[i] ~= nil then shieldtoken[i].destruct() end
          local position = self.getPosition()
          local moving = setSpawnPositions({3.60, -4.75, -1, 0})
          position = {(position[1]+moving[1]+moving[3]*i),(position[2]+0.1),(position[3]+moving[2]-moving[4]*i)}
          shieldtoken[i] = spawnToken(position, '3')
          spawnshield[i] = true
          shieldtoken[i].interactable = false
          return
        elseif spawnshield[i] == true then
          if shieldtoken[i] ~= nil then shieldtoken[i].destruct() end
          spawnshield[i] = false
          return
        end
      end
      self.setVar(funcName, func)
      self.createButton(params)
  end

  if self.getName() == 'Blue' then
    owner = 'Blue'
  else
    owner = 'Red'
  end
end

function spawnToken(position, number)
  local obj_parameters = {}
  obj_parameters.type = 'Custom_Token'
  obj_parameters.position = position
  obj_parameters.rotation = {3.87674022, self.getRotation()[2], 0.239081308}
  local token = spawnObject(obj_parameters)
  local custom = {}
  custom.thickness = 0.1
  custom.merge_distance = 5.0
  custom.stackable = false
  if number == '1' then
    custom.image = tokenplayerone.damageone
  elseif number == '2' then
    custom.image = tokenplayerone.damagethree
  elseif number == '3' then
    custom.image = tokenplayerone.shield
  else
    return nil
  end
  token.setCustomObject(custom)
  token.scale {0.227068469, 1, 0.227068469}
  return token
end

function onCollisionEnter(collision_info)
  local cardSet = ''
  local cardNumber = ''
  local position = self.getPosition()
  local object = collision_info.collision_object
  local obj_parameters = {}
  local custom = {}
  local SWDARHISTHEBEST = Global.getTable("SWDARHISTHEBEST")

  obj_parameters.type = 'Custom_Dice'
  obj_parameters.scale = {1.7,1.7,1.7}
  obj_parameters.position = {object.getPosition()[1],object.getPosition()[2]+1,object.getPosition()[3]}
  obj_parameters.rotation = {0,object.getRotation()[2]+180,0}

  if object.getVar("spawned") ~= true and object.tag == 'Card' then
    local cardFound = false
    local cardDescription = object.getDescription()
    local cardDescriptionLength = 0
    local dataTableIndex = 1
    local isElite = false

    if cardDescription != nil then
      cardDescriptionLength = string.len(cardDescription)
      if string.sub(cardDescription, 1, 5) == 'elite' then
        isElite = true
      end
    end

    -- If there is text past "elite", or the card is not elite and there is text at all, the card uses the new format.
    if (((isElite == true) and (cardDescriptionLength > 5)) or
        ((isElite == false) and (cardDescriptionLength > 0))) then
      -- This is a new card export.  Extract the set and number.
      local setCharIndex = 1
      local numberCharIndex = 1
      if (isElite == true) then
        setCharIndex = 7
      else
        setCharIndex = 1
      end

      -- Do a plain search.
      numberCharIndex = (string.find(cardDescription, ' ', setCharIndex, true) + 1)
      cardSet = string.sub(cardDescription, setCharIndex, (numberCharIndex - 2))
      -- Leaving out the third argument takes a substring to the end of the string.
      cardNumber = string.sub(cardDescription, numberCharIndex)

      -- Find the card by its set and number.
      for i in ipairs(SWDARHISTHEBEST) do
        if ((SWDARHISTHEBEST[i]["set"] == cardSet) and
            (SWDARHISTHEBEST[i]["number"] == cardNumber) and
            (SWDARHISTHEBEST[i]["diceimage"] != nil) and
            ((SWDARHISTHEBEST[i]["type"] == 'Upgrade') or (SWDARHISTHEBEST[i]["type"] == 'Plot') or (SWDARHISTHEBEST[i]["type"] == 'Downgrade') or (SWDARHISTHEBEST[i]["type"] == 'Character') or (SWDARHISTHEBEST[i]["type"] == 'Battlefield'))) then
          cardFound = true
          dataTableIndex = i
          break
        end
      end

      local diceSpawnDebug = Global.getVar("diceSpawnDebug")

      if (cardFound == false) then
        if diceSpawnDebug == true then
          printToAll("Error, card " .. cardSet .. " " .. cardNumber .. " not found (make sure it is not a support).", {1,0,0})
        end
      end
    else
      -- This may be an old card export.  Do nothing.
    end

    if (cardFound == true) then
      -- For character cards, spawn the dice on the table for ease of rollout.
      zOffset = 0
      if (SWDARHISTHEBEST[dataTableIndex]["type"] == 'Character') then
        if owner == 'Blue' then
          zOffset = (-6)
        else
          zOffset = 5
        end
      end

      collision_info.collision_object.setVar("spawned", true)
      obj_parameters.position[3] = (obj_parameters.position[3] + zOffset)
      local dice = spawnObject(obj_parameters)
      custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
      dice.setCustomObject(custom)
      if ((cardSet == 'EaW') and (cardNumber == '10')) then
        -- For EaW Seventh Sister, spawn an ID9 Seeker Droid die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/869614883116891249/E95F6BDCAD82D95AEEFF7798BA2EB89013F1C530/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
      elseif ((cardSet == 'CONV') and (cardNumber == '18')) then
        -- For CONV Captain Phasma, spawn 2 First Order Stormtrooper dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/940587492855532900/1228C3F5E9F9ADF45DC65F9E14C5448B0A7006B1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/940587492855532900/1228C3F5E9F9ADF45DC65F9E14C5448B0A7006B1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
      elseif ((cardSet == 'CONV') and (cardNumber == '172')) then
        -- For CONV Sonic Detonators, spawn 6 resource tokens on the card.
        local spawnXOffset = -1.7
        local spawnZOffset = -1.72

        if owner == "Red" then
           spawnXOffset = -1.16
           spawnZOffset = 1.03
        end

        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = { object.getPosition()[1]+spawnXOffset+(i*0.7), object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset }
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
        for i=1,3 do
          obj_parameters.position = { object.getPosition()[1]+spawnXOffset+(i*0.7), object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset+0.70 }
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      elseif ((cardSet == 'SoH') and (cardNumber == '5')) then
        -- For SoH Old Daka, spawn a SoH Nightsister Zombie.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
      elseif ((cardSet == 'FA') and (cardNumber == '63')) then
        -- For Merrin, spawn a SoH Nightsister Zombie.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '9')) then
        -- For Chant of Resurrection, spawn 3 SoH Nightsister Zombie.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "11004",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '16')) then
        -- For General Veers, spawn a Snowtrooper.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "15017",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '25')) then
        -- For 501st Assault Team, spawn a E-Web Emplacement.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "02005",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '48')) then
        -- For You Will Go To The Dagobah System, spawn a Jedi Trials.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "12065",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '52')) then
        -- For Admiral Ackbar , spawn a X-Wing.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "08086",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
	  elseif ((cardSet == 'RM') and (cardNumber == '53')) then
        -- For Bothan Spy , spawn a Death Star Plans then kill him.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "12126",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

                                 elseif ((cardSet == 'HS') and (cardNumber == '98')) then
                                     -- For Greef Karga , spawn a Bounty Board.
                                     local spawnXOffset = -7.0
                                     local spawnZOffset = 2.3

                                     if owningPlayerColor == "Red" then
                                        spawnXOffset = 7.0
                                        spawnZOffset = -2.3
                                     end

                                     Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                cardCode = "09047",
                                                                spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

                                  elseif ((cardSet == 'AF') and (cardNumber == '48')) then
                                      -- For Cere Junda , spawn a Jedi Archives.
                                      local spawnXOffset = -7.0
                                      local spawnZOffset = 2.3

                                      if owningPlayerColor == "Red" then
                                         spawnXOffset = 7.0
                                         spawnZOffset = -2.3
                                      end

                                      Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                 cardCode = "23053",
                                                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })


                                                              elseif ((cardSet == 'HS') and (cardNumber == '104')) then
                                                                  -- For Ugly , spawn Outdated Tech.
                                                                  local spawnXOffset = -7.0
                                                                  local spawnZOffset = 2.3

                                                                  if owningPlayerColor == "Red" then
                                                                     spawnXOffset = 7.0
                                                                     spawnZOffset = -2.3
                                                                  end

                                                                  Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                                             cardCode = "12148",
                                                                                             spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                                             spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })






	  elseif ((cardSet == 'FA') and (cardNumber == '83')) then
		-- For Extremist Campaign, Spawn associated cards
		local spawnXOffset = -7.0
		local spawnZOffset = 2.3

		if owner == "Red" then
			spawnXOffset = 7.0
			spawnZOffset = -2.3
		end

		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "02112",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "02112",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "03137",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "03137",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "08038",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "08038",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

	  elseif ((cardSet == 'RM') and (cardNumber == '2')) then
		-- For Kylo Ren Driven By Fear, Spawn associated cards
		local spawnXOffset = -7.0
		local spawnZOffset = 2.3

		if owner == "Red" then
			spawnXOffset = 7.0
			spawnZOffset = -2.3
		end

		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "01082",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "01082",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "02071",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
		Global.call("spawnCard", { playerColor = owner,
                                 cardCode = "02071",
                                 spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                 spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
      elseif ((cardSet == 'SoH') and (cardNumber == '93')) then
        -- For SoH Chief Chirpa, spawn a SoH Ewok Warrior.
        local spawnXOffset = -7.0
        local spawnZOffset = 0.0

        if owner == "Red" then
           spawnXOffset = 7.0
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "11095",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })




                                                                      elseif ((cardSet == 'UH') and (cardNumber == '73')) then
                                                                                  -- For UH Padme Amidala spawn Diplomatic Immunity
                                                                                  local spawnXOffset = -7.0
                                                                                  local spawnZOffset = 0.0

                                                                                  if owningPlayerColor == "Red" then
                                                                                     spawnXOffset = 7.0
                                                                                  end

                                                                                  Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                                                             cardCode = "01050",
                                                                                                             spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                                                             spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })


                                                                      elseif ((cardSet == 'UH') and (cardNumber == '33')) then
                                                                                  -- For UH Pre Viszla spawn HS Darksaber
                                                                                  local spawnXOffset = -7.0
                                                                                  local spawnZOffset = 0.0

                                                                                  if owningPlayerColor == "Red" then
                                                                                     spawnXOffset = 7.0
                                                                                  end

                                                                                  Global.call("spawnCard", { playerColor = owningPlayerColor,
                                                                                                             cardCode = "17105",
                                                                                                             spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                                                                                             spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })



      elseif ((cardSet == 'CM') and (cardNumber == '146')) then
        -- For CM Z-6 Jetpack, spawn 1 resource token on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        obj_parameters.position = {object.getPosition()[1]-1.5+0.7,object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+0.7}
        local token = spawnObject(obj_parameters)
        local custom = {}
        custom.image = tokenplayerone.resource
        custom.thickness = 0.1
        custom.merge_distance = 5.0
        custom.stackable = false
        token.setCustomObject(custom)
      else
        -- Nothing needs done here.
      end

      if (isElite == true) then
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, (object.getPosition()[3] + 1 + zOffset)}
        local dice = spawnObject(obj_parameters)
        dice.setCustomObject(custom)
      end
    end
  end
end

function setSpawnPositions(position)
  if self.getRotation()[2] < 5 and self.getRotation()[2] > -5 then
    return {position[1], position[2], position[3], position[4]}
  elseif self.getRotation()[2] < 95 and self.getRotation()[2] > 85 then
    return {position[2], position[1]*-1, position[4], position[3]}
  elseif self.getRotation()[2] < 185 and self.getRotation()[2] > 175 then
    return {position[1]*-1, position[2]*-1, position[3]*-1, position[4]}
  elseif self.getRotation()[2] < 275 and self.getRotation()[2] > 265 then
    return {position[2]*-1, position[1], position[4], position[3]*-1}
  end
end
]]


supportPlaymatScript = [[
function onLoad()
  tokenplayerone = Global.getTable('tokenplayerone')
  tokenplayertwo = Global.getTable('tokenplayertwo')

  if self.getName() == 'Blue Supports' then
    owner = 'Blue'
  else
    owner = 'Red'
  end
end

function onCollisionEnter(collision_info)
  local cardSet = ''
  local cardNumber = ''
  local position = self.getPosition()
  local object = collision_info.collision_object
  local obj_parameters = {}
  local custom = {}
  local SWDARHISTHEBEST = Global.getTable("SWDARHISTHEBEST")

  obj_parameters.type = 'Custom_Dice'
  obj_parameters.scale = {1.7,1.7,1.7}
  obj_parameters.position = {object.getPosition()[1],object.getPosition()[2]+1,object.getPosition()[3]}
  obj_parameters.rotation = {0,object.getRotation()[2]+180,0}

  if object.getVar("spawned") ~= true and object.tag == 'Card' then
    local cardFound = false
    local cardDescription = object.getDescription()
    local cardDescriptionLength = 0
    local dataTableIndex = 1
    local isElite = false

    if cardDescription != nil then
      cardDescriptionLength = string.len(cardDescription)
      if string.sub(cardDescription, 1, 5) == 'elite' then
        isElite = true
      end
    end

    -- If there is text past "elite", or the card is not elite and there is text at all, the card uses the new format.
    if (((isElite == true) and (cardDescriptionLength > 5)) or
        ((isElite == false) and (cardDescriptionLength > 0))) then
      -- This is a new card export.  Extract the set and number.
      local setCharIndex = 1
      local numberCharIndex = 1
      if (isElite == true) then
        setCharIndex = 7
      else
        setCharIndex = 1
      end

      -- Do a plain search.
      numberCharIndex = (string.find(cardDescription, ' ', setCharIndex, true) + 1)
      cardSet = string.sub(cardDescription, setCharIndex, (numberCharIndex - 2))
      -- Leaving out the third argument takes a substring to the end of the string.
      cardNumber = string.sub(cardDescription, numberCharIndex)

      -- Find the card by its set and number.
      for i in ipairs(SWDARHISTHEBEST) do
        if ((SWDARHISTHEBEST[i]["set"] == cardSet) and
            (SWDARHISTHEBEST[i]["number"] == cardNumber) and
            ((SWDARHISTHEBEST[i]["type"] == 'Support') or (SWDARHISTHEBEST[i]["type"] == 'Battlefield'))) then
          cardFound = true
          dataTableIndex = i
          break
        end
      end

      local diceSpawnDebug = Global.getVar("diceSpawnDebug")

      if (cardFound == false) then
        if diceSpawnDebug == true then
          printToAll("Error, card " .. cardSet .. " " .. cardNumber .. " not found (make sure it is actually a support).", {1,0,0})
        end
      end
    else
      -- This may be an old card export.  Do nothing.
    end

    if (cardFound == true) then
      collision_info.collision_object.setVar("spawned", true)

      if (SWDARHISTHEBEST[dataTableIndex]["diceimage"] != nil) then
        local dice = spawnObject(obj_parameters)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        dice.setCustomObject(custom)
      end

      if ((cardSet == 'AW') and (cardNumber == '99')) then
        -- For AW Backup Muscle, spawn 3 damage tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = {collision_info.collision_object.getPosition()[1]-1.5+(i*0.7),collision_info.collision_object.getPosition()[2]+0.2,collision_info.collision_object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.damageone
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      elseif ((cardSet == 'LEG') and (cardNumber == '70')) then
        -- For LEG Modified HWK-290, spawn 2 damage tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,2 do
          obj_parameters.position = {collision_info.collision_object.getPosition()[1]-1.5+(i*0.7),collision_info.collision_object.getPosition()[2]+0.2,collision_info.collision_object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.damageone
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      elseif ((cardSet == 'SoR') and (cardNumber == '124')) then
        -- For SoR Air Superiority, spawn 3 shield tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = {collision_info.collision_object.getPosition()[1]-1.5+(i*0.7),collision_info.collision_object.getPosition()[2]+0.2,collision_info.collision_object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.shield
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
     elseif ((cardSet == 'WotF') and (cardNumber == '128')) then
        -- For WotF Ammo Reserves, spawn 3 damage tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = {collision_info.collision_object.getPosition()[1]-1.5+(i*0.7),collision_info.collision_object.getPosition()[2]+0.2,collision_info.collision_object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.damageone
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      elseif ((cardSet == 'CONV') and (cardNumber == '31')) then
        -- For CONV Megablaster Troopers, spawn a First Order Stormtrooper die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/940587492855532900/1228C3F5E9F9ADF45DC65F9E14C5448B0A7006B1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '85')) then
        -- For AF Anakin's Spirit, spawn a Darth Vader die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/937205659715959521/EEB265C565C4D19B03B95E29E3383255D154DE5D/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '90')) then
        -- For AF Senate Guard, spawn a Stun Baton die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910157197472462168/B3286FC5C47D12E529035AE6246DF9EB43A98F0D/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '18')) then
        -- For AF Morgan Elspeth, spawn a Thrawn die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/771720478341861471/B936B387387095363632D20FE9A437EC52896F78/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '37')) then
        -- For AF Cumulus-Class Corsair, spawn a Snub Fighter die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/hdcWOIe.png"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'AF') and (cardNumber == '58')) then
        -- For AF Jan Dodonna, spawn a Rebel Trooper die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/147885549582781089/21E1106177BD4C9C67CAACA5FFC310E4A3B39C31/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'DoP') and (cardNumber == '23')) then
        -- For DoP Executor, spawn a Planetary Bombardment die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910172009674812868/54D81E914D64B52CB27DD8EE91F1B2FF74C9F31C/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'DoP') and (cardNumber == '56')) then
        -- For DoP Aayla, spawn a Clone Trooper die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910157197472418178/7C0B5FF88FF25AACA93F475486ADB0C41FA6758F/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'DoP') and (cardNumber == '116')) then
        -- For DoP Jawa Trade Route, spawn a Jawa Scavenger die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/866244165279375107/78A625BE6D642B8F8DE5DCC602DC05FFBC549368/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'DoP') and (cardNumber == '33')) then
        -- For DoP Rook Kast, spawn Mando Commando and Maul dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/948453532242773388/D3672474872AF3718C016EE0ED82EE3F6DEBEFE6/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/771720478341846336/2BD67269B1D301F475942CF572E6812F3AF98727/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '25')) then
        -- For SA Star Destroyer, spawn 3 TIE Fighter dice on the card.
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "http://i.imgur.com/EyA8opr.jpg"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "http://i.imgur.com/EyA8opr.jpg"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+2, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "http://i.imgur.com/EyA8opr.jpg"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '47')) then
        -- For SA Big Rey, spawn Luke & Leia dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/257091088004693948/C3986CEC4CDD4F70FB3443F041B97029E0BFC2C4/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665906525/FA09A4229B293A483BE7E61F425F039FD32C99F1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '46')) then
        -- For SA Little Rey, spawn Big Rey, Luke & Leia dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/257091088004693948/C3986CEC4CDD4F70FB3443F041B97029E0BFC2C4/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665906525/FA09A4229B293A483BE7E61F425F039FD32C99F1/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+2, object.getPosition()[2]+1, object.getPosition()[3]+2}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/Acly8BM.png"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '5')) then
        -- For SA Snoke, spawn Citadel Lab dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/5IpkCCs.png"
        extradice.setCustomObject(custom)

      elseif ((cardSet == 'SA') and (cardNumber == '6')) then
        -- For SA Citadel Lab, spawn Snoke Lab dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/6Aa7jH1.png"
        extradice.setCustomObject(custom)

      elseif ((cardSet == 'SA') and (cardNumber == '55')) then
        -- For Jedi Temple Guards, make it elite.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/tFVFtMl.png"
        extradice.setCustomObject(custom)

      elseif ((cardSet == 'SA') and (cardNumber == '63')) then
        -- For SA Tallissan, spawn A-Wing dice on the card.
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/934964008673137645/2460E379D583CB6ACE6103EAD12601FEDE413A48/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '69')) then
        -- For SA Venator, spawn 2 ARC-170 dice on the card.
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/948454029952543079/F680053EC03D7D1DF28D2E891A92236E10B7CF20/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/948454029952543079/F680053EC03D7D1DF28D2E891A92236E10B7CF20/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'SA') and (cardNumber == '101')) then
        -- For SA Tusken Camp, spawn 2 Tusken Raider dice on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/194046562282923028/7D7DC21B0F1EF2458857FA71648AAD7FA95913C0/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/194046562282923028/7D7DC21B0F1EF2458857FA71648AAD7FA95913C0/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '1')) then
        -- For RES Allya, spawn a Nightsister die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/194046562282917283/7BC2002A4274F4AF6C429256B5BB7F1B34BDB6C8/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '25')) then
        -- For RES ISB Central Office, spawn an ISB Agent die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://drive.google.com/uc?id=1iE1GdTIc5nbuQdTfpBfJI_9p8Sb2tG6s"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '26')) then
        -- For RES Pre-Mor Enforcers, spawn a Conscript Squad die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/949605779489070002/508DC7B151C3C66CD421CBB1E573166460BF8EBA/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

        -- EVENTS DO NOT SPAWN DICE
      elseif ((cardSet == 'RES') and (cardNumber == '49')) then
        -- For RES Desperate Power, spawn a Force Retaliation die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://i.imgur.com/FyShEtk.png"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

      elseif ((cardSet == 'RES') and (cardNumber == '105')) then
        -- For RES Going Somewhere, Solo? spaw a Greedo and a Han Solo die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910157197472405292/985BD94742BE2FE3891CA1C988B8244D805BA7A6/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/771720478341882755/66F677DD426228E54F0D768DDFCAB03E117D3192/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]


      elseif ((cardSet == 'UH') and (cardNumber == '4')) then
        -- For UH Ren, spawn a Servant of the darkside die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/869614971447060228/C85E02EF69DD550F2CC533307AD77CA8BCDCE44F/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]



      elseif ((cardSet == 'UH') and (cardNumber == '68')) then
        -- For UH The Bad Batch spaw a Clone Trooper and a Rebel Engineer die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/910157197472418178/7C0B5FF88FF25AACA93F475486ADB0C41FA6758F/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
        obj_parameters.position = {object.getPosition()[1], object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/952969527667705761/79E1A1F84406DE5C07021C7FAF771C7BE8F69154/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]



	  elseif ((cardSet == 'RM') and (cardNumber == '60')) then
        -- For RED Redemption, spawn a Medical Droid die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/858354911724420112/984FA39EC5929853F0C047FFF70FAE9D1FCCF425/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

		obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/858354911724420112/984FA39EC5929853F0C047FFF70FAE9D1FCCF425/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
	  elseif ((cardSet == 'RM') and (cardNumber == '3')) then
        -- For RED Maul 3A, spawn Maul 3B.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665912771/B520C11D5753DAE3B5455576138FA8DEF5584208/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
	   elseif ((cardSet == 'RM') and (cardNumber == '5')) then
        -- For RED Savage 4A, spawn Savage 4B.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665924865/D0CB98B795A6D75799BC24A508D19CD2C4D58D1F/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
	  elseif ((cardSet == 'RM') and (cardNumber == '12')) then
        -- For RED Watch Your Career With Great Interest, spawn Vader 10B.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665890223/25CA88EAB9BA70883B8965011A0FD15ACC889F53/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
	  elseif ((cardSet == 'RM') and (cardNumber == '95')) then
        -- For RED The Ultimate Heist, spawn Master of Pirates 92B.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226666159528/4B0F30C9946F8613850FEF6B157E6A6FBAB7C182/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
	  elseif ((cardSet == 'RM') and (cardNumber == '91')) then
        -- For RED Hondo Ohnaka, spawn a Pirate Loyalist die on the card.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665917819/ACF3309D19EE7E9768FFC8CCEE7008D69900941E/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]

		obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]+1}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665917819/ACF3309D19EE7E9768FFC8CCEE7008D69900941E/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
	  elseif ((cardSet == 'RM') and (cardNumber == '26')) then
        -- For RED Blizzard, spawn an extra die.
        obj_parameters.position = {object.getPosition()[1]+1, object.getPosition()[2]+1, object.getPosition()[3]}
        local extradice = spawnObject(obj_parameters)
        custom.image = "https://steamusercontent-a.akamaihd.net/ugc/1750180226665885478/CDC41216758A6B0519A5C8981B38AF01112674D9/"
        extradice.setCustomObject(custom)
        custom.image = SWDARHISTHEBEST[dataTableIndex]["diceimage"]
      elseif ((cardSet == 'AoN') and (cardNumber == '17')) then
        -- For AoN LR-57 Combat Droid, spawn 1 resource token on the card.
    --    obj_parameters.type = 'Custom_Token'
    --    obj_parameters.rotation = {3.87674022, 0, 0.239081308}
    --    obj_parameters.scale = {0.227068469, 1, 0.227068469}
    --    obj_parameters.position = {object.getPosition()[1]-0.8,object.getPosition()[2]+0.2,object.getPosition()[3]-0.8}
    --    local token = spawnObject(obj_parameters)
    --    local custom = {}
    --    custom.image = tokenplayerone.resource
    --    custom.thickness = 0.1
    --    custom.merge_distance = 5.0
    --    custom.stackable = false
    --    token.setCustomObject(custom)


  elseif ((cardSet == 'HS') and (cardNumber == '77')) then
   -- For HS Whistling birds spawn a resource token on the card.
    obj_parameters.type = 'Custom_Token'
    obj_parameters.rotation = {3.87674022, 0, 0.239081308}
    obj_parameters.scale = {0.227068469, 1, 0.227068469}
    obj_parameters.position = {object.getPosition()[1]-0.8,object.getPosition()[2]+0.2,object.getPosition()[3]-0.8}
    local token = spawnObject(obj_parameters)
    local custom = {}
    custom.image = tokenplayerone.resource
    custom.thickness = 0.1
    custom.merge_distance = 5.0
    custom.stackable = false
    token.setCustomObject(custom)



      elseif ((cardSet == 'SoH') and (cardNumber == '71')) then
        -- For SoH Three Lessons, spawn 3 resource tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      elseif ((cardSet == 'SoH') and (cardNumber == '105')) then
        -- For SoH Chief Chirpa's Hut, spawn a SoH Ewok Warrior.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owner == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owner,
                                   cardCode = "11095",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

       elseif ((cardSet == 'RES') and (cardNumber == '16')) then
        -- For RES Linus Mosk, spawn 2x Measure for Measure, 2x Fresh Supplies and 2x Seizing Territory.
        local spawnXOffset = -7.0
        local spawnZOffset = 2.3

        if owningPlayerColor == "Red" then
           spawnXOffset = 7.0
           spawnZOffset = -2.3
        end

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "09127",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })
         Global.call("spawnCard", { playerColor = owningPlayerColor,
                                    cardCode = "09127",
                                    spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                    spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "09126",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

       Global.call("spawnCard", { playerColor = owningPlayerColor,
                                  cardCode = "09126",
                                  spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                  spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

        Global.call("spawnCard", { playerColor = owningPlayerColor,
                                   cardCode = "11129",
                                   spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                   spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

       Global.call("spawnCard", { playerColor = owningPlayerColor,
                                  cardCode = "11129",
                                  spawnPosition = { object.getPosition()[1]+spawnXOffset, object.getPosition()[2]+0.2, object.getPosition()[3]+spawnZOffset },
                                  spawnRotation = { object.getRotation()[1], object.getRotation()[2], object.getRotation()[3] } })

     elseif ((cardSet == 'CM') and (cardNumber == '146')) then
       -- For CM Z-6 Jetpack, spawn 1 resource token on the card.
       obj_parameters.type = 'Custom_Token'
       obj_parameters.rotation = {3.87674022, 0, 0.239081308}
       obj_parameters.scale = {0.227068469, 1, 0.227068469}
       obj_parameters.position = {object.getPosition()[1]-1.5+0.7,object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+0.7}
       local token = spawnObject(obj_parameters)
       local custom = {}
       custom.image = tokenplayerone.resource
       custom.thickness = 0.1
       custom.merge_distance = 5.0
       custom.stackable = false
       token.setCustomObject(custom)

      elseif ((cardSet == 'CM') and
              ((cardNumber == '113') or (cardNumber == '125') or (cardNumber == '142'))) then
        -- For CM Seeking Knowledge, CM Tactical Delay, or CM Improvised Explosive, spawn 2 resource tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,2 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      elseif ((cardSet == 'CM') and
              ((cardNumber == '33') or (cardNumber == '154'))) then
        -- For CM Merchant Freighter or CM TIE Bomber, spawn 3 resource tokens on the card.
        obj_parameters.type = 'Custom_Token'
        obj_parameters.rotation = {3.87674022, 0, 0.239081308}
        obj_parameters.scale = {0.227068469, 1, 0.227068469}
        for i=1,3 do
          obj_parameters.position = {object.getPosition()[1]-1.5+(i*0.7),object.getPosition()[2]+0.2,object.getPosition()[3]-1.5+(i*0.7)}
          local token = spawnObject(obj_parameters)
          local custom = {}
          custom.image = tokenplayerone.resource
          custom.thickness = 0.1
          custom.merge_distance = 5.0
          custom.stackable = false
          token.setCustomObject(custom)
        end
      else
        -- Nothing needs done here.
      end

      if (isElite == true) then
        printToAll("Error, supports cannot be elite.  Ignoring tag.", {1,0,0})
      end
    end
  end
end

function setSpawnPositions(position)
  if self.getRotation()[2] < 5 and self.getRotation()[2] > -5 then
    return {position[1], position[2], position[3], position[4]}
  elseif self.getRotation()[2] < 95 and self.getRotation()[2] > 85 then
    return {position[2], position[1]*-1, position[4], position[3]}
  elseif self.getRotation()[2] < 185 and self.getRotation()[2] > 175 then
    return {position[1]*-1, position[2]*-1, position[3]*-1, position[4]}
  elseif self.getRotation()[2] < 275 and self.getRotation()[2] > 265 then
    return {position[2]*-1, position[1], position[4], position[3]*-1}
  end
end
]]

function spawnResource() -- Extend to remove resource on right click.
  local position = self.getPosition()
  local obj_parameters = {}
  obj_parameters.type = 'Custom_Token'
  if owner == 'Blue' then
    obj_parameters.position = {(position[1]+2.60-spawnd),(position[2]+0.2),(position[3]-6.55)}
    obj_parameters.rotation = {3.87674022, 0, 0.239081308}
  else
    obj_parameters.position = {(position[1]-2.60+spawnd),(position[2]+0.2),(position[3]+6.55)}
    obj_parameters.rotation = {3.87674022, 180, 0.239081308}
  end
  obj_parameters.callback_function = resourceSpawned
  local token = spawnObject(obj_parameters)
  local custom = {}
  custom.image = tokenplayerone.resource
  custom.thickness = 0.1
  custom.merge_distance = 5.0
  custom.stackable = false
  token.setCustomObject(custom)
  token.scale {0.227068469, 1, 0.227068469}
  spawnd = spawnd + 0.8
  if spawnd > 4.8 then
    spawnd = 0
  end
end

function randomDiscard()
  local handObjects = Player[owner].getHandObjects()
  local numHandObjects = #handObjects
  local position=self.getPosition()

  if numHandObjects > 0 then
    if owner == 'Blue' then handObjects[math.random(numHandObjects)].setPosition({position[1]-math.random(10)+5,1.2,position[3]-10})
    else handObjects[math.random(numHandObjects)].setPosition({position[1]+math.random(10)-5,1.2,position[3]+10}) end
  end
end

function shuffleHand()
  local handObjects = Player[owner].getHandObjects()
  local numHandObjects = #handObjects
  local cardPositions = {}

  if numHandObjects > 0 then
    for i, v in pairs(handObjects) do
        cardPositions[i] = v.getPosition()
    end
    local handObjectsShuffled = shuffleTable(handObjects)
    local cardPositionsShuffled = shuffleTable(cardPositions)
    for i, v in pairs(handObjectsShuffled) do
        v.setPosition(cardPositionsShuffled[i])
    end
  end
end

function shuffleTable(t)
    for i = #t, 2, -1 do
        local n = math.random(i)
        t[i], t[n] = t[n], t[i]
    end
    return t
end

function movePlayerBoards()
  blueResourceZone.setPosition({-23.00, 2.51, 0.32})
  blueBattlefieldZone.setPosition({-18.39, 2.51, 0.27})
  blueMatZone.setPosition({4.82, 0.90, 10.20})
  blueBoardsPrefab.setPosition({-20.85, 0.97, 10.05})

  redResourceZone.setPosition({23.00, 2.51, -0.32})
  redResourceZone.setRotation({0, 180, 0})
  redBattlefieldZone.setPosition({18.39, 2.51, -0.27})
  redBattlefieldZone.setRotation({0, 180, 0})
  redMatZone.setPosition({-4.82, 0.90, -10.20})
  redMatZone.setRotation({0, 180, 0})
  redBoardsPrefab.setPosition({20.85, 0.97, -10.05})
  redBoardsPrefab.setRotation({0, 0, 0})

  Global.setVar("blueBoardsPrefab", blueBoardsPrefab)
  Global.setVar("blueResourceZone", blueResourceZone)
  Global.setVar("blueBattlefieldZone", blueBattlefieldZone)
  Global.setVar("blueMatZone", blueMatZone)

  Global.setVar("redBoardsPrefab", redBoardsPrefab)
  Global.setVar("redResourceZone", redResourceZone)
  Global.setVar("redBattlefieldZone", redBattlefieldZone)
  Global.setVar("redMatZone", redMatZone)
end

function redtokenclassic()
  token = {
    damageone = "https://steamusercontent-a.akamaihd.net/ugc/194046562280483535/A29691412CEC7FDE752A603736EBB99405CC347B/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/194046562280484252/758430B535676DA603F0041356827EE9BD7B830A/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/194046562280485442/DA82F2C7D32BF37A2CB403635876FF96D7D1B0E8/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/194046562280484903/A696882BD4631043881D60F55CC823EE1FC7BE1D/"
  }
  Global.setTable('tokenplayerone', token)
  self.editButton({index=12,label='!Red: Classic!'})
  self.editButton({index=9,label='Red: BrokenEgg LS'})
  self.editButton({index=8,label='Red: BrokenEgg DS'})
end

function bluetokenclassic()
  token = {
    damageone = "https://steamusercontent-a.akamaihd.net/ugc/194046562280483535/A29691412CEC7FDE752A603736EBB99405CC347B/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/194046562280484252/758430B535676DA603F0041356827EE9BD7B830A/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/194046562280485442/DA82F2C7D32BF37A2CB403635876FF96D7D1B0E8/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/194046562280484903/A696882BD4631043881D60F55CC823EE1FC7BE1D/"
  }
  Global.setTable('tokenplayertwo', token)
  self.editButton({index=13,label='!Blue: Classic!'})
  self.editButton({index=10,label='Blue: BrokenEgg LS'})
  self.editButton({index=11,label='Blue: BrokenEgg DS'})
end

function redtokenls()
  token = {
    damageone = "https://steamusercontent-a.akamaihd.net/ugc/138878581189337871/63224277C5E0CCD81E5623C78329C2B053801F5B/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/138878581189338583/F235212117B6FD1BB4FC4B043F0EC9DAF569F524/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/138878581189344376/524AA619CACA1109F1B0A469C9C9859A364F86BD/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/138878581189343694/82BE715910B90A4A5569BAD0DB945B283CAEB1E1/"
  }
  Global.setTable('tokenplayerone', token)
  self.editButton({index=12,label='Red: Classic'})
  self.editButton({index=9,label='!Red: BrokenEgg LS!'})
  self.editButton({index=8,label='Red: BrokenEgg DS'})
end

function redtokends()
  token = {
    damageone = "https://steamusercontent-a.akamaihd.net/ugc/138878581189341027/478EF1F25A98207586F29710DEDA956B5CC5C798/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/138878581189342765/9149CFBF36AF9E1B58B348527545B95653B90BF5/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/138878581189340289/234BB8378F5AF4E842976CBA8AD0C14F7246E13B/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/138878581189339560/A134B915FD6DD175F8056A5C808B11AD5F73230A/"
  }
  Global.setTable('tokenplayerone', token)
  self.editButton({index=12,label='Red: Classic'})
  self.editButton({index=9,label='Red: BrokenEgg LS'})
  self.editButton({index=8,label='!Red: BrokenEgg DS!'})
end

function bluetokenls()
  token = {
    damageone = "https://steamusercontent-a.akamaihd.net/ugc/138878581189337871/63224277C5E0CCD81E5623C78329C2B053801F5B/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/138878581189338583/F235212117B6FD1BB4FC4B043F0EC9DAF569F524/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/138878581189344376/524AA619CACA1109F1B0A469C9C9859A364F86BD/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/138878581189343694/82BE715910B90A4A5569BAD0DB945B283CAEB1E1/"
  }
  Global.setTable('tokenplayertwo', token)
  self.editButton({index=13,label='Blue: Classic'})
  self.editButton({index=10,label='!Blue: BrokenEgg LS!'})
  self.editButton({index=11,label='Blue: BrokenEgg DS'})
end

function bluetokends()
  token = {
    damageone = "https://steamusercontent-a.akamaihd.net/ugc/138878581189341027/478EF1F25A98207586F29710DEDA956B5CC5C798/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/138878581189342765/9149CFBF36AF9E1B58B348527545B95653B90BF5/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/138878581189340289/234BB8378F5AF4E842976CBA8AD0C14F7246E13B/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/138878581189339560/A134B915FD6DD175F8056A5C808B11AD5F73230A/"
  }
  Global.setTable('tokenplayertwo', token)
  self.editButton({index=13,label='Blue: Classic'})
  self.editButton({index=10,label='Blue: BrokenEgg LS'})
  self.editButton({index=11,label='!Blue: BrokenEgg DS!'})
end

function redtokentcsaga()
  token = {
    damageone = "https://steamusercontent-a.akamaihd.net/ugc/102851052181836065/6DD94520F5D424BBF0F9E0FABCF8FD22305BCA36/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/102851052181834275/A6699914EDB3C0F45CEBBC6C0C3E90DA28E96E26/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/102851052181842011/05D809854B7D3788095964674BED5C1BFC0407E7/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/102851052181837876/FBB02E7AB22AD194A4E1023E3D2F3E3615F72B26/"
  }
  Global.setTable('tokenplayerone', token)
  self.editButton({index=12,label='Red: Classic'})
  self.editButton({index=9,label='Red: BrokenEgg LS'})
  self.editButton({index=8,label='Red: BrokenEgg DS'})
  self.editButton({index=14, label = '!Red: TC Saga!'})
end

function bluetokentcsaga()
  token = {
    damageone = "https://steamusercontent-a.akamaihd.net/ugc/102851052181836065/6DD94520F5D424BBF0F9E0FABCF8FD22305BCA36/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/102851052181834275/A6699914EDB3C0F45CEBBC6C0C3E90DA28E96E26/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/102851052181842011/05D809854B7D3788095964674BED5C1BFC0407E7/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/102851052181837876/FBB02E7AB22AD194A4E1023E3D2F3E3615F72B26/"
  }
  Global.setTable('tokenplayertwo', token)
  self.editButton({index=13,label='Blue: Classic'})
  self.editButton({index=10,label='Blue: BrokenEgg LS'})
  self.editButton({index=11,label='Blue: BrokenEgg DS'})
  self.editButton({index=15, label ='!Blue: TC Saga!'})
end

function buildBox(player, _, id)
  local boxSuccess = true -- Assume successful unless proven otherwise.
  local whichExpansion = nil -- Which expansion is being built.
  player.changeColor('Blue')
  Global.UI.setAttribute("build_box_panel", "active", false)
  Global.setVar("Mode", "Build A Box") -- Record that the build a box format is being used.

  -- Generate a box of the requested expansion.
  if id == "box_aw" then whichExpansion = 'AW'
  elseif id == "box_sor" then whichExpansion = 'SoR'
  elseif id == "box_eaw" then whichExpansion = 'EaW'
  elseif id == "box_leg" then whichExpansion = 'LEG'
  elseif id == "box_wotf" then whichExpansion = 'WotF'
  elseif id == "box_atg" then whichExpansion = 'AtG'
  elseif id == "box_conv" then whichExpansion = 'CONV'
  elseif id == "box_soh" then whichExpansion = 'SoH'
  elseif id == "box_cm" then whichExpansion = 'CM'
  elseif id == "box_fa" then whichExpansion = 'FA'
  elseif id == "box_rm" then whichExpansion = 'RM'
  elseif id == "box_hs" then whichExpansion = 'HS'
  elseif id == "box_uh" then whichExpansion = 'UH'
  elseif id == "box_sa" then whichExpansion = 'SA'
  else print("Error, unknown box ID \"" .. id .. "\".", {1,0,0}) boxSuccess = false end

  if boxSuccess == true then
    -- Hide the menu object while the box builds.
    self.setLock(true)
    self.interactable = false
    self.setPosition({0,-4,0})

    -- Briefly wait so that the modern GUI can close.
    Wait.time(function() continueBuildBox(whichExpansion) end, 0.05)
  end
end

function continueBuildBox(whichExpansion)
  -- Table of dice cards separated by color.
  local boxDiceCards = { {}, {}, {}, {} }
  -- Table of other cards separated by color.
  local boxNonDiceCards = { {}, {}, {}, {} }

  local SWDARHISTHEBEST = Global.getTable("SWDARHISTHEBEST")
  local ttsDeckInfo = Global.getTable("ttsDeckInfo")

  for i,curExpansion in pairs(allExpansions) do
    expansionLegendaries[curExpansion] = {}
    expansionRares[curExpansion]       = {}
    expansionUncommons[curExpansion]   = {}
    expansionCommons[curExpansion]     = {}
  end

  -- Generate tables for cards in each expansion.
  for index,curCard in ipairs(SWDARHISTHEBEST) do
    local cardSet = curCard["set"]
    local rarity = curCard["rarity"]

    if expansionLegendaries[cardSet] and "Legendary" == rarity then
      table.insert(expansionLegendaries[cardSet], curCard["set"] .. ' ' .. curCard["number"])
    elseif expansionRares[cardSet] and "Rare" == rarity then
      table.insert(expansionRares[cardSet], curCard["set"] .. ' ' .. curCard["number"])
    elseif expansionUncommons[cardSet] and "Uncommon" == rarity then
      table.insert(expansionUncommons[cardSet], curCard["set"] .. ' ' .. curCard["number"])
    elseif expansionCommons[cardSet] and "Common" == rarity then
      table.insert(expansionCommons[cardSet], curCard["set"] .. ' ' .. curCard["number"])
    end
  end

  -- Generate a box for the requested expansion.
  rivalsExpansionPacks[whichExpansion] = {}
  generateBox(whichExpansion)

  local cardIndex = 1
  local curDescription = nil
  local curCardInfo = nil

  -- Separate cards by color.
  for packIndex=1,36 do
    for nonDiceIndex=1,4 do
      curDescription = rivalsExpansionPacks[whichExpansion][cardIndex]
      curCardInfo = getCardInfo(SWDARHISTHEBEST, curDescription)

      if curCardInfo then
        if curCardInfo["color"] == "blue" then
          table.insert(boxNonDiceCards[1], curCardInfo)
        elseif curCardInfo["color"] == "red" then
          table.insert(boxNonDiceCards[2], curCardInfo)
        elseif curCardInfo["color"] == "yellow" then
          table.insert(boxNonDiceCards[3], curCardInfo)
        elseif curCardInfo["color"] == "gray" then
          table.insert(boxNonDiceCards[4], curCardInfo)
        else printToAll("Error, unknown color for card \"" .. curDescription .. "\".", {1,0,0}) end
      else printToAll("Failed to find card \"" .. curDescription .. "\".", {1,0,0}) end

      cardIndex = cardIndex + 1
    end

    curDescription = rivalsExpansionPacks[whichExpansion][cardIndex]
    curCardInfo = getCardInfo(SWDARHISTHEBEST, curDescription)

    if curCardInfo ~= nil then
      if curCardInfo["color"] == "blue" then
        table.insert(boxDiceCards[1], curCardInfo)
      elseif curCardInfo["color"] == "red" then
        table.insert(boxDiceCards[2], curCardInfo)
      elseif curCardInfo["color"] == "yellow" then
        table.insert(boxDiceCards[3], curCardInfo)
      elseif curCardInfo["color"] == "gray" then
        table.insert(boxDiceCards[4], curCardInfo)
      else print("Error, unknown color for card \"" .. curDescription .. "\".", {1,0,0}) end
    else print("Failed to find card \"" .. curDescription .. "\".", {1,0,0}) end

    cardIndex = cardIndex + 1
  end

  -- Spawn all dice cards in a square.
  cardIndex = 1
  for colorIndex=1,4 do
    for i,cardInfo in pairs(boxDiceCards[colorIndex]) do
      spawnSingleCard(ttsDeckInfo,
                      cardInfo,
                      { 10.30 - (4.00 * ((cardIndex - 1) % 6)),
                        1.03,
                        (-22.50) + (5.00 * math.floor((cardIndex - 1) / 6)) })

      cardIndex = cardIndex + 1
    end
  end

  -- Spawn all non-dice cards in stacks.
  for colorIndex=1,4 do
    cardIndex = 1
    for i,cardInfo in pairs(boxNonDiceCards[colorIndex]) do
      spawnSingleCard(ttsDeckInfo,
                      cardInfo,
                      { 10.30 - (6.67 * (colorIndex - 1)),
                        1.03 + (0.50 * (cardIndex - 1)),
                        10 })

      cardIndex = cardIndex + 1
    end
  end
  
  setupObject.destruct()
  self.destruct()
end

function getCardInfo(SWDARHISTHEBEST, cardDescription)
  local retValue = nil
  local cardSet = nil
  local numberCharIndex = 1
  local cardNumber = nil

  -- Get the card set and number.
  numberCharIndex = (string.find(cardDescription, ' ', 1, true) + 1)
  cardSet = string.sub(cardDescription, 1, (numberCharIndex - 2))
  -- Leaving out the third argument takes a substring to the end of the string.
  cardNumber = string.sub(cardDescription, numberCharIndex)

  for index,curCard in ipairs(SWDARHISTHEBEST) do
    if ((curCard["set"] == cardSet) and (curCard["number"] == cardNumber)) then
      retValue = curCard
      break
    end
  end

  return retValue
end

function spawnSingleCard(ttsDeckInfo, cardInfo, spawnPosition)
  local spawnParams = {}
  local cardJSON = nil
  local cardName = nil
  local cardID = 0
  local cardDeckID = 0
  local cardSideways = false
  local actualRotY = 0.0
  local ttsDeckImage = nil
  local ttsDeckWidth = 0
  local ttsDeckHeight = 0

  cardName = cardInfo["cardname"]
  cardID = cardInfo["ttscardid"]
  cardDeckID = string.sub(cardID, 1, -3)
  if cardInfo["type"] == "Battlefield" then
    cardSideways = true
  else
    cardSideways = false
  end

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
    Description = (cardInfo["set"] .. " " .. cardInfo["number"]),
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
    SidewaysCard = cardSideways,
    CustomDeck = {},
    LuaScript = "",
    LuaScriptState = "",
    GUID = "700000" -- The GUID will be automatically updated when a card is spawned onto the table.
  }

  ttsDeckImage = nil
  ttsDeckWidth = 0
  ttsDeckHeight = 0
  for i,ttsDeck in pairs(ttsDeckInfo) do
    if ttsDeck.ttsdeckid == cardDeckID then
      ttsDeckImage = ttsDeck.deckimage
      ttsDeckWidth = ttsDeck.deckwidth
      ttsDeckHeight = ttsDeck.deckheight
      break
    end
  end

  if ttsDeckImage then
    cardJSON.CustomDeck[tostring(cardDeckID)] = {
      FaceURL = ttsDeckImage,
      BackURL = "https://steamusercontent-a.akamaihd.net/ugc/102850418890247821/C495C2DA41D081A5CD513AC62BE8F69775DC5ADB/",
      NumWidth = ttsDeckWidth,
      NumHeight = ttsDeckHeight,
      BackIsHidden = true,
      UniqueBack = false
    }
  else
    print("Did not find deck with ID " .. cardDeckID .. " !", {1,0,0})
  end

  -- Directly spawn the card.
  spawnParams.json = JSON.encode(cardJSON)
  spawnParams.position = { spawnPosition[1], spawnPosition[2], spawnPosition[3] }
  spawnParams.rotation = { 0, 0, 0 }
  spawnObjectJSON(spawnParams)
end