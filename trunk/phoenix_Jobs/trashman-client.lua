_player = getLocalPlayer()trashCanCreated = niltrashBlip = niltrashMarker, trashMarker2 = nil, niljunkYardMarker = niljunkYardBlip = niltrashCan = niltrashVeh = nilclickedTrashCan = niltrash = niljunkYardPos = {2105.7397460938, -2008.8702392578, 13.546875} --Muuta hiljem Angel Pine oma vastu?function createTrashcan()	local playerJob = getElementData(_player, "Character.playerJob")	local trashCans = getElementsByType("trashcan")	local vehModel = nil	trashVeh = getPedOccupiedVehicle(_player)			if isPedInVehicle(_player) then vehModel = getElementModel(trashVeh) end			if vehModel == 408 and tonumber(playerJob) == 1 then			trash = getElementData(trashVeh, "trashAmount");				if( trash == false ) then 					setElementData( trashVeh, "trashAmount", "0" );			trash = 0;					end						if tonumber(trash) < 100 then			if not trashCanCreated then							if #trashCans > 0 then 									local randTrashCan = trashCans[math.random(#trashCans)]					local model = getElementData(randTrashCan, "model")					local posX = getElementData(randTrashCan, "posX")					local posY = getElementData(randTrashCan, "posY")					local posZ = getElementData(randTrashCan, "posZ")					local rotX = getElementData(randTrashCan, "rotX")					local rotY = getElementData(randTrashCan, "rotY")					local rotZ = getElementData(randTrashCan, "rotZ")										if model and posX and posY and posZ and rotX and rotY and rotZ then											trashCan = createObject(model, posX, posY, posZ, rotX, rotY, rotZ)						--posZ = getGroundPosition(posX, posY, posZ)						trashMarker = createMarker(posX, posY, posZ, "cylinder", 1.5, 102, 255, 153)						trashBlip = createBlip(posX, posY, posZ, 0, 2, 102, 255, 153)												if trashCan and trashMarker and trashBlip then													executeCommandHandler( "me", "kasutab pr�giauto GPS-i")							outputChatBox("Pr�gikast on m�rgitud pr�giauto GPS-ile.")							trashCanCreated = true													end											end										end							else							outputChatBox("((Pr�gikast on juba m�rgitud kaardile))")					end						else						if not junkYardMarker and not junkYardBlip then							junkYard()						else							outputChatBox("((Pr�giauto on t�is, k�i esmalt pr�gim�el.))")						end					end				else			outputChatBox("((Sa ei ole pr�giautos v�i sa pole pr�givedaja.))", 255, 0, 0)			end		endaddCommandHandler("pr�gi", createTrashcan, false)addEventHandler("onClientMarkerHit", getRootElement(),	function()				if source == trashMarker then						if not isPedInVehicle(_player) then							destroyElement(trashMarker)				destroyElement(trashBlip)				trashMarker = nil				trashBlip = nil				showCursor(true)				setPedFrozen(_player, true)				outputChatBox("((Parem hiirekl�ps pr�gikastil.))")				--attachElements(trashCan, _player, 0.8, 0.8)  --Midagi sellist tulevikus vb						else							outputChatBox("((Sa pead olema pr�giautost v�ljas.))")					end					elseif source == trashMarker2 then			destroyElement(trashMarker2)			trashMarker2 = nil			executeCommandHandler( "me", "hakkab pr�gi pr�giautosse t�stma")			outputChatBox("((Palun oota kuni tegevus on l�ppenud.))")						toggleAllControls(false)			setPedFrozen(_player, true)								setTimer(								function()										executeCommandHandler( "me", "paneb kogu pr�gi pr�giautosse")					outputChatBox("((Pr�gi autosse t�stetud.))")										destroyElement(trashCan)					trashCan = nil										toggleAllControls(true)					setPedFrozen(_player, false)										showCursor(false)					trashCanCreated = false																local trash = getElementData(trashVeh, "trashAmount")										if tonumber(trash) >= 100 then											setElementData(trashVeh, "trashAmount", "100")						junkYard()											else											trash = tonumber(trash) + 55 --Hiljem muuta						setElementData(trashVeh, "trashAmount", tostring(trash))														end									end								,5000, 1) --Hiljem muuta					elseif source == junkYardMarker then					trashVeh = getPedOccupiedVehicle(_player)			if isPedInVehicle(_player) then vehModel = getElementModel(trashVeh) end			if vehModel == 408 then							trash = getElementData(trashVeh, "trashAmount")												if tonumber(trash) >= 100 then									destroyElement(junkYardMarker)					destroyElement(junkYardBlip)					junkYardMarker = nil					junkYardBlip = nil										executeCommandHandler( "me", "vajutab nuppu ja pr�giauto hakkab pr�gi maha laadima")					outputChatBox("((Palun oota, pr�gi maha laadimine.))")					setVehicleFrozen(trashVeh, true)										setTimer(											function()									trashCanCreated = false														setVehicleFrozen(trashVeh, false)														setElementData(trashVeh, "trashAmount", "0")														--Hiljem raha lisamine siia ka, palgatsekiile vms														outputChatBox("((Pr�gi maha laetud.))")																		end														,10000, 1)	--Hiljem muuta									else									trashCanCreated = false					setVehicleFrozen(trashVeh, false)					outputChatBox("((Pr�giautos pole piisavalt pr�gi.))")									end							else								outputChatBox("((Sa pead olema pr�giautos.))")						end					end					end)addEventHandler("onClientClick", getRootElement(),	function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)				if button == "right" and state == "up" and clickedElement == trashCan and not clickedTrashCan then						local posx1, posy1, posz1 = getElementPosition(trashCan)			local posx2, posy2, posz2 = getElementPosition(_player)			local dist = getDistanceBetweenPoints3D(posx1, posy1, posz1, posx2, posy2, posz2)			if dist <= 2.0 then								executeCommandHandler( "me", "hakkab pr�gikastist pr�gi v�lja v�tma")				outputChatBox("((Palun oota kuni tegevus on l�ppenud.))")								clickedTrashCan = true								setTimer(									function()											executeCommandHandler( "me", "v�tab pr�gikastist pr�gi v�lja")						outputChatBox("((Pr�gi v�lja v�etud, vii pr�gi auto taha.))")												clickedTrashCan = false						toggleAllControls(true)								setPedFrozen(_player, false)							trashCanEmty()						showCursor(false)											end									,5000, 1) --Hiljem muuta							else								outputChatBox("((Sa pole pr�gikasti l�heduses.))")						end					end			end	)function trashCanEmty()	if trashVeh then			local x, y, z = getElementPosition(trashVeh)		local rx, ry, rz = getElementRotation(trashVeh)				x = x + (3.9 * (math.sin(math.rad(-rz-180))))		y = y + (3.9 * (math.cos(math.rad(-rz-180))))				local z = getGroundPosition(x, y, z)				trashMarker2 = createMarker(x, y, z, "cylinder", 1.0, 102, 255, 153)			end	endfunction junkYard()outputChatBox("Pr�giauto on t�is, pr�gim�gi m�rgitud GPS-ile.")--junkYardPos[3] = getGroundPosition(junkYardPos[1], junkYardPos[2], junkYardPos[3])junkYardMarker = createMarker(junkYardPos[1], junkYardPos[2], junkYardPos[3], "cylinder", 8.0, 102, 255, 153)junkYardBlip = createBlip(junkYardPos[1], junkYardPos[2], junkYardPos[3], 0, 2, 102, 255, 153)end