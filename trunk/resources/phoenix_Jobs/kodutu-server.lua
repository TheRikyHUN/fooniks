foundBottle = { 5, 10, 25 }
foundFood = {"pirni", "�una", "kanakoiva"}

function onKodutuSuccess()
	if client then
	local midasai = math.random(1,3)
		
		if midasai == 1 then
			suvapudel = math.random ( 1, #foundBottle )
			outputChatBox("Leidsid pr�gikastist pudeli, millel on taaram�rgistus " ..foundBottle[suvapudel].. "'le SAKile", client, 0, 255, 255)
		elseif midasai == 2 then
			suvatoit = math.random ( 1, #foundFood )
			setElementHealth(client, getElementHealth(client)+math.random(5,50))
			outputChatBox("Leidsid pr�gikastist " ..foundFood[suvatoit].. " ning s�id selle �ra.", client, 0, 255, 255)
		elseif midasai == 3 then
			outputChatBox("Leidsid pr�gikastist kasutatud kondoomi ja p�hkisid k�ed p�kste k�lge", client, 0, 255, 255)
		end
	end
end
addEvent("onKodutuSuccess", true)
addEventHandler( "onKodutuSuccess", getRootElement(), onKodutuSuccess, true)