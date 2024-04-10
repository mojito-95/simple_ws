local function AddFile(file, directory)

	local prefix = string.lower(string.Left(file, 3))

	if SERVER && prefix == "sv_" then

		include(directory ..file)

	elseif prefix == "sh_" then

		if SERVER then

			AddCSLuaFile(directory ..file)

		end

		include(directory ..file)

	elseif prefix == "cl_" then

		if SERVER then

			AddCSLuaFile(directory ..file)

		elseif CLIENT then

			include(directory ..file)

		end

	end

end

local function LoadDirectory(directory)

	directory = directory .."/"

	local files, directories = file.Find(directory .."*", "LUA")

	for k, v in ipairs(files) do

		if string.EndsWith(v, ".lua") then

			AddFile(v, directory)

		end

	end

	for k, v in ipairs(directories) do

		LoadDirectory(directory ..v)

	end

end
LoadDirectory("m_ws")