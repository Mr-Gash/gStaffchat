local function isAdmin( ply )
	if not IsValid( ply ) then return false end

	return ply:IsUserGroup( "operator" ) or ply:IsAdmin()
end

hook.Add( "PlayerSay", "Staff Chat", function( ply, text )
	if not isAdmin( ply ) then return end
	if text:Left( 1 ) ~= "@" then return end

	if text:lower():Left( 3 ) == "@p " then
		local rest = text:sub( 4, #text )
		local pomf = string.Explode( " ", rest )[ 1 ]

		local targ
		local soft = false
		for k, v in pairs( player.GetAll() ) do
			if not string.find( v:Nick():lower(), pomf:lower() ) then continue end

			if v:Nick() == pomf then
				targ = v
				break
			elseif v:Nick():lower() == pomf:lower() then
				targ = v
				soft = true
			elseif not soft then
				targ = v
			end
		end

		if not targ then
			ply:ChatPrint( "No target found!" )
			return ""
		end

		local send = rest:sub( #pomf + 2, #text )
		targ:ChatPrint( "(From " .. ply:Nick() .. ") " .. send )

		local str = "(" .. ply:Nick() .. " -> " .. targ:Nick() .. ") " .. send
		ServerLog( "SC: " .. str .. "\n" )

		if not isAdmin( targ ) then
			for k, v in pairs( player.GetAll() ) do
				if not isAdmin( v ) then continue end

				v:ChatPrint( str )
			end
		else ply:ChatPrint( "(To " .. targ:Nick() .. ") " .. send ) end
	elseif text:lower():Trim() == "@" then
		for k, v in pairs( {
			"staff only chat: @ text",
			"private messaging: @ playername text",
			"- staff to nonstaff are shown to all staff. staff to staff are private.",
			"global messaging: @! text",
		} ) do
			ply:ChatPrint( v )
		end
	else
		local start = 2
		local is_all = text:Left( start ) == "@!"

		if is_all then start = start + 1 end
		if text:sub( start, start ) == " " then start = start + 1 end

		local send = text:sub( start, #text )
		local str = ( is_all and "(GLOBAL) " or "(STAFF) " ) .. ply:Nick() .. ": " .. send

		for k, v in pairs( player.GetAll() ) do
			if not is_all and not isAdmin( v ) then continue end

			v:ChatPrint( str )
		end

		ServerLog( "SC: " .. str .. "\n" )
	end

	return ""
end )
