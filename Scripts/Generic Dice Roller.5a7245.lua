-- http://steamcommunity.com/profiles/76561197968345269
-- http://steamcommunity.com/sharedfiles/filedetails/?id=726800282
-- v20180713
	-- race condition fix
-- v20180712
	-- api changes
-- v20180120
	--onDestroy
-- v20171223
	-- params.smooth=false
	-- change to timer based trigger - preserve diceGuids
	-- d10 is 1-10, not 0-9 anymore
-- v20170628
	-- sorting
-- v20170624
	-- Rotation on rows
-- v20170623
	-- D10 fix

local version=180713.1
local customFace={4,6,8,10,12,20}
local diceGuidFaces={}
local wait_takeDiceOut=nil
local diceGuids={}

math.randomseed(os.time()+tonumber(self.getGUID(),16)+self.getPosition().x*10+self.getPosition().y*10+self.getPosition().z*10)

function onLoad(save_state)
	if self.getDescription()=='' then
		setDefaultState()
	end
end

function onSave()
	return self.getDescription()
end

function onDropped(player_color)
	if self.getDescription()=='' then
		setDefaultState()
	end
end

function setDefaultState()
	self.setDescription(JSON.encode({sort='no',rows='no',step=1.5,ver=version}))
end

function sortByVal(t, type)
	local keys = {}
	for key in pairs(t) do
		table.insert(keys, key)
	end
	if type=="asc" then
		table.sort(keys, function(a, b) return t[a] < t[b] end)
	elseif type=="desc" then
		table.sort(keys, function(a, b) return t[a] > t[b] end)
	end
	return keys
end

function hasGuid(t, g)
	for k,v in ipairs(t) do
		if v.guid==g then
			return true
		end
	end
	return false
end

function onCollisionEnter(collision_info)
	if collision_info.collision_object.getGUID()==nil then
		return
	end
	if wait_takeDiceOut~=nil then
		Wait.stop(wait_takeDiceOut)
	end

	--Save number of faces on dice
	for k,v in ipairs(getAllObjects()) do
		if v.tag=='Dice' then
			objType=tostring(v)
			faces=tonumber(string.match(objType,"Die_(%d+).*"))
			if faces==nil then
				faces=tonumber(customFace[v.getCustomObject().type+1])
			end
			diceGuidFaces[v.getGUID()]=faces
		end
	end
	wait_takeDiceOut=Wait.time(|| takeDiceOut(), 0.3)
end


function takeDiceOut()
	local data = JSON.decode(self.getDescription())
	if data==nil then
		setDefaultState()
		data = JSON.decode(self.getDescription())
		printToAll('Warning - invalid description. Restored defaut configuration.', {0.8,0.5,0})
	end

	if data.step<1 then
		setDefaultState()
		data = JSON.decode(self.getDescription())
		printToAll('Warning - "step" can\'t be lower than 1. Restored defaut configuration.', {0.8,0.5,0})
	end

	sortedKeys={}
	for k,v in pairs(self.getObjects()) do
		faces=diceGuidFaces[v.guid]
		r=math.random(faces)
		diceGuids[v.guid]=r
		table.insert(sortedKeys,v.guid)
	end

	local objs = self.getObjects()
	local position = self.getPosition()
	local rotation = self.getRotation()

	if data.sort=="asc" or data.sort=="desc" then
		sortedKeys = sortByVal(diceGuids, data.sort)
	end

	rows={}
	n=1
	for _, key in ipairs(sortedKeys) do
		if hasGuid(objs,key) then
			if rows[diceGuids[key]]==nil then
				rows[diceGuids[key]]=0
			end
			rows[diceGuids[key]]=rows[diceGuids[key]]+1
			local params = {}
			params.guid=key
			if data.rows=="no" then
				params.position = { position.x+(-1)*math.sin((90+rotation.y)*0.0174532)*(n+0.5)*data.step,
				position.y+1,
				position.z+(-1)*math.cos((90+rotation.y)*0.0174532)*(n+0.5)*data.step}
			else
				params.position = {
					position.x+(rows[diceGuids[key]]*math.cos((180+self.getRotation().y)*0.0174532))*data.step-(diceGuids[key]*math.sin((self.getRotation().y)*0.0174532))*data.step,
					position.y+0.3,
					position.z+(rows[diceGuids[key]]*math.sin((self.getRotation().y)*0.0174532))*data.step+(diceGuids[key]*math.cos((180+self.getRotation().y)*0.0174532))*data.step}
			end
			params.rotation = {rotation.x, rotation.y, rotation.z}
			params.callback_function=function(obj) setValueCallback(obj,key) end
			params.smooth=false
			self.takeObject(params)
			n=n+1
		end
	end
end

function setValueCallback(obj, key)
	obj.setValue(diceGuids[key])
end