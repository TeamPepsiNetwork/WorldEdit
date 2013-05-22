------------------------------------------------
---------------------REMOVE---------------------
------------------------------------------------
function HandleRemoveCommand( Split, Player )
	if Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage( cChatColor.Rose .. "Too few arguments.\n/remove <type> <radius>" )
	else
		if Split[3] == nil or tonumber( Split[3] ) == nil then
			Player:SendMessage( cChatColor.Rose .. 'Number expected; string "' .. Split[3] .. '" given' )
			return true
		end
		if string.upper( Split[2] ) == "ITEMS" then -- check if the plugin has to destroy pickups
			local Entitys = 0
			local LoopEntity = function( Entity )
				if Entity:IsPickup() then -- if the entity is a pickup then destroy it.
					Entity:Destroy()
					Entitys = Entitys + 1
				end
			end
			Player:GetWorld():ForEachEntity( LoopEntity )
		elseif string.upper( Split[2] ) == "MINECARTS" then -- check if the plugin needs to destroy minecarts
			Entitys = 0
			local LoopEntity = function( Entity )
				if Entity:IsMinecart() then -- if the entity is a minecart then destroy it 
					Entity:Destroy()
					Entitys = Entitys + 1
				end
			end
			Player:GetWorld():ForEachEntity( LoopEntity )	
		else
			Player:SendMessage( cChatColor.Rose .. "Acceptable types: items, minecarts" ) -- the entity that the player wants to destroy does not exist.
			return true
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. "Marked " .. Entitys .. " entit(ies) for removal." )
	return true
end


-------------------------------------------------
---------------------BUTCHER---------------------
-------------------------------------------------
function HandleButcherCommand( Split, Player )
	if Split[2] == nil then -- if the player did not give a radius then the radius is the normal radius
		Radius = ButcherRadius
	elseif tonumber( Split[2] ) == nil then -- if the player gave a string as radius then stop
		Player:SendMessage( cChatColor.Rose .. 'Number expected; string "' .. Split[2] .. '" given' )
		return true
	else -- the radius is set to the given radius
		Radius = tonumber( Split[2] )
	end
	X = Player:GetPosX()
	Y = Player:GetPosY()
	Z = Player:GetPosZ()
	Distance =  math.abs( math.floor( X + Y + Z ) )
	local Mobs = 0
	local EachEntity = function( Entity )
		if Entity:IsMob() == true then -- if the entity is a mob 
			if Radius == 0 then -- if the radius is 0 then destroy all the mobs
				Entity:Destroy() -- destroy the mob
				Mobs = Mobs + 1
			else
				EntityX = Entity:GetPosX()
				EntityY = Entity:GetPosY()
				EntityZ = Entity:GetPosZ()
				if (math.abs( Distance - math.abs( math.floor( EntityX + EntityY + EntityZ ) ) ) ) < Radius then -- check if the mob is in range
					Entity:Destroy()
					Mobs = Mobs + 1
				end
			end
		end
	end
	local World = Player:GetWorld()
	World:ForEachEntity( EachEntity ) -- loop through all the entitys
	Player:SendMessage( cChatColor.LightPurple .. "Killed " .. Mobs .. " mobs." )
	return true
end