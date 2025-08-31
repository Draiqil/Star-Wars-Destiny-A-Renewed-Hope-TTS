--[[ CREDITS [In no particular order] ]]--

-- Agent of Zion
-- AceJon
-- AgentElrond
-- Draiqil


function onload()
  Wait.frames(function() setTableDesign(nil, nil, "table_classic_blue") deckInited = false hideSetup() end, 3)
  Player.White.changeColor('Blue') -- So the menu is right side up.

  MENU_NONE                   = 0
  MENU_MAIN                   = 1
  MENU_LIMITED                = 2
  MENU_BUILD_BOX              = 3
  MENU_OPTIONS                = 4

  debugMode				   = true -- Used for verbose function logging.

  cycleDeckGUIDs		   = {'60e044', '2c77b2', 'c90abd', '3b60b9', '939b99', 'c89805'} -- AWK, LEG, CONV, FA, UH, RES
  trashBagGUIDS            = {'ec426b', 'cf6ca1'}

  menuGuid                    = '2a325b'
  blueBoardsTransparentGuid   = '4e185d'
  redBoardsTransparentGuid    = '59f7a8'

  initSeatData()

  -- Rivals setup.
  numWinchesterPlayers        = 0
  limboCheckEnabled           = false
  periodicLimboCheckWaitID    = nil
  pleaseWaitBoardGuid         = '251e70'
  passLeftBoardGuid           = '652fd2'
  passRightBoardGuid          = 'fbdc80'
  winchesterBoardGuid         = 'b12301'
  winchesterStockZones        = {}
  winchesterDraftZones        = {}
  winchesterBasePositions     = {}
  winchesterNumZoneCards      = {}

  -- The number of Winchester packs MUST be a multiple of 2, or else the final card may not be dealt correctly.
  numWinchesterPacks          = 8
  winchesterPickCount         = 0
  winchesterPickCountText     = nil

  pleaseWaitBoard             = getObjectFromGUID(pleaseWaitBoardGuid)
  pleaseWaitBoard.use_gravity = false pleaseWaitBoard.interactable = false pleaseWaitBoard.setLock(true)

  -- These boards have not yet spawned.
  winchesterBoard          = nil
  passLeftBoard            = nil
  passRightBoard           = nil

  mainMenuPanelOpen        = true
  modernInterfaceActive    = true
  draftGameStarted         = false
  normalGameStarted        = false
  cubeCompatibilityMode    = false
  areBoardsInteractable    = false
  curHostColor             = nil
  passRound                = 1
  curWinchesterPlayer      = nil

  Mode               = "None"

  packSelections           = nil
  nextExpansionIndex       = {}
  rivalsExpansionPacks     = nil
  mixedPacksDeck           = nil
  dealtCardsInfo           = {}
  numPacksDealt            = 0
  seatedPlayers            = {}

  boardStyle               = "board_transparent"

  blueBoardsPrefab         = nil
  blueResourceZone         = nil
  blueBattlefieldZone      = nil
  blueMatZone              = nil
  redBoardsPrefab          = nil
  redResourceZone          = nil
  redBattlefieldZone       = nil
  redMatZone               = nil

  bluePanelMaximized       = true redPanelMaximized = true 
  blueHandCount            = 0 redHandCount = 0
  blueResourceCount        = 0 redResourceCount = 0

setupBagGuid             = '771f25'
setupObject = getObjectFromGUID(setupBagGuid)

  -- Use a small startup delay that blocks dice from spawning.  Otherwise if a midgame save file is loaded, more dice will spawn.
  loadDelayFinished        = false
  Wait.time(function() loadDelayFinished = true end, 1.5)

  scanSeatedPlayers()
  UI.setAttribute("blue_panel", "active", false)
  UI.setAttribute("red_panel", "active", false)
  Wait.time(periodicHandCheck, 1) -- No need for this, can be done on demand?

  winchesterBasePositions[1] = { 21.10, 1.00, 7.10}
  winchesterBasePositions[2] = {  9.20, 1.00, 7.10}
  winchesterBasePositions[3] = { -2.68, 1.00, 7.10}
  winchesterBasePositions[4] = {-14.58, 1.00, 7.10}

  winchesterNumZoneCards[1] = 0
  winchesterNumZoneCards[2] = 0
  winchesterNumZoneCards[3] = 0
  winchesterNumZoneCards[4] = 0

  dataObjectGuid           = '409015'

  dataObject = getObjectFromGUID(dataObjectGuid)
  if dataObject then
    dataObject.interactable = false
  end

  gameTableReference       = nil
  tempTableDesignObject    = nil
  tableDesignLoading       = false

  matKeys                  = {}
  matImages                = {}
  matKeys[1]               = 'hyp'
  matKeys[2]               = 'gld'
  matKeys[3]               = 'kor'
  matKeys[4]               = 'DL1'
  matKeys[5]               = 'DL2'
  matImages["hyp"]         = 'https://steamusercontent-a.akamaihd.net/ugc/919177062067046601/96ECA6342810F724B1ED851D101C754917D04FBD/'
  matImages["gld"]         = 'https://steamusercontent-a.akamaihd.net/ugc/920304477969141605/5D7397B74461A96CD86F438129FCDC0B1AA0A9D4/'
  matImages["kor"]         = 'https://steamusercontent-a.akamaihd.net/ugc/952959191178358429/AE3BB1947C78495EA4EC63FA58B116A55E116310/'
  matImages["DL1"]         = 'https://steamusercontent-a.akamaihd.net/ugc/920304477969169347/2D3828075808D4531890FC9B0CAB9F03DC358BBF/'
  matImages["DL2"]         = 'https://steamusercontent-a.akamaihd.net/ugc/920304477969169845/95318949E96B74FA31C108524A6C0DB4380C05B2/'

  randomizeMats()

  -- Wait before making things uninteractable, or else it does not seem to work, presumably because of reload() in randomizeMats().
  Wait.time(makeDraftTilesUninteractable, 0.5)
  Wait.time(function() setInteractableBoards(areBoardsInteractable) end, 0.5)

  tokenplayerone = {
      damageone = "https://steamusercontent-a.akamaihd.net/ugc/194046562280483535/A29691412CEC7FDE752A603736EBB99405CC347B/",
      damagethree = "https://steamusercontent-a.akamaihd.net/ugc/194046562280484252/758430B535676DA603F0041356827EE9BD7B830A/",
      shield = "https://steamusercontent-a.akamaihd.net/ugc/194046562280485442/DA82F2C7D32BF37A2CB403635876FF96D7D1B0E8/",
      resource = "https://steamusercontent-a.akamaihd.net/ugc/194046562280484903/A696882BD4631043881D60F55CC823EE1FC7BE1D/"
  }
  tokenplayertwo = {
    damageone = "https://steamusercontent-.akamaihd.net/ugc/194046562280483535/A29691412CEC7FDE752A603736EBB99405CC347B/",
    damagethree = "https://steamusercontent-a.akamaihd.net/ugc/194046562280484252/758430B535676DA603F0041356827EE9BD7B830A/",
    shield = "https://steamusercontent-a.akamaihd.net/ugc/194046562280485442/DA82F2C7D32BF37A2CB403635876FF96D7D1B0E8/",
    resource = "https://steamusercontent-a.akamaihd.net/ugc/194046562280484903/A696882BD4631043881D60F55CC823EE1FC7BE1D/"
  }

end

function initSeatData()
  -- Data for seats.  Each entry contains information on the following:
  --
  -- Whether the seat is filled.
  -- Guid of an object to hold dice.
  -- Vector indicating which direction dice should be spawned.
  -- Vector indicating which direction dice rows grow.
  -- Guid of an object to hold the Rivals deck.
  -- Guid of an object to hold a Pass button.
  -- Guid for a draft card scripting zone.
  -- Guid of an object to hold the limbo deck.
  -- Whether this seat has a Pass button.
  -- Whether this seat should have a Pass button.
  -- The limbo deck.
  -- The draw deck.  NOTE:  This variable may occasionally be invalid, such as when a player is down to their last card,
  --                        or if a deck is combined with another deck.  If it becomes invalid, the script zone must
  --                        be searched.
  -- Whether this player's draft stack has cards.
  -- Whether this player's limbo area has cards.
  -- How many pass turns this player finished.
  -- A horizontal offset for placing dice for this player.
  -- A row offset for placing dice for this player.
  seatData = {
    ["Green"]   = { filled=false, diceHolderGuid='e603b5', diceDirectionVector={-1,0,0}, diceRowDirectionVector={0,0,-1}, rivalsDeckHolderGuid='4297fe', passButtonHolderGuid='71f70f', scriptZoneGuid='f05de1', limboHolderGuid='7a0028', hasButton=false, shouldHaveButton=false, limboDeck=nil, drawDeck=nil, draftStackHasCards=false, limboHasCards=false, passTurnsFinished=0, dieOffset=0, dieRowOffset=0, hiddenZoneGuid='64ea2a', hiddenZonePosition={-11.57, 35, 23.71}, matGuid='ab8055'},
    ["Blue"]    = { filled=false, diceHolderGuid='38f77f', diceDirectionVector={-1,0,0}, diceRowDirectionVector={0,0,-1}, rivalsDeckHolderGuid='6d097a', passButtonHolderGuid='6214b1', scriptZoneGuid='645473', limboHolderGuid='0bd257', hasButton=false, shouldHaveButton=false, limboDeck=nil, drawDeck=nil, draftStackHasCards=false, limboHasCards=false, passTurnsFinished=0, dieOffset=0, dieRowOffset=0, hiddenZoneGuid='0b4a6e', hiddenZonePosition={  7.51, 35, 23.71}, matGuid='2cdefc'},
    ["Purple"]  = { filled=false, diceHolderGuid='dfd6c9', diceDirectionVector={0,0,1},  diceRowDirectionVector={-1,0,0}, rivalsDeckHolderGuid='f61d1d', passButtonHolderGuid='61ba3d', scriptZoneGuid='f43f15', limboHolderGuid='3da4dc', hasButton=false, shouldHaveButton=false, limboDeck=nil, drawDeck=nil, draftStackHasCards=false, limboHasCards=false, passTurnsFinished=0, dieOffset=0, dieRowOffset=0, hiddenZoneGuid='db8bab', hiddenZonePosition={ 23.71, 35, 11.57}, matGuid='e51074'},
    ["Pink"]    = { filled=false, diceHolderGuid='79e39b', diceDirectionVector={0,0,1},  diceRowDirectionVector={-1,0,0}, rivalsDeckHolderGuid='f5eeef', passButtonHolderGuid='623f55', scriptZoneGuid='54b60a', limboHolderGuid='bab556', hasButton=false, shouldHaveButton=false, limboDeck=nil, drawDeck=nil, draftStackHasCards=false, limboHasCards=false, passTurnsFinished=0, dieOffset=0, dieRowOffset=0, hiddenZoneGuid='bb0332', hiddenZonePosition={ 23.71, 35, -7.51}, matGuid='5dc222'},
    ["White"]   = { filled=false, diceHolderGuid='41c691', diceDirectionVector={1,0,0},  diceRowDirectionVector={0,0,1},  rivalsDeckHolderGuid='78a6a5', passButtonHolderGuid='bbd437', scriptZoneGuid='6c8d53', limboHolderGuid='cf5444', hasButton=false, shouldHaveButton=false, limboDeck=nil, drawDeck=nil, draftStackHasCards=false, limboHasCards=false, passTurnsFinished=0, dieOffset=0, dieRowOffset=0, hiddenZoneGuid='5aa86f', hiddenZonePosition={ 11.57, 35,-23.71}, matGuid='96f199'},
    ["Red"]     = { filled=false, diceHolderGuid='301d4c', diceDirectionVector={1,0,0},  diceRowDirectionVector={0,0,1},  rivalsDeckHolderGuid='cb63fc', passButtonHolderGuid='0b4f1d', scriptZoneGuid='e88ebb', limboHolderGuid='750faf', hasButton=false, shouldHaveButton=false, limboDeck=nil, drawDeck=nil, draftStackHasCards=false, limboHasCards=false, passTurnsFinished=0, dieOffset=0, dieRowOffset=0, hiddenZoneGuid='aeedb8', hiddenZonePosition={ -7.51, 35,-23.71}, matGuid='772bad'},
    ["Orange"]  = { filled=false, diceHolderGuid='25c131', diceDirectionVector={0,0,-1}, diceRowDirectionVector={1,0,0},  rivalsDeckHolderGuid='795944', passButtonHolderGuid='7b408b', scriptZoneGuid='a2c916', limboHolderGuid='90cb62', hasButton=false, shouldHaveButton=false, limboDeck=nil, drawDeck=nil, draftStackHasCards=false, limboHasCards=false, passTurnsFinished=0, dieOffset=0, dieRowOffset=0, hiddenZoneGuid='19c306', hiddenZonePosition={-23.71, 35,-11.57}, matGuid='737a7e'},
    ["Yellow"]  = { filled=false, diceHolderGuid='7a43ac', diceDirectionVector={0,0,-1}, diceRowDirectionVector={1,0,0},  rivalsDeckHolderGuid='41b6c1', passButtonHolderGuid='2a267a', scriptZoneGuid='b99e98', limboHolderGuid='1cf0d6', hasButton=false, shouldHaveButton=false, limboDeck=nil, drawDeck=nil, draftStackHasCards=false, limboHasCards=false, passTurnsFinished=0, dieOffset=0, dieRowOffset=0, hiddenZoneGuid='0c446e', hiddenZonePosition={-23.71, 35,  7.51}, matGuid='827083'}
  }
end

characterGUILuaScript = [[
function onload()
  -- Load inside the script since global images do not work for players who join late.
  local resourceAssets = {
    { name = "card_minus_button", url = "https://steamusercontent-a.akamaihd.net/ugc/932693183049785038/A3CE1312007B6D4BCDEB2D84F9EB5B498D122C4B/"},
	{ name = "card_plus_button", url = "https://steamusercontent-a.akamaihd.net/ugc/932693183049785426/CD098AC296A5D9124CB9A7F7526BEF7D91881249/"},
	{ name = "card_shield", url = "https://steamusercontent-a.akamaihd.net/ugc/952959316956336450/435B327FE88014C1537D79BE7C14AFE2DFD8D8E0/"},
	{ name = "card_damage", url = "https://steamusercontent-a.akamaihd.net/ugc/952959316956327073/77138A8358F3B5A0DD96FBE1EB931FC32FCF1841/"}
  }
  self.UI.setCustomAssets(resourceAssets)

  self.UI.setXml(Global.getVar("characterGUIXMLScript"))

  -- The XML buttons do nothing and are implemented by hidden classic buttons, since GUI XML buttons can be triggered by middle/right click with no way to differentiate.
  self.createButton({
    click_function="shieldMinus", function_owner=self,
    position={-1.290, 1.060, -3.205}, width=430, height=430, font_size=72, color={0,0,0,0}})
  
	self.createButton({
    click_function="shieldPlus", function_owner=self,
    position={ 0.655, 1.060, -3.205}, width=430, height=430, font_size=72, color={0,0,0,0}})
  
	self.createButton({
    click_function="damagePlus", function_owner=self,
    position={ 2.845, 1.060, -0.907}, width=430, height=430, font_size=72, color={0,0,0,0}})
  
	self.createButton({
    click_function="damageMinus", function_owner=self,
    position={ 2.845, 1.060, 1.195}, width=430, height=430, font_size=72, color={0,0,0,0}})

  self.locked = true self.interactable = false
end

function shieldMinus(buttonObject, playerColor, altClick)
  if ((playerColor == owner) and (altClick == false)) then
    if (shields > 0) then
      shields = (shields - 1)
      self.UI.setAttribute("shields", "text", shields)
      self.UI.setAttribute("opponent_view_shields", "text", shields)

      if ((shields == 6) or (shields == 9) or (shields == 16) or (shields == 19)) then
        self.UI.setAttribute("shields_underline", "text", "__")
        self.UI.setAttribute("opponent_view_shields_underline", "text", "__")
      else
        self.UI.setAttribute("shields_underline", "text", "")
        self.UI.setAttribute("opponent_view_shields_underline", "text", "")
      end
    end
  end
end

function shieldPlus(buttonObject, playerColor, altClick)
  if ((playerColor == owner) and (altClick == false)) then
    shields = (shields + 1)
    self.UI.setAttribute("shields", "text", shields)
    self.UI.setAttribute("opponent_view_shields", "text", shields)

    if ((shields == 6) or (shields == 9) or (shields == 16) or (shields == 19)) then
      self.UI.setAttribute("shields_underline", "text", "__")
      self.UI.setAttribute("opponent_view_shields_underline", "text", "__")
    else
      self.UI.setAttribute("shields_underline", "text", "")
      self.UI.setAttribute("opponent_view_shields_underline", "text", "")
    end
  end
end

function damageMinus(buttonObject, playerColor, altClick)
  if ((playerColor == owner) and (altClick == false)) then
    if (damage > 0) then
      damage = (damage - 1)
      self.UI.setAttribute("damage", "text", damage)
      self.UI.setAttribute("opponent_view_damage", "text", damage)

      if ((damage == 6) or (damage == 9)) then
        self.UI.setAttribute("damage_underline", "text", "_")
        self.UI.setAttribute("opponent_view_damage_underline", "text", "_")
      else
        self.UI.setAttribute("damage_underline", "text", "")
        self.UI.setAttribute("opponent_view_damage_underline", "text", "")
      end
    end
  end
end

function damagePlus(buttonObject, playerColor, altClick)
  if ((playerColor == owner) and (altClick == false)) then
    damage = (damage + 1)
    self.UI.setAttribute("damage", "text", damage)
    self.UI.setAttribute("opponent_view_damage", "text", damage)

    if ((damage == 6) or (damage == 9)) then
      self.UI.setAttribute("damage_underline", "text", "__")
      self.UI.setAttribute("opponent_view_damage_underline", "text", "__")
    else
      self.UI.setAttribute("damage_underline", "text", "")
      self.UI.setAttribute("opponent_view_damage_underline", "text", "")
    end
  end
end
]]

characterGUIXMLScript = [[
<Panel
   id="card_gui"
   active="false"
   position="0 200 -108"
   rotation="0 0 180"
   rectAlignment="MiddleCenter"
   width="128"
   height="128"
   raycastTarget="false"
>
<Button
   offsetXY="-129 520"
   width="80"
   height="80"
   image="card_minus_button"
   raycastTarget="false"
></Button>
<Text
   id="shields_underline"
   offsetXY="-32 520"
   scale="1.5 1.5"
   fontStyle="Bold"
   fontSize="72"
   color="#FFFFFF"
></Text>
<Text
   id="shields"
   offsetXY="-32 520"
   scale="1.5 1.5"
   fontStyle="Bold"
   fontSize="72"
   color="#FFFFFF"
>0</Text>
<Button
   offsetXY="65 520"
   width="80"
   height="80"
   image="card_plus_button"
   raycastTarget="false"
></Button>
<Image
   offsetXY="160 520"
   width="80"
   height="80"
   image="card_shield"
   raycastTarget="false"
></Image>
<Image
   offsetXY="284 390"
   width="80"
   height="80"
   image="card_damage"
   raycastTarget="false"
></Image>
<Button
   offsetXY="284 290"
   width="80"
   height="80"
   image="card_plus_button"
   raycastTarget="false"
></Button>
<Text
   id="damage_underline"
   offsetXY="284 185"
   scale="1.5 1.5"
   fontStyle="Bold"
   fontSize="72"
   color="#FFFFFF"
></Text>
<Text
   id="damage"
   offsetXY="284 185"
   scale="1.5 1.5"
   fontStyle="Bold"
   fontSize="72"
   color="#FFFFFF"
>0</Text>
<Button
   offsetXY="284 80"
   width="80"
   height="80"
   image="card_minus_button"
   raycastTarget="false"
></Button> </Panel>

<Panel
   id="opponent_card_gui"
   active="false"
   position="0 200 -108"
   rotation="0 0 180"
   rectAlignment="MiddleCenter"
   width="128"
   height="128"
   raycastTarget="false"
>

<Text
   id="opponent_view_shields_underline"
   offsetXY="-32 520"
   rotation="0 0 180"
   scale="1.5 1.5"
   fontStyle="Bold"
   fontSize="72"
   color="#FFFFFF"
></Text>

<Text
   id="opponent_view_shields"
   offsetXY="-32 520"
   rotation="0 0 180"
   scale="1.5 1.5"
   fontStyle="Bold"
   fontSize="72"
   color="#FFFFFF"
>0</Text>

<Text
   id="opponent_view_damage_underline"
   offsetXY="280 185"
   width="100"
   height="100"
   rotation="0 0 180"
   scale="1.5 1.5"
   fontStyle="Bold"
   fontSize="72"
   color="#FFFFFF"
></Text>

<Text
   id="opponent_view_damage"
   offsetXY="280 185"
   width="100"
   height="100"
   rotation="0 0 180"
   scale="1.5 1.5"
   fontStyle="Bold"
   fontSize="72"
   color="#FFFFFF"
>0</Text>

<Image
   offsetXY="55 520"
   rotation="0 0 180"
   width="80"
   height="80"
   image="card_shield"
   raycastTarget="false"
></Image>

<Image
   offsetXY="280 285"
   rotation="0 0 180"
   width="80"
   height="80"
   image="card_damage"
   raycastTarget="false"
></Image> </Panel>
]]

function hideSetup()

	if draftMode == true then 
   for _, GUID in ipairs(trashBagGUIDS) do local trashObject = getObjectFromGUID(GUID)
		if trashObject then
			trashObject.destruct()
		end
   end
end

	if deckInited ~= true then
  for _, GUID in ipairs(cycleDeckGUIDs) do local deckObject = getObjectFromGUID(GUID)
	if deckObject then
		deckObject.locked = true
		deckObject.interactable = false
		currentPosition = deckObject.getPosition()
		deckObject.setPosition({(currentPosition.x - 50), (currentPosition.y + 200), (currentPosition.z)})
			end
		end
	end
end

function makeDraftTilesUninteractable()
  local curTile = nil

  -- Make various draft tiles uninteractable to prevent alt-zooming them.
  for i,someSeat in pairs(seatData) do
    curTile = getObjectFromGUID(someSeat.diceHolderGuid)
    if curTile ~= nil then
      curTile.interactable = false
    end

    curTile = getObjectFromGUID(someSeat.rivalsDeckHolderGuid)
    if curTile ~= nil then
      curTile.interactable = false
    end

    curTile = getObjectFromGUID(someSeat.passButtonHolderGuid)
    if curTile ~= nil then
      curTile.interactable = false
    end

    curTile = getObjectFromGUID(someSeat.limboHolderGuid)
    if curTile ~= nil then
      curTile.interactable = false
    end
  end
end

function setInteractableBoards(shouldBeInteractable)
  -- Make mats uninteractable to prevent alt-zooming them.
  local curMat = nil
  for i,someSeat in pairs(seatData) do
    curMat = getObjectFromGUID(someSeat.matGuid)

    if curMat != nil then
      curMat.interactable = shouldBeInteractable
      -- These are made interactable but technically left locked so they do not fall off the bottom of the table.
    end
  end

  -- Handle 2-player board prefabs.

  if (blueBoardsPrefab ~= nil) then
    blueBoardsPrefab.locked         = (not shouldBeInteractable)
    blueBoardsPrefab.interactable   = shouldBeInteractable
  end

  if (redBoardsPrefab ~= nil) then
    redBoardsPrefab.locked          = (not shouldBeInteractable)
    redBoardsPrefab.interactable    = shouldBeInteractable
  end
end

function initBoards()
  -- Make certain objects uninteractable so that players do not alt-zoom or unlock them.
  for i,someSeat in pairs(seatData) do
    local someObject = getObjectFromGUID(someSeat.diceHolderGuid)
    someObject.interactable = false

    someObject = getObjectFromGUID(someSeat.rivalsDeckHolderGuid)
    someObject.interactable = false

    someObject = getObjectFromGUID(someSeat.passButtonHolderGuid)
    someObject.interactable = false

    someObject = getObjectFromGUID(someSeat.limboHolderGuid)
    someObject.interactable = false

    -- Leave mats interactable if players unlock them so that they can use custom images if desired.
    someObject = getObjectFromGUID(someSeat.matGuid)
    someObject.setLock(true)
  end

  -- Spawn boards under the table to avoid white flash(es) while they load.
  winchesterBoard = setupObject.takeObject({position={0,-4,8}, rotation={0,0,0}, guid=winchesterBoardGuid, flip=false, smooth=false, callback='setupWinchesterPickCounter', callback_owner=self})
  winchesterBoard.use_gravity = false
  winchesterBoard.interactable = false
  winchesterBoard.setLock(true)
  winchesterBoard.setPosition({0,-2.4,0})
  passLeftBoard = setupObject.takeObject({position={0,-4,8}, rotation={0,0,0}, guid=passLeftBoardGuid, flip=false, smooth=false})
  passLeftBoard.use_gravity = false
  passLeftBoard.interactable = false
  passLeftBoard.setLock(true)
  passLeftBoard.setPosition({0,-2.2,0})
  passRightBoard = setupObject.takeObject({position={0,-4,8}, rotation={0,0,0}, guid=passRightBoardGuid, flip=false, smooth=false})
  passRightBoard.use_gravity = false
  passRightBoard.interactable = false
  passRightBoard.setLock(true)
  passRightBoard.setPosition({0,-2.1,0})

  -- Create script zones for the Winchester draft stacks.  These are created under the table to avoid white flash(es).
  local obj_parameters = {}

  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.scale = {11.09, 5.10, 33.29}
  obj_parameters.position = {18.010,-4.000, -6.390}
  obj_parameters.rotation = { 0.000, 0.000,  0.000}
  winchesterDraftZones[1] = spawnObject(obj_parameters)

  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.scale = {11.09, 5.10, 33.29}
  obj_parameters.position = { 5.900,-4.000, -6.390}
  obj_parameters.rotation = { 0.000, 0.000,  0.000}
  winchesterDraftZones[2] = spawnObject(obj_parameters)

  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.scale = {11.09, 5.10, 33.29}
  obj_parameters.position = {-5.900,-4.000, -6.390}
  obj_parameters.rotation = { 0.000, 0.000,  0.000}
  winchesterDraftZones[3] = spawnObject(obj_parameters)

  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.scale = {11.09, 5.10, 33.29}
  obj_parameters.position = {-18.010,-4.000, -6.390}
  obj_parameters.rotation = {  0.000, 0.000,  0.000}
  winchesterDraftZones[4] = spawnObject(obj_parameters)

  -- Create a script zones for Winchester stock decks.  These are created under the table to avoid white flash(es).

  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.scale = {5, 5, 6}
  obj_parameters.position = {28.25, -4, 6.60}
  obj_parameters.rotation = {0, 0, 0}
  winchesterStockZones["Blue"] = spawnObject(obj_parameters)

  obj_parameters.type = 'ScriptingTrigger'
  obj_parameters.scale = {5, 5, 6}
  obj_parameters.position = {(-28.25), -4, 6.60}
  obj_parameters.rotation = {0, 0, 0}
  winchesterStockZones["Green"] = spawnObject(obj_parameters)
end

function getColorByIndex(colorIndex)
  if colorIndex == 1 then returnColor = "Green"
  elseif colorIndex == 2 then returnColor = "Blue"
  elseif colorIndex == 3 then returnColor = "Purple"
  elseif colorIndex == 4 then returnColor = "Pink"
  elseif colorIndex == 5 then returnColor = "White"
  elseif colorIndex == 6 then returnColor = "Red"
  elseif colorIndex == 7 then returnColor = "Orange"
  elseif colorIndex == 8 then returnColor = "Yellow"
  else print("Invalid color index " .. colorIndex, {1,0,0}) end
  return returnColor
end

function onChat(message, chatPlayer)

  if string.sub(message, 1, 4) == "!mat" then
    matIndexString = string.sub(message, 6)
    if matImages[matIndexString] ~= nil then
      local matObject = getObjectFromGUID(seatData[chatPlayer.color].matGuid)
      if matObject ~= nil then
        local customObject = matObject.getCustomObject()
        customObject.image = matImages[matIndexString]
        matObject.setCustomObject(customObject)
        matObject.reload()
        Wait.time(function() setInteractableBoards(areBoardsInteractable) end, 0.5)
      end
    else
      if (normalGameStarted == false) then
        printToColor("", chatPlayer.color, {1,1,1})
        printToColor("Usage:", chatPlayer.color, {1,1,1})
        printToColor("", chatPlayer.color, {1,1,1})
        -- Note that the chat font is not necessarily fixed-width, so alignment is done manually.
        printToColor("!mat hyp      Hyperloops mat", chatPlayer.color, {1,1,1})
        printToColor("!mat gld       Golden Dice mat", chatPlayer.color, {1,1,1})
        printToColor("!mat kor       Knights of Ren mat", chatPlayer.color, {1,1,1})
        printToColor("!mat DL1       Destiny League mat 1", chatPlayer.color, {1,1,1})
        printToColor("!mat DL2       Destiny League mat 2", chatPlayer.color, {1,1,1})
        printToColor("", chatPlayer.color, {1,1,1})
      end
    end
end
end

function setOpenMenuWithParams(params)
  local whichMenu = params.whichMenu
  setOpenMenu(whichMenu)
end

function setOpenMenu(whichMenu)
  if (MENU_MAIN == whichMenu) then mainMenuPanelOpen = true
    UI.setAttribute("main_menu_panel", "active", true)
  	else mainMenuPanelOpen = false UI.setAttribute("main_menu_panel", "active", false) end

  if (MENU_LIMITED == whichMenu) then UI.setAttribute("limited_panel", "active", true)
  	else UI.setAttribute("limited_panel", "active", false) end

  if (MENU_BUILD_BOX == whichMenu) then
    UI.setAttribute("build_box_panel", "active", true)
  else
    UI.setAttribute("build_box_panel", "active", false)
  end

  if (MENU_OPTIONS == whichMenu) then UI.setAttribute("options_panel", "active", true)
  	else UI.setAttribute("options_panel", "active", false) end
end

function enableMainMenu(player)
  setOpenMenu(MENU_MAIN)
  updatePanelVisibility()
end

function enableBuildBoxMenu(player)
  setOpenMenu(MENU_BUILD_BOX)
  updatePanelVisibility()
end

function enableLimitedMenu(_)
	draftMode = true hideSetup()
	printToAll("Still in testing! Please report any bugs to Draiqil/Palpatine.", {0.5,0.5,1})
	getObjectFromGUID(menuGuid).setPosition({0, 1, 0})
  
  	setOpenMenu(MENU_LIMITED)
  	updatePanelVisibility()
end

function optionsGUIClicked(player)
  setOpenMenu(MENU_OPTIONS)
  updatePanelVisibility()
end

function setTableDesign(player, _, id) 
	-- Use a ray cast to get a reference to the table.
  local castParameters = {origin={0,2,0}, direction={0,-1,0}, type=1}
  local hitObjects = Physics.cast(castParameters)
  for _,curHit in ipairs(hitObjects) do
    if curHit.hit_object.tag == "Surface" then
      gameTableReference = curHit.hit_object
      break
    end
  end
  if (gameTableReference) then
    if (tableDesignLoading ~= true) then local imageURL
      if id == "table_black" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/922547277902504571/4C206C65460313386BFA3A08981FECD188A8DEB8/"
      elseif id == "table_classic_blue" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/87094544885068211/999D58ABF92A84B0F9DEC49F26494FEA118B9617/"
      elseif id == "table_felt_black" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/952959191175993071/DD605FB1E7C2686C411DED76AAC862C76CEC732B/"
      elseif id == "table_felt_dark_gray" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/952959191175993758/5BAF51C16974164CC188E6437420A3168EEF1489/"
      elseif id == "table_felt_gray" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/952959191175664857/CBBE2E1CC5BF288811907068F2B5E2D1B87A51C0/"
      elseif id == "table_felt_blue" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/952959191176028154/B7FD413C09EC98B96C66FF9E79060CE0BE285028/"
      elseif id == "table_felt_aqua" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/952959191176028666/CD65C281ABE4F9F672414F5ED24876C205D2D0BC/"
      elseif id == "table_felt_green" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/952959191176071242/AD48C0979DBCB857DC0537ECFFC097B9AEA4BBF4/"
      elseif id == "table_felt_red" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/952959191176071726/320D8CAA90D9B4B2BE475792AA205568D3F42A3E/"
      elseif id == "table_felt_purple" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/952959191176072302/5793FB14E4A4F3553E488052843C5B1524F3CA4F/"
      elseif id == "table_felt_white" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/981107421962128802/DB5B554923DD3BDE8716DFC87CAB4757A91765FB/"
      elseif id == "table_camo_green" then imageURL = "https://steamusercontent-a.akamaihd.net/ugc/981107421962121474/344EB3E1A469A47632EC02FFC63DBABE553D10CE/"
	  end

      if imageURL then
        tableDesignLoading = true
        local obj_parameters = {}
        obj_parameters.type = 'Custom_Tile'
        obj_parameters.position = {0,-4,0}
        obj_parameters.rotation = {0,0,0}
        obj_parameters.scale = {1,1,1}
        obj_parameters.sound = false
        obj_parameters.callback_function = function(newObject) updateTempTableDesignObject(imageURL) end
        tempTableDesignObject = spawnObject(obj_parameters)
      		end
    	end
	end
end

function updateTempTableDesignObject(imageURL)
  tempTableDesignObject:setCustomObject({image = imageURL})
  tempTableDesignObject = tempTableDesignObject.reload()

  local checkForImageLoadingFinished = function() return (not tempTableDesignObject.loading_custom) end

  -- Wait for table image to finish loading.
  Wait.condition(function() finishSetTableDesign(imageURL) end, checkForImageLoadingFinished, 10)
end

-- Now that the texture has loaded, set the table design so that it changes very quickly.
function finishSetTableDesign(imageURL)
  gameTableReference.setCustomObject({image=imageURL})
  gameTableReference = gameTableReference.reload()
  -- After a short delay, clean up.  Unfortunately the table object always seems to return loading_custom == true so there is no way to check if the load finished.
  Wait.time(handleTableFinishedUpdating, 0.5)
end

function handleTableFinishedUpdating()
  tempTableDesignObject.destruct()
  tempTableDesignObject = nil
  tableDesignLoading = false

  -- TODO consider calling a utility function that rescales all the hand zones appropriately for the current mode, since changing table settings resets hand zones.
  --   TODO when this is done, also remove code below.
  for i,someSeat in pairs(seatData) do
    local handTransform = Player[i].getHandTransform()
    handTransform.position.y = -10
    handTransform.scale.x = 0.01
    handTransform.scale.y = 0.01
    handTransform.scale.z = 0.01
    Player[i].setHandTransform(handTransform)
  end
  local handTransform = Player["Red"].getHandTransform()
  handTransform.position.x = -1.70
  handTransform.position.y = 4.60
  handTransform.position.z = (-20.00)
  handTransform.rotation.x = 0.00
  handTransform.rotation.y = 0.00
  handTransform.rotation.z = 0.00
  handTransform.scale.x = 35.00
  handTransform.scale.y = 6.65
  handTransform.scale.z = 4.00
  Player["Red"].setHandTransform(handTransform)
  handTransform = Player["Blue"].getHandTransform()
  handTransform.position.x = 1.70
  handTransform.position.y = 4.60
  handTransform.position.z = 20.00
  handTransform.rotation.x = 0.00
  handTransform.rotation.y = 180.00
  handTransform.rotation.z = 0.00
  handTransform.scale.x = 35.00
  handTransform.scale.y = 6.65
  handTransform.scale.z = 4.00
  Player["Blue"].setHandTransform(handTransform)
end

function setBoardStyle(_, _, id)
  -- Move the marker.
  UI.setAttribute("board_style_marker", "offsetXY", UI.getAttribute(id, "offsetXY"))
  boardStyle = id
end

function spawnDraftDeckForPlayer(playerColor, spawnPosition, spawnRotation)
  local deckJSON = nil
  local cardJSON = nil
  local cardName = nil
  local cardDescription = nil
  local cardID = 0
  local cardDeckID = 0
  local ttsDeckImage = nil
  local ttsDeckWidth = 0
  local ttsDeckHeight = 0
  local spawnParams = {}

  deckJSON = {
    Name = "Deck",
    Transform = {
      posX = 0.0,
      posY = 0.0,
      posZ = 0.0,
      rotX = 0.0,
      rotY = 0.0,
      -- The deck is spawned facedown.
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
    -- Note that if there is a conflict, the GUID will be automatically updated when a card is spawned onto the table.
    GUID = "800000"
  }

  for i,curCardInfo in pairs(dealtCardsInfo[playerColor]) do
    cardName = curCardInfo.cardname
    cardDescription = curCardInfo.set .. " " .. curCardInfo.number
    cardID = curCardInfo.ttscardid
    cardDeckID = string.sub(cardID, 1, -3)
    cardJSON = {
      Name = "Card",
      Transform = {
        posX = 0.0,
        posY = 0.0,
        posZ = 0.0,
        rotX = 0.0,
        rotY = 0.0,
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
      -- Note that if there is a conflict, the GUID will be automatically updated when a card is spawned onto the table.
      GUID = "700000"
    }

    -- Record the card ID for each card, even though some ID(s) may be repeated.  Note that despite the name, these values represent card IDs.
    table.insert(deckJSON.DeckIDs, cardID)

    -- If needed, record the CustomDeck information in the overall deck JSON.
    if deckJSON.CustomDeck[tostring(cardDeckID)] == nil then
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

      if ttsDeckImage ~= nil then
        deckJSON.CustomDeck[tostring(cardDeckID)] = {
          FaceURL = ttsDeckImage,
          BackURL = "https://steamusercontent-a.akamaihd.net/ugc/102850418890247821/C495C2DA41D081A5CD513AC62BE8F69775DC5ADB/",
          NumWidth = ttsDeckWidth,
          NumHeight = ttsDeckHeight,
          BackIsHidden = true,
          UniqueBack = false
        }
      else
        printToAll("Error, did not find deck with ID " .. cardDeckID, {1,0,0})
      end
    end -- end for i,curCardName in pairs(cardList)

    -- Add the card to the deck JSON.
    table.insert(deckJSON.ContainedObjects, cardJSON)
  end -- end for i,curCardName in pairs(dealtCardsInfo[playerColor])

  -- Spawn the deck.
  spawnParams.json = JSON.encode(deckJSON)
  spawnParams.position = { spawnPosition.x, spawnPosition.y, spawnPosition.z }
  spawnParams.rotation = { spawnRotation.x, spawnRotation.y, spawnRotation.z }
  spawnObjectJSON(spawnParams)
end

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

function spawnCard(params)
  local playerColor = params.playerColor
  local cardCode = params.cardCode
  local spawnPosition = params.spawnPosition
  local spawnRotation = params.spawnRotation
  local spawnParams = {}
  local spawnSuccessful = true
  local cardInfo = getCardInfo(cardCode)
  local cardJSON = nil
  local cardName = nil
  local cardDescription = nil
  local cardID = 0
  local cardDeckID = 0
  local cardSideways = false
  local ttsDeckImage = nil
  local ttsDeckWidth = 0
  local ttsDeckHeight = 0

  -- TODO consolidate this code instead of duplicating it in multiple places?
  cardName = cardInfo.cardname
  cardDescription = cardInfo.set .. " " .. cardInfo.number
  cardID = cardInfo.ttscardid
  cardDeckID = string.sub(cardID, 1, -3)
  if cardInfo.type == "Battlefield" then
    cardSideways = true
  else
    cardSideways = false
  end
  -- TODO figure out rotating battlefield from any orientation
  cardJSON = {
    Name = "Card",
    Transform = {
      posX = 0.0,
      posY = 0.0,
      posZ = 0.0,
      rotX = 0.0,
      rotY = 0.0,
      rotZ = 0.0,
      scaleX = 1.45,
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
    SidewaysCard = cardSideways,
    CustomDeck = {},
    LuaScript = "",
    LuaScriptState = "",
    -- Note that if there is a conflict, the GUID will be automatically updated when a card is spawned onto the table.
    GUID = "700000"
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
    printToAll("Error, did not find deck with ID " .. cardDeckID, {1,0,0})
    spawnSuccessful = false
  end

  -- Spawn the card.
  spawnParams.json = JSON.encode(cardJSON)
  spawnParams.position = { spawnPosition[1], spawnPosition[2], spawnPosition[3] }
  spawnParams.rotation = { spawnRotation[1], spawnRotation[2], spawnRotation[3] }
  spawnObjectJSON(spawnParams)

  return spawnSuccessful
end

function guiResource(player, clickType)
  if player.color == "Blue" then
    blueBoardsPrefab.call('spawnResource', clickType)
  else
    redBoardsPrefab.call('spawnResource', clickType)
  end
end

function guiPass(player)
  if player.color == "Blue" then
    blueBoardsPrefab.call('passButton')
  else
    redBoardsPrefab.call('passButton')
  end
end

function guiShuffle(player)
  if player.color == "Blue" then
    blueBoardsPrefab.call('shuffleHand')
  else
    redBoardsPrefab.call('shuffleHand')
  end
end

function guiDiscard(player)
  if player.color == "Blue" then
    if (blueHandCount > 0) then
      blueBoardsPrefab.call('randomDiscard')
      blueHandCount = (blueHandCount - 1)
    else
      printToAll(player.color .. "'s hand is empty.", stringColorToRGB(player.color))
    end
  else
    if (redHandCount > 0) then
      redBoardsPrefab.call('randomDiscard')
      redHandCount = (redHandCount - 1)
    else
      printToAll(player.color .. "'s hand is empty.", stringColorToRGB(player.color))
    end
  end
end

function guiToggle(player)
  if normalGameStarted == true then
    if player.color == "Blue" then
      bluePanelMaximized = (not bluePanelMaximized)
    else
      redPanelMaximized = (not redPanelMaximized)
    end

    updatePanelVisibility()
  end
end

-- These functions make sure the middle and right mouse buttons were not clicked.

function blueClaimBattlefield(buttonObject, playerColor, altClick)
  if ((playerColor == "Blue") and (altClick == false)) then
    claimBattlefield(buttonObject, playerColor, altClick)
  end
end

function redClaimBattlefield(buttonObject, playerColor, altClick)
  if ((playerColor == "Red") and (altClick == false)) then
    claimBattlefield(buttonObject, playerColor, altClick)
  end
end

function claimBattlefield(buttonObject, playerColor, altClick)
  local zoneObjects = nil
  local blueBattlefieldCard = nil
  local redBattlefieldCard = nil
  local atLeastOneBattlefieldFound = false

  if normalGameStarted == true then
    zoneObjects = blueBattlefieldZone.getObjects()
    for objectIndex,curObject in ipairs(zoneObjects) do
      if curObject.tag == "Card" then
        blueBattlefieldCard = curObject
        atLeastOneBattlefieldFound = true
        break
      end
    end

    zoneObjects = redBattlefieldZone.getObjects()
    for objectIndex,curObject in ipairs(zoneObjects) do
      if curObject.tag == "Card" then
        redBattlefieldCard = curObject
        atLeastOneBattlefieldFound = true
        break
      end
    end

    if playerColor == "Blue" then
      if blueBattlefieldCard != nil then
        animateBattlefieldInPlace(blueBattlefieldCard)
      elseif redBattlefieldCard != nil then
        animateBattlefieldMove(redBattlefieldCard, redBattlefieldCard.getRotation(), blueBattlefieldZone, 25)
      else
        printToAll("Error, no battlefield found.", {1,0,0})
      end

      if atLeastOneBattlefieldFound == true then
        -- Hide the button while the animation plays.
        blueBoardsPrefab.UI.setAttribute("claim_button", "position", "-255 690 40")
        Wait.time(function() blueBoardsPrefab.UI.setAttribute("claim_button", "position", "-255 690 -10") end, 1.0)

        -- Announce to all players.
        broadcastToAll('Claim', {0.1,0.5,1.0})
      end
    else
      if redBattlefieldCard != nil then
        animateBattlefieldInPlace(redBattlefieldCard)
      elseif blueBattlefieldCard != nil then
        animateBattlefieldMove(blueBattlefieldCard, blueBattlefieldCard.getRotation(), redBattlefieldZone, 25)
      else
        printToAll("Error, no battlefield found.", {1,0,0})
      end

      if atLeastOneBattlefieldFound == true then
        -- Hide the button while the animation plays.
        redBoardsPrefab.UI.setAttribute("claim_button", "position", "-255 690 40")
        Wait.time(function() redBoardsPrefab.UI.setAttribute("claim_button", "position", "-255 690 -10") end, 1.0)

        -- Announce to all players.
        broadcastToAll('Claim', {0.8,0.1,0.1})
      end
    end
  end
end

function animateBattlefieldInPlace(battlefieldCard)
  animateBattlefieldInPlaceFull(battlefieldCard, battlefieldCard.getPosition(), battlefieldCard.getRotation(), 25)
end

function animateBattlefieldInPlaceFull(battlefieldCard, startPosition, startRotation, percentage)
  local newPosition = {x = startPosition.x, y = startPosition.y, z = startPosition.z}
  local newRotation = {x = startRotation.x, y = startRotation.y, z = startRotation.z}

  if (percentage == 25) then
    newPosition.y = (newPosition.y + 2)
    newRotation.y = (newRotation.y + 90)
  elseif (percentage == 50) then
    newPosition.y = (newPosition.y + 4)
    newRotation.y = (newRotation.y + 180)
  elseif (percentage == 75) then
    newPosition.y = (newPosition.y + 2)
    newRotation.y = (newRotation.y + 270)
  elseif (percentage == 100) then
    -- Nothing needs done, since the final position and rotation match the start.
  end

  battlefieldCard.setPositionSmooth(newPosition, false, false)
  battlefieldCard.setRotationSmooth(newRotation, false, false)
  percentage = (percentage + 25)

  if (percentage <= 100) then
    Wait.time(function() animateBattlefieldInPlaceFull(battlefieldCard, startPosition, startRotation, percentage) end, 0.24)
  end
end

function animateBattlefieldMove(battlefieldCard, startRotation, endBattlefieldZone, percentage)
  local zonePosition = endBattlefieldZone.getPosition()
  local newPosition = {x = zonePosition.x, y = zonePosition.y, z = zonePosition.z}
  local newRotation = {x = startRotation.x, y = startRotation.y, z = startRotation.z}

  -- Use a number rather than the zone position because the zone position is midair.
  if (percentage == 25) then
    newPosition.y = (1.18 + 2)
    newRotation.y = (newRotation.y + 90)
    battlefieldCard.setRotationSmooth(newRotation, false, false)
  elseif (percentage == 50) then
    newPosition.y = (1.18 + 4)
    newRotation.y = (newRotation.y + 180)
    battlefieldCard.setRotationSmooth(newRotation, false, false)
  elseif (percentage == 75) then
    newPosition.y = (1.18 + 2)
  elseif (percentage == 100) then
    newPosition.y = 1.18
  end

  battlefieldCard.setPositionSmooth(newPosition, false, false)
  percentage = (percentage + 25)

  if (percentage <= 100) then
    Wait.time(function() animateBattlefieldMove(battlefieldCard, startRotation, endBattlefieldZone, percentage) end, 0.25)
  end
end

function handleNormalGameStarted()
  normalGameStarted = true
  if modernInterfaceActive == true then

    UI.setAttribute("blue_panel", "active", true)
    UI.setAttribute("red_panel", "active", true)

      bluePanelMaximized = (not bluePanelMaximized)
      redPanelMaximized = (not redPanelMaximized)
	  	  Wait.frames(function () updatePanelVisibility() end, 150)
    end
  end

function setupWinchesterPickCounter()
  local obj_parameters = {}

  -- NOTE:  According to people on the internet, assigning rotation here apparently does not work for 3DText.
  -- NOTE:  Unfortunately, using a callback when spawning 3DText does not seem to work at all anymore, so a delay is used instead.
  obj_parameters.type = "3DText"
  obj_parameters.position = {0,-4,0}
  winchesterPickCountText = spawnObject(obj_parameters)

  Wait.time(setupWinchesterText, 0.5)
end

function setupWinchesterText()
  winchesterPickCountText.TextTool.setValue(" ")
  winchesterPickCountText.setRotation({90,180,0})
  winchesterPickCountText.setScale({2,2,2})
  winchesterPickCountText.interactable = false
end

function passButtonClickedGeneral(buttonColor, playerColor)
  if playerColor == buttonColor then
    -- Attempt to avoid synchronization problems where one player is stuck.
    startLuaCoroutine(self, ("passButtonClickedCoroutine" .. playerColor))
  else
    printToAll(playerColor .. " clicked the wrong Pass button.", stringColorToRGB(playerColor))
  end
end

function passButtonClickedCoroutine(playerColor)
  local sourceDeck
  -- Default to the current player.
  local destinationPlayerColor = playerColor

  -- Make sure this is actually passing and not a player clicking a Done button.
  if seatData[playerColor].passTurnsFinished < 14 then
    -- First, determine the pass destination player color.
    if (passRound == 1) then
      destinationPlayerColor = getSeatedPlayerLeft(playerColor)
    else
      destinationPlayerColor = getSeatedPlayerRight(playerColor)
    end

    -- Next, check if the source stack has cards.
    sourceDeck = seatData[playerColor].drawDeck

    -- Check the source stack card count.
    local sourceDeckCount = 0
    if sourceDeck != nil then
      if sourceDeck.tag == "Deck" then
        sourceDeckCount = #(sourceDeck.getObjects())
      else
        -- Assume a single card was found.
        sourceDeckCount = 1
      end
    else
      -- This case should only happen if a single card is left in the script zone, since the deck object is no longer valid.
      -- It may also happen if a player messes up the deck by dragging a card on / off by accident, or because they changed
      -- their mind.
      local scriptZoneObjects = getObjectFromGUID(seatData[playerColor].scriptZoneGuid).getObjects()
      for deckIndex,curDeck in ipairs(scriptZoneObjects) do
        sourceDeck = curDeck
        seatData[playerColor].drawDeck = sourceDeck

        if curDeck.tag == "Deck" then
          sourceDeckCount = #(sourceDeck.getObjects())
        else
          -- Assume a single card was found.
          sourceDeckCount = 1
        end

        break
      end
    end

    -- Check conditions and print a message if needed.  Otherwise, perform the pass.
    if (sourceDeck == nil) then
      broadcastToColor("You have no cards to pass.", playerColor, stringColorToRGB(playerColor))
    elseif (seatData[destinationPlayerColor].limboHasCards == true) then
      broadcastToColor("The next player is not ready for cards.", playerColor, stringColorToRGB(playerColor))
    elseif (sourceDeckCount != (14 - seatData[playerColor].passTurnsFinished)) then
      broadcastToColor("You must pass " .. (14 - seatData[playerColor].passTurnsFinished) .. " cards.", playerColor, stringColorToRGB(playerColor))
    elseif (seatData[playerColor].passTurnsFinished == 14) then
      printToAll(playerColor .. " tried to pass an extra time.", stringColorToRGB(playerColor))
    else
      local destinationPosition = getObjectFromGUID(seatData[destinationPlayerColor].limboHolderGuid).getPosition()
      local destinationRotation = getObjectFromGUID(seatData[destinationPlayerColor].limboHolderGuid).getRotation()

      -- The pass was successful, so delete the Pass button for the passing player.
      local passButtonHolder = getObjectFromGUID(seatData[playerColor].passButtonHolderGuid)
      passButtonHolder.clearButtons()
      seatData[playerColor].hasButton = false
      seatData[playerColor].shouldHaveButton = false

      -- Adjust the limbo position slightly in an attempt to avoid limbo deck(s) rarely falling from the bottom of the table.
      destinationPosition.y = destinationPosition.y - 0.2

      -- The deck will be uninteractable with no gravity while in limbo, and it will be locked so it does not float around.
      sourceDeck.interactable = false
      sourceDeck.use_gravity = false
      sourceDeck.setLock(true)

      -- Move the deck.
      sourceDeck.setPosition(destinationPosition)
      sourceDeck.setRotation({ destinationRotation.x + 180, destinationRotation.y, destinationRotation.z })

      -- Link the deck as the limbo deck for the destination player.
      seatData[destinationPlayerColor].limboDeck = sourceDeck
      seatData[destinationPlayerColor].limboHasCards = true

      -- Update the pass count for the passing player.
      if (seatData[playerColor].passTurnsFinished < 14) then
        seatData[playerColor].passTurnsFinished = seatData[playerColor].passTurnsFinished+1
      end

      -- Clear the draw deck variable for the passing player, and mark their draft stack as empty.
      seatData[playerColor].drawDeck = nil
      seatData[playerColor].draftStackHasCards = false
    end
  elseif seatData[playerColor].passTurnsFinished == 14 then
    -- Make sure the player took their last card.
    if seatData[playerColor].drawDeck != nil then
      broadcastToColor("You must take your last card.", playerColor, stringColorToRGB(playerColor))
    else
      -- Delete the button.
      local passButtonHolder = getObjectFromGUID(seatData[playerColor].passButtonHolderGuid)
      passButtonHolder.clearButtons()
      seatData[playerColor].hasButton = false
      seatData[playerColor].shouldHaveButton = false

      -- Record a final pass turn.  This lets scanForDraftRoundFinish() detect when all players are ready.
      seatData[playerColor].passTurnsFinished = seatData[playerColor].passTurnsFinished+1
      -- Scan for whether everyone has finished the draft round.
      scanForDraftRoundFinish()
    end
  else printToAll("Error, it should be impossible to pass after clicking the Done button.", {1,0,0}) end
  return 1
end

function periodicLimboCheck()
  startLuaCoroutine(self, "periodicLimboCheckCoroutine")
end

function periodicLimboCheckCoroutine()
  if limboCheckEnabled == true then
    for i,somePlayer in pairs(seatedPlayers) do
      if ((seatData[somePlayer].limboHasCards == true) and (seatData[somePlayer].draftStackHasCards == false)) then
        local limboDeck = seatData[somePlayer].limboDeck
        local destinationPosition = getObjectFromGUID(seatData[somePlayer].scriptZoneGuid).getPosition()
        local destinationRotation = getObjectFromGUID(seatData[somePlayer].scriptZoneGuid).getRotation()

        -- The deck will be placed above the table.
        destinationPosition.y = 1

        -- Move the deck from limbo to the script zone.
        seatData[somePlayer].limboDeck = nil
        limboDeck.setPosition(destinationPosition)
        limboDeck.setRotation({ destinationRotation.x + 180, destinationRotation.y, destinationRotation.z })
        seatData[somePlayer].drawDeck = limboDeck

        -- The deck can now be interacted with, gravity is enabled, and it is unlocked.
        limboDeck.interactable = true
        limboDeck.use_gravity = true
        limboDeck.setLock(false)

        -- Update the draft stack and limbo state variables.
        seatData[somePlayer].draftStackHasCards = true
        seatData[somePlayer].limboHasCards = false

        -- Mark that the destination player should have a pass button.
        seatData[somePlayer].shouldHaveButton = true

        -- After a delay, create the Pass button for the destination player.
        Wait.time(function() createPassButton(somePlayer) end, 1.0)
      end
    end

    -- Set up the next periodic wait.
    periodicLimboCheckWaitID = Wait.time(periodicLimboCheck, 1.0)
  end

  return 1
end

function createPassButton(playerColor)
  local passButtonHolder = getObjectFromGUID(seatData[playerColor].passButtonHolderGuid)

  if (seatData[playerColor].shouldHaveButton == true) then
    if (seatData[playerColor].hasButton == false) then
      if (seatData[playerColor].passTurnsFinished < 14) then
        passButtonHolder.createButton({
          label='Pass', click_function = ("passButtonClicked" .. playerColor), function_owner=Global,
          position={0,1,0}, rotation={0,-90,0}, width=870, height=750, font_size=400,
          color=stringColorToRGB(playerColor)
        })
      else
        passButtonHolder.createButton({
          label='Done', click_function = ("passButtonClicked" .. playerColor), function_owner=Global,
          position={0,1,0}, rotation={0,-90,0}, width=870, height=750, font_size=400,
          color=stringColorToRGB(playerColor)
        })
      end

      seatData[playerColor].hasButton = true
    else
      printToAll("Error, createPassButton() called but a button already exists.", {1,0,0})
    end
  else
    printToAll("Error, createPassButton() called but a button should NOT be created.", {1,0,0})
  end
end

function endRoundOneCoroutine()
  -- Disable the limbo check.  This must be done inside a coroutine to make sure the limbo check is not currently running.
  limboCheckEnabled = false

  -- Reset pass counts.
  for i,somePlayer in pairs(seatedPlayers) do
    seatData[somePlayer].passTurnsFinished = 0
  end

  passRound = 2
  draftReadyForDeal()

  return 1
end

function endRoundTwoCoroutine()
  -- Stop the periodic limbo check.  This must be done inside a coroutine to make sure the limbo check is not currently running.
  limboCheckEnabled = false
  if periodicLimboCheckWaitID != nil then
    Wait.stop(periodicLimboCheckWaitID)
    periodicLimboCheckWaitID = nil
  end

  -- Indicate drafting is over.
  passRound = 0

  -- Mark everyone as not needing a Pass button, and Delete all Pass buttons.
  for i,somePlayer in pairs(seatedPlayers) do
    seatData[somePlayer].hasButton = false
    seatData[somePlayer].shouldHaveButton = false

    local buttonHolder = getObjectFromGUID(seatData[somePlayer].passButtonHolderGuid)
    buttonHolder.clearButtons()
  end

  -- Destruct the sign.
  passRightBoard.destruct()

  -- Cleanup the table.
  cleanupTable()

  printToAll("===========================================", {1,1,1})
  printToAll("Remember to right click and save your deck!", {1,1,1})
  printToAll("===========================================", {1,1,1})

  -- Set up the deckbuilding zones.
  setupHiddenZones()

  return 1
end

function scanForDraftRoundFinish()
  local roundFinished = true

  if passRound == 1 then
    for i,somePlayer in pairs(seatedPlayers) do
      if seatData[somePlayer].passTurnsFinished != 15 then
        roundFinished = false
        break
      end
    end

    if roundFinished == true then
      startLuaCoroutine(self, "endRoundOneCoroutine")
    end
  elseif passRound == 2 then
    for i,somePlayer in pairs(seatedPlayers) do
      if seatData[somePlayer].passTurnsFinished != 15 then
        roundFinished = false
        break
      end
    end

    if roundFinished == true then
      startLuaCoroutine(self, "endRoundTwoCoroutine")
    end
  else
    -- This should never happen.
    printToAll("Error, it should be impossible to pass once draft rounds are over.", {1,0,0})
  end
end

function spawnDraftDice()
  for playerIndex,curPlayer in pairs(seatedPlayers) do
    local draftDeckZoneObjects = getObjectFromGUID(seatData[curPlayer].scriptZoneGuid).getObjects()
    local diceHolder = getObjectFromGUID(seatData[curPlayer].diceHolderGuid)
    local diceVector = seatData[curPlayer].diceDirectionVector
    local diceRowVector = seatData[curPlayer].diceRowDirectionVector
    local horizontalOffset = (-3)
    local verticalOffset = 2

    local dieOffset = seatData[curPlayer].dieOffset+horizontalOffset
    local dieRowOffset = seatData[curPlayer].dieRowOffset

    for deckIndex,curDeck in ipairs(draftDeckZoneObjects) do
      if curDeck.tag == "Deck" then
        -- Record the initial deck for this player.
        seatData[curPlayer].drawDeck = curDeck

        for cardIndex,curCardInfo in ipairs(dealtCardsInfo[curPlayer]) do
          if (curCardInfo.diceimage != nil) then
            local custom = {}
            local obj_parameters = {}
            obj_parameters.type = 'Custom_Dice'
            obj_parameters.scale = {1.7,1.7,1.7}
            obj_parameters.position = {diceHolder.getPosition()[1]+(diceVector[1]*dieOffset)+(diceRowVector[1]*dieRowOffset),
                                       diceHolder.getPosition()[2]+verticalOffset,
                                       diceHolder.getPosition()[3]+(diceVector[3]*dieOffset)+(diceRowVector[3]*dieRowOffset)}
            obj_parameters.rotation = {diceHolder.getRotation()[1], diceHolder.getRotation()[2]+180, diceHolder.getRotation()[3]}

            dieOffset = dieOffset+2

            -- Add a row offset if there are a lot of dice.
            if (dieOffset == (horizontalOffset + 14)) then
              dieOffset = horizontalOffset
              dieRowOffset = dieRowOffset+2
            end

            local dice = spawnObject(obj_parameters)
            custom.image = curCardInfo.diceimage
            dice.setCustomObject(custom)
          end -- end if (curCardInfo.diceimage != nil)
        end -- end for cardIndex,curCardInfo in ipairs(dealtCardsInfo[curPlayer])
      else -- end if curDeck.tag == "Deck"
        -- This should never happen.
        printToAll("Error, only one card found.", {1,0,0})
      end
    end

    seatData[curPlayer].dieOffset = dieOffset-horizontalOffset
    seatData[curPlayer].dieRowOffset = dieRowOffset
  end

  -- If this was for the first round, some state needs updated.
  if passRound == 1 then

    showPassLeft()
    scanSeatedPlayers()
  else

    showPassRight()
    scanSeatedPlayers()
  end
end

function periodicHandCheck()
  if normalGameStarted == true then
    -- Use a coroutine to avoid synchronization problems.
    startLuaCoroutine(self, "periodicHandCheckCoroutine")
  end

  Wait.time(periodicHandCheck, 1)
end

function periodicHandCheckCoroutine()
  local zoneObjects = nil
  local foundResourceCount = 0

  if ((normalGameStarted == true) and (modernInterfaceActive == true)) then
    -- Scan for cards.

    if Player["blue"] then
      blueHandCount = #(Player["blue"].getHandObjects())
    end

    if Player["red"] then
      redHandCount = #(Player["red"].getHandObjects())
    end

    -- Scan for resources.

    if blueResourceZone then
      zoneObjects = blueResourceZone.getObjects()
      foundResourceCount = 0

      for _,curObject in ipairs(zoneObjects) do
        if curObject.getName() == "Resource" then
          foundResourceCount = (foundResourceCount + 1)
        end
      end

      blueResourceCount = foundResourceCount
    end

    if redResourceZone then
      zoneObjects = redResourceZone.getObjects()
      foundResourceCount = 0

      for _,curObject in ipairs(zoneObjects) do
        if curObject.getName() == "1 resource" then
          foundResourceCount = (foundResourceCount + 1)
        end
      end

      redResourceCount = foundResourceCount
    end

    -- Update UI elements.

    UI.setAttribute("blue_panel_blue_cards", "text", blueHandCount)
    UI.setAttribute("blue_panel_blue_resources", "text", blueResourceCount)
    UI.setAttribute("blue_panel_red_cards", "text", redHandCount)
    UI.setAttribute("blue_panel_red_resources", "text", redResourceCount)

    UI.setAttribute("red_panel_blue_cards", "text", blueHandCount)
    UI.setAttribute("red_panel_blue_resources", "text", blueResourceCount)
    UI.setAttribute("red_panel_red_cards", "text", redHandCount)
    UI.setAttribute("red_panel_red_resources", "text", redResourceCount)

    if blueBoardsPrefab then
      blueBoardsPrefab.UI.setAttribute("blue_panel_blue_cards", "text", blueHandCount)
      blueBoardsPrefab.UI.setAttribute("blue_panel_blue_resources", "text", blueResourceCount)
      blueBoardsPrefab.UI.setAttribute("blue_panel_red_cards", "text", redHandCount)
      blueBoardsPrefab.UI.setAttribute("blue_panel_red_resources", "text", redResourceCount)
    end

    if redBoardsPrefab then
      redBoardsPrefab.UI.setAttribute("red_panel_blue_cards", "text", blueHandCount)
      redBoardsPrefab.UI.setAttribute("red_panel_blue_resources", "text", blueResourceCount)
      redBoardsPrefab.UI.setAttribute("red_panel_red_cards", "text", redHandCount)
      redBoardsPrefab.UI.setAttribute("red_panel_red_resources", "text", redResourceCount)
    end

  end

  return 1
end

function updatePanelVisibility()
  if modernInterfaceActive == true then
    if normalGameStarted == false then
       UI.setAttribute("blue_panel", "active", false)
       UI.setAttribute("red_panel", "active", false)

       if blueBoardsPrefab ~= nil then
         blueBoardsPrefab.UI.setAttribute("blue_panel", "active", false)
       end

       if redBoardsPrefab ~= nil then
         redBoardsPrefab.UI.setAttribute("red_panel", "active", false)
       end
    else
       UI.setAttribute("blue_panel", "active", bluePanelMaximized)
       UI.setAttribute("red_panel", "active", redPanelMaximized)

       if blueBoardsPrefab then
         blueBoardsPrefab.UI.setAttribute("blue_panel", "active", (not bluePanelMaximized))
       end

       if redBoardsPrefab then
         redBoardsPrefab.UI.setAttribute("red_panel", "active", (not redPanelMaximized))
       end
    end
  else
    UI.setAttribute("blue_panel", "active", false)
    UI.setAttribute("red_panel", "active", false)
  end
end

function onPlayerConnect(player)
  updatePanelVisibility()
end

function onPlayerChangedColor(player)
  updatePanelVisibility()
end

function onObjectDrop(_, dropObject)
  if (dropObject.tag == "Card") then
    dropObject.setVar("curLiftingPlayer", nil)

    -- If the card was already in a spawning zone, handle spawning the GUI and/or dice.  This also handles updating the GUI position.
    if ((dropObject.getVar("curMatZone") == "Blue") or (dropObject.getVar("curBattlefieldZone") == "Blue")) then
      blueBoardsPrefab.call('handlePossibleDiceSpawn', { owningPlayerColor = "Blue", cardObject = dropObject})
    elseif ((dropObject.getVar("curMatZone") == "Red") or (dropObject.getVar("curBattlefieldZone") == "Red")) then
      redBoardsPrefab.call('handlePossibleDiceSpawn', { owningPlayerColor = "Red", cardObject = dropObject})
	end
  end
end

function onObjectPickUp(playerColor, pickUpObject)
  if (pickUpObject.tag == "Card") then
    pickUpObject.setVar("curLiftingPlayer", playerColor)
  end
end

function onObjectEnterScriptingZone(zone, enterObject)
  local zoneObjects = nil
  local spawnBluePerspective = false
  local spawnRedPerspective = false
  local objectY = enterObject.getPosition().y
  local rotationZ = enterObject.getRotation().z
  local HideFaceDown = enterObject.hide_when_face_down

  if ((normalGameStarted == true) and (modernInterfaceActive == true)) then
    -- Only check cards.
    if (enterObject.tag == "Card") then
      -- Check if the card is face up.
      if ((rotationZ > 357) or (rotationZ < 3) or (HideFaceDown == false)) then
        -- Check if the zone should spawn dice.
        if (zone == blueMatZone) then
          enterObject.setVar("curMatZone", "Blue")
          spawnBluePerspective = true
        elseif (zone == blueBattlefieldZone) then
          enterObject.setVar("curBattlefieldZone", "Blue")
          spawnBluePerspective = true
        elseif (zone == redMatZone) then
          enterObject.setVar("curMatZone", "Red")
          spawnRedPerspective = true
        elseif (zone == redBattlefieldZone) then
          enterObject.setVar("curBattlefieldZone", "Red")
          spawnRedPerspective = true
        end

        -- Only check for spawning here if no one is currently lifting the card.
        if (spawnBluePerspective == true) then
          if (enterObject.getVar("curLiftingPlayer") == nil) then
            blueBoardsPrefab.call('handlePossibleDiceSpawn', { owningPlayerColor="Blue", cardObject = enterObject})
          end
        elseif (spawnRedPerspective == true) then
          if (enterObject.getVar("curLiftingPlayer") == nil) then
            redBoardsPrefab.call('handlePossibleDiceSpawn', { owningPlayerColor="Red", cardObject = enterObject})
          end
        end
      end
    end
  end
end

function onObjectLeaveScriptingZone(zone, leaveObject)
  if ((normalGameStarted == true) and (modernInterfaceActive == true)) then
    -- Only check cards.
    if (leaveObject.tag == "Card") then
      -- Check if the card is leaving a mat zone.
      if ((zone == blueMatZone) or (zone == redMatZone)) then
        leaveObject.setVar("curMatZone", nil)

        -- Hide the GUI when the card leaves a mat zone.
        local linkedGUIHolder = leaveObject.getVar("linkedGUIHolder")

        if linkedGUIHolder then
          linkedGUIHolder.UI.setAttribute("card_gui", "active", false)
          linkedGUIHolder.UI.setAttribute("opponent_card_gui", "active", false)
        end
      end

      -- Check if the card is leaving a battlefield zone.
      if ((zone == blueBattlefieldZone) or (zone == redBattlefieldZone)) then
        leaveObject.setVar("curBattlefieldZone", nil)

        -- Do not hide the GUI when leaving a battlefield zone in case of rare overlap between the two zones.
      end
    end
  end
end

function onObjectDestroy(destroyObject)
  if ((normalGameStarted == true) and (modernInterfaceActive == true)) then
    -- Only check cards.
    if (destroyObject.tag == "Card") then
      local linkedGUIHolder = destroyObject.getVar("linkedGUIHolder")

      if linkedGUIHolder then
        linkedGUIHolder.destruct()
      end
    end
  end
end

function dealPackForEachPlayer(dealExpansion)
  local numberCharIndex = nil
  local cardSet = nil
  local cardNumber = nil
  local cardFound = false
  local curExpansionIndex = nil
  local curNameOrDescription = nil

  for playerIndex,somePlayer in pairs(seatedPlayers) do
    -- Deal an entire pack to each player.
    for cardIndex=1,5 do
      curExpansionIndex = nextExpansionIndex[dealExpansion]
      curNameOrDescription = rivalsExpansionPacks[dealExpansion][curExpansionIndex]

      -- The card set always starts at index 1 since draft cards are never elite.
      numberCharIndex = (string.find(curNameOrDescription, ' ', 1, true) + 1)
      cardSet = string.sub(curNameOrDescription, 1, (numberCharIndex - 2))
      cardNumber = string.sub(curNameOrDescription, numberCharIndex)

      -- Record card info.
      cardFound = false
      for i in ipairs(SWDARHISTHEBEST) do
        if ((SWDARHISTHEBEST[i]["set"] == cardSet) and (SWDARHISTHEBEST[i]["number"] == cardNumber)) then
          table.insert(dealtCardsInfo[somePlayer], SWDARHISTHEBEST[i])
          cardFound = true
          break
        elseif (SWDARHISTHEBEST[i]["cardname"] == curNameOrDescription) then
          table.insert(dealtCardsInfo[somePlayer], SWDARHISTHEBEST[i])
          cardFound = true
          break
        end
      end

      if (false == cardFound) then
        printToAll("Error, card " .. curNameOrDescription .. " not found.", {1,0,0})
      end

      nextExpansionIndex[dealExpansion] = (nextExpansionIndex[dealExpansion] + 1)
    end 
  end 
end

function draftReadyForDeal()
  startLuaCoroutine(self, "draftReadyForDealCoroutine")
end

function draftReadyForDealCoroutine()
  local numPacksToDeal = 0

  if Mode == "Normal Sealed" then
    numPacksToDeal = 8
  elseif Mode == "Winchester Draft" then
    numPacksToDeal = numWinchesterPacks
  elseif Mode == "Normal Draft" then
    numPacksToDeal = 3
  elseif Mode == "Cube Draft" then
    numPacksToDeal = 3
  end

  -- Scan seats in case players were shuffled before the round starts.
  if (passRound == 1) then
    scanSeatedPlayers()
    draftGameStarted = true
    cleanupMats()
  end

  local dealPositionForPlayers = {}
  local dealRotationForPlayers = {}

  for i,somePlayer in pairs(seatedPlayers) do
    dealtCardsInfo[somePlayer] = {}

    local zonePosition = getObjectFromGUID(seatData[somePlayer].scriptZoneGuid).getPosition()
    local zoneRotation = getObjectFromGUID(seatData[somePlayer].scriptZoneGuid).getRotation()

    dealPositionForPlayers[somePlayer] = {}
    dealRotationForPlayers[somePlayer] = {}

    if Mode != "Winchester Draft" then
      dealPositionForPlayers[somePlayer].x = zonePosition.x
      -- Cards are dealt in the air in case the Rivals deck is underneath.
      dealPositionForPlayers[somePlayer].y = 2.5
      dealPositionForPlayers[somePlayer].z = zonePosition.z
      dealRotationForPlayers[somePlayer].x = (zoneRotation.x + 180)
      dealRotationForPlayers[somePlayer].y = zoneRotation.y
      dealRotationForPlayers[somePlayer].z = zoneRotation.z
    else
      -- Override the card position for Winchester mode.
      if somePlayer == "Blue" then
        dealPositionForPlayers[somePlayer].x = 28.25
        dealPositionForPlayers[somePlayer].y = 2.5
        dealPositionForPlayers[somePlayer].z = 6.60
        dealRotationForPlayers[somePlayer].x = 0
        dealRotationForPlayers[somePlayer].y = 0
        dealRotationForPlayers[somePlayer].z = 180
      elseif somePlayer == "Green" then
        dealPositionForPlayers[somePlayer].x = (-28.25)
        dealPositionForPlayers[somePlayer].y = 2.5
        dealPositionForPlayers[somePlayer].z = 6.60
        dealRotationForPlayers[somePlayer].x = 0
        dealRotationForPlayers[somePlayer].y = 0
        dealRotationForPlayers[somePlayer].z = 180
        return
      end
    end
  end

  if Mode == "Winchester Draft" then winchesterBoard.setPosition({0,1,-4.8}) end

  -- Deal in reverse order so the first selected expansion pack ends up on the top of the stack.
  local packSelectionIndex = (numPacksDealt + numPacksToDeal)

  for dealPackIndex=1,numPacksToDeal do
    dealPackForEachPlayer(packSelections[packSelectionIndex])
    packSelectionIndex = packSelectionIndex - 1
  end

  coroutine.yield(0)

  -- Now that the new draft decks have been created, spawn them.
  spawnDraftDecks(dealPositionForPlayers, dealRotationForPlayers)

  numPacksDealt = numPacksDealt + numPacksToDeal

  -- Sealed mode is almost ready at this point.  Draft modes still need dice spawned.
  if Mode == "Normal Sealed" then
    cleanupTable()

    printToAll("===========================================", {1,1,1})
    printToAll("      Remember to save your deck!", {1,1,1})
    printToAll("===========================================", {1,1,1})

    -- Set up the deckbuilding zones.
    setupHiddenZones()
  elseif Mode == "Winchester Draft" then
    cleanupTable()

    -- Move certain script zones above the table now.  This prevents the zones from flashing briefly.

    for i,somePlayer in pairs(seatedPlayers) do
      local newZonePosition = winchesterStockZones[somePlayer].getPosition()
      newZonePosition.y = 1
      winchesterStockZones[somePlayer].setPosition(newZonePosition)
    end

    for curZoneIndex=1,4 do
      newZonePosition = winchesterDraftZones[curZoneIndex].getPosition()
      newZonePosition.y = 1.270
      winchesterDraftZones[curZoneIndex].setPosition(newZonePosition)
    end

    Wait.time(startWinchesterDeal, 2.0)
  elseif ((Mode == "Normal Draft") or (Mode == "Cube Draft")) then
    Wait.time(spawnDraftDice, 0.5)
  end

  return 1
end

function spawnDraftDecks(dealPositionForPlayers, dealRotationForPlayers)
  for i,somePlayer in pairs(seatedPlayers) do
     spawnDraftDeckForPlayer(somePlayer, dealPositionForPlayers[somePlayer], dealRotationForPlayers[somePlayer])
  end
end

function cleanupTable()
  -- Set a small delay in case any last cards are still being pulled from decks.
  Wait.time(cleanupTableAfterWait, 0.5)
end

function cleanupTableAfterWait()
  -- Destruct the sign.
  if not pleaseWaitBoard then pleaseWaitBoard.destruct() end

  -- Destruct leftover decks.
  if not mixedPacksDeck then mixedPacksDeck.destruct() end
  if not draftDiceCardDeck then draftDiceCardDeck.destruct() end
  if not draftUncommonDeck then draftUncommonDeck.destruct() end
  if not draftCommonDeck then draftCommonDeck.destruct() end

  -- Destruct the setup bag.
  if not setupObject then setupObject.destruct() end
end

function setupHiddenZones()
  -- Move hidden deckbuilding zones out of the sky.

  for i,somePlayer in pairs(seatedPlayers) do
    local hiddenZone = getObjectFromGUID(seatData[somePlayer].hiddenZoneGuid)
    local zoneScale = {18.75, 80.00, 13.12}
    local zonePosition = seatData[somePlayer].hiddenZonePosition

    -- For Winchester draft, use bigger deckbuilding zones.
    if Mode == "Winchester Draft" then
      zoneScale[3] = 21.00
      zonePosition[3] = 20.00
    end

    hiddenZone.setScale(zoneScale)
    hiddenZone.setPosition(zonePosition)
  end
end

function startWinchesterDeal()
  -- Deal 2 cards from each seated player's stock deck.

  for _,somePlayer in pairs(seatedPlayers) do
    local scriptZoneObjects = winchesterStockZones[somePlayer].getObjects()
    for _,curDeck in ipairs(scriptZoneObjects) do
      local dealPosition = {}

      -- Mark the deck as not interactable.
      curDeck.interactable = false

      -- For Winchester, new cards are dealt on top of the Winchester board and next to any existing cards.
      --
      -- NOTE:  Only checking for the "Deck" tag is fine because all Winchester source decks are currently
      --        required to contain an even number of cards.  This means the 2 last cards of a deck will
      --        be dealt simultaneously.

      if somePlayer == "Blue" then
        dealPosition[1] = (winchesterBasePositions[1][1] - ((winchesterNumZoneCards[1] % 3) * 3.26))
        dealPosition[2] = 2
        dealPosition[3] = (winchesterBasePositions[1][3] - (math.floor(winchesterNumZoneCards[1] / 3) * 4.45))

        if curDeck.tag == "Deck" then
          curDeck.takeObject({position=dealPosition, rotation={0,0,0}, flip=false, smooth=false})
          winchesterNumZoneCards[1] = (winchesterNumZoneCards[1] + 1)
        end

        dealPosition[1] = (winchesterBasePositions[2][1] - ((winchesterNumZoneCards[2] % 3) * 3.26))
        dealPosition[2] = 2
        dealPosition[3] = (winchesterBasePositions[2][3] - (math.floor(winchesterNumZoneCards[2] / 3) * 4.45))

        if curDeck.tag == "Deck" then
          curDeck.takeObject({position=dealPosition, rotation={0,0,0}, flip=false, smooth=false})
          winchesterNumZoneCards[2] = (winchesterNumZoneCards[2] + 1)
        end
      elseif somePlayer == "Green" then
        dealPosition[1] = (winchesterBasePositions[3][1] - ((winchesterNumZoneCards[3] % 3) * 3.26))
        dealPosition[2] = 2
        dealPosition[3] = (winchesterBasePositions[3][3] - (math.floor(winchesterNumZoneCards[3] / 3) * 4.45))

        if curDeck.tag == "Deck" then
          curDeck.takeObject({position=dealPosition, rotation={0,0,0}, flip=false, smooth=false})
          winchesterNumZoneCards[3] = (winchesterNumZoneCards[3] + 1)
        end

        dealPosition[1] = (winchesterBasePositions[4][1] - ((winchesterNumZoneCards[4] % 3) * 3.26))
        dealPosition[2] = 2
        dealPosition[3] = (winchesterBasePositions[4][3] - (math.floor(winchesterNumZoneCards[4] / 3) * 4.45))

        if curDeck.tag == "Deck" then
          curDeck.takeObject({position=dealPosition, rotation={0,0,0}, flip=false, smooth=false})
          winchesterNumZoneCards[4] = (winchesterNumZoneCards[4] + 1)
        end
      else printToAll("Error, Winchester draft only supports Blue and Green seated players.", {1,0,0}) return 		
	  end
    end
  end

  Wait.time(handleWinchesterDealFinished, 0.75)
end

function handleWinchesterDealFinished()
  -- If this is the first round, determine the number of Winchester players.  This should always be 1 or 2.
  if numWinchesterPlayers == 0 then
    local lastSeatedPlayer = nil

    numWinchesterPlayers = 0
    for i,somePlayer in pairs(seatedPlayers) do
      lastSeatedPlayer = somePlayer
      numWinchesterPlayers = numWinchesterPlayers+1
    end

    if numWinchesterPlayers == 0 then
      -- This should never happen.
      printToAll("Error, no seated players found.", {1,0,0})
      pleaseWaitBoard.destruct()
      return
    elseif numWinchesterPlayers == 1 then
      -- Calculate the Winchester pick count.
      winchesterPickCount = (((numWinchesterPacks * 5) / 2) + 1)

      curWinchesterPlayer = lastSeatedPlayer
      printToAll(curWinchesterPlayer .. " is the only player and will go first.", stringColorToRGB(curWinchesterPlayer))
    elseif numWinchesterPlayers == 2 then
      -- Calculate the Winchester pick count.
      winchesterPickCount = (((numWinchesterPacks * 5) / 2) + 3)

      -- Randomly pick the first player.
      if (math.random(1, 2) == 1) then
        curWinchesterPlayer = "Blue"
      else
        curWinchesterPlayer = "Green"
      end
      printToAll(curWinchesterPlayer .. " was randomly selected to go first.", stringColorToRGB(curWinchesterPlayer))
    else
      printToAll("Error, Winchester draft only supports 2 seated players.", {1,0,0})
      pleaseWaitBoard.destruct()
      return
    end

    -- Make the pick counter visible.
    winchesterPickCountText.TextTool.setValue("Turns left:  " .. winchesterPickCount)
    winchesterPickCountText.setPosition({0, 1.2, 14.5})
  end

  -- Start the Winchester turn.
  startLuaCoroutine(self, "startWinchesterTurnCoroutine")
end

function startWinchesterTurnCoroutine()
  local winchesterZoneHasCards = {}

  -- Scan all draft zones and lock all card(s) in them.  Making them uninteractable would prevent zooming with Alt.
  for curZoneIndex=1,4 do
    winchesterZoneHasCards[curZoneIndex] = false

    -- Note that the tags must be checked since the board or other object(s) may be detected in these script zones.
    local scriptZoneObjects = winchesterDraftZones[curZoneIndex].getObjects()
    for deckIndex,curDeck in ipairs(scriptZoneObjects) do
      if ((curDeck.tag == "Deck") or (curDeck.tag == "Card")) then
        curDeck.setLock(true)
        winchesterZoneHasCards[curZoneIndex] = true
      end
    end
  end

  -- Create buttons for each draft zone if they have card(s).  Since the Winchester board is scaled differently from the
  -- main table, these values are hardcoded here.

  if winchesterZoneHasCards[1] == true then
    winchesterBoard.createButton({
      label='Take', click_function = ("takeButton1Clicked"), function_owner=Global,
      position={-0.850,0.2,0.80}, rotation={0,0,0}, width=160, height=85, font_size=60, color=stringColorToRGB(curWinchesterPlayer)
    })
  end

  if winchesterZoneHasCards[2] == true then
    winchesterBoard.createButton({
      label='Take', click_function = ("takeButton2Clicked"), function_owner=Global,
      position={-0.285,0.2,0.80}, rotation={0,0,0}, width=160, height=85, font_size=60, color=stringColorToRGB(curWinchesterPlayer)
    })
  end

  if winchesterZoneHasCards[3] == true then
    winchesterBoard.createButton({
      label='Take', click_function = ("takeButton3Clicked"), function_owner=Global,
      position={0.285,0.2,0.80}, rotation={0,0,0}, width=160, height=85, font_size=60, color=stringColorToRGB(curWinchesterPlayer)
    })
  end

  if winchesterZoneHasCards[4] == true then
    winchesterBoard.createButton({
      label='Take', click_function = ("takeButton4Clicked"), function_owner=Global,
      position={0.850,0.2,0.80}, rotation={0,0,0}, width=160, height=85, font_size=60, color=stringColorToRGB(curWinchesterPlayer)
    })
  end

  return 1
end

function takeButtonGeneral(buttonObject, playerColor, whichButton)
  if playerColor == curWinchesterPlayer then
    local draftFinalPosition = getObjectFromGUID(seatData[playerColor].scriptZoneGuid).getPosition()
    local draftFinalRotation = getObjectFromGUID(seatData[playerColor].scriptZoneGuid).getRotation()

    -- Move the card above the table to fall on the player's card(s), if any.
    -- The card will be moved without collision, and it will be moved fast.
    -- Just using setPosition() instead would result in the card hovering.
    draftFinalPosition.y = 2

    -- Delete the buttons.  More buttons will be created as needed.
    winchesterBoard.clearButtons()

    -- Note that the tags must be checked since the board or other object(s) may be detected in these script zones.
    local scriptZoneObjects = winchesterDraftZones[whichButton].getObjects()
    local draftStack = nil
    for objectIndex,curObject in ipairs(scriptZoneObjects) do
      if (curObject.tag == "Card") then
        curObject.setLock(false)
        curObject.setPositionSmooth(draftFinalPosition, false, true)
        curObject.setRotation({ draftFinalRotation.x + 180, draftFinalRotation.y, draftFinalRotation.z })
        -- Lift each card slightly so they fall in sequence.
        draftFinalPosition.y = draftFinalPosition.y + 0.3
      elseif (curObject.tag == "Deck") then
        -- This should never happen.
        printToAll("Error, deck found in Winchester zone.", {1,0,0})
      else
        -- Nothing needs done.
      end
    end

    -- Mark the zone as having no cards.
    winchesterNumZoneCards[whichButton] = 0

    -- If there are two players, switch the current player.
    if numWinchesterPlayers == 2 then
      if curWinchesterPlayer == "Blue" then curWinchesterPlayer = "Green"
      else curWinchesterPlayer = "Blue" end
    end

    -- Decrement the pick count.
    if winchesterPickCount > 0 then
      winchesterPickCount = winchesterPickCount-1

      -- Update the pick counter.
      winchesterPickCountText.TextTool.setValue("Turns left:  " .. winchesterPickCount)

      if winchesterPickCount == 0 then
        finishWinchesterDraft()
        return
      end
    else printToAll("Error, it should be impossible to click a button after the final pick.", {1,0,0}) end

    -- Prepare to deal more cards.
    Wait.time(startWinchesterDeal, 0.5)
  else
    printToAll(playerColor .. " tried to take cards out of turn.", stringColorToRGB(playerColor))
  end
end

function takeButton1Clicked(buttonObject, playerColor)
  takeButtonGeneral(buttonObject, playerColor, 1)
end

function takeButton2Clicked(buttonObject, playerColor)
  takeButtonGeneral(buttonObject, playerColor, 2)
end

function takeButton3Clicked(buttonObject, playerColor)
  takeButtonGeneral(buttonObject, playerColor, 3)
end

function takeButton4Clicked(buttonObject, playerColor)
  takeButtonGeneral(buttonObject, playerColor, 4)
end

function finishWinchesterDraft()

  winchesterPickCountText.destruct()
  printToAll("===========================================", {1,1,1})
  printToAll("		Remember to save your deck!", {1,1,1})
  printToAll("===========================================", {1,1,1})

  setupHiddenZones()
end

function showPleaseWait()
  pleaseWaitBoard.setPosition({0,1.5,0})

  -- This is a convenient function that gets called for all draft / sealed modes.  Scale all hand zones down so they don't grab cards.
  for i,someSeat in pairs(seatData) do
    local handTransform = Player[i].getHandTransform()
    handTransform.scale.x = 0.01
    handTransform.scale.y = 0.01
    handTransform.scale.z = 0.01
    Player[i].setHandTransform(handTransform)
  end
end

function showPassLeft()
  pleaseWaitBoard.destruct()
  passLeftBoard.setPosition({0,1,0})

  -- All seated players should have Pass buttons at the start of the round.
  for i,somePlayer in pairs(seatedPlayers) do
    seatData[somePlayer].draftStackHasCards = true
    seatData[somePlayer].limboHasCards = false
    seatData[somePlayer].shouldHaveButton = true
  end

  -- Start a repeating loop to check limbo areas.
  periodicLimboCheckWaitID = Wait.time(periodicLimboCheck, 1.0)
  limboCheckEnabled = true
end

function showPassRight()
  passLeftBoard.destruct()
  passRightBoard.setPosition({0,1,0})

  -- All seated players should have Pass buttons at the start of the round.
  for i,somePlayer in pairs(seatedPlayers) do
    seatData[somePlayer].draftStackHasCards = true
    seatData[somePlayer].limboHasCards = false
    seatData[somePlayer].shouldHaveButton = true
  end

  -- Enable the limbo check again.
  periodicLimboCheckWaitID = Wait.time(periodicLimboCheck, 1.0)
  limboCheckEnabled = true
end

-- Note:  These two functions could be made smaller with another data structure, but they work at present in their silly form.

function getSeatedPlayerLeft(playerColor)
  -- Default to the current player.
  local returnPlayer = playerColor

  if playerColor == "Green" then
     if seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     else
        printToAll("Only one player in game.", {1,1,1})
     end
  elseif playerColor == "Blue" then
     if seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     else
        printToAll("Only one player in game.", {1,1,1})
     end
  elseif playerColor == "Purple" then
     if seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     else
        printToAll("Only one player in game.", {1,1,1})
     end
  elseif playerColor == "Pink" then
     if seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     else
        printToAll("Only one player in game.", {1,1,1})
     end
  elseif playerColor == "White" then
     if seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     else
        printToAll("Only one player in game.", {1,1,1})
     end
  elseif playerColor == "Red" then
     if seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     else
        printToAll("Only one player in game.", {1,1,1})
     end
  elseif playerColor == "Orange" then
     if seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     else
        printToAll("Only one player in game.", {1,1,1})
     end
  elseif playerColor == "Yellow" then
     if seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     else
        printToAll("Only one player in game.", {1,1,1})
     end
  end

  return returnPlayer
end

function getSeatedPlayerRight(playerColor)
  local returnPlayer = playerColor -- Default to the current player.

  if playerColor == "Green" then
     if seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue" end

  elseif playerColor == "Blue" then
     if seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple" end

  elseif playerColor == "Purple" then
     if seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink" end

  elseif playerColor == "Pink" then
     if seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["White"].filled == true then
        returnPlayer = "White" end

  elseif playerColor == "White" then
     if seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red" end

  elseif playerColor == "Red" then
     if seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow"
     elseif seatData["Orange"].filled == true then
        returnPlayer = "Orange" end

  elseif playerColor == "Orange" then
      if seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green"
     elseif seatData["Yellow"].filled == true then
        returnPlayer = "Yellow" end
		
  elseif playerColor == "Yellow" then
      if seatData["Orange"].filled == true then
        returnPlayer = "Orange"
     elseif seatData["Red"].filled == true then
        returnPlayer = "Red"
     elseif seatData["White"].filled == true then
        returnPlayer = "White"
     elseif seatData["Pink"].filled == true then
        returnPlayer = "Pink"
     elseif seatData["Purple"].filled == true then
        returnPlayer = "Purple"
     elseif seatData["Blue"].filled == true then
        returnPlayer = "Blue"
     elseif seatData["Green"].filled == true then
        returnPlayer = "Green" end
  end return returnPlayer 
end

function passButtonClickedCoroutineGreen()
  return passButtonClickedCoroutine("Green")
end

function passButtonClickedCoroutineBlue()
  return passButtonClickedCoroutine("Blue")
end

function passButtonClickedCoroutinePurple()
  return passButtonClickedCoroutine("Purple")
end

function passButtonClickedCoroutinePink()
  return passButtonClickedCoroutine("Pink")
end

function passButtonClickedCoroutineWhite()
  return passButtonClickedCoroutine("White")
end

function passButtonClickedCoroutineRed()
  return passButtonClickedCoroutine("Red")
end

function passButtonClickedCoroutineOrange()
  return passButtonClickedCoroutine("Orange")
end

function passButtonClickedCoroutineYellow()
  return passButtonClickedCoroutine("Yellow")
end

function passButtonClickedGreen(passButton, playerColor)
  passButtonClickedGeneral("Green", playerColor)
end

function passButtonClickedBlue(passButton, playerColor)
  passButtonClickedGeneral("Blue", playerColor)
end

function passButtonClickedPurple(passButton, playerColor)
  passButtonClickedGeneral("Purple", playerColor)
end

function passButtonClickedPink(passButton, playerColor)
  passButtonClickedGeneral("Pink", playerColor)
end

function passButtonClickedWhite(passButton, playerColor)
  passButtonClickedGeneral("White", playerColor)
end

function passButtonClickedRed(passButton, playerColor)
  passButtonClickedGeneral("Red", playerColor)
end

function passButtonClickedOrange(passButton, playerColor)
  passButtonClickedGeneral("Orange", playerColor)
end

function passButtonClickedYellow(passButton, playerColor)
  passButtonClickedGeneral("Yellow", playerColor)
end

function scanSeatedPlayers()
  if (draftGameStarted == false) then
    -- Note that getSeatedPlayers() never returns Grey or Black players, and it only returns colors.
    seatedPlayers = getSeatedPlayers()

    -- Initialize the seated states.
    for i,someSeat in pairs(seatData) do
       someSeat.filled = false
    end

    for i,somePlayer in pairs(seatedPlayers) do
      seatData[somePlayer].filled = true
    end
  end

  for i,someSeat in pairs(seatData) do
    -- Record the host's color.
    if (Player[i].host == true) then
      curHostColor = i
    end

    -- Spawn/destruct if needed.
    if ((Mode == "Normal Draft") or (Mode == "Cube Draft")) then
      local buttonHolder = getObjectFromGUID(someSeat.passButtonHolderGuid)

      if (someSeat.filled == true) then
        if ((someSeat.shouldHaveButton == true) and (someSeat.hasButton == false)) then
          -- Create the button.
          createPassButton(i)
        end
      else
        if (someSeat.hasButton == true) then
          -- The player is not seated.  Destruct the button.
          buttonHolder.clearButtons()
          someSeat.hasButton = false
        end
      end
    end
  end
end

function moveAllMatsUp()
  local curMat = nil
  local curZone = nil
  local curPosition = nil

  for i,someSeat in pairs(seatData) do
    curMat = getObjectFromGUID(someSeat.matGuid)

    curPosition = curMat.getPosition()
    curPosition.y = 0.96
    curMat.setPosition(curPosition)

    -- Also, move the deck scripting zone up for this seat.
    curZone = getObjectFromGUID(someSeat.scriptZoneGuid)
    curPosition = curZone.getPosition()
    curPosition.y = 3.51
    curZone.setPosition(curPosition)
  end

  -- This is also a convenient place to move the Rivals deck scripting zone up.
  local rivalsDeckZone = getObjectFromGUID(rivalsDeckZoneGuid)
  if rivalsDeckZone then
    curPosition = rivalsDeckZone.getPosition()
    curPosition.y = 3.51
    rivalsDeckZone.setPosition(curPosition)
  end
end

function randomizeMats()
  local curMat = nil
  local customObject = nil
  local randomKeyIndex = 0

  for i,someSeat in pairs(seatData) do
    curMat = getObjectFromGUID(someSeat.matGuid)

    -- Update seat image
    if curMat then
      customObject = curMat.getCustomObject()

      randomKeyIndex = math.random(1, #matKeys)
      customObject.image = matImages[matKeys[5]]

      curMat.setCustomObject(customObject)
      curMat.reload()
    end
  end
end

function cleanupMats()
  local curMat = nil

  if draftGameStarted == true then
    for i,someSeat in pairs(seatData) do
      if someSeat.filled == false then
        curMat = getObjectFromGUID(someSeat.matGuid)
        if curMat then
          curMat.destruct()
        end
      end
    end
  end
end

function fixCardName(params)
  local possiblyBrokenName = params[1]
  local fixedName = possiblyBrokenName

  for _,testFix in ipairs(cardNameFixes) do
    if possiblyBrokenName == testFix.brokenName then
      fixedName = testFix.fixedName
      break
    end
  end

  return fixedName
end 