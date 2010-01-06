veh = nil
function cCarMenu()
	CarMenu = guiCreateWindow(787,445,96,164,"",false)
	guiWindowSetSizable(CarMenu,false)
	btnAlarm = guiCreateButton(0.0938,0.1524,0.8125,0.122,"Alarm peale",true,CarMenu)
	btnLukk = guiCreateButton(0.0938,0.2988,0.8125,0.122,"Lukusta",true,CarMenu)
	btnPagasnik = guiCreateButton(0.0938,0.4451,0.8125,0.122,"Pagasnik",true,CarMenu)
	btnKindalaegas = guiCreateButton(0.0938,0.5976,0.8125,0.122,"Kindalaegas",true,CarMenu)
	btnSulge = guiCreateButton(0.3542,0.7866,0.3021,0.1585,"X",true,CarMenu)
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), 
	function ()
		cCarMenu()
		addEventHandler("onClientGUIClick", btnSulge, CarMenuSulge, false)
		addEventHandler("onClientGUIClick", btnAlarm, CarMenuAlarm, false)
		addEventHandler("onClientGUIClick", btnLukk, CarMenuLukk, false)
		addEventHandler("onClientGUIClick", btnPagasnik, CarMenuTulekul, false)
		addEventHandler("onClientGUIClick", btnKindalaegas, CarMenuTulekul, false)
		guiSetVisible(CarMenu, false)
	end
)

bindKey ("mouse3", "down",
        function()
                showCursor( not isCursorShowing() )
        end)
		
bindKey ("m", "down",
        function()
                showCursor( not isCursorShowing() )
        end)
		
		
function carclick(button, state, ax, ay, wx, wy, wz, element)

	if getElementData(getLocalPlayer(), "clickMenu") then
		return false;
	end
	
	if button == "right" and element and getElementType(element) == "vehicle" and state=="down" and tostring(getVehicleType(element)) ~= "BMX" then
	
		local x, y, z = getElementPosition(getLocalPlayer())
		
		if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=30 then
		
			if tonumber(getElementData(element, "vAlarm")) == 1 then
				guiSetText(btnAlarm, "Alarm maha")
			else
				guiSetText(btnAlarm, "Alarm peale")
			end
			if isVehicleLocked(element) then
				guiSetText(btnLukk, "Ava")
			else
				guiSetText(btnLukk, "Lukusta")
			end
			
			guiSetVisible(CarMenu, true)
			guiSetPosition ( CarMenu, ax, ay, false )
			guiSetEnabled ( btnLukk, false )
			guiSetEnabled ( btnPagasnik, false )
			guiSetEnabled ( btnKindalaegas, false )
			setElementData(getLocalPlayer(), "clickMenu", true)
			veh = element
			
			if getDistanceBetweenPoints3D(x, y,z, wx, wy, wz)<=2 then
				guiSetEnabled ( btnLukk, true )
				guiSetEnabled ( btnPagasnik, true )
			end
			
			if isPedInVehicle ( getLocalPlayer() ) then
				guiSetEnabled ( btnLukk, true )
				guiSetEnabled ( btnKindalaegas, true )
			end
			
			if tostring(getVehicleType(element)) == "Bike" or tostring(getVehicleType(element)) == "Quad" then
				guiSetVisible ( btnPagasnik, false )
				guiSetVisible ( btnLukk, false )
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), carclick, true)

function CarMenuSulge(button, state)

	if button == "left" then
	
		guiSetVisible(CarMenu, false)
		showCursor(false)
		triggerServerEvent("kustuta", getRootElement())
		veh = nil
		
	end
	
end

function CarMenuAlarm(button, state)
	if button == "left" then
		local x, y, z = getElementPosition(veh)
		if tonumber(getElementData(veh, "vAlarm")) == 0 then
			playSound3D("files/sounds/alarmkinni.wav", x, y, z, false)
			triggerServerEvent("alarmOn", getRootElement(), veh)
			CarMenuSulge(button, state)
		else
			playSound3D("files/sounds/alarmlahti.wav", x, y, z, false)
			triggerServerEvent("alarmOff", getRootElement(), veh)
			CarMenuSulge(button, state)
		end
	end
end

function CarMenuLukk(button, state)
	if button == "left" then
		triggerServerEvent("CarMenuLock", getRootElement(), veh)
		CarMenuSulge(button, state)
	end
end

function alarmactivated(vx, vy, vz)
	alarmon = playSound3D("files/sounds/alarmon.wav", vx, vy, vz, true)
	setSoundMaxDistance(alarmon, 20)
	setTimer(stopalarm, 30000, 1)
end
addEvent( "alarmactivated", true )
addEventHandler( "alarmactivated", getRootElement(), alarmactivated )

function stopalarm()
	stopSound( alarmon )
end

function CarMenuTulekul(button, state)
	if button == "left" then
		CarMenuSulge(button, state)
		outputChatBox("Tulekul", source)
	end
end

