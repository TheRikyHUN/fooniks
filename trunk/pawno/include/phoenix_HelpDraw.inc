/*
*    The contents of this file are subject to the Mozilla Public License
*    Version 1.1 (the "License"); you may not use this file except in
*    compliance with the License. You may obtain a copy of the License at
*    http://www.mozilla.org/MPL/
*    
*    Software distributed under the License is distributed on an "AS IS"
*    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*    License for the specific language governing rights and limitations
*    under the License.
*    
*    The Original Code is Phoenix.
*    The Initial Developers of the Original Code are Jyrno42 and 13th.
*/

/*
*    This File: phoenix_HelpDraw.inc
*    Purpose: This is for easy streamed help textdraw creation.
*/

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

#define MAX_HELPDRAWS 32
#define HELPBOX_BACK 0x000000AA

Itter_Create(HelpDraw, MAX_HELPDRAWS);

enum helpInf
{
	Float: helpX,
	Float: helpY,
	Float: helpZ,
	Text: helpTextDraw,
	Text: helpTextDraw2
};
new HelpDraws[MAX_HELPDRAWS][helpInf];
new usedHelpDraws = 0;
new isHelpActive[MAX_PLAYERS];

enum smallInf
{
	bool: inUse,
	Text: smDraw
};
new SmallHelpDraw[32][smallInf];
new gPlayerSmDraw[MAX_PLAYERS] = {-1, ...};

forward AddHelpDraw(Float: x, Float: y, Float: z, header[], text[]);
forward HelpDrawTimer();
forward HelpDrawShow(playerid, drawId);
forward HelpDrawHide(playerid, drawId);
forward SmallHelpDrawShow(playerid, helpText[], timer);
forward SmallHelpDrawHide(playerid);
forward HelpDraw_OnGameModeInit();
forward HelpDraw_OnPlayerConnect(playerid);
forward HelpDraw_OnPlayerDisconnect(playerid);

public AddHelpDraw(Float: x, Float: y, Float: z, header[], text[])
{
	if(usedHelpDraws >= MAX_HELPDRAWS) return -1;
	
	HelpDraws[usedHelpDraws][helpX] = x;
	HelpDraws[usedHelpDraws][helpY] = y;
	HelpDraws[usedHelpDraws][helpZ] = z;
	
	new string[128];
	
	format(string, 128, "~b~ %s", header);
	
	HelpDraws[usedHelpDraws][helpTextDraw] = TextDrawCreate(25, 150, string);
	TextDrawUseBox(HelpDraws[usedHelpDraws][helpTextDraw], 1);
	TextDrawBoxColor(HelpDraws[usedHelpDraws][helpTextDraw], HELPBOX_BACK);
	TextDrawFont(HelpDraws[usedHelpDraws][helpTextDraw], 2);
	TextDrawTextSize(HelpDraws[usedHelpDraws][helpTextDraw], 150.0, 15.0);
	
	new iCount;	
	
	new i = 0, textsize = strlen(text);
	while(i < textsize)
	{
		str_ireplace(" ", "~n~", text, iCount, 1, i);
		i += 35;
	}
	
	format(string, 128, "~w~%s", text);
	
	HelpDraws[usedHelpDraws][helpTextDraw2] = TextDrawCreate(25, 165, string);
	TextDrawUseBox(HelpDraws[usedHelpDraws][helpTextDraw2], 1);
	TextDrawBoxColor(HelpDraws[usedHelpDraws][helpTextDraw2], HELPBOX_BACK);
	TextDrawFont(HelpDraws[usedHelpDraws][helpTextDraw2], 2);
	TextDrawLetterSize(HelpDraws[usedHelpDraws][helpTextDraw2], 0.299999,1.100000);
	TextDrawSetProportional(HelpDraws[usedHelpDraws][helpTextDraw2], true);
	TextDrawTextSize(HelpDraws[usedHelpDraws][helpTextDraw2], 200.0, 50.0);
	
	Itter_Add(HelpDraw, usedHelpDraws);	
	usedHelpDraws++;
	return usedHelpDraws-1;
}

public HelpDrawTimer()
{	
	foreach(Player, i)
	{
		foreach(HelpDraw, drawId)
		{
			if(IsPlayerInRangeOfPoint(i, 5.0, HelpDraws[drawId][helpX], HelpDraws[drawId][helpY], HelpDraws[drawId][helpZ]))
			{
				if(isHelpActive[i] != drawId)
				{
					HelpDrawShow(i, drawId);
				}
			}
			else if(isHelpActive[i] == drawId)
			{
				HelpDrawHide(i, drawId);
			}
		}
	}
}

public HelpDrawShow(playerid, drawId)
{
	if(isHelpActive[playerid] != -1) HelpDrawHide(playerid, drawId);
	TextDrawShowForPlayer(playerid, HelpDraws[drawId][helpTextDraw]);
	TextDrawShowForPlayer(playerid, HelpDraws[drawId][helpTextDraw2]);
	isHelpActive[playerid] = drawId;
}

public HelpDrawHide(playerid, drawId)
{
	TextDrawHideForPlayer(playerid, HelpDraws[drawId][helpTextDraw]);
	TextDrawHideForPlayer(playerid, HelpDraws[drawId][helpTextDraw2]);
	isHelpActive[playerid] = -1;
}

public SmallHelpDrawShow(playerid, helpText[], timer)
{
	if(gPlayerSmDraw[playerid] != -1) return 0;
	if(timer < 1000) timer = 1000;
	
	new foundId = -1;
	for(new i = 0; i < 32; i++)
	{
		if(!SmallHelpDraw[i][inUse])
		{
			foundId = i;
			break;
		}
	}
	if(foundId == -1) return 0;
	
	TextDrawSetString(SmallHelpDraw[foundId][smDraw], helpText);
	TextDrawShowForPlayer(playerid, SmallHelpDraw[foundId][smDraw]);
	SmallHelpDraw[foundId][inUse] = true;
	SetTimerEx("SmallHelpDrawHide", timer, 0, "i", playerid);
	gPlayerSmDraw[playerid] = foundId;
	return 1;
}

public SmallHelpDrawHide(playerid)
{
	if(gPlayerSmDraw[playerid] == -1) return 0;
	TextDrawHideForPlayer(playerid, SmallHelpDraw[gPlayerSmDraw[playerid]][smDraw]);
	SmallHelpDraw[gPlayerSmDraw[playerid]][inUse] = false;
	gPlayerSmDraw[playerid] = -1;
	return 1;
}

public OnGameModeInit()
{
	SetTimer("HelpDrawTimer", 3000, 1);
	
	for(new i = 0; i < 32; i++)
	{
		SmallHelpDraw[i][inUse] = false;
		SmallHelpDraw[i][smDraw] = TextDrawCreate(400, 336, " ");
		TextDrawUseBox(SmallHelpDraw[i][smDraw], 1);
		TextDrawBoxColor(SmallHelpDraw[i][smDraw], HELPBOX_BACK);
		TextDrawFont(SmallHelpDraw[i][smDraw], 2);
		TextDrawLetterSize(SmallHelpDraw[i][smDraw], 0.299999,1.100000);
		TextDrawSetProportional(SmallHelpDraw[i][smDraw], true);
		TextDrawTextSize(SmallHelpDraw[i][smDraw], 550.0, 450.0);
	}
	
    if (funcidx("HelpDraw_OnGameModeInit") != -1)
    {
        return CallLocalFunction("HelpDraw_OnGameModeInit", "");
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
	isHelpActive[playerid] = -1;
	SmallHelpDrawHide(playerid);
	
    if (funcidx("HelpDraw_OnPlayerConnect") != -1)
    {
        return CallLocalFunction("HelpDraw_OnPlayerConnect", "i", playerid);
    }
    return 1;
}

public OnPlayerDisconnect(playerid)
{
	isHelpActive[playerid] = -1;
	SmallHelpDrawHide(playerid);
	
    if (funcidx("HelpDraw_OnPlayerDisconnect") != -1)
    {
        return CallLocalFunction("HelpDraw_OnPlayerDisconnect", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit HelpDraw_OnGameModeInit

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect HelpDraw_OnPlayerConnect

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect HelpDraw_OnPlayerDisconnect