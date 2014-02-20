-------------------------------------------------
---------------CREATEWALLSFUNCTION---------------
-------------------------------------------------
function HandleCreateWalls(Player, World, BlockType, BlockMeta)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player) -- Get the right X, Y and Z coordinates
	if CheckIfInsideAreas(OneX, TwoX, OneY, TwoY, OneZ, TwoZ, Player, World, "walls") then -- Check if the region intersects with any of the areas.
		return false
	end
	
	local PlayerName = Player:GetName()
	
	LastCoords[PlayerName] = {X = OneX, Y = OneY, Z = OneZ, WorldName = World:GetName()}
	
	PersonalUndo[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	PersonalBlockArea[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	local Blocks = (2 * (PersonalBlockArea[PlayerName]:GetSizeX() - 1 + PersonalBlockArea[PlayerName]:GetSizeZ() - 1) * PersonalBlockArea[PlayerName]:GetSizeY()) -- Calculate the amount if blocks that are going to change
	if Blocks == 0 then -- if the wall is 1x1x1 then the amout of blocks changed are 1
		Blocks = 1
	end
	
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[PlayerName]:GetSizeX() - 1
	local YY = PersonalBlockArea[PlayerName]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[PlayerName]:GetSizeZ() - 1
	
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, YY, Z, Z, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, YY, ZZ, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(XX, XX, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, X, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:Write(World, OneX, OneY, OneZ) -- Write the region into the world
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	return Blocks
end


-------------------------------------------------
---------------CREATEFACESFUNCTION---------------
-------------------------------------------------
function HandleCreateFaces(Player, World, BlockType, BlockMeta)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player) -- get the coordinates
	
	if CheckIfInsideAreas(OneX, TwoX, OneY, TwoY, OneZ, TwoZ, Player, World, "faces") then -- Check if the region intersects with any of the areas.
		return false
	end
	
	local PlayerName = Player:GetName()
	
	LastCoords[PlayerName] = {X = OneX, Y = OneY, Z = OneZ, WorldName = World:GetName()}
	
	PersonalUndo[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	PersonalBlockArea[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ) -- read the area
	local Blocks = (2 * (PersonalBlockArea[PlayerName]:GetSizeX() - 1 + PersonalBlockArea[PlayerName]:GetSizeZ() - 1) * PersonalBlockArea[PlayerName]:GetSizeY()) -- calculate the amount of changed blocks.
	if Blocks == 0 then
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[PlayerName]:GetSizeX() - 1
	local YY = PersonalBlockArea[PlayerName]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[PlayerName]:GetSizeZ() - 1
	
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, YY, Z, Z, 3, BlockType, BlockMeta) -- Walls
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, YY, ZZ, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(XX, XX, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, X, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, Y, Z, ZZ, 3, BlockType, BlockMeta) -- Floor
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, YY, YY, Z, ZZ, 3, BlockType, BlockMeta) -- Ceiling

	PersonalBlockArea[PlayerName]:Write(World, OneX, OneY, OneZ) -- write the area in the world.
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	return Blocks
end





--- Fills the selection stored in the specified cPlayerState with the specified block type
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function FillSelection(a_PlayerState, a_Player, a_World, a_BlockType, a_BlockMeta)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState, a_Player, a_World, "fill")) then -- Check if the region intersects with any of the areas.
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "fill")

	-- Fill the selection:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	Area:Create(MaxX - MinX + 1, MaxY - MinY + 1, MaxZ - MinZ + 1)
	Area:Fill(cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)
	Area:Write(a_World, MinX, MinY, MinZ)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	return (MaxX - MinX + 1) * (MaxY - MinY + 1) * (MaxZ - MinZ + 1)
end





--- Replaces the specified blocks in the selection stored in the specified cPlayerState
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
-- If a_TypeOnly is set, the block meta is ignored and conserved
function ReplaceSelection(a_PlayerState, a_Player, a_World, a_SrcBlockType, a_SrcBlockMeta, a_DstBlockType, a_DstBlockMeta, a_TypeOnly)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState, a_Player, a_World, "fill")) then -- Check if the region intersects with any of the areas.
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "replace")

	-- Read the area to be replaced:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	
	-- Replace the blocks:
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	local NumBlocks = 0
	if (a_TypeOnly) then
		for X = 0, XSize do
			for Y = 0, YSize do
				for Z = 0, ZSize do
					if (Area:GetRelBlockType(X, Y, Z) == a_SrcBlockType) then
						Area:SetRelBlockType(X, Y, Z, a_DstBlockType)
						NumBlocks = NumBlocks + 1
					end
				end
			end
		end
	else
		for X = 0, XSize do
			for Y = 0, YSize do
				for Z = 0, ZSize do
					local BlockType, BlockMeta = Area:GetRelBlockTypeMeta(X, Y, Z)
					if ((BlockType == a_SrcBlockType) and (BlockMeta == a_SrcBlockMeta)) then
						Area:SetRelBlockTypeMeta(X, Y, Z, a_DstBlockType, a_DstBlockMeta)
						NumBlocks = NumBlocks + 1
					end
				end
			end
		end
	end
	
	-- Write the area back to world:
	Area:Write(a_World, MinX, MinY, MinZ)
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	return NumBlocks
end





-------------------------------------------
------------RIGHTCLICKCOMPASS--------------
-------------------------------------------
function RightClickCompass(Player)
	local World = Player:GetWorld()
	local Teleported = false
	local WentThroughBlock = false
	
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if not g_BlockTransparent[BlockType] then
				WentThroughBlock = true
			else
				if WentThroughBlock then
					if BlockType == E_BLOCK_AIR and g_BlockIsSolid[World:GetBlock(X, Y - 1, Z)] then
						Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
						Teleported = true
						return true
					else
						for y = Y, 1, -1 do
							if g_BlockIsSolid[World:GetBlock(X, y, Z)] then
								Player:TeleportToCoords(X + 0.5, y + 1, Z + 0.5)
								Teleported = true
								return true
							end
						end
					end
				end
			end
		end;
	};
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()	

	local Start = EyePos
	local End = EyePos + LookVector * 75
	
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	if not Teleported then
		Player:SendMessage(cChatColor.Rose .. "Nothing to pass through!")
	end
end


------------------------------------------
------------LEFTCLICKCOMPASS--------------
------------------------------------------
function LeftClickCompass(Player)
	local World = Player:GetWorld()
	local HasHit = false
	
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if BlockType ~= E_BLOCK_AIR and not g_BlockOneHitDig[BlockType] then
				local IsValid, WorldHeight = World:TryGetHeight(X, Z)
				for y = Y, WorldHeight + 1 do
					if not g_BlockIsSolid[World:GetBlock(X, y, Z)] then
						Y = y
						break
					end
				end
				Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
				HasHit = true
				return true
			end
		end
	};
	
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()
	
	local Start = EyePos
	local End = EyePos + LookVector * 75
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	return HasHit
end


------------------------------------------------
------------------HPOSSELECT--------------------
------------------------------------------------
function HPosSelect(Player, World)
	local hpos = nil
	local Callbacks = {
	OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
		if BlockType ~= E_BLOCK_AIR and not g_BlockOneHitDig[BlockType] then
			hpos = Vector3i(X, Y, Z)
			return true
		end
	end
	};
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()
	local Start = EyePos
	local End = EyePos + LookVector * 150
	
	if cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z) then
		return false
	end
	return true, hpos
end