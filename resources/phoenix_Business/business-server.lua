-- TODO:

--[[
	
	* Realval Calc.
	* simple trucker job.
	
	Hiljem:
	* Servicetüüp mis koosneb teistest servicetüübitest.
		kiirsöökla
			* pitsa
			* burks
			* sprite jne
]]--

local biznesses = { };
local services = { };

local warehouses = { };
local oPos = { };
local teletime = { };

function displayLoadedRes( res )	

	LoadServices( );
	LoadBizzes( );			
	setTimer( SaveBizzes, 110000, 0 );

end

addEventHandler( "onResourceStart", getResourceRootElement( getResourceFromName( "phoenix_Base" ) ), displayLoadedRes );
addEventHandler( "onResourceStart", getResourceRootElement( getThisResource() ), function () if( getResourceState( getResourceFromName( "phoenix_Base" ) ) == "running" ) then displayLoadedRes( ); end end );


addEventHandler ( "onResourceStop", getResourceRootElement( getThisResource( ) ), 
    function ( resource )
	
		SaveBizzes( );
	
	end
	
);

function LoadServices( )

	local xmlFile =  xmlLoadFile ( "services.xml" );
	if ( xmlFile ~= false ) then
	
		outputDebugString( "phoenix-Business: Services database loaded." );
	
		local allnodes = xmlNodeGetChildren( xmlFile );
		
		if( allnodes ~= false ) then
		
			for i, node in ipairs( allnodes ) do
		
           		-- node
            	local id = tonumber( xmlNodeGetAttribute( node, "id" ) );
				services[id] = { };
				services[id] = xmlNodeGetAttributes( node );
				
				services[id]["needed"] = { };
				
				local children = xmlNodeGetChildren( node );
				for k, v in ipairs( children ) do
				
					local key = xmlNodeGetName( v );
					local val = xmlNodeGetValue( v );
					services[id]["needed"][key] = val;
				
				end
			
			end
		end
		
		xmlUnloadFile ( xmlFile );
		
	else
	
		outputDebugString( "phoenix-Business: Services not loaded.", 2 );
	
	end
end

function LoadBizzes( )

	local query = "SELECT * FROM ph_Buisness";
	local result = exports.phoenix_Base:SelectQuery( query );

	if( result ) then
	
		for k, v in ipairs( result ) do
		
			local officeTbl = { };
			officeTbl["posX"] = k["oPosX"];
			officeTbl["posY"] = k["oPosY"];
			officeTbl["posZ"] = k["oPosZ"];
			officeTbl["oDim"] = k["oDim"];
			officeTbl["oToInt"] = k["oToInt"];
			
			
			
			local loadbayTbl = { };
			loadbayTbl["posX"] = k["lPosX"];
			loadbayTbl["posY"] = k["lPosY"];
			loadbayTbl["posZ"] = k["lPosZ"];			
			
			local serviceTbl = LoadBizServiceSpots( k["id"] );
			local prodTbl = LoadBizStorage( k["id"] );
			
			addBiz( k["bizOwner"], k["bizName"], k["bizBank"], k["bizOpen"], officeTbl, serviceTbl, loadbayTbl, prodTbl, k["id"] );
		
		end
	
	end

end

function SaveBizzes( )

	for k, v in ipairs( biznesses ) do
	
		local query = "UPDATE ph_Buisness SET bizOwner = '" .. v["bizOwner"] .. "', bizName = '" .. v["bizName"] .. "', bizBank = '" .. v["bizBank"] .. "' WHERE id = '" .. k .. "'";
		exports.phoenix_Base:SimpleQuery( query );
		SaveBizStorage( k );
	
	end

end

function LoadBizServiceSpots( id )

	local tbl = { };
	local query = "SELECT * FROM ph_Buisness_Services WHERE bid = '" .. id .. "'";
	local result = exports.phoenix_Base:SelectQuery( query );
	
	if( result ) then
	
		for k, v in ipairs( result ) do
			
			local tbl2 = { };
			tbl2["id"] = v["id"];
			tbl2["bid"] = id;
			tbl2["posX"] = v["posX"];
			tbl2["posY"] = v["posY"];
			tbl2["posZ"] = v["posZ"];
			tbl2["int"] = tonumber( v["int"] );
			tbl2["dim"] = tonumber( v["dim"] );
			tbl2["type"] = v["type"];
			tbl2["name"] = services[tonumber( v["type"] )]["name"];
			tbl2["cost"] = tonumber( v["cost"] );
			
			table.insert( tbl, tbl2 );
		
		end
	
	end
	
	return tbl;

end

function LoadBizStorage( id )

	local tbl = { };
	local query = "SELECT * FROM ph_Buisness_Storage WHERE bid = '" .. id .. "'";
	local result = exports.phoenix_Base:SelectQuery( query );
	
	if( result ) then
	
		for k, v in ipairs( result ) do
		
			for field, value in ipairs( v ) do
			
				if( field ~= "id" and field ~= "bid" ) then
				
					local idx = string.find( value, "," );
					local idx2 = string.find( value, ",", idx+1 );
					local idx3 = string.find( value, ",", idx2+1 );
					tbl[field] = { };
					
					if( idx and idx2 ) then
					
						tbl[field]["has"] = tonumber( string.sub( value, 0, idx-1 ) ) or 25;
						tbl[field]["max"] = tonumber( string.sub( value, idx+1, idx2-1 ) ) or 25;
						tbl[field]["wants"] = tonumber( string.sub( value, idx2+1, idx3-1 ) ) or 0;
						tbl[field]["autobuy"] = tonumber( string.sub( value, idx3+1 ) ) or 0;
					
					else
					
						tbl[field]["has"] = 25;
						tbl[field]["max"] = 25;
						tbl[field]["wants"] = 0;
						tbl[field]["autobuy"] = 0;
					
					end
				
				end
			
			end
		
	  	end
	
	end
	
	return tbl;

end

function SaveBizStorage( id )

	local query = exports.phoenix_Base:MysqlUpdatebuild( "ph_Buisness_Storage");
	
	for k, v in pairs( biznesses[id]["products"] ) do
	
		local val = v["has"] .. "," .. v["max"] .. "," .. v["wants"] .. "," .. v["autobuy"];
		query = exports.phoenix_Base:MysqlSetField( query, k, val );
	
	end
	
	-- Finish query.
	query = exports.phoenix_Base:DoUpdateFinish( query, "bid", id );

end

function addBiz( owner, name, till, bizOpen, officeTbl, serviceTbl, loadbayTbl, prodTbl, sqlid )

	local elem = createElement( "bizness" );
	if( elem ) then
	
		local query;
	
		if( not sqlid ) then
		
			query = "INSERT INTO `ph_Buisness`(`id`, `bizOwner`, `bizName`, `bizBank`, `oPosX`, `oPosY`, `oPosZ`, " .. 
					"`oDim`, `oToInt`, `lPosX`, `lPosY`, `lPosZ`) VALUES " .. 
					"(NULL, '" .. owner .. "', '" .. name .. "', '" .. till .. "', " .. 
					"'" .. officeTbl["posX"] .. "', '" .. officeTbl["posY"] .. "', " .. 
					"'" .. officeTbl["posZ"] .. "', '" .. officeTbl["oDim"] .. "', '" .. officeTbl["oToInt"] .. "', " .. 
					"'" .. loadbayTbl["posX"] .. "', '" .. loadbayTbl["posY"] .. "', '" .. loadbayTbl["posZ"] .. "')";
			sqlid = exports.phoenix_Base:SimpleQuery( query, true );
			if( not sqlid ) then return false; end
			
			for k, v in ipairs( serviceTbl ) do 
			
				query = "INSERT INTO `ph_Buisness_Services` (`id`, `bid`, `type`, `posX`, `posY`, `posZ`, `int`, `dim`) " .. 
						"VALUES (NULL, '" .. sqlid .. "', " .. 
						"'" .. v["type"] .. "', '" .. v["posX"] .. "', '" .. v["posY"] .. "', '" .. v["posZ"] .. "', " ..
						"'" .. v["int"] .. "', '" .. v["dim"] .. "')";
				local tempid = exports.phoenix_Base:SimpleQuery( query, true );
				if( tempid ) then 
				
					serviceTbl[k]["id"] = tempid;
				
				end				
			
			end
			
		
		end
		
		setElementData( elem, "sqlid", sqlid );
		setElementData( elem, "bizOwner", owner );
		setElementData( elem, "bizName", name );
		setElementData( elem, "bizBank", till );
		setElementData( elem, "bizOpen", bizOpen );
		officeTbl["oToInt"] = tonumber( officeTbl["oToInt"] );
		
		sqlid = tonumber( sqlid );		
		loadbayTbl["pickup"] = createPickup( loadbayTbl["posX"], loadbayTbl["posY"], loadbayTbl["posZ"], 3, 1274, 3000 );
		setElementData( loadbayTbl["pickup"], "BizID", sqlid );		
		
		for k, v in ipairs( serviceTbl ) do
			
			serviceTbl[k]["marker"] = createMarker( v["posX"], v["posY"], v["posZ"], "cylinder", 1, 255, 0, 0 );
			setElementInterior( serviceTbl[k]["marker"], v["int"] );
			setElementDimension( serviceTbl[k]["marker"], v["dim"] );
			setElementData( serviceTbl[k]["marker"], "serviceId", v["id"] );
			setElementData( serviceTbl[k]["marker"], "serviceType", v["type"] );
			setElementData( serviceTbl[k]["marker"], "serviceCost", v["cost"] );
			setElementData( serviceTbl[k]["marker"], "bizId", v["bid"] );
		
		end
		
		if( exports.phoenix_Infospots:addInfoSpot( "Biz." .. sqlid, officeTbl["posX"], officeTbl["posY"], officeTbl["posZ"], 0, 0, 0, 20000+sqlid, officeTbl["oToInt"] ) ~= false ) then
			
			if( tonumber( bizOpen ) == 0 ) then
			
				exports.phoenix_Infospots:InfoSpotSetLocked( "Biz." .. sqlid, true );
			
			else
			
				exports.phoenix_Infospots:InfoSpotSetLocked( "Biz." .. sqlid, false );
			
			end
			
			exports.phoenix_Infospots:InfoSpotSetManual( "Biz." .. sqlid, true );
			
		end			
		
		biznesses[sqlid] = { };
		biznesses[sqlid]["bizElem"] = elem;
		biznesses[sqlid]["bizName"] = name;
		biznesses[sqlid]["bizOwner"] = owner;
		biznesses[sqlid]["bizBank"] = tonumber( till );
		biznesses[sqlid]["bizOpen"] = bizOpen;
		biznesses[sqlid]["offices"] = officeTbl;
		biznesses[sqlid]["services"] = serviceTbl;
		biznesses[sqlid]["loadbay"] = loadbayTbl;
		biznesses[sqlid]["products"] = prodTbl;
		
		local node = getResourceConfig( "ladu.map" );
		
		warehouses[sqlid] = { };
		warehouses[sqlid]["elem"] = createElement( "wareHouse" );
		setElementParent( warehouses[sqlid]["elem"], biznesses[sqlid]["bizElem"] );
		
		warehouses[sqlid]["marker"] = createMarker( 322.505, -1205.956, 53.629, "cylinder", 1, 255, 0, 0 );
		setElementParent( warehouses[sqlid]["marker"], warehouses[sqlid]["elem"] );
		setElementDimension( warehouses[sqlid]["marker"], 20000+sqlid );
		setElementInterior( warehouses[sqlid]["marker"], sqlid );
			
		local tbl = xmlNodeGetChildren( node );
		warehouses[sqlid]["boxes"] = { };
		
		for k, v in ipairs( tbl ) do
		
			local data = xmlNodeGetAttributes( v );
			local obj = createObject( data["model"], data["posX"]-5000, data["posY"], data["posZ"], data["rotX"], data["rotY"], data["rotZ"] );
			setElementParent( obj, warehouses[sqlid]["elem"] );
			setElementDimension( obj, 20000+sqlid );
			setElementInterior( obj, sqlid );
			
			if( data["type"] == "kast" ) then
			
				table.insert( warehouses[sqlid]["boxes"] , obj );
			
			end
		
		end	
		
		addEventHandler( "onPlayerPickupUse", getRootElement( ), 

			function ( pickup )
			
				if( not teletime[source] ) then
				
					local parent = tonumber( getElementData( pickup, "BizID" ) );
					if( parent ) then
					
						
						EnterWarehouse( source, biznesses[parent]["bizElem"] );
					
					end
				
				end
			
			end

		);		
		
		return true;
	
	end
	
	return false;

end

addEvent( "onBisnessPurchase", true );
addEventHandler( "onBisnessPurchase", getRootElement(),

	function ( bElem, price )
	
		if( client ) then
		
			local charId = getElementData( client, "Character.id" );
			if( not charId ) then
			
				return false;
			
			end		
			
			if( getPlayerMoney( client ) < price ) then
			
				exports.phoenix_Chat:OocInfo( client, "Sul pole piisavalt raha" );
			
			else
			
				local sqlid = tonumber( getElementData( bElem, "sqlid" ) );				
				takePlayerMoney( client, price );
				setElementData( bElem, "bizOwner", charId );
				biznesses[sqlid]["bizOwner"] = charId;
				exports.phoenix_Chat:OocInfo( client, "Ost sooritatud!" );
			
			end
		
		end
	
	end
	
);

addEvent( "onBisnessNameChange", true );
addEventHandler( "onBisnessNameChange", getRootElement(),

	function ( bElem, newName )
	
		if( client ) then
		
			local sqlid = tonumber( getElementData( bElem, "sqlid" ) );
			setElementData( bElem, "bizName", newName );
			biznesses[sqlid]["bizName"] = newName;
			exports.phoenix_Chat:OocInfo( client, "Muudetud!" );
		
		end
	
	end
	
);

addEvent( "onBizCPInit", true );
addEventHandler( "onBizCPInit", getRootElement(),

	function ( bElem )
	
		if( client ) then
		
			local sqlid = tonumber( getElementData( bElem, "sqlid" ) );
			if( sqlid ) then
			
				triggerClientEvent( client, "onBizCPDisplay", client, bElem, biznesses[sqlid]["products"], biznesses[sqlid]["services"], getPlayerMoney( client ) );
			
			end
		
		end
	
	end
	
);

addEvent( "onBisnessOpenClose", true );
addEventHandler( "onBisnessOpenClose", getRootElement(),

	function ( bElem, status )
	
		if( client ) then
		
			local sqlid = tonumber( getElementData( bElem, "sqlid" ) );
			local str;
			if( status == 1 ) then
			
				biznesses[sqlid]["bizOpen"] = "1";
				setElementData( bElem, "bizOpen", "1" );
				str = "Avatud!";
				exports.phoenix_Infospots:InfoSpotSetLocked( "Biz." .. sqlid, false );
			
			else
			
				biznesses[sqlid]["bizOpen"] = "0";
				setElementData( bElem, "bizOpen", "0" );
				str = "Suletud!";
				exports.phoenix_Infospots:InfoSpotSetLocked( "Biz." .. sqlid, true );
			
			end
			
			exports.phoenix_Chat:OocInfo( client, str );
		
		end
	
	end
	
);

addEventHandler( "onPlayerMarkerHit", getRootElement( ),

	function ( markerHit, matchingDimension )
	
		if( not Open and matchingDimension ) then
		
			local id = getElementData( markerHit, "serviceId" );
			if( id ~= false ) then
			
				initService( source, markerHit )
			
			end
		
		end
	
	end

);

function initService( client, serviceElem )

	local bid = tonumber( getElementData( serviceElem, "bizId" ) );
	local sType = tonumber( getElementData( serviceElem, "serviceType" ) );
	local needed = services[sType]["needed"];
	
	local canHas = false; -- How many can has.
	
	for k, v in pairs( needed ) do
	
		local daPhak = math.floor( biznesses[bid]["products"][k]["has"] / v );
		if( ( not canHas or canHas > daPhak ) and daPhak ) then
		
			canHas = daPhak;
		
		end
	
	end
	
	if( not canHas ) then canHas = 0; end
	
	local price = tonumber( getElementData( serviceElem, "serviceCost" ) );
	local canBuy = false;
	if( getPlayerMoney( client ) >= price ) then canBuy = true; end	
	triggerClientEvent( client, "onPlayerServiceRequest", client, biznesses[bid]["bizName"], serviceElem, services[sType]["name"], services[sType]["type"], canHas, price, canBuy );

end

addEvent( "onPlayerServicePurchase", true );
addEventHandler( "onPlayerServicePurchase", getRootElement(),

	function ( serviceElem, cost, amount )
		
		local bid = tonumber( getElementData( serviceElem, "bizId" ) );
		local sType = tonumber( getElementData( serviceElem, "serviceType" ) );		
		
		if( not amount ) then amount = 1; end
		
		local myVeh = 0;
		-- Some Checks...
		if( services[sType]["vehicle"] ) then
		
			if( not isPedInVehicle( client ) ) then
			
				exports.phoenix_Chat:OocInfo( client, "Pead olema masinas." );
				return false;
				
			else
				
				if( services[sType]["driver"] and getPedOccupiedVehicleSeat( client ) ~= 0 ) then 
				
					exports.phoenix_Chat:OocInfo( client, "Pead olema juht." );
					return false;
				
				end
				
				myVeh = getPedOccupiedVehicle( client );
			
			end
		
		end
		
		-- Take & Give Money
		if( cost*amount > getPlayerMoney( client ) ) then
		
			exports.phoenix_Chat:OocInfo( client, "Pole piisavalt raha." );
			return false;
		
		end
		
		takePlayerMoney( client, cost*amount );
		local till = tostring( tonumber( biznesses[bid]["bizBank"] ) + cost*amount );
		setElementData( biznesses[bid]["bizElem"], "bizBank", till );
		biznesses[bid]["bizBank"] = till;
		
		-- Take some products.			
		for k, v in pairs( services[sType]["needed"] ) do
		
			biznesses[bid]["products"][k]["has"] = biznesses[bid]["products"][k]["has"] - v;
		
		end
		
		-- Do item special stuff.		
		
		if( sType == 1 ) then
		
			local pHealth = getElementHealth( client );
			local nHealth = 100;
			if( pHealth < 50 ) then nHealth = pHealth + 50; end
			setElementHealth( client, nHealth );
		
		elseif( sType == 2 ) then
		
			local rFuel = tonumber( getElementData( myVeh, "Vehicle.RFuel" ) );
			if( not rFuel ) then rFuel = 100; end
			
			local mFuel = tonumber( getElementData( myVeh, "Vehicle.MFuel" ) );
			if( not mFuel ) then mFuel = 100; end
			
			if( amount + rFuel > mFuel ) then
			
				rFuel = mFuel;
				
				local leftout = (amount + rFuel) - mFuel;
				-- Give some money back.
				givePlayerMoney( client, cost*leftout );
				till = till - cost*leftout;
				setElementData( biznesses[bid]["bizElem"], "bizBank", till );
				biznesses[bid]["bizBank"] = till;
			
			else
			
				rFuel = amount + rFuel;
			
			end
			
			setElementData( myVeh, "Vehicle.RFuel", rFuel );
		
		end		
	
		exports.phoenix_Chat:OocInfo( client, "Tehing sooritatud." );
	
	end

);

function getWareHouseInfo( sqlid )

	local has = 0;
	local maximum = 0;

	for k, v in pairs( biznesses[sqlid]["products"] ) do
	
		has = has + v["has"];
		maximum = maximum + v["max"];
		
	end
	
	return has, maximum;

end

function ExitHandler( markerHit, matchingDimension )

	local parent = getElementParent( markerHit ) ;

	if( matchingDimension and parent and getElementType( parent ) == "wareHouse" ) then
	
		ExitWarehouse( source );
		cancelEvent( );
	
	end

end

addEventHandler( "onPlayerMarkerHit", getRootElement( ), ExitHandler );

function EnterWarehouse( thePlayer, theBiz )

	local sqlid = tonumber( getElementData( theBiz, "sqlid" ) );
	outputChatBox( sqlid );
	
	local has, maximum = getWareHouseInfo( sqlid );
	local rem = #warehouses[sqlid]["boxes"] - math.ceil( #warehouses[sqlid]["boxes"] * ( has / maximum ) );
	
	for k, v in ipairs( warehouses[sqlid]["boxes"] ) do
	
		if( rem > 0 ) then
		
			setElementDimension( v, 100 ); -- set to a place where all bad things go xD
			rem = rem - 1;
		
		end
	
	end
	
	oPos[thePlayer] = { };
	oPos[thePlayer][0], oPos[thePlayer][1], oPos[thePlayer][2] = getElementPosition( thePlayer );
	oPos[thePlayer][3] = getElementInterior( thePlayer );
	oPos[thePlayer][4] = getElementDimension( thePlayer );
	
	setElementDimension( thePlayer, 20000+sqlid );
	setElementInterior( thePlayer, sqlid );	
	setElementPosition( thePlayer, 319.3500976563, -1206.158, 54.627 ); -- Set player inside...

end
addEvent( "onPlayerEnterWarehouse", true );
addEventHandler( "onPlayerEnterWarehouse", getRootElement(), EnterWarehouse );

function ExitWarehouse( thePlayer )

	teletime[thePlayer] = true;
	setElementPosition( thePlayer,  oPos[thePlayer][0], oPos[thePlayer][1], oPos[thePlayer][2] ); -- Set player back...
	setElementInterior( thePlayer, oPos[thePlayer][3] );
	setElementDimension( thePlayer, oPos[thePlayer][4] );
	setTimer( disableTeleTime, 1000, 1, thePlayer );

end

function disableTeleTime( thePlayer ) teletime[thePlayer] = false; end

addEvent( "onBizServiceEdit", true );
addEventHandler( "onBizServiceEdit", getRootElement(),

	function ( bElem, id, serviceInf )
	
		local sqlid = tonumber( getElementData( bElem, "sqlid" ) );
		if( client and type( biznesses[sqlid]["services"][id] ) == "table" ) then
		
			for k, v in pairs( serviceInf ) do
			
				if( biznesses[sqlid]["services"][id][k] ~= v ) then
				
					biznesses[sqlid]["services"][id][k] = v;
				
				end
			
			end
			
			setElementData( biznesses[sqlid]["services"][id]["marker"], "serviceCost", serviceInf["cost"] );
		
		end
	
	end

);

addEvent( "onBizProductstatusChange", true );
addEventHandler( "onBizProductstatusChange", getRootElement(),

	function ( bElem, product, editor )
	
		local sqlid = tonumber( getElementData( bElem, "sqlid" ) );
		if( client and type( biznesses[sqlid]["products"][product] ) == "table" ) then
		
			local newval = biznesses[sqlid]["products"][product]["wants"] + editor;
			
			if( newval >= 0 and newval <= biznesses[sqlid]["products"][product]["max"]-biznesses[sqlid]["products"][product]["has"] ) then
			
				biznesses[sqlid]["products"][product]["wants"] = newval;
			
			end
		
		end
	
	end

);

addEvent( "onBizProductautoChange", true );
addEventHandler( "onBizProductautoChange", getRootElement(),

	function ( bElem, product, newI )
	
		local sqlid = tonumber( getElementData( bElem, "sqlid" ) );
		if( client and type( biznesses[sqlid]["products"][product] ) == "table" ) then
		
			biznesses[sqlid]["products"][product]["autobuy"] = newI;
		
		end
	
	end

);

addEvent( "onBisnessSold", true );
addEventHandler( "onBisnessSold", getRootElement( ),

	function ( bElem )
	
		local sqlid = tonumber( getElementData( bElem, "sqlid" ) );
		
		if( client ) then
			
			biznesses[sqlid]["bizOwner"] = 0;
			setElementData( bElem, "bizOwner", "0" );
		
		end
	
	end

);

addEvent( "onBizBank", true );
addEventHandler( "onBizBank", getRootElement( ),

	function ( bElem, amount )
	
		local sqlid = tonumber( getElementData( bElem, "sqlid" ) );
		
		if( client ) then
			
			if( amount > 0 ) then -- If we are giving money to biz.
			
				takePlayerMoney( client, amount );
				
			else
			
				givePlayerMoney( client, amount*-1 );
			
			end
			
			biznesses[sqlid]["bizBank"] = biznesses[sqlid]["bizBank"] + amount;
			setElementData( bElem, "bizBank", biznesses[sqlid]["bizBank"] );
		
		end
	
	end

);