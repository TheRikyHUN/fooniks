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
*    This File: phoenix_NewsPaper.inc
*    Purpose: Create a good-looking newspaper.
*/

#if !defined _phoenix_included
	#error "Phoenix ERROR #1, You need phoenix base for this gamemode to run!"
	#endinput
#endif

/*
	STAT Calculating querys: 
		stat1 = 
			SELECT SUM( money )  FROM `ph_characters`
		stat2 = 
			SELECT COUNT( * )  FROM `ph_characters`  WHERE UNIX_TIMESTAMP( ) - UNIX_TIMESTAMP( `regDate` ) < 86400
		stat3 = 
			SELECT id FROM `ph_characters`  ORDER BY UNIX_TIMESTAMP( regDate ) ASC LIMIT 1
		stat4 = 
		
*/

/*
*    DEFINES
*/

#define NEWSPAPERBACK 0x000000AA

#define FRONT_PAGE 0

#define MAX_NEWSPAPERS 10

/*
*    GLOBALS
*/

new paperActive[MAX_PLAYERS];
new paperDrawActive[MAX_PLAYERS];
new currentPage[MAX_PLAYERS];

enum newsDrawInf
{
	Text: Text0,
	Text: Text1,
	Text: Text2,
	Text: Text3,
	Text: Text4,
	Text: Text5,
	Text: Text6,
	bool: used,
	textId
};
new NewsDraw[50][newsDrawInf];

enum newsInf
{
	headLine[32],
	article1[256],
	article2[256],
	article3[256],
	article4[256],
	stat1,
	stat2,
	stat3,
	stat4,
	add1[256],
	add2[256],
	add3[256],
	add4[256],
	bool: paperUsed,
	sqlId
};
new NewsPapers[MAX_NEWSPAPERS][newsInf];

enum writeInf
{
	bool: isWriting,
	writerId,
	writingStatus,
	headline[32],
	article1[256],
	article2[256],
	article3[256],
	article4[256],	
	add1[256],
	add2[256],
	add3[256],
	add4[256]	
};
new PaperWriter[writeInf] = {false, -1, 0, "_", "_", "_", "_", "_", "_", "_", "_", "_"};
/*
new JobAds[3][jAddInf] =
{
	{"Pr�givedaja", }
};*/

/*
*    FORWARDS
*/

forward ShowNewsPaper(playerid, paperid);
forward HideNewsPaper(playerid, page);
forward CreatePaperDraw(paperid);
forward LoadNewsPapers();
forward WritePaper(playerid);
forward AddNewsPaper(head_line[], block_1[], block_2[], block_3[], block_4[], add_1[], add_2[], add_3[], add_4[]);

/*
*    ALS Next Ones
*/
forward NewsPaper_OnGameModeInit();
forward NP_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
forward NP_OnPlayerConnect(playerid);
forward NP_OnPlayerDisconnect(playerid);
forward NP_OnPlayerText(playerid, text[]);

/*
*    STOCKS
*/

stock findFreePaperDraw()
{
	for(new i = 0; i < 50; i++)
	{
		if(!NewsDraw[i][used])
		{
			return i;
		}
	}
	return -1;
}

/*
*    PUBLICS
*/
 
public ShowNewsPaper(playerid, paperid)
{
	if(paperid < 0 || paperid > MAX_NEWSPAPERS) return 1;
	if(!NewsPapers[paperid][paperUsed]) return 2;
	
	if(paperDrawActive[playerid] > -1)
	{
		HideNewsPaper(playerid, false);
	}
	else
	{
		// Just opened!
		SmallHelpDrawShow(playerid, "~b~Ajaleht.~n~~g~Liikumiseks kasuta: ~n~~<~ ~w~~k~~VEHICLE_TURRETLEFT~~n~~>~ ~w~~k~~VEHICLE_TURRETRIGHT~~n~~r~Sulgemiseks: ~n~~w~~k~~VEHICLE_ENTER_EXIT~", 10000);
	}
	
	new i = findFreePaperDraw();
	if(i != -1)
	{
		if(currentPage[playerid] < 0) currentPage[playerid] = 0;
		if(currentPage[playerid] > 3) currentPage[playerid] = 3;
		
		if(currentPage[playerid] == 0)
		{
			TextDrawSetString(NewsDraw[i][Text1], NewsPapers[paperid][headLine]);
			TextDrawSetString(NewsDraw[i][Text2], "1 / 4");
			
			TextDrawSetString(NewsDraw[i][Text3], NewsPapers[paperid][article1]);
			TextDrawSetString(NewsDraw[i][Text4], NewsPapers[paperid][article2]);
			TextDrawSetString(NewsDraw[i][Text5], NewsPapers[paperid][article3]);
			TextDrawSetString(NewsDraw[i][Text6], NewsPapers[paperid][article4]);
		}
		else if(currentPage[playerid] == 1)
		{
			TextDrawSetString(NewsDraw[i][Text1], "F88niks Numbrites");
			TextDrawSetString(NewsDraw[i][Text2], "2 / 4");
			
			new string[150];
			format(string, 150, "~b~Majandus~n~~n~~g~Sularaha: ~w~%d~n~~g~Pangas: ~w~x~n~~g~Kinnisvaraturul: ~w~x~n~~g~Autoturul: ~w~x~n~~g~Arimaailmas: ~w~x", NewsPapers[i][stat1]);
			TextDrawSetString(NewsDraw[i][Text3], string);

			format(string, 128, "~b~Sotsiaalelu~n~~n~~g~Syndide Arv: ~w~%d~n~~g~Vanim isik: ~w~%s", NewsPapers[i][stat2], GetCharacterName(NewsPapers[i][stat3]));
			TextDrawSetString(NewsDraw[i][Text4], string);

			format(string, 128, "~b~Kuritegevus~n~~n~M6rvu: x~n~Varguseid: x~n~2Randamisi: x~n~Trahvide arv: x");
			TextDrawSetString(NewsDraw[i][Text5], string);
			
			format(string, 100, "Infot vahendab Riigi Statistikaamet.~n~Kontaktisik: Martin_Mets~n~53934751~n~Linnavalitsus: ~n~113");
			TextDrawSetString(NewsDraw[i][Text6], string);
		}
		else if(currentPage[playerid] == 2)
		{
			TextDrawSetString(NewsDraw[i][Text1], "T88kuulutused");
			TextDrawSetString(NewsDraw[i][Text2], "3 / 4");
			
			TextDrawSetString(NewsDraw[i][Text3], " ");
			TextDrawSetString(NewsDraw[i][Text4], " ");
			TextDrawSetString(NewsDraw[i][Text5], " ");
			TextDrawSetString(NewsDraw[i][Text6], " ");
		}
		else if(currentPage[playerid] == 3)
		{
			TextDrawSetString(NewsDraw[i][Text1], "Kuulutused");
			TextDrawSetString(NewsDraw[i][Text2], "4 / 4");
			
			TextDrawSetString(NewsDraw[i][Text3], NewsPapers[paperid][add1]);
			TextDrawSetString(NewsDraw[i][Text4], NewsPapers[paperid][add2]);
			TextDrawSetString(NewsDraw[i][Text5], NewsPapers[paperid][add3]);
			TextDrawSetString(NewsDraw[i][Text6], NewsPapers[paperid][add4]);
		}
		
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text0]); // Taust
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text1]); // Pealkiri
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text2]); // Lehenumber
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text3]); // Block 1
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text4]); // Block 2
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text5]); // Block 3
		TextDrawShowForPlayer(playerid, NewsDraw[i][Text6]); // Block 4
		NewsDraw[i][used] = true;
		paperActive[playerid] = paperid;
		paperDrawActive[playerid] = i;
		TogglePlayerControllableEx(playerid, 0, -1);
		return 0;
	}
	return 4;
}

public HideNewsPaper(playerid, page)
{
	new i = paperDrawActive[playerid];
	if(i == -1) return 1;	
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text0]); // Taust
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text1]); // Pealkiri
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text2]); // Lehenumber
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text3]); // Block 1
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text4]); // Block 2
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text5]); // Block 3
	TextDrawHideForPlayer(playerid, NewsDraw[i][Text6]); // Block 4
	NewsDraw[i][used] = false;
	paperDrawActive[playerid] = -1;
	if(page) currentPage[playerid] = 0;
	TogglePlayerControllableEx(playerid, 1, -1);
	return 0;	
}

public CreatePaperDraw(paperid)
{
	NewsDraw[paperid][Text0] = TextDrawCreate(44, 86, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawUseBox(NewsDraw[paperid][Text0], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text0], NEWSPAPERBACK);
	TextDrawFont(NewsDraw[paperid][Text0], 2);
	TextDrawTextSize(NewsDraw[paperid][Text0], 492, 308.0);
	
	NewsDraw[paperid][Text1] = TextDrawCreate(52, 90, " ");
	TextDrawFont(NewsDraw[paperid][Text1], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text1], 0.499999, 1.300000);
	TextDrawSetProportional(NewsDraw[paperid][Text1], true);
	
	NewsDraw[paperid][Text2] = TextDrawCreate(452, 290.0, "1 / 4");
	TextDrawFont(NewsDraw[paperid][Text2], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text2], 0.299999, 1.100000);
	TextDrawSetProportional(NewsDraw[paperid][Text2], true);	
	
	NewsDraw[paperid][Text3] = TextDrawCreate(72, 128, "~b~Lorem ipsum~n~~n~~w~Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.");
	TextDrawTextSize(NewsDraw[paperid][Text3], 260, 300);
	TextDrawUseBox(NewsDraw[paperid][Text3], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text3], NEWSPAPERBACK);	
	TextDrawFont(NewsDraw[paperid][Text3], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text3], 0.199999, 0.900000);
	TextDrawSetProportional(NewsDraw[paperid][Text3], true);	
	
	NewsDraw[paperid][Text4] = TextDrawCreate(72, 210, "~b~Lorem ipsum~n~~n~~w~Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.");
	TextDrawTextSize(NewsDraw[paperid][Text4], 260, 300);
	TextDrawUseBox(NewsDraw[paperid][Text4], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text4], NEWSPAPERBACK);	
	TextDrawFont(NewsDraw[paperid][Text4], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text4], 0.199999, 0.900000);
	TextDrawSetProportional(NewsDraw[paperid][Text4], true);	
	
	NewsDraw[paperid][Text5] = TextDrawCreate(270, 128, "~b~Lorem ipsum~n~~n~~w~Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.");
	TextDrawTextSize(NewsDraw[paperid][Text5], 458, 300);
	TextDrawUseBox(NewsDraw[paperid][Text5], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text5], NEWSPAPERBACK);	
	TextDrawFont(NewsDraw[paperid][Text5], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text5], 0.199999, 0.900000);
	TextDrawSetProportional(NewsDraw[paperid][Text5], true);	
	
	NewsDraw[paperid][Text6] = TextDrawCreate(270, 210, "~b~Lorem ipsum~n~~n~~w~Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt.");
	TextDrawTextSize(NewsDraw[paperid][Text6], 458, 300);
	TextDrawUseBox(NewsDraw[paperid][Text6], 1);
	TextDrawBoxColor(NewsDraw[paperid][Text6], NEWSPAPERBACK);	
	TextDrawFont(NewsDraw[paperid][Text6], 2);
	TextDrawLetterSize(NewsDraw[paperid][Text6], 0.199999, 0.900000);
	TextDrawSetProportional(NewsDraw[paperid][Text6], true);
}

public LoadNewsPapers()
{
	new string[64];
	format(string, 64, "SELECT * FROM %sNewsPaper ORDER BY id ASC LIMIT %d", MYSQL_PREFIX, MAX_NEWSPAPERS-1);
	
	mysql_query(string);
	mysql_store_result();
	
	new Field[260], Data[1024], numRows = mysql_num_rows();
	for(new nId = 0; nId < numRows; nId++)
	{
		if(!mysql_fetch_row_format(Data, " ")) continue;
		
		mysql_fetch_field_row(Field, "id");
		NewsPapers[nId][sqlId] = strval(Field);
		
		mysql_fetch_field_row(Field, "headLine");
		format(NewsPapers[nId][headLine], 32, "%s", Field);
		
		mysql_fetch_field_row(Field, "Block1");
		format(NewsPapers[nId][article1], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Block2");
		format(NewsPapers[nId][article2], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Block3");
		format(NewsPapers[nId][article3], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Block4");
		format(NewsPapers[nId][article4], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Add1");
		format(NewsPapers[nId][add1], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Add2");
		format(NewsPapers[nId][add2], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Add3");
		format(NewsPapers[nId][add3], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "Add4");
		format(NewsPapers[nId][add4], 256, "%s", Field);
		
		mysql_fetch_field_row(Field, "stat1");
		NewsPapers[nId][stat1] = strval(Field);
		
		mysql_fetch_field_row(Field, "stat2");
		NewsPapers[nId][stat2] = strval(Field);
		
		mysql_fetch_field_row(Field, "stat3");
		NewsPapers[nId][stat3] = strval(Field);
		
		mysql_fetch_field_row(Field, "stat4");
		NewsPapers[nId][stat4] = strval(Field);
		
		#if defined PH_DEBUG
		printf("\n NewsStats: %d, %d, %d, %d, \n", NewsPapers[nId][stat1], NewsPapers[nId][stat2], NewsPapers[nId][stat3], NewsPapers[nId][stat4]);
		#endif
		
		NewsPapers[nId][paperUsed] = true;
	}
	mysql_free_result();
}

public WritePaper(playerid)
{
	if(PaperWriter[isWriting])
	{
		return 0;
	}
	
	PaperWriter[isWriting] = true;
	PaperWriter[writerId] = playerid;
	PaperWriter[writingStatus] = 0;	
	return 1;
}

public AddNewsPaper(head_line[], block_1[], block_2[], block_3[], block_4[], add_1[], add_2[], add_3[], add_4[])
{
	mysql_real_escape_string(head_line, head_line);
	mysql_real_escape_string(block_1, block_1);
	mysql_real_escape_string(block_2, block_2);
	mysql_real_escape_string(block_3, block_3);
	mysql_real_escape_string(block_4, block_4);
	
	mysql_real_escape_string(add_1, add_1);
	mysql_real_escape_string(add_2, add_2);
	mysql_real_escape_string(add_3, add_3);
	mysql_real_escape_string(add_4, add_4);

	new string[1024];
	
	// Insert some stuff.
	format(string, 1024, "INSERT INTO %sNewsPaper(id, headLine, Block1, Block2, Block3) VALUES(NULL, '%s', '%s', '%s', '%s')", MYSQL_PREFIX, head_line, block_1, block_2, block_3);
	if(mysql_query(string))
	{	
		// Get The Added ID.
		new tempSqlID = mysql_insert_id();
		
		// Set The aditional values.
		format(string, 1024, "UPDATE %sNewsPaper SET Block4 = '%s', Add1 = '%s', Add2 = '%s' WHERE id = '%d'", MYSQL_PREFIX, block_4, add_1, add_2, tempSqlID);
		mysql_query(string);
		
		format(string, 768, "UPDATE %sNewsPaper SET Add3 = '%s', Add4 = '%s' WHERE id = '%d'", MYSQL_PREFIX, add_3, add_4, tempSqlID);
		mysql_query(string);
		
		// Get The stats from stat querys.
		format(string, 64, "SELECT SUM( money )  FROM `%scharacters`", MYSQL_PREFIX);
		mysql_query(string);
		mysql_store_result();
		new stat_1 = mysql_fetch_int();
		mysql_free_result();
		
		format(string, 128, "SELECT COUNT( * )  FROM `%scharacters`  WHERE UNIX_TIMESTAMP( ) - UNIX_TIMESTAMP( `regDate` ) < 166400", MYSQL_PREFIX);
		mysql_query(string);
		mysql_store_result();
		new stat_2 = mysql_fetch_int();
		mysql_free_result();
		
		format(string, 90, "SELECT id FROM `%scharacters`  ORDER BY UNIX_TIMESTAMP( regDate ) ASC LIMIT 1", MYSQL_PREFIX);
		mysql_query(string);
		mysql_store_result();
		new stat_3 = mysql_fetch_int();
		mysql_free_result();
		
		format(string, 128, "UPDATE %sNewsPaper SET stat1 = '%d', stat2 = '%d', stat3 = '%d' WHERE id = '%d'", MYSQL_PREFIX, stat_1, stat_2, stat_3, tempSqlID);
		mysql_query(string);
		
		LoadNewsPapers();
		return 1;
	}
	return 0;
}

/*
*    Silent Implentation
*/

public OnGameModeInit()
{
	for(new i = 0; i < 50; i++)
	{
		CreatePaperDraw(i);
	}
	
	foreach(Player, i)
	{
		paperDrawActive[i] = -1;
	}
	
	LoadNewsPapers();
	
    if (funcidx("NewsPaper_OnGameModeInit") != -1)
    {
        return CallLocalFunction("NewsPaper_OnGameModeInit", "");
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(paperActive[playerid] > -1)
	{
		if(PRESSED(KEY_ANALOG_LEFT)) currentPage[playerid]--;
		else if(PRESSED(KEY_ANALOG_RIGHT)) currentPage[playerid]++;
		else if(PRESSED(KEY_SECONDARY_ATTACK))
		{
			HideNewsPaper(playerid, true);
			goto wrong_key;
		}
		else
		{
			goto wrong_key;
		}
		currentPage[playerid] = (currentPage[playerid] > 3)?0:currentPage[playerid];
		currentPage[playerid] = (currentPage[playerid] < 0)?3:currentPage[playerid];
		ShowNewsPaper(playerid, paperActive[playerid]);
	}
	wrong_key:
    if (funcidx("NP_OnPlayerKeyStateChange") != -1)
    {
        return CallLocalFunction("NP_OnPlayerKeyStateChange", "iii", playerid, newkeys, oldkeys);
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
	HideNewsPaper(playerid, true);
	paperActive[playerid] = -1;
	
    if (funcidx("NP_OnPlayerConnect") != -1)
    {
        return CallLocalFunction("NP_OnPlayerConnect", "i", playerid);
    }
    return 1;
}

public OnPlayerDisconnect(playerid)
{
	HideNewsPaper(playerid, true);
	paperActive[playerid] = -1;
	
	if(PaperWriter[isWriting] && PaperWriter[writerId] == playerid)
	{
		PaperWriter[isWriting] = false;
		PaperWriter[writerId] = -1;
		format(PaperWriter[article1], 32, "_");
		format(PaperWriter[article2], 32, "_");
		format(PaperWriter[article3], 32, "_");
		format(PaperWriter[article4], 32, "_");
	}
	
    if (funcidx("NP_OnPlayerDisconnect") != -1)
    {
        return CallLocalFunction("NP_OnPlayerDisconnect", "i", playerid);
    }
    return 1;
}

public OnPlayerText(playerid, text[])
{
	if(PaperWriter[isWriting] && PaperWriter[writerId] == playerid)
	{
		new txtLen = strlen(text);

		if(!strcmp("edasi", text, true, strlen("edasi")))
		{
			if(PaperWriter[writingStatus] == 0)
			{
				SendClientMessage(playerid, COLOR_RED, LANG_MUST_WRITE_HEADLINE);
				return 0;
			}
			PaperWriter[writingStatus]++;
			SendClientMessage(playerid, COLOR_GREEN, LANG_SKIP_ARTICLE);
			SendFormattedText(playerid, COLOR_GREEN, LANG_WRITE_ARTICLE, PaperWriter[writingStatus]);
			if(PaperWriter[writingStatus] < 5) return 0;
		}
		
		if(PaperWriter[writingStatus] == 0)
		{
			format(PaperWriter[headline], 32, "%s", text);
			if(txtLen > 32)
			{
				SendClientMessage(playerid, COLOR_RED, LANG_WARNING_TURNCATE);
			}
			SendClientMessage(playerid, COLOR_GREEN, LANG_SHOW_HEADLINE);
			SendClientMessage(playerid, COLOR_GREEN, PaperWriter[headline]);
			PaperWriter[writingStatus]++;
			SendFormattedText(playerid, COLOR_GREEN, LANG_WRITE_ARTICLE, PaperWriter[writingStatus]);
		}
		else if(PaperWriter[writingStatus] == 1)
		{
			if(strlen(PaperWriter[article1]) == 1)
			{
				format(PaperWriter[article1], 250, "%s", text);
			}
			else
			{
				format(PaperWriter[article1], 250, "%s%s", PaperWriter[article1], text);
			}
			
			if(txtLen > 250)
			{
				SendClientMessage(playerid, COLOR_RED, LANG_WARNING_TURNCATE);
				SendClientMessage(playerid, COLOR_GREEN, LANG_SHOW_ARTICLE);
				SendClientMessage(playerid, COLOR_GREEN, PaperWriter[article1]);
				PaperWriter[writingStatus]++;
				SendFormattedText(playerid, COLOR_GREEN, LANG_WRITE_ARTICLE, PaperWriter[writingStatus]+1);
			}
			else
			{
				new leftChars = 250 - txtLen;
				SendFormattedText(playerid, COLOR_YELLOW, "Teade: Sellese l�iku mahub veel %d t�hem�rki.", leftChars);
				SendClientMessage(playerid, COLOR_YELLOW, "Kirjuta: \"edasi\", et j�rgmisesse l�iku kirjutada.");
			}
		}
		else if(PaperWriter[writingStatus] == 2)
		{
			if(strlen(PaperWriter[article2]) == 1)
			{
				format(PaperWriter[article2], 250, "%s", text);
			}
			else
			{
				format(PaperWriter[article2], 250, "%s%s", PaperWriter[article2], text);
			}
			
			if(txtLen > 250)
			{
				SendClientMessage(playerid, COLOR_RED, LANG_WARNING_TURNCATE);
				SendClientMessage(playerid, COLOR_GREEN, LANG_SHOW_ARTICLE);
				SendClientMessage(playerid, COLOR_GREEN, PaperWriter[article2]);
				PaperWriter[writingStatus]++;
				SendFormattedText(playerid, COLOR_GREEN, LANG_WRITE_ARTICLE, PaperWriter[writingStatus]);
			}
			else
			{
				new leftChars = 250 - txtLen;
				SendFormattedText(playerid, COLOR_YELLOW, "Teade: Sellese l�iku mahub veel %d t�hem�rki.", leftChars);
				SendClientMessage(playerid, COLOR_YELLOW, "Kirjuta: \"edasi\", et j�rgmisesse l�iku kirjutada.");
			}
		}
		else if(PaperWriter[writingStatus] == 3)
		{
			if(strlen(PaperWriter[article3]) == 1)
			{
				format(PaperWriter[article3], 250, "%s", text);
			}
			else
			{
				format(PaperWriter[article3], 250, "%s%s", PaperWriter[article3], text);
			}
			
			if(txtLen > 250)
			{
				SendClientMessage(playerid, COLOR_RED, LANG_WARNING_TURNCATE);
				SendClientMessage(playerid, COLOR_GREEN, LANG_SHOW_ARTICLE);
				SendClientMessage(playerid, COLOR_GREEN, PaperWriter[article3]);
				PaperWriter[writingStatus]++;
				SendFormattedText(playerid, COLOR_GREEN, LANG_WRITE_ARTICLE, PaperWriter[writingStatus]);
			}
			else
			{
				new leftChars = 250 - txtLen;
				SendFormattedText(playerid, COLOR_YELLOW, "Teade: Sellese l�iku mahub veel %d t�hem�rki.", leftChars);
				SendClientMessage(playerid, COLOR_YELLOW, "Kirjuta: \"edasi\", et j�rgmisesse l�iku kirjutada.");
			}
		}
		else if(PaperWriter[writingStatus] == 4)
		{
			if(strlen(PaperWriter[article4]) == 1)
			{
				format(PaperWriter[article4], 250, "%s", text);
			}
			else
			{
				format(PaperWriter[article4], 250, "%s%s", PaperWriter[article4], text);
			}
			
			if(txtLen > 250)
			{
				SendClientMessage(playerid, COLOR_RED, LANG_WARNING_TURNCATE);
				SendClientMessage(playerid, COLOR_GREEN, LANG_SHOW_ARTICLE);
				SendClientMessage(playerid, COLOR_GREEN, PaperWriter[article4]);
				PaperWriter[writingStatus]++;
			}
			else
			{
				new leftChars = 250 - txtLen;
				SendFormattedText(playerid, COLOR_YELLOW, "Teade: Sellese l�iku mahub veel %d t�hem�rki.", leftChars);
				SendClientMessage(playerid, COLOR_YELLOW, "Kirjuta: \"edasi\", et j�rgmisesse l�iku kirjutada.");
			}
		}
		if(PaperWriter[writingStatus] > 4)
		{			
			AddNewsPaper(PaperWriter[headline], PaperWriter[article1], PaperWriter[article2], PaperWriter[article3], PaperWriter[article4], "_", "_", "_", "_");
			SendClientMessage(playerid, COLOR_YELLOW, "TEHTUD!");
			
			PaperWriter[isWriting] = false;
			PaperWriter[writerId] = -1;
			format(PaperWriter[article1], 32, "_");
			format(PaperWriter[article2], 32, "_");
			format(PaperWriter[article3], 32, "_");
			format(PaperWriter[article4], 32, "_");
		}
		
		return 0;
	}
	
    if (funcidx("NP_OnPlayerText") != -1)
    {
        return CallLocalFunction("NP_OnPlayerText", "is", playerid, text);
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit NewsPaper_OnGameModeInit

#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange NP_OnPlayerKeyStateChange

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect NP_OnPlayerConnect

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect NP_OnPlayerDisconnect

#if defined _ALS_OnPlayerText
    #undef OnPlayerText
#else
    #define _ALS_OnPlayerText
#endif
#define OnPlayerText NP_OnPlayerText