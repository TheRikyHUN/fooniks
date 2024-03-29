--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_warp.lua
*
*	Original File by lil_Toady
*
**************************************]]

aWarpForm = nil

function aPlayerWarp ( player )
	if ( aWarpForm == nil ) then
		local x, y = guiGetScreenSize()
		aWarpForm		= guiCreateWindow ( x / 2 - 110, y / 2 - 150, 200, 300, "Player Warp Management", false )
		aWarpList		= guiCreateGridList ( 0.03, 0.08, 0.94, 0.73, true, aWarpForm )
					   guiGridListAddColumn( aWarpList, "Player", 0.9 )
		aWarpSelect		= guiCreateButton ( 0.03, 0.82, 0.94, 0.075, "Select", true, aWarpForm )
		aWarpCancel		= guiCreateButton ( 0.03, 0.90, 0.94, 0.075, "Cancel", true, aWarpForm )

		addEventHandler ( "onClientGUIDoubleClick", aWarpForm, aClientWarpDoubleClick )
		addEventHandler ( "onClientGUIClick", aWarpForm, aClientWarpClick )
		--Register With Admin Form
		aRegister ( "PlayerWarp", aWarpForm, aPlayerWarp, aPlayerWarpClose )
	end
	aWarpSelectPointer = player
	guiGridListClear ( aWarpList )
	for id, player in ipairs ( getElementsByType ( "player" ) ) do
		guiGridListSetItemText ( aWarpList, guiGridListAddRow ( aWarpList ), 1, getPlayerName ( player ), false, false )
	end
	guiSetVisible ( aWarpForm, true )
	guiBringToFront ( aWarpForm )
end

function aPlayerTele ( player )
	if ( aWarpForm == nil ) then
		local x, y = guiGetScreenSize()
		aWarpForm		= guiCreateWindow ( x / 2 - 110, y / 2 - 150, 200, 300, "Player Teleport Management", false )
		aWarpList		= guiCreateGridList ( 0.03, 0.08, 0.94, 0.73, true, aWarpForm )
					   guiGridListAddColumn( aWarpList, "Koht", 0.9 )
		aWarpSelect		= guiCreateButton ( 0.03, 0.82, 0.94, 0.075, "Select", true, aWarpForm )
		aWarpCancel		= guiCreateButton ( 0.03, 0.90, 0.94, 0.075, "Cancel", true, aWarpForm )

		addEventHandler ( "onClientGUIDoubleClick", aWarpForm, aClientWarpDoubleClick2 )
		addEventHandler ( "onClientGUIClick", aWarpForm, aClientWarpClick2 )
		--Register With Admin Form
		aRegister ( "PlayerWarp", aWarpForm, aPlayerWarp, aPlayerWarpClose )
	end
	aWarpSelectPointer = player
	guiGridListClear ( aWarpList )
	
	local infospots = getElementsByType ( "InfoSpot" );
	for k, v in ipairs ( infospots ) do
		guiGridListSetItemText ( aWarpList, guiGridListAddRow ( aWarpList ), 1, getElementData( v, "infoId" ), false, false )
	end
	
	guiSetVisible ( aWarpForm, true )
	guiBringToFront ( aWarpForm )
	
end

function aPlayerWarpClose ( destroy )
	if ( ( destroy ) or ( guiCheckBoxGetSelected ( aPerformanceWarp ) ) ) then
		if ( aWarpForm ) then
			removeEventHandler ( "onClientGUIDoubleClick", aWarpForm, aClientWarpDoubleClick )
			removeEventHandler ( "onClientGUIClick", aWarpForm, aClientWarpClick )
			destroyElement ( aWarpForm )
			aWarpForm = nil
		end
	else
		guiSetVisible ( aWarpForm, false )
	end
end

function aClientWarpDoubleClick ( button )
	if ( button == "left" ) then
		if ( source == aWarpList ) then
			if ( guiGridListGetSelectedItem ( aWarpList ) ~= -1 ) then
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aWarpSelectPointer, "warpto", getPlayerFromNick ( guiGridListGetItemText ( aWarpList, guiGridListGetSelectedItem ( aWarpList ), 1 ) ) )
				aPlayerWarpClose ( false )
			end
		end
	end
end

function aClientWarpClick ( button )
	if ( button == "left" ) then
		if ( source == aWarpSelect ) then
			if ( guiGridListGetSelectedItem ( aWarpList ) ~= -1 ) then
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aWarpSelectPointer, "warpto", getPlayerFromNick ( guiGridListGetItemText ( aWarpList, guiGridListGetSelectedItem ( aWarpList ), 1 ) ) )
				aPlayerWarpClose ( false )
			end
		elseif ( source == aWarpCancel ) then
			aPlayerWarpClose ( false )
		end
	end
end

function aClientWarpDoubleClick2 ( button )
	if ( button == "left" ) then
		if ( source == aWarpList ) then
			if ( guiGridListGetSelectedItem ( aWarpList ) ~= -1 ) then
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aWarpSelectPointer, "teleto", guiGridListGetItemText ( aWarpList, guiGridListGetSelectedItem ( aWarpList ), 1 ) )
				aPlayerWarpClose ( false )
			end
		end
	end
end

function aClientWarpClick2 ( button )
	if ( button == "left" ) then
		if ( source == aWarpSelect ) then
			if ( guiGridListGetSelectedItem ( aWarpList ) ~= -1 ) then
				triggerServerEvent ( "aPlayer", getLocalPlayer(), aWarpSelectPointer, "teleto", guiGridListGetItemText ( aWarpList, guiGridListGetSelectedItem ( aWarpList ), 1 ) )
				aPlayerWarpClose ( false )
			end
		elseif ( source == aWarpCancel ) then
			aPlayerWarpClose ( false )
		end
	end
end