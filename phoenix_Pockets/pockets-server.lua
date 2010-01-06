connection = nil;

items = { };
pockets = { };
max_items = 0;

function displayLoadedRes( res )	

	if( not connection ) then
	
		connection = mysql_connect( get( "#phoenix_Base.MYSQL_HOST" ), get( "#phoenix_Base.MYSQL_USER" ), get( "#phoenix_Base.MYSQL_PASS" ), get( "#phoenix_Base.MYSQL_DB" ) );
		
		if( not connection ) then
		
			outputDebugString( "Phoenix-Pockets: Ei saanud mysql ühendust kätte." );
			stopResource( res );
		
		else
		
			outputDebugString( "Phoenix-Pockets: Mysql serveriga ühendatud." );
			local ret = RegisterItems( );
			max_items = tonumber( get( "#NUM_POCKETS" ) ) + ret;
			outputDebugString( "Max Items is: " .. max_items );
			PocketsSafe();
		
		end	
		
	end

end

addEventHandler( "onResourceStart", getResourceRootElement( getThisResource( ) ), displayLoadedRes );


function PocketsSafe( )

	for i = 1, max_items, 1 do
	
		local added = false;
		local query = "SHOW COLUMNS FROM ph_Pockets LIKE 'Pocket_" .. i .. "'";
		local result = mysql_query( connection, query );
		
		if( result ~= false ) then
		
			if( mysql_num_rows( result ) > 0 ) then
		
				mysql_free_result( result );
				added = true;
			
			end
		
			mysql_free_result( result );
		
		end
		
		if( added ~= true ) then
		
			-- Add the more spots to database so players can use them. :)
			query = "ALTER TABLE `ph_Pockets` ADD `Pocket_" .. i .. "` VARCHAR( 32 ) NOT NULL DEFAULT '{0,0}'";
			result = mysql_query( connection, query );
			
			if( result ~= false and result ~= nil ) then	
			
				mysql_free_result( result );
			
			end	
		
		end
	
	end
	
end

function RegisterItems( )

	local ret = 0;
	local xmlFile =  xmlLoadFile ( "items.xml" );
	if ( xmlFile ~= false ) then
	
		outputDebugString( "phoenix-Pockets: Items database loaded." );
	
		local items = xmlNodeGetChildren( xmlFile );
		
		if( items ~= false ) then
		
			for i, node in ipairs( items ) do
		
            	local id = tonumber( xmlNodeGetAttribute( node, "id" ) );
            	
            	if( id ~= false ) then
            	
            		items[id] = { };
            		
            		items[id]["myType"] = xmlNodeGetAttribute( node, "type" );
            		
            		if( items[id]["myType"] == "WEAPON" ) then
            		
            			items[id]["wepId"] = tonumber( xmlNodeGetAttribute( node, "weaponId" ) );
            		
					elseif( items[id]["myType"] == "POCKET" ) then
					
						items[id]["extraSlots"] = tonumber( xmlNodeGetAttribute( node, "extraSlots" ) );
						
						if( extraSlots > ret ) then ret = extraSlots; end -- allows us to always be sure there are enough fields in the DB.
					
            		else
            		
            			items[id]["useEvent"] = xmlNodeGetAttribute( node, "useEvent" );
            		
            		end
            		
            	 	items[id]["parent"] = tonumber( xmlNodeGetAttribute( node, "parent" ) );
            		items[id]["name"] = xmlNodeGetAttribute( node, "name" );
            		items[id]["canDrop"] = xmlNodeGetAttribute( node, "canDrop" );
            		
            		outputDebugString( "Registred Item: " .. id .. "->" .. items[id]["name"] );
            	
            	end
            
      		end
      		
      	else
      	
      		outputDebugString( "phoenix-Pockets: Bad Database syntax.", 1 );
      		      
       	end

		xmlUnloadFile ( xmlFile );
		
	else
	
		outputDebugString( "phoenix-Pockets: Pockets database failed to load.", 1 );
		
	end
	
	return ret;

end

function LoadPocketsForPlayer( thePlayer )

	if( not thePlayer or not isElement ( thePlayer )  ) then return false; end
	local charId = getElementData( thePlayer, "Character.id" );
	if( not charId ) then return false; end	
	
	local query = "SELECT * FROM ph_Pockets WHERE cid = '" .. charId .. "'";
	local result = mysql_query( connection, query );
	
	pockets[thePlayer] = { };
	
	if( result ~= false ) then
	
		if( mysql_num_rows( result ) > 0 ) then
		
			mysql_field_seek( result, 1 );
			
  			for k,v in ipairs( mysql_fetch_row( result ) ) do
  				
    			local field = mysql_fetch_field( result );
    			if (v == mysql_null()) then v = ''; end
    			
				if( #field["name"] > 4 ) then -- We dont want the cid field, do we?
				
					local pocketId = tonumber( string.sub( field["name"], 7 ) ); -- escape Pocket_ in front of field name, and get the number only.
					
					if( pocketId ~= nil ) then
					
						pockets[thePlayer][pocketId] = { };
						
						-- v holds something like this: {1,2}
						local id, data = string.match(v, "%{(%d+),(%d+)%}");
						if( id ~= nil and data ~= nil ) then
						
							outputChatBox( "Happy: " .. id .. "->" .. data, thePlayer );
						
						else 
						
							outputChatBox( "nil", thePlayer );
						
						end
					
					end
				
				end
    		
	  		end
		
		else
	
			mysql_free_result( result );
			query = "INSERT INTO ph_Pockets(cid) VALUES('" .. charId .. "')";
			result = mysql_query( connection, query );
			
			if( result ~= false ) then
			
				mysql_free_result( result );
				setTimer( LoadPocketsForPlayer, 600, 1, thePlayer );
				
			end
		
		end
	
	end
	
end

addEvent( "onPocketsRequired", true );
addEventHandler( "onPocketsRequired", getRootElement(), LoadPocketsForPlayer );

-- TODO:
-- Saving for player.