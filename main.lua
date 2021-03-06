
-- main.lua

-- Contains the Initialize and OnDisable functions. It also loads all the necessary files.





-- First of all load all the library expansions
dofolder(cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/LibrariesExpansion")





--- All the folders that shouldn't be loaded by
g_ExcludedFolders = table.todictionary{
	"craftscripts",
	"LibrariesExpansion",
	".",
	"..",
}





-- Load all the folders
local WorldEditPath = cPluginManager:GetCurrentPlugin():GetLocalFolder()
for _, Folder in ipairs(cFile:GetFolderContents(WorldEditPath)) do repeat
	local Path = WorldEditPath .. "/" .. Folder
	if (not cFile:IsFolder(Path)) then
		break -- Is a continue due to a do-while directly after the for
	end

	if (g_ExcludedFolders[Folder]) then
		break -- Is a continue due to a do-while directly after the for
	end

	dofolder(Path)
until true end

PLUGIN = nil


function Initialize(a_Plugin)
	PLUGIN = a_Plugin
	PLUGIN:SetName(g_PluginInfo.Name)
	PLUGIN:SetVersion(g_PluginInfo.Version)

	InitializeConfiguration(a_Plugin:GetLocalFolder() .. "/config.cfg")

	-- Load the InfoReg shared library:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")

	--Bind all the commands:
	RegisterPluginInfoCommands();

	if (false and g_Config.Updates.CheckForUpdates) then
		cUpdater:CheckForNewerVersion()
	end

	-- Initialize SQL Storage
	cSQLStorage:Get()

	cFile:CreateFolder("schematics")

	LOG("[WorldEdit] Enabling WorldEdit v" .. g_PluginInfo.DisplayVersion)
	return true
end





function OnDisable()
	LOG("[WorldEdit] Disabling WorldEdit v" .. g_PluginInfo.DisplayVersion)
	ForEachPlayerState(
		function(a_State)
			a_State:Save(a_State:GetUUID())
		end
	)
end
