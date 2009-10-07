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
*    The Initial Developers of the Original Code are 13th and Jyrno42.
*/

/*
*    EXTERNAL CREDITS
*
*        External Credit #1 - Simon, IsValidSkin
*        External Credit #2 - Alex "Y_Less" Cole, MD5 Core
*        External Credit #3 - Alex "Y_Less" Cole, Y_SERVER
*        External Credit #4 - Alex "Y_Less" Cole, sscanf
*        External Credit #5 - DCMD
*        External Credit #6 - Alex "Y_Less" Cole, SendFormattedText/SendFormattedTextToAll
*
*/

/*
*    INCLUDES
*/

 // author: -, External Credit #4
#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))



#include <a_samp>
#include <a_mysql>
#include <md5_core>  // author: Alex "Y_Less" Cole, External Credit #2
#include <Y_server>  // author: Alex "Y_Less" Cole, External Credit #3
#include <phoenix_Core>
#include <phoenix_Lang>
#include <phoenix_RealCarnames>

// author: Alex "Y_Less" Cole, External Credit #6
#define SendFormattedText(%1,%2,%3,%4) do{new sendfstring[128];format(sendfstring,128,(%3),%4);SendClientMessage((%1), (%2) ,sendfstring);}while(FALSE)
#define SendFormattedTextToAll(%1,%2,%3) do{new sendfstring[128];format(sendfstring,128,(%2),%3);SendClientMessageToAll((%1),sendfstring);}while(FALSE)

/*
*    DEFINES
*/

#define SCRIPT_NAME			"Phoenix"
#define SCRIPT_VERSION  	"0.1.1"
#define SCRIPT_REVISION 	"109"

#define MYSQL_HOST			"localhost"
#define MYSQL_USER			"estrpco_portal"
#define MYSQL_DB			"estrpco_portal"
#define MYSQL_PREFIX		"ph_"

    /*
         *  THREADS IDs
         */
	#define VEHICLE_LOAD_THREAD     1
	#define VEHICLE_SAVE_THREAD     2
	#define FETCH_UINFO_THREAD      3

#define VEHICLE_DELAY 1000*60*5
#define SQL_FINISH_TIME 1000
#define CHAT_RADIUS 25
#define CHAT_RADIUS_SHOUT 40

#define STRING_LENGHT 256
#define MAX_QUERY 255

#define VEHICLE_GROUP			0	// G�ngid, Grupeeringud
#define VEHICLE_JOB				1	// T��d
#define VEHICLE_BUYABLE			2	// Ostetav masin
#define VEHICLE_SPECIAL			3	// Rongid, transpordivahendid jms. PS: Neid ei saa m�ngijad kasutada. Botid juhivad!
#define VEHICLE_ADMIN			4	// Administraatorite masinad

#define COLOR_YELLOW		0xFFFF00AA
#define COLOR_RED 0xAA3333AA
#define COLOR_GREEN 0x33AA33AA

#define PLAYER_COLOR 0xFFFF0000

#define COLOR_CHAT_IC 0xf2ffacAA
#define COLOR_CHAT_OOC_GLOBAL 0x8cf8ffAA
#define COLOR_CHAT_OOC_LOCAL 0xf2ffacAA
#define COLOR_CHAT_ME 0xda92e5AA
#define COLOR_CHAT_SHOUT 0xd7ff00AA
#define COLOR_CHAT_ES 0xfffc00AA
#define COLOR_ADMINMSG 0xff3c00AA
#define COLOR_ADMINCHAT 0xffa800AA
#define COLOR_TEATA 0xff0000AA
#define COLOR_ADMIN_MESSAGE 0x0082fcAA
/* DialogIDs */
#define DIALOG_LOGIN 2009
#define DIALOG_PLAYER 2010
#define DIALOG_SENDES 2011
#define DIALOG_BANPLAYER 2012
#define DIALOG_KICKPLAYER 2013

#define NPC_IGOR 1

/*
*    SKILL DEFINES
*/
#define MAX_SKILLS		11

#define SKILL_PISTOL				0
#define SKILL_PISTOLS				1
#define SKILL_DEAGLE				2
#define SKILL_SHOTGUN				3
#define SKILL_SAWNOFF_SHOTGUN		4
#define SKILL_SPAS12_SHOTGUN		5
#define SKILL_MICRO_UZI				6
#define SKILL_MP5					7
#define SKILL_AK47					8
#define SKILL_M4					9
#define SKILL_SNIPERRIFLE			10

/*
*    GLOBAL VARIABLES
*/

new WelcomeStr[64];

    /*
         *  THREADS Vars
         */
	new Fetch_UInfo_Thread = -1;

new PistolPickup, SawnoffPickup, MP5Pickup, AKPickup;

enum pInf
{
	uSqlId,
	uUserName[20],	
	uPassWordHash[64],
	uSalt[10],
	pLoggedIn,
	pCharName[30],
	pSqlId,
	pAdmin,
	pJob,
	pMember,
	pLeader,
	pModel,
	pAdminLevel,
	
	Float:pPosX,
	Float:pPosY,
	Float:pPosZ,
	Float:pAngle,
	Float:pHealth,
	pVW,
	pInterior,
	
	SelectedPlayer,
	npcId,
	pSkill[MAX_SKILLS+1],
	pSkillTimer
};
new pInfo[MAX_PLAYERS][pInf];

new Text:  InfoBar[MAX_PLAYERS];
new 	   InfoBarTimer[MAX_PLAYERS];

new VEHICLE_SAVE_NEXT = 0;
new LOADED_VEHICLES = 0;
enum vInf
{
	vSqlID,
	vSampId,
	
	vModel,
	vType,
	
	Float: vPosXd,
	Float: vPosYd,
	Float: vPosZd,
	Float: vAngZd,
	Float: vPosX,
	Float: vPosY,
	Float: vPosZ,
	vSpeed,
	Float: vSpeedX,
	Float: vSpeedY,
	Float: vSpeedZ,
	Float: vAngZ,
	
	vColor1,
	vColor2,
	
	vOwner,
	vValue,
	
	vDeaths,
	Float: vHealth,
};
new Vehicles[700][vInf];

enum sInf
{
	sName[32],
	sLevel,
	Float: sRatio
};
new Skills[MAX_SKILLS][sInf] = 
{
	{"PISTOL", 1000, 1.5},
	{"PISTOL_VAIKNE", 1250, 1.5},
	{"DEAGLE", 1500, 1.5},
	{"SHOTGUN", 2000, 1.5},
	{"SAWNOFF_SHOTGUN", 2100, 1.5},
	{"SPAS12_SHOTGUN", 1800, 1.5},
	{"MICRO_UZI", 3000, 1.5},
	{"MP5", 1800, 1.5},
	{"AK47", 3500, 1.5},
	{"M4", 2000, 1.5},
	{"SNIPERRIFLE", 5000, 1.5}
};

new SkillDelay[MAX_PLAYERS][MAX_SKILLS];

/*
*    FORWARDS
*/
forward SendTeata(playerid, text[]);
forward SendAdminMessage(playerid, text[]);
forward CheckFalseDeadPlayers(playerid);
forward AddCarToSQL(model, Float:posX, Float:posY, Float:posZ, Float:angle);
forward SendAdminChat(playerid, text[]);
forward ShowBanDialog(playerid);
forward ShowKickDialog(playerid);
forward WarpPlayerToPlayer(WarpWho, WarpTo);
forward BanPlayer(playerid, banner, reason[]);
forward KickPlayer(playerid, kicker, reason[]);
forward SendEs(playerid);
forward ForwardEs(playerid, message[]);
forward SendEmote(playerid, emote[]);
forward SCMTAInPlayerRadius(playerid, radius, color, message[]);
forward LoadAllVehiclesStart();
forward LoadAllVehiclesFinish();
forward SaveAllVehicles(closingdown);
forward SaveVehicle(vId, saveall);
forward SetVehicleSpawn(vId);
forward OnDriverEnterVehicle(playerid);
forward OnDriverExitVehicle(playerid);
forward ShowSpeedo(playerid);
forward OnSpeedoUpdate(playerid);
forward CheckCharacter(playerid);
forward CheckCharacterFinish(playerid);
forward GetUserInfo(playerid);
forward GetUserInfoFinish(playerid);
forward AuthenticateUser(playerid, givenPassword[]);
forward FetchCharacterInformation(playerid);
forward FetchCharacterInformationFinish(playerid);
forward UpdatePlayer(playerid);
forward UpdateAllPlayers();

forward MysqlUpdateBuild(query[], table[]);
forward MysqlUpdateInt(query[], field[], value);
forward MysqlUpdateFlo(query[], field[], Float: value);
forward MysqlUpdateStr(query[], field[], value[]);
forward MysqlUpdateFinish(query[], field[], value);
forward Velocity(playerid, Float: X, Float: Y, Float: Z);
forward NPCHandle(playerid);
forward LoadSkills(playerid);
forward SaveSkills(playerid);
forward XpAdd(playerid, skillId, amount);
forward SetSkills(playerid);
forward OnLevelUp(playerid, skillId, newLevel, showMsg);
forward GetLevel(skillId, xP, &xpNeeded);
forward ClearDelay(playerid, skillId);

/*
*    MAIN()
*/

main()
{
	print("FIREBIRDIE HAS MAIN()");
}

/*
*    STOCKS
*/

stock GetVehicleSqlId(vehicleid)
{
	for(new i; i < LOADED_VEHICLES; i++)
	{
		if(Vehicles[i][vSampId] == vehicleid) return i;
	}
	return -1;
}

stock findBotAVehicle(botType)
{
	for(new i; i < LOADED_VEHICLES; i++)
	{
		if(Vehicles[i][vType] == VEHICLE_SPECIAL && Vehicles[i][vOwner] == botType) return i;
	}
	return -1;
}

stock VehPos(vId)
{
	GetVehiclePos(Vehicles[vId][vSampId], Vehicles[vId][vPosX], Vehicles[vId][vPosY], Vehicles[vId][vPosZ]);
	GetVehicleZAngle(Vehicles[vId][vSampId], Vehicles[vId][vAngZ]);
}

stock VehPosd(vId)
{
	Vehicles[vId][vPosX] = Vehicles[vId][vPosXd];
	Vehicles[vId][vPosY] = Vehicles[vId][vPosZd];
	Vehicles[vId][vPosZ] = Vehicles[vId][vPosYd];
	Vehicles[vId][vAngZ] = Vehicles[vId][vAngZd];
}

stock IsValidSkin(skinid) // author: Simon, External Credit #1
{
    #define	MAX_BAD_SKINS 22
    new badSkins[MAX_BAD_SKINS] =
    { 3, 4, 5, 6, 8, 42, 65, 74, 86, 119, 149, 208, 268, 273, 289 };
    if (skinid < 0 || skinid > 299) return false;
    for (new i = 0; i < MAX_BAD_SKINS; i++) { if (skinid == badSkins[i]) return false; }
    #undef MAX_BAD_SKINS
    return 1;
}

stock IsGroupMember(playerid)
{
	new ret = pInfo[playerid][pMember];
	if(pInfo[playerid][pLeader] > 0) ret = pInfo[playerid][pLeader];
	return ret;
}

stock showLogin(playerid)
{
	new string[64];
	format(string, 64, LANG_DIALOG_LOGIN_INFO, pInfo[playerid][uUserName]);
	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, LANG_DIALOG_LOGIN_CAPTION, string, LANG_DIALOG_LOGIN_LOGINBUTTON, LANG_DIALOG_EXITBUTTON);
}

PasswordHash(password[], salt[])
{
	new string[STRING_LENGHT];
	format(string, STRING_LENGHT, "%s%s", strtolower(MD5_Hash(password)), salt);
	format(string, STRING_LENGHT, "%s", strtolower(MD5_Hash(string)));
	return string;
}

public GetLevel(skillId, xP, &xpNeeded)
{
	if(xP < Skills[skillId][sLevel])
	{
		xpNeeded = Skills[skillId][sLevel];
		return 1;
	}
	new temp = Skills[skillId][sLevel];
	for(new i = 0; i < 99; i++)
	{
		temp = floatround(temp*Skills[skillId][sRatio]);
		xpNeeded = floatround(temp * i);
		if(xP < xpNeeded) return i;
	}	
	xpNeeded = 999;
	return 99;
}

/*
*    NATIVES
*/


public OnGameModeInit()
{
	// First things first, lets attempt to connect to database.
	new Connection = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASSWORD);
	if(!Connection)
	{
		printf(LANG_FAILED_TO_CONNECT, SCRIPT_NAME);
		SendRconCommand("exit");
		return 1;
	}
	printf(LANG_CONNECTED, SCRIPT_NAME);
	mysql_debug(1);

	new string[24]; // 24 should be enough.
	format(string, 24, "%s %s r%s", SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION);
	SetGameModeText(string);
	
	printf(LANG_LOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	format(WelcomeStr, 64, LANG_WELCOME_TO, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	
	AddPlayerClass(0, 1492.5065, 1007.7800, 10.8203, 90, 0, 0, 0, 0, 0, 0);
	
	LoadAllVehiclesStart();
	
	for(new td; td < MAX_PLAYERS; td++)
	{
		InfoBar[td] = TextDrawCreate(200.0,418.0,":)"); //minX = 120 // 330
		TextDrawAlignment(InfoBar[td],1);
		TextDrawUseBox(InfoBar[td],1);
		TextDrawBoxColor(InfoBar[td],0x00000050);
		TextDrawTextSize(InfoBar[td],640.0,480.0);
		TextDrawFont(InfoBar[td],1);
		TextDrawSetOutline(InfoBar[td],0);
	}
	
	ShowNameTags( 1 );
	SetNameTagDrawDistance(7.5);
	LimitGlobalChatRadius(CHAT_RADIUS);
	
	SetTimer("UpdateAllPlayers", 1000*60*15, true);
	SetTimer("CheckFalseDeadPlayers", 3000, true);
	
	PistolPickup = CreatePickup(346 , 2, 2394.2112,-1206.5466,27.8595, 0); // Pistol
	SawnoffPickup = CreatePickup(350 , 2, 2505.4795,-1117.3652,56.2031, 0); // sawnoff
	MP5Pickup = CreatePickup(353 , 2, 2526.4465,-1237.0942,43.6563, 0); // mp5
	AKPickup = CreatePickup(355 , 2, 2345.6289,-1364.8751,28.0859, 0); // AK
	
	ConnectNPC("Igor", "Igor_Takso");
	
	//// KARDIRAJA OBJEKTID
	CreateObject(978, 1801.377563, -1040.903320, 23.426163, 0.0000, 0.0000, 154.6978);
	CreateObject(978, 1781.199097, -1042.265991, 23.383846, 0.0000, 0.0000, 200.2479);
	CreateObject(978, 1792.510254, -1039.356445, 23.426163, 0.0000, 0.0000, 186.3938);
	CreateObject(978, 1769.416504, -1043.925049, 23.414612, 0.0000, 0.0000, 159.7513);
	CreateObject(978, 1783.479004, -1041.437866, 23.401163, 0.0000, 0.0000, 200.2479);
	CreateObject(978, 1737.989136, -1039.293091, 23.426163, 0.0000, 0.0000, 146.0003);
	CreateObject(978, 1741.407593, -1058.687622, 23.451162, 0.0000, 0.0000, 329.0603);
	CreateObject(978, 1749.786133, -1062.751587, 23.428240, 0.0000, 0.0000, 339.3735);
	CreateObject(978, 1733.522095, -1053.656616, 23.435760, 0.0000, 0.0000, 325.6225);
	CreateObject(978, 1725.913574, -1048.359009, 23.379263, 0.0000, 359.1406, 324.7631);
	CreateObject(978, 1718.344360, -1042.902344, 23.329264, 0.0000, 0.0000, 323.9037);
	CreateObject(978, 1696.818115, -1039.661865, 23.346476, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1753.548096, -1042.090332, 23.346476, 0.0000, 0.0000, 180.3777);
	CreateObject(978, 1754.148804, -1064.387573, 23.421474, 0.0000, 0.0000, 339.3735);
	CreateObject(978, 1679.393433, -1039.629150, 23.371454, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1667.020996, -1039.424561, 23.388662, 0.0000, 0.0000, 18.0473);
	CreateObject(978, 1663.532104, -1040.595337, 23.388662, 0.0000, 0.0000, 17.1879);
	CreateObject(978, 1643.608154, -1041.927490, 23.363663, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1623.853638, -1038.247925, 23.363663, 0.0000, 0.0000, 304.1366);
	CreateObject(978, 1619.487183, -1031.782471, 23.368946, 0.0000, 0.0000, 304.1366);
	CreateObject(978, 1611.642090, -1033.153198, 23.388662, 0.0000, 0.0000, 64.4569);
	CreateObject(978, 1607.655518, -1041.492188, 23.371454, 0.0000, 0.0000, 64.4569);
	CreateObject(978, 1603.672974, -1049.829590, 23.371475, 0.0000, 0.0000, 64.4569);
	CreateObject(978, 1601.389648, -1054.602783, 23.371475, 0.0000, 0.0000, 64.4569);
	CreateObject(978, 1604.144653, -1065.579956, 23.346476, 0.0000, 0.0000, 142.6656);
	CreateObject(978, 1611.590332, -1071.177368, 23.363663, 0.0000, 0.0000, 143.4220);
	CreateObject(978, 1618.918579, -1076.868896, 23.363663, 0.0000, 0.0000, 140.8436);
	CreateObject(978, 1625.153076, -1108.348511, 23.371475, 0.0000, 0.0000, 90.1369);
	CreateObject(978, 1625.136230, -1098.987793, 23.371475, 0.0000, 0.0000, 90.1369);
	CreateObject(978, 1625.091553, -1089.621948, 23.379259, 0.0000, 0.0000, 90.2400);
	CreateObject(978, 1621.439453, -1078.901611, 23.363663, 0.0000, 0.0000, 140.8436);
	CreateObject(978, 1625.069092, -1086.744873, 23.346476, 0.0000, 0.0000, 90.2400);
	CreateObject(978, 1653.917969, -1111.886841, 23.416231, 0.0000, 0.0000, 270.6186);
	CreateObject(978, 1653.878174, -1102.550293, 23.421474, 0.0000, 0.0000, 269.7591);
	CreateObject(978, 1653.863525, -1093.183228, 23.346476, 0.0000, 359.1406, 269.8394);
	CreateObject(978, 1653.894775, -1083.826050, 23.271477, 0.0000, 0.0000, 269.8623);
	CreateObject(978, 1649.192383, -1082.291992, 23.346476, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1639.923584, -1082.277222, 23.346476, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1630.578369, -1082.136719, 23.346476, 0.0000, 0.0000, 358.2811);
	CreateObject(978, 1648.632568, -1118.609863, 23.371475, 0.0000, 0.0000, 171.7834);
	CreateObject(978, 1639.362915, -1117.193726, 23.371475, 0.0000, 0.0000, 170.9239);
	CreateObject(978, 1630.443481, -1115.775513, 23.371475, 0.0000, 0.0000, 170.9239);
	CreateObject(978, 1777.193359, -1065.995605, 23.401163, 0.0000, 0.0000, 180.3777);
	CreateObject(978, 1755.306274, -1065.880981, 23.426163, 0.0000, 0.0000, 179.6214);
	CreateObject(978, 1749.381226, -1065.848022, 23.421963, 0.0000, 0.0000, 181.3403);
	CreateObject(978, 1740.191772, -1065.795166, 23.426163, 0.0000, 0.0000, 177.9026);
	CreateObject(978, 1735.519775, -1065.763062, 23.413609, 0.0000, 0.0000, 179.6214);
	CreateObject(978, 1722.148438, -1065.414307, 23.435490, 0.0000, 0.8586, 179.6214);
	CreateObject(978, 1712.811401, -1065.429810, 23.371475, 0.0000, 0.0000, 180.4809);
	CreateObject(978, 1703.469238, -1065.536743, 23.396475, 0.0000, 0.0000, 180.4809);
	CreateObject(978, 1694.112305, -1065.627197, 23.371475, 0.0000, 0.0000, 180.4809);
	CreateObject(978, 1685.592529, -1068.395996, 23.379633, 0.0000, 0.0000, 214.7552);
	CreateObject(978, 1678.181152, -1065.294922, 23.413662, 0.0000, 0.0000, 104.7473);
	CreateObject(978, 1675.270630, -1056.572021, 23.363663, 0.0000, 0.0000, 112.4822);
	CreateObject(978, 1670.394043, -1048.710815, 23.363663, 0.0000, 0.0000, 131.3898);
	CreateObject(978, 1662.842041, -1043.802612, 23.338663, 0.0000, 0.0000, 162.3296);
	CreateObject(978, 1682.891235, -1092.518066, 23.346476, 0.0000, 0.0000, 48.9870);
	CreateObject(978, 1639.453491, -1059.855713, 23.388662, 0.0000, 0.0000, 2.5775);
	CreateObject(978, 1648.526978, -1060.493286, 23.388662, 0.0000, 0.0000, 349.6868);
	CreateObject(978, 1657.196533, -1062.843750, 23.363663, 0.0000, 0.0000, 340.2330);
	CreateObject(978, 1638.258667, -1059.910034, 23.396454, 0.0000, 0.0000, 2.5775);
	CreateObject(978, 1678.198975, -1091.790527, 23.338663, 0.0000, 0.0000, 113.3417);
	CreateObject(978, 1674.315674, -1084.005005, 23.354258, 0.0000, 0.0000, 120.2172);
	CreateObject(978, 1669.595459, -1076.687500, 23.363663, 0.0000, 0.0000, 125.3738);
	CreateObject(978, 1663.745361, -1069.897827, 23.340876, 0.0000, 0.0000, 135.6870);
	CreateObject(978, 1669.632080, -1072.209839, 23.388662, 0.0000, 0.0000, 312.7310);
	CreateObject(978, 1676.031372, -1079.042603, 23.388662, 0.0000, 0.0000, 313.5904);
	CreateObject(978, 1682.526489, -1085.765991, 23.371475, 0.0000, 0.0000, 314.4499);
	CreateObject(978, 1666.294434, -1068.684937, 23.388662, 0.0000, 0.0000, 313.5904);
	CreateObject(978, 1679.968872, -1100.670288, 23.371475, 0.0000, 0.0000, 90.2400);
	CreateObject(978, 1690.430786, -1089.196899, 23.371475, 0.0000, 0.0000, 359.1406);
	CreateObject(978, 1699.810425, -1089.252319, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1709.176880, -1089.256836, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1718.554810, -1089.262695, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1727.893555, -1089.248657, 23.372623, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1737.260376, -1089.237427, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1746.577393, -1089.245483, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1755.939331, -1089.243164, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1765.303345, -1089.223022, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1774.683350, -1089.222778, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1783.985962, -1089.232178, 23.408846, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1793.349243, -1089.238159, 23.408846, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1802.711670, -1089.251465, 23.401163, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1804.842285, -1089.252319, 23.421032, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1809.599121, -1084.548950, 23.426163, 0.0000, 0.0000, 90.2400);
	CreateObject(978, 1809.569580, -1075.185669, 23.426064, 0.0000, 0.0000, 90.2400);
	CreateObject(978, 1809.381714, -1065.835205, 23.433846, 0.0000, 0.0000, 91.8558);
	CreateObject(978, 1808.500000, -1056.665894, 23.426163, 0.0000, 0.0000, 98.8344);
	CreateObject(978, 1806.708862, -1047.473999, 23.426163, 0.0000, 0.0000, 103.1316);
	CreateObject(978, 1736.442261, -1038.244141, 23.401163, 0.0000, 0.0000, 146.1034);
	CreateObject(978, 1768.317871, -1043.504150, 23.426163, 0.0000, 0.0000, 159.9575);
	CreateObject(978, 1656.177856, -1065.088257, 23.363663, 0.0000, 0.0000, 160.6107);
	CreateObject(978, 1647.186401, -1062.592529, 23.363663, 0.0000, 0.0000, 168.4487);
	CreateObject(978, 1637.956909, -1062.415405, 23.388662, 0.0000, 0.0000, 189.0752);
	CreateObject(978, 1643.492554, -1042.448730, 23.363663, 0.0000, 0.0000, 179.6214);
	CreateObject(978, 1718.383545, -1027.036255, 23.391417, 0.0000, 0.0000, 149.4380);
	CreateObject(978, 1710.284058, -1022.347412, 23.404263, 0.0000, 0.0000, 150.2974);
	CreateObject(978, 1702.177002, -1017.736206, 23.401142, 0.0000, 0.0000, 150.4006);
	CreateObject(978, 1694.047363, -1013.114258, 23.404263, 0.0000, 0.0000, 150.2974);
	CreateObject(978, 1685.954102, -1008.431519, 23.393353, 0.0000, 0.0000, 149.5411);
	CreateObject(978, 1726.390259, -1031.831055, 23.396475, 0.0000, 0.0000, 148.6817);
	CreateObject(978, 1731.380005, -1034.931030, 23.396475, 0.0000, 0.0000, 147.8223);
	CreateObject(978, 1677.507324, -1007.514709, 23.388662, 0.0000, 0.0000, 198.5290);
	CreateObject(978, 1668.522461, -1010.000122, 23.388662, 0.0000, 0.0000, 192.4098);
	CreateObject(978, 1659.392578, -1011.875977, 23.388662, 0.0000, 0.0000, 190.7941);
	CreateObject(978, 1653.169678, -1013.034363, 23.363663, 0.0000, 0.0000, 190.6910);
	CreateObject(978, 1644.196899, -1012.499756, 23.363663, 0.0000, 0.0000, 162.4327);
	CreateObject(978, 1635.260620, -1009.669922, 23.363663, 0.0000, 0.0000, 162.4327);
	CreateObject(978, 1626.309204, -1006.901794, 23.363663, 0.0000, 0.0000, 163.1890);
	CreateObject(978, 1615.491699, -1005.033691, 23.404272, 0.0000, 0.0000, 178.7620);
	CreateObject(978, 1624.593384, -1006.445740, 23.396475, 0.0000, 0.0000, 163.1890);
	CreateObject(978, 1606.153198, -1004.827209, 23.404272, 0.0000, 0.0000, 178.7620);
	CreateObject(978, 1599.043457, -1008.736267, 23.396475, 0.0000, 0.0000, 238.9226);
	CreateObject(978, 1594.336304, -1016.821838, 23.396475, 0.0000, 0.0000, 240.6414);
	CreateObject(978, 1590.245239, -1025.165161, 23.371475, 0.0000, 0.0000, 247.5169);
	CreateObject(978, 1586.940186, -1033.865112, 23.371475, 0.0000, 0.0000, 250.8515);
	CreateObject(978, 1584.280396, -1042.805542, 23.371475, 0.0000, 0.0000, 256.0082);
	CreateObject(978, 1582.944946, -1048.092163, 23.371475, 0.0000, 0.0000, 256.0082);
	CreateObject(978, 1584.633667, -1056.001343, 23.371475, 0.0000, 0.0000, 308.4338);
	CreateObject(978, 1588.060425, -1060.317017, 23.371475, 0.0000, 0.0000, 308.4338);
	CreateObject(978, 1593.107056, -1068.131348, 23.368353, 0.0000, 0.0000, 297.2611);
	CreateObject(978, 1597.374878, -1076.409546, 23.371475, 0.0000, 0.0000, 297.2611);
	CreateObject(978, 1601.017212, -1084.832886, 23.379261, 0.0000, 0.0000, 289.5262);
	CreateObject(978, 1603.046509, -1090.315186, 23.371840, 0.0000, 0.0000, 290.3856);
	CreateObject(978, 1605.617920, -1099.268066, 23.371475, 0.0000, 0.0000, 281.7913);
	CreateObject(978, 1606.587402, -1103.918701, 23.371475, 0.0000, 0.0000, 281.7913);
	CreateObject(978, 1608.215210, -1113.122925, 23.371475, 0.0000, 0.0000, 278.3535);
	CreateObject(978, 1680.047119, -1119.331177, 23.346476, 0.0000, 0.0000, 90.1369);
	CreateObject(978, 1659.577515, -1140.142212, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1679.993530, -1110.032959, 23.371475, 0.0000, 0.0000, 90.1369);
	CreateObject(978, 1680.047852, -1122.335449, 23.360540, 0.0000, 0.0000, 89.3806);
	CreateObject(978, 1676.616943, -1130.265259, 23.371475, 0.0000, 0.0000, 43.8304);
	CreateObject(978, 1669.964111, -1135.937012, 23.396475, 0.0000, 0.0000, 36.9549);
	CreateObject(978, 1668.030029, -1137.347900, 23.371475, 0.0000, 0.0000, 36.9549);
	CreateObject(978, 1650.791748, -1140.133911, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1609.497925, -1122.360229, 23.371475, 0.0000, 0.0000, 277.5972);
	CreateObject(978, 1610.474243, -1131.389282, 23.371475, 0.0000, 0.0000, 274.9158);
	CreateObject(978, 1615.869507, -1139.548828, 23.346476, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1610.767456, -1134.859497, 23.371475, 0.0000, 0.0000, 274.9158);
	CreateObject(978, 1620.257202, -1139.549683, 23.329807, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1645.980469, -1140.102051, 23.371475, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1629.151611, -1140.030396, 23.396475, 0.0000, 0.8586, 0.0000);
	CreateObject(966, 1634.226196, -1140.067627, 22.906250, 0.0000, 0.0000, 180.4809);
	CreateObject(968, 1634.109741, -1140.096680, 23.661848, 0.0000, 0.0000, 0.8586);
	//////////KARDIRADA L�PP
	
	return 1;
}

public OnGameModeExit()
{
	SaveAllVehicles(true);
	UpdateAllPlayers();

	printf(LANG_UNLOADED, SCRIPT_NAME, SCRIPT_VERSION, SCRIPT_REVISION, SCRIPTER_NAME);
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) return NPCHandle(playerid);
	
    GetPlayerName(playerid, pInfo[playerid][pCharName], 30);
	SendClientMessage(playerid, COLOR_YELLOW, WelcomeStr);
	InfoBarTimer[playerid] = -1;
	CheckCharacter(playerid);

	pInfo[playerid][pLoggedIn] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid)
{
	UpdatePlayer(playerid);
	SaveSkills(playerid);
}

public OnPlayerRequestClass(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	SetPlayerVirtualWorld(playerid, playerid);
	SetPlayerPos(playerid, 1763.4633,-1110.3879,74.4867);
	SetPlayerFacingAngle(playerid, 90);
	
	SetPlayerCameraPos(playerid, 	2028.6260,-856.2253,157.4038);
	SetPlayerCameraLookAt(playerid, 1813.7842,-1015.3187,188.0742);
	if( !pInfo[playerid][pLoggedIn] )	showLogin(playerid);
	
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
	{
		if(pInfo[playerid][npcId] == NPC_IGOR)
		{
			new npcVeh = findBotAVehicle(NPC_IGOR);
			if(npcVeh != -1)
			{
				SetPlayerSkin(playerid, 255);
				PutPlayerInVehicle(playerid, Vehicles[npcVeh][vSampId], 0);
				return 1;
			}
			Kick(playerid);
		}
	}

    SetPlayerPos(playerid, pInfo[playerid][pPosX],pInfo[playerid][pPosY],pInfo[playerid][pPosZ]+1);
	SetPlayerVirtualWorld(playerid, pInfo[playerid][pVW]);
	SetPlayerInterior(playerid,pInfo[playerid][pInterior]);
	SetPlayerFacingAngle(playerid, pInfo[playerid][pAngle]);
	SetPlayerSkin(playerid, pInfo[playerid][pModel]);
	SetPlayerHealth(playerid, pInfo[playerid][pHealth]);
	SetPlayerColor(playerid, PLAYER_COLOR);
	
	SetCameraBehindPlayer(playerid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER) 										OnDriverEnterVehicle(playerid);
	else if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) OnDriverExitVehicle(playerid);
}

public OnVehicleDeath(vehicleid)
{
	/*
	new vSqlId = GetVehicleSqlId(vehicleid);
	if(vSqlId != -1)
	{
		Vehicles[vSqlId][vDeaths]++;
		VehPosd(vSqlId);
		SetTimerEx("SetVehicleSpawn", 500, 0, "d", vSqlId);
	}
	*/
	return 1;
}

public OnRconCommand(cmd[])
{
	if( strcmp(cmd, "gmx", true) == 0 ) OnGameModeExit();
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_LOGIN)
	{
		if(response == 0)
		{
			SendClientMessage(playerid, COLOR_RED, LANG_MUST_LOGIN);
			
			SendClientMessage(playerid, COLOR_GREEN, LANG_BB);
			Kick(playerid);
			return 1;
		}
		else
		{
			AuthenticateUser(playerid, inputtext);
			return 1;
		}
	}
	else if( dialogid == DIALOG_PLAYER )
	{
	    if( response == 0 )
	    {
	        return 1;
	    }
	    else if( listitem == 0 ) // Eras�num
	    {
			SendEs(playerid);
	    }
	    else if( listitem == 1 ) // Tele Siia
	    {
	        WarpPlayerToPlayer(pInfo[playerid][SelectedPlayer], playerid);
	    }
	    else if( listitem == 2 ) // Tele Sinna
	    {
            WarpPlayerToPlayer(playerid, pInfo[playerid][SelectedPlayer]);
	    }
	    else if( listitem == 3 ) // Kick
	    {
	        ShowKickDialog(playerid);
	    }
	    else if( listitem == 4 ) // Ban
	    {
	        ShowBanDialog(playerid);
	    }
	}
	else if( dialogid == DIALOG_SENDES )
	{
	    if( strlen(inputtext) == 0 )
		{
		    SendClientMessage(playerid, COLOR_RED, LANG_EMPTY_ES);
		    SendEs(playerid);
		}
		else
		{
		    if( IsPlayerConnected(pInfo[playerid][SelectedPlayer]) && pInfo[pInfo[playerid][SelectedPlayer]][pLoggedIn] )
		    {
				ForwardEs(playerid, inputtext);
		    }
			else
			SendClientMessage(playerid, COLOR_RED, LANG_NOT_ONLINE);
		}
	}
	else if( dialogid == DIALOG_KICKPLAYER )
	{
	    if( response == 0 )
	    {
	        return 1;
	    }
	    else
	    {
	        KickPlayer(pInfo[playerid][SelectedPlayer], playerid, inputtext);
	    }
	}
	else if( dialogid == DIALOG_BANPLAYER )
	{
	    if( response == 0 )
	    {
	        return 1;
	    }
	    else
	    {
	        BanPlayer(pInfo[playerid][SelectedPlayer], playerid, inputtext);
	    }
	}
	return 1;
}
public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
    if( !pInfo[playerid][pLoggedIn] )
    {
        SendClientMessage(playerid, COLOR_RED, LANG_MUST_LOGIN);
		
		showLogin(playerid);
		return 0;    
    }
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if( pickupid == PistolPickup )
		GivePlayerWeapon(playerid, 22, 100);
	if( pickupid == SawnoffPickup )
		GivePlayerWeapon(playerid, 26, 100);
	if( pickupid == MP5Pickup )
		GivePlayerWeapon(playerid, 29, 100);
	if( pickupid == AKPickup )
		GivePlayerWeapon(playerid, 30, 100);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	pInfo[playerid][pPosX] = 2420.3459;
	pInfo[playerid][pPosY] = -1229.8799;
	pInfo[playerid][pPosZ] = 24.7299;
	pInfo[playerid][pAngle] = 180;
	pInfo[playerid][pHealth] = 100;
	pInfo[playerid][pVW] = 0;
	pInfo[playerid][pInterior] = 0;
	
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new delay = ( strlen(text) * 150 ) + 2000;
	new str[STRING_LENGHT];
	format(str, sizeof(str),"%s:  %s", pInfo[playerid][pCharName], text);	
	if(IsPlayerNPC(playerid))
	{
		format(str, sizeof(str),"Igor_Yakov:  %s", text);
	}

	SetPlayerChatBubble(playerid, str, COLOR_CHAT_IC, CHAT_RADIUS, delay);
	SCMTAInPlayerRadius(playerid, CHAT_RADIUS, COLOR_CHAT_IC, str);
	return 0;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    pInfo[playerid][SelectedPlayer] = clickedplayerid;
    new str[STRING_LENGHT];
    str = "Eras�num";

	if( pInfo[playerid][pAdminLevel] > 0 )
        format( str, sizeof(str), "%s\nTele Siia\nTele Sinna\nKicki\nBanni", str);

	ShowPlayerDialog( playerid, DIALOG_PLAYER, DIALOG_STYLE_LIST, "M�ngija Valikud", str, "Ok", LANG_DIALOG_EXITBUTTON);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if( PRESSED(KEY_FIRE) || PRESSED(KEY_FIRE | KEY_HANDBRAKE) )
    {
		if(!IsPlayerInAnyVehicle(playerid))
		{
			if(SkillDelay[playerid][SKILL_PISTOL] == 0 && GetPlayerWeapon(playerid) == 22)
			{
				XpAdd(playerid, SKILL_PISTOL, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_PISTOL, 25);
			}
			if(SkillDelay[playerid][SKILL_PISTOLS] == 0 && GetPlayerWeapon(playerid) == 23)
			{
				XpAdd(playerid, SKILL_PISTOLS, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_PISTOLS, 25);
			}
			if(SkillDelay[playerid][SKILL_DEAGLE] == 0 && GetPlayerWeapon(playerid) == 24)
			{
				XpAdd(playerid, SKILL_DEAGLE, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_DEAGLE, 25);
			}
			if(SkillDelay[playerid][SKILL_SHOTGUN] == 0 && GetPlayerWeapon(playerid) == 25)
			{
				XpAdd(playerid, SKILL_SHOTGUN, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_SHOTGUN, 25);
			}
			if(SkillDelay[playerid][SKILL_SAWNOFF_SHOTGUN] == 0 && GetPlayerWeapon(playerid) == 26)
			{
				XpAdd(playerid, SKILL_SAWNOFF_SHOTGUN, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_SAWNOFF_SHOTGUN, 25);
			}
			if(SkillDelay[playerid][SKILL_SPAS12_SHOTGUN] == 0 && GetPlayerWeapon(playerid) == 27)
			{
				XpAdd(playerid, SKILL_SPAS12_SHOTGUN, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_SPAS12_SHOTGUN, 25);
			}
			if(SkillDelay[playerid][SKILL_MICRO_UZI] == 0 && GetPlayerWeapon(playerid) == 28)
			{
				XpAdd(playerid, SKILL_MICRO_UZI, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_MICRO_UZI, 25);
			}
			if(SkillDelay[playerid][SKILL_MP5] == 0 && GetPlayerWeapon(playerid) == 29)
			{
				XpAdd(playerid, SKILL_MP5, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_MP5, 25);
			}
			if(SkillDelay[playerid][SKILL_AK47] == 0 && GetPlayerWeapon(playerid) == 30)
			{
				XpAdd(playerid, SKILL_AK47, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_AK47, 25);
			}
			if(SkillDelay[playerid][SKILL_M4] == 0 && GetPlayerWeapon(playerid) == 31)
			{
				XpAdd(playerid, SKILL_M4, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_M4, 25);
			}
			if(SkillDelay[playerid][SKILL_SNIPERRIFLE] == 0 && GetPlayerWeapon(playerid) == 34)
			{
				XpAdd(playerid, SKILL_SNIPERRIFLE, 25);
				if( pInfo[playerid][pSkillTimer] == 0 ) pInfo[playerid][pSkillTimer] = SetTimerEx("XpAdd", 300, true, "iii", playerid, SKILL_SNIPERRIFLE, 25);
			}			
		}
	}
	if( RELEASED(KEY_FIRE) || RELEASED(KEY_FIRE | KEY_HANDBRAKE) )
	{
	    if( pInfo[playerid][pSkillTimer] != 0 )
	    {
	    	KillTimer(pInfo[playerid][pSkillTimer]);
			pInfo[playerid][pSkillTimer] = 0;
		}
	}
}
/*
*    COMMANDS
*/
public OnPlayerCommandText(playerid, cmdtext[])
{
	dcmd(o, 1, cmdtext);
	dcmd(b, 1, cmdtext);
	dcmd(me, 2, cmdtext);
	dcmd(s, 1, cmdtext);
	dcmd(es, 2, cmdtext);
	dcmd(mjuurde, 7, cmdtext);
	dcmd(msiia, 5, cmdtext);
	dcmd(kick, 4, cmdtext);
	dcmd(ban, 3, cmdtext);
	dcmd(a, 1, cmdtext);
	dcmd(oskus, 5, cmdtext);
	dcmd(teata, 5, cmdtext);
	dcmd(am, 2, cmdtext);
	
	// ajutine
	dcmd(kaklus, 6, cmdtext);
	dcmd(mj, 2, cmdtext);
	dcmd(addveh, 6, cmdtext);

	return 1;
}

dcmd_o(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);
	
	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /o tekst");
	format(str, sizeof(str), "(( %s: %s ))", pInfo[playerid][pCharName], text);
	
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] && !IsPlayerNPC(i) )
	    {
				SendClientMessage(i, COLOR_CHAT_OOC_GLOBAL, str);
	    }
	}
	
	return 1;
}
dcmd_b(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /b tekst");

	format(str, sizeof(str), "%s OOC:(( %s ))", pInfo[playerid][pCharName], text);
	SCMTAInPlayerRadius(playerid, CHAT_RADIUS, COLOR_CHAT_OOC_LOCAL, str);
	return 1;
}
dcmd_me(playerid, params[])
{
	new text[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /me tekst");

	SendEmote(playerid, text);
	return 1;
}
dcmd_s(playerid, params[])
{
	new text[STRING_LENGHT], str[STRING_LENGHT];
	sscanf(params, "s", text);

	if(strlen(text) == 0) return SendClientMessage(playerid, COLOR_RED, "KASUTUS: /s tekst");

	new delay = ( strlen(text) * 150 ) + 2000;
	format(str, sizeof(str), "%s %s: %s", pInfo[playerid][pCharName], LANG_ACTION_SHOUT, text);
	SetPlayerChatBubble(playerid, str, COLOR_CHAT_SHOUT, CHAT_RADIUS_SHOUT, delay);
	SCMTAInPlayerRadius(playerid, CHAT_RADIUS_SHOUT, COLOR_CHAT_SHOUT, str);
	return 1;
}
dcmd_es(playerid, params[])
{
	new selplayer, text[STRING_LENGHT];
	sscanf(params, "us", selplayer, text);
	pInfo[playerid][SelectedPlayer] = selplayer;
	if( strlen(text) > 0 ) ForwardEs(playerid, text);
	else SendEs(playerid);
}

dcmd_mjuurde(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new selectedplayer;
	if ( sscanf(params, "u", selectedplayer) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /mjuurde [ID/NIMI]");
    WarpPlayerToPlayer(playerid, selectedplayer);
    return 1;
}
dcmd_msiia(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
    new selectedplayer;
    if ( sscanf(params, "u", selectedplayer) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /msiia [ID/NIMI]");
    WarpPlayerToPlayer(selectedplayer, playerid);
    return 1;
}
dcmd_kick(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new selectedplayer, reason[STRING_LENGHT];
    sscanf(params, "us", selectedplayer, reason);
    if( strlen(reason) == 0 ){ pInfo[playerid][SelectedPlayer] = selectedplayer; ShowKickDialog(playerid); return 1;}
    else KickPlayer(selectedplayer, playerid, reason);
    return 1;
}
dcmd_ban(playerid, params[])
{
    if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
    new selectedplayer, reason[STRING_LENGHT];
    sscanf(params, "us", selectedplayer, reason);
	if( strlen(reason) == 0 ){ pInfo[playerid][SelectedPlayer] = selectedplayer; ShowBanDialog(playerid); return 1;}
    else BanPlayer(selectedplayer, playerid, reason);
    return 1;
}
dcmd_a(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new str[STRING_LENGHT];
	if( sscanf(params,"s",str) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /a [S�NUM]");
	SendAdminChat(playerid, str);
	return 1;
}

dcmd_oskus(playerid, params[])
{
	#pragma unused params
	
	SendClientMessage(playerid, COLOR_YELLOW, "Sinu oskused:");
	new string[128];
	
	for(new i = 0; i < MAX_SKILLS; i++)
	{
		new xpNeeded;
		new level = GetLevel(i, pInfo[playerid][pSkill][i], xpNeeded);
		format(string, 128, "Oskus: %s, Level: %d, XP: %d / %d", Skills[i][sName], level, pInfo[playerid][pSkill][i], xpNeeded);
		SendClientMessage(playerid, COLOR_YELLOW, string);
	}
	return 1;
}
dcmd_teata(playerid, params[])
{
	new str[STRING_LENGHT];
	if( sscanf(params,"s",str) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /teata [S�NUM]");
	SendTeata(playerid, str);
	return 1;
}
dcmd_am(playerid, params[])
{
	if( pInfo[playerid][pAdminLevel] == 0 ) return SendClientMessage(playerid,COLOR_YELLOW, LANG_NOT_ADMIN);
	new str[STRING_LENGHT];
	if( sscanf(params,"s",str) ) return SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /am [S�NUM]");
	SendAdminChat(playerid, str);
	return 1;
}

// AJUTISED
dcmd_kaklus(playerid, params[])
{
	new style;
	if(sscanf(params, "i", style))
	{
		SendClientMessage(playerid, COLOR_YELLOW, "KASUTUS: /kaklus [stiiliNR]");
		SendClientMessage(playerid, COLOR_YELLOW, "stiiliNR: 0(tava), 1(poks), 2(kungfu), 3(p�lv, pea), 4(haare, l��k), 5(k��narnukid)");
		return 1;
	}
	if(style < 0 || style > 5) return SendClientMessage(playerid, COLOR_RED, "Vale stiiliNR.");
	
	new sampStyleID = 4;
	if(style == 1) 		sampStyleID = 5;
	else if(style == 2) sampStyleID = 6;
	else if(style == 3) sampStyleID = 7;
	else if(style == 4) sampStyleID = 15;
	else if(style == 5) sampStyleID = 26;
	
	SendClientMessage(playerid, COLOR_RED, "Muutsid oma kaklusstiili.");
	SetPlayerFightingStyle(playerid, sampStyleID);
	return 1;	
}

dcmd_mj(playerid, params[])
{
	#pragma unused params
	new Float: vx, Float: vy, Float: vz;
	GetPlayerVelocity(playerid, vx, vy, vz);
	vz += 10.0;
	SetPlayerVelocity(playerid, vx, vy, vz);
	SendEmote(playerid, "h�ppab jube k�rgele.");
	return 1;
}
dcmd_addveh(playerid, params[])
{
    #pragma unused params
	if( pInfo[playerid][pAdminLevel] > 1 )
	{
	    if( IsPlayerInAnyVehicle(playerid) )
	    {
	        new vid = GetPlayerVehicleID(playerid);
	        new model = GetVehicleModel(vid);
	        new Float:posX, Float:posY, Float:posZ, Float:angle;
	        GetVehicleZAngle(vid, angle);
	        GetVehiclePos(vid, posX, posY, posZ);
	        AddCarToSQL(model, posX, posY, posZ, angle);

			SendClientMessage(playerid, COLOR_YELLOW, "LISATUD!");
	    }
	    else return 1;
	}
	return 1;
}

/*
*    PUBLICS
*/

public SendEs(playerid)
{
	new str[STRING_LENGHT];
	format(str, sizeof(str), LANG_SEND_ES_TO, pInfo[pInfo[playerid][SelectedPlayer]][pCharName]);
	ShowPlayerDialog(playerid, DIALOG_SENDES, DIALOG_STYLE_INPUT, LANG_ES, str, LANG_DIALOG_SEND, LANG_DIALOG_EXITBUTTON);
}
public ForwardEs(playerid, message[])
{
	new str[STRING_LENGHT];
	
	format(str, sizeof(str),"-> %s: %s", pInfo[pInfo[playerid][SelectedPlayer]][pCharName], message);
	SendClientMessage(playerid, COLOR_CHAT_ES, str);
	format(str, sizeof(str),"<- %s: %s", pInfo[playerid][pCharName], message);
	SendClientMessage(pInfo[playerid][SelectedPlayer], COLOR_CHAT_ES, str);
}

public SendEmote(playerid, emote[])
{
	new Float:PlayerLocX, Float:PlayerLocY, Float:PlayerLocZ, str[STRING_LENGHT];
	GetPlayerPos(playerid, PlayerLocX, PlayerLocY, PlayerLocZ);
	format(str, sizeof(str),"*%s %s*", pInfo[playerid][pCharName], emote);
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] )
	    {
	        if( IsPlayerInRangeOfPoint(i, CHAT_RADIUS, PlayerLocX, PlayerLocY, PlayerLocZ) )
	        {
				SendClientMessage(i, COLOR_CHAT_ME, str);
	        }
	    }
	}
}
public SCMTAInPlayerRadius(playerid, radius, color, message[])
{
	new Float:PlayerLocX, Float:PlayerLocY, Float:PlayerLocZ;
	GetPlayerPos(playerid, PlayerLocX, PlayerLocY, PlayerLocZ);
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] )
	    {
	        if( IsPlayerInRangeOfPoint(i, radius, PlayerLocX, PlayerLocY, PlayerLocZ) )
	        {
				SendClientMessage(i, color, message);
	        }
	    }
		else if(IsPlayerNPC(i) && i != playerid)
		{
			if(pInfo[i][npcId] == NPC_IGOR)
			{
				if(color == COLOR_CHAT_IC)
				{
					if(IsPlayerInVehicle(playerid, GetPlayerVehicleID(i)))
					{
						SendClientMessage(i, color, message);
					}
				}
			}
		}
	}
}

public OnQueryFinish(query[], resultid)
{
	if( resultid == VEHICLE_LOAD_THREAD )
	{
		LoadAllVehiclesFinish();
	}
	else if( resultid == VEHICLE_SAVE_THREAD )
	{
		if(VEHICLE_SAVE_NEXT < LOADED_VEHICLES)
		{
			SaveVehicle(VEHICLE_SAVE_NEXT, true);
			VEHICLE_SAVE_NEXT++;
		}
		else VEHICLE_SAVE_NEXT = 0;
	}
	else if( resultid == FETCH_UINFO_THREAD )
	{
		FetchCharacterInformationFinish(Fetch_UInfo_Thread);
	}
}

public LoadAllVehiclesStart()
{
	print("\t\t Started Loading Vehicles.");
	new query[32];
	format(query, 32, "SELECT * FROM %svehicles", MYSQL_PREFIX);
	mysql_query(query, VEHICLE_LOAD_THREAD);
}

public LoadAllVehiclesFinish()
{
	mysql_store_result();
	
	new Field[64], Data[128], vId;
	for(vId = 0; vId < mysql_num_rows(); vId++)
	{
		mysql_fetch_row(Data);
		
		mysql_fetch_field_row(Field, "vehicleId");
		Vehicles[vId][vSqlID] = strval(Field);
		
		mysql_fetch_field_row(Field, "vModel");
		Vehicles[vId][vModel] = strval(Field);
		
		mysql_fetch_field_row(Field, "vType");
		Vehicles[vId][vType] = strval(Field);
		
		mysql_fetch_field_row(Field, "vPosXd");
		Vehicles[vId][vPosXd] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosYd");
		Vehicles[vId][vPosYd] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosZd");
		Vehicles[vId][vPosZd] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vAngZd");
		Vehicles[vId][vAngZd] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosX");
		Vehicles[vId][vPosX] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosY");
		Vehicles[vId][vPosY] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vPosZ");
		Vehicles[vId][vPosZ] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vAngZ");
		Vehicles[vId][vAngZ] = floatstr(Field);
		
		mysql_fetch_field_row(Field, "vColor1");
		Vehicles[vId][vColor1] = strval(Field);
		
		mysql_fetch_field_row(Field, "vColor2");
		Vehicles[vId][vColor2] = strval(Field);
		
		mysql_fetch_field_row(Field, "vOwner");
		Vehicles[vId][vOwner] = strval(Field);
		
		mysql_fetch_field_row(Field, "vValue");
		Vehicles[vId][vValue] = strval(Field);
		
		mysql_fetch_field_row(Field, "vDeaths");
		Vehicles[vId][vDeaths] = strval(Field);
		
		mysql_fetch_field_row(Field, "vHealth");
		Vehicles[vId][vHealth] = floatstr(Field);
		if(Vehicles[vId][vHealth] < 400.0) Vehicles[vId][vHealth] = 450.0;
		
		Vehicles[vId][vSampId] = AddStaticVehicleEx(Vehicles[vId][vModel], 
													Vehicles[vId][vPosXd],
													Vehicles[vId][vPosYd],
													Vehicles[vId][vPosZd],
													Vehicles[vId][vAngZd],
													/*Vehicles[vId][vColor1]*/-1,
													/*Vehicles[vId][vColor2]*/-1,
													VEHICLE_DELAY);
		//SetTimerEx("SetVehicleSpawn", 500, 0, "d", vId);
	}
	LOADED_VEHICLES = vId+1;
	printf("\t\t %d Vehicles Loaded.", LOADED_VEHICLES);
	mysql_free_result();
}

public SaveAllVehicles(closingdown)
{
	print("Started Saving all vehicles.");
	if(closingdown)
	{
		print("Saving all before server shutdown.");
		for(new i; i < LOADED_VEHICLES; i++)
		{
			SaveVehicle(i, false); // Kui server on kinni minemas peame kindlad olema, et ennem asjad salvestatud on.
		}
		print("All vehicles saved.");
	}
	else
	{
		SaveVehicle(VEHICLE_SAVE_NEXT, true);
		VEHICLE_SAVE_NEXT++;
	}
}

public SaveVehicle(vId, saveall)
{
	VehPos(vId);
	new query[512];
	
	format(query, 512, "UPDATE %svehicles SET vPosX = '%.5f', vPosY = '%.5f', vPosZ = '%.5f', vAngZ = '%.5f', vColor1 = '%d', vColor2 = '%d', vOwner = '%d', vValue = '%d', vDeaths = '%d', vHealth = '%f' WHERE vehicleId = '%d'",
		MYSQL_PREFIX,
		Vehicles[vId][vPosX],
		Vehicles[vId][vPosY],
		Vehicles[vId][vPosZ],
		Vehicles[vId][vAngZ],
		Vehicles[vId][vColor1],
		Vehicles[vId][vColor2],
		Vehicles[vId][vOwner],
		Vehicles[vId][vValue],
		Vehicles[vId][vDeaths],
		Vehicles[vId][vHealth],
		Vehicles[vId][vSqlID]);
	if(!saveall) mysql_query(query);
	else mysql_query(query, VEHICLE_SAVE_THREAD);
}

public SetVehicleSpawn(vId)
{
	SetVehicleHealth(Vehicles[vId][vSampId], Vehicles[vId][vHealth]);
	SetVehiclePos(Vehicles[vId][vSampId], Vehicles[vId][vPosX], Vehicles[vId][vPosY], Vehicles[vId][vPosZ]);
	SetVehicleZAngle(Vehicles[vId][vSampId], Vehicles[vId][vAngZ]);
}

public OnDriverEnterVehicle(playerid)
{
	new vId = GetVehicleSqlId(GetPlayerVehicleID(playerid));
	new Remove = false, Freeze = false;
	new string[128];
	
	if(vId == -1) Remove = false;
	else
	{
		if		(Vehicles[vId][vType] == VEHICLE_GROUP)
		{
			if(Vehicles[vId][vOwner] == 0) Remove = false;
			else if(IsGroupMember(playerid) != Vehicles[vId][vOwner]) Remove = true;
		}
		else if	(Vehicles[vId][vType] == VEHICLE_JOB)
		{
			if(Vehicles[vId][vOwner] == 0) Remove = false;
			else if(pInfo[playerid][pJob] != Vehicles[vId][vOwner]) Remove = true;
		}
		else if	(Vehicles[vId][vType] == VEHICLE_BUYABLE)
		{
			if(Vehicles[vId][vOwner] > 0) Remove = true;
			else
			{	
				format(string, 128, "~y~ %s ~n~~g~ Hind: %d SAK", CarNames[Vehicles[vId][vModel] - 400], Vehicles[vId][vValue]);
				GameTextForPlayer(playerid, string, 3000, 4);
				
				format(string, 128, "Kirjuta: /omasin, et seda masinat osta.");
				SendClientMessage(playerid, COLOR_GREEN, string);	
				Freeze = false;
			}
		}
		else if	(Vehicles[vId][vType] == VEHICLE_SPECIAL)
		{
			if(!IsPlayerNPC(playerid)) Remove = true;
		}
		else
		{
			if(pInfo[playerid][pAdmin] < 1) Remove = true;
			else if(pInfo[playerid][pAdmin] < Vehicles[vId][vOwner]) Remove = true;
		}
	}
	
	if(Remove)
	{
		RemovePlayerFromVehicle(playerid);
		SendClientMessage(playerid, COLOR_RED, LANG_VEH_NOKEYS);
	}
	else
	{
		if(Freeze) TogglePlayerControllable(playerid, 0);
	
		ShowSpeedo(playerid);
		format(string, 128, "%s", CarNames[Vehicles[vId][vModel] - 400]);
		GameTextForPlayer(playerid, string, 6000, 1);
	}
	return 1;
}

public OnDriverExitVehicle(playerid)
{
	OnSpeedoUpdate(playerid);
	new vId = GetVehicleSqlId(GetPlayerVehicleID(playerid));
	if(vId == -1) return 0;
	
	Vehicles[vId][vSpeed] = 0;
	InfoBarTimer[playerid] = -1;
	return 1;
}

public ShowSpeedo(playerid)
{
	if(InfoBarTimer[playerid] != -1) return 0;
	
	InfoBarTimer[playerid] = SetTimerEx("OnSpeedoUpdate", 200, 1, "i", playerid);
	TextDrawShowForPlayer(playerid, InfoBar[playerid]);	
	return 1;
}

public OnSpeedoUpdate(playerid)
{
	if(IsPlayerConnected(playerid) && IsPlayerInAnyVehicle(playerid))
	{
		new vId = GetVehicleSqlId(GetPlayerVehicleID(playerid));
		if(vId == -1) return 0;

		new oSpeed = Vehicles[vId][vSpeed], Float: oHealth = Vehicles[vId][vHealth];
		new Float: oX = Vehicles[vId][vSpeedX], Float: oY = Vehicles[vId][vSpeedY], Float: oZ = Vehicles[vId][vSpeedZ];
	
		GetVehicleHealth(Vehicles[vId][vSampId], Vehicles[vId][vHealth]);
		new hProtsenti = floatround((Vehicles[vId][vHealth] - 300) / 10);
		new string[128], fuel[3] = "-";
		
		GetVehicleVelocity(Vehicles[vId][vSampId], Vehicles[vId][vSpeedX], Vehicles[vId][vSpeedY], Vehicles[vId][vSpeedZ]);
		new Float: distance = floatabs(Vehicles[vId][vSpeedX]) + floatabs(Vehicles[vId][vSpeedY]) + floatabs(Vehicles[vId][vSpeedZ]);
		Vehicles[vId][vSpeed] = floatround(distance * 175);
		format(string,sizeof(string),"~y~~h~Bensiin: %s  ~y~~h~Kiirus: ~w~%i km/h  ~y~~h~Korras: ~w~%d", fuel, Vehicles[vId][vSpeed], hProtsenti);
		TextDrawSetString(InfoBar[playerid], string);
		
		if((oSpeed - Vehicles[vId][vSpeed]) > 50 && (oHealth - Vehicles[vId][vHealth]) > 50)
		{
			VehPos(vId);
			SendEmote(playerid, LANG_VEH_CRASH);
			SetPlayerPos(playerid, Vehicles[vId][vPosX], Vehicles[vId][vPosY], Vehicles[vId][vPosZ]+2);
			SetTimerEx("Velocity", 75, 0, "ifff", playerid, oX, oY, oZ);
			ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 1, 1, 1, 1);
			Vehicles[vId][vSpeed] = 0;
		}
	}
	else
	{
		TextDrawHideForPlayer(playerid, InfoBar[playerid]);
		KillTimer(InfoBarTimer[playerid]);
	}
	return 1;
}

public CheckCharacter(playerid)
{
	new eName[32], query[86];
	mysql_real_escape_string(pInfo[playerid][pCharName], eName);
	format(query, 86, "SELECT id, userid FROM %scharacters WHERE name = '%s' LIMIT 0, 1", MYSQL_PREFIX, eName);	
	mysql_query(query);
		
	if(mysql_store_result())
	{
		if(mysql_num_rows() > 0)
		{
			new Field[64], Data[128];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "id");
			pInfo[playerid][pSqlId] = strval(Field);
			
			mysql_fetch_field_row(Field, "userid");
			pInfo[playerid][uSqlId] = strval(Field);
			mysql_free_result();
			
			GetUserInfo(playerid);
			return 1;
		}	
	}
	
	SendClientMessage(playerid, COLOR_RED, LANG_NOCHARACTER);
	Kick(playerid);
	return 1;
}

public GetUserInfo(playerid)
{
	new query[86];
	format(query, 86, "SELECT username, password, salt FROM user WHERE userid = '%d' LIMIT 1", pInfo[playerid][uSqlId]);
	mysql_query(query);

	if(mysql_store_result() == 1)
	{		
		if(mysql_num_rows() > 0)
		{
			new Field[64], Data[128];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "username");
			strmid(pInfo[playerid][uUserName], Field, 0, strlen(Field), STRING_LENGHT);
			
			mysql_fetch_field_row(Field, "password");
			strmid(pInfo[playerid][uPassWordHash], Field, 0, strlen(Field), STRING_LENGHT);
			
			mysql_fetch_field_row(Field, "salt");
			strmid(pInfo[playerid][uSalt], Field, 0, strlen(Field), STRING_LENGHT);
			mysql_free_result();
		}	
		return 1;
	}
	SendClientMessage(playerid, COLOR_RED, LANG_NOUSER);
	Kick(playerid);
	return 1;
}

public AuthenticateUser(playerid, givenPassword[])
{
	new string[STRING_LENGHT];
	format(string, STRING_LENGHT, "%s", PasswordHash(givenPassword, pInfo[playerid][uSalt]));
	new strC = strcmp(pInfo[playerid][uPassWordHash], string, true);
	

	if(strC != 0) // wrong Password
	{
		SendClientMessage(playerid, COLOR_RED, LANG_WRONG_PASSWORD);
		showLogin(playerid);
	}
	else
	{
	    FetchCharacterInformation(playerid);
	}
	return 1;
}

public FetchCharacterInformation(playerid)
{
	if(Fetch_UInfo_Thread != -1) // thread is busy, lets attemp again in 1 second.
	{
		SetTimerEx("FetchCharacterInformation", 1000, 0, "i", playerid);
		return 1;
	}
	Fetch_UInfo_Thread = playerid;

	new query[86];
	format(query, 86, "SELECT * FROM %scharacters WHERE id = '%d' LIMIT 0, 1", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
	mysql_query(query, FETCH_UINFO_THREAD);
	SetTimerEx("FetchCharacterInformationFinish", SQL_FINISH_TIME, 0, "i", playerid);
	return 1;

}

public FetchCharacterInformationFinish(playerid)
{
	if(Fetch_UInfo_Thread != playerid) return 1;
	
	if(mysql_store_result() == 1)
	{
		if(mysql_num_rows() < 1)
		{
			SendClientMessage(playerid, COLOR_RED, LANG_NOCHARACTER);
			Kick(playerid);
		}
		else
		{
			new Field[64], Data[1024];
			mysql_fetch_row(Data);
			
			mysql_fetch_field_row(Field, "model");
			pInfo[playerid][pModel] = strval(Field);
			mysql_fetch_field_row(Field, "money");
			GivePlayerMoney(playerid, strval(Field));
			mysql_fetch_field_row(Field, "posX");
			pInfo[playerid][pPosX] = floatstr(Field);
			mysql_fetch_field_row(Field, "posY");
			pInfo[playerid][pPosY] = floatstr(Field);
			mysql_fetch_field_row(Field, "posZ");
			pInfo[playerid][pPosZ] = floatstr(Field);
			mysql_fetch_field_row(Field, "angle");
			pInfo[playerid][pAngle] = floatstr(Field);
			mysql_fetch_field_row(Field, "VirtualWorld");
			pInfo[playerid][pVW] = strval(Field);
			mysql_fetch_field_row(Field, "interior");
			pInfo[playerid][pInterior] = strval(Field);
			mysql_fetch_field_row(Field, "health");
			pInfo[playerid][pHealth] = floatstr(Field);
			mysql_fetch_field_row(Field, "adminLevel");
			pInfo[playerid][pAdminLevel] = strval(Field);
			
			mysql_free_result();
			LoadSkills(playerid);
		}
	}
	Fetch_UInfo_Thread = -1;
	return 1;
}

public UpdatePlayer(playerid)
{
	if(!pInfo[playerid][pLoggedIn]) return 1;
	
	GetPlayerPos(playerid, pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ]);
	GetPlayerFacingAngle(playerid, pInfo[playerid][pAngle]);
	GetPlayerHealth(playerid, pInfo[playerid][pHealth]);
	
	new sqlid = pInfo[playerid][pSqlId];
	
	new query[MAX_QUERY], table[32];
	format(table, 32, "%scharacters", MYSQL_PREFIX);
	
	MysqlUpdateBuild(query, table);
	
	MysqlUpdateInt(query, "money", GetPlayerMoney(playerid));
	MysqlUpdateInt(query, "model", pInfo[playerid][pModel]);
	MysqlUpdateFlo(query, "posX", pInfo[playerid][pPosX]);
	MysqlUpdateFlo(query, "posY", pInfo[playerid][pPosY]);
	MysqlUpdateFlo(query, "posZ", pInfo[playerid][pPosZ]);
	MysqlUpdateFlo(query, "angle", pInfo[playerid][pAngle]);

	MysqlUpdateInt(query, "VirtualWorld", pInfo[playerid][pVW]);
	MysqlUpdateInt(query, "interior", pInfo[playerid][pInterior]);
	MysqlUpdateFlo(query, "health", pInfo[playerid][pHealth]);
	MysqlUpdateInt(query, "adminLevel", pInfo[playerid][pAdminLevel]);
	
	MysqlUpdateFinish(query, "id", sqlid);

	return 1;
}

public UpdateAllPlayers()
{
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] )
	    UpdatePlayer(i);
		SaveSkills(i);
	}
}

public MysqlUpdateBuild(query[], table[])
{
	format(query, MAX_QUERY, "UPDATE %s SET ", table);
	return 1;
}

public MysqlUpdateInt(query[], field[], value)
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%d', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateFlo(query[], field[], Float: value)
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%f', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateStr(query[], field[], value[])
{
	new qLen = strlen(query);
	if(qLen+50 < MAX_QUERY) // It 's safe to add.
	{
		format(query, MAX_QUERY, "%s %s = '%s', ", query, field, value);
	}
	return 1;
}

public MysqlUpdateFinish(query[], field[], value)
{
	new qLen = strlen(query);
	strdel(query, qLen-2, qLen); // remove the extra comma 
	
	format(query, MAX_QUERY, "%s WHERE %s = '%d'", query, field, value);
	print(query);
	mysql_query(query);
}

public WarpPlayerToPlayer(WarpWho, WarpTo)
{
	new Float:WarpToX, Float:WarpToY, Float:WarpToZ;
	GetPlayerPos(WarpTo, WarpToX, WarpToY, WarpToZ);
	SetPlayerPos(WarpWho, WarpToX, WarpToY, WarpToZ);
}

public BanPlayer(playerid, banner, reason[])
{
	new str[STRING_LENGHT];
	format(str, sizeof(str), LANG_GLOBAL_BANMSG, pInfo[banner][pCharName], pInfo[playerid][pCharName], reason);
    SendClientMessageToAll(COLOR_ADMINMSG, str);
	// Siia v�iks mingi hea ban s�steemi teha :D
}

public KickPlayer(playerid, kicker, reason[])
{
	new str[STRING_LENGHT];
	format(str, sizeof(str), LANG_GLOBAL_KICKMSG, pInfo[kicker][pCharName], pInfo[playerid][pCharName], reason);
	SendClientMessageToAll(COLOR_ADMINMSG, str);
	Kick(playerid);
}

public ShowBanDialog(playerid)
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), LANG_DIALOG_BAN_S, pInfo[pInfo[playerid][SelectedPlayer]][pCharName]);
	ShowPlayerDialog(playerid, DIALOG_BANPLAYER, DIALOG_STYLE_INPUT, str, LANG_DIALOG_REASON, LANG_DIALOG_BAN, LANG_DIALOG_END);
}

public ShowKickDialog(playerid)
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), LANG_DIALOG_KICK_S, pInfo[pInfo[playerid][SelectedPlayer]][pCharName]);
	ShowPlayerDialog(playerid, DIALOG_KICKPLAYER, DIALOG_STYLE_INPUT, str, LANG_DIALOG_REASON, LANG_DIALOG_KICK, LANG_DIALOG_END);
}

public SendAdminChat(playerid, text[])
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), "(%i)%s: %s", pInfo[playerid][pAdminLevel], pInfo[playerid][pCharName], text);
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] && pInfo[i][pAdminLevel] > 0 )
	    	SendClientMessage(i, COLOR_ADMINCHAT, str);
	}
}
public SendTeata(playerid, text[])
{
	new str[STRING_LENGHT];
	format( str, sizeof(str), LANG_REPORT, playerid, pInfo[playerid][pCharName], text);
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] && pInfo[i][pAdminLevel] > 0 )
	    	SendClientMessage(i, COLOR_TEATA, str);
	}
}
public SendAdminMessage(playerid, text[])
{
    new str[STRING_LENGHT];
	format( str, sizeof(str), LANG_ADMINMSG, pInfo[playerid][pCharName], text);
	SendClientMessageToAll(COLOR_ADMIN_MESSAGE, str);
}

public Velocity(playerid, Float: X, Float: Y, Float: Z)
{
	SetPlayerVelocity(playerid, X, Y, Z);
	ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 1, 1, 1, 1);
}

public NPCHandle(playerid)
{
	new pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	if(!strcmp(pName, "Igor", true))
	{
		pInfo[playerid][npcId] = NPC_IGOR;
		strmid(pInfo[playerid][pCharName], "Igor_Yakov", 0, 30);
		return 1;
	}
	//Kick(playerid);
	return 0;
}

public AddCarToSQL(model, Float:posX, Float:posY, Float:posZ, Float:angle)
{
	new query[1028];
	format(query, sizeof(query), "INSERT INTO `estrpco_portal`.`ph_vehicles` (`vehicleId` ,`vModel` ,`vType` ,`vPosXd` ,`vPosYd` ,`vPosZd` ,`vAngZd` ,`vPosX` ,`vPosY` ,`vPosZ` ,`vAngZ` ,`vColor1` ,`vColor2` ,`vOwner` ,`vValue` ,`vDeaths` ,`vHealth`)VALUES (NULL , '%i', '0', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '-1', '-1', '0', '0', '0', '1000');", model, posX, posY, posZ, angle, posX, posY, posZ, angle);
	mysql_query(query, FETCH_UINFO_THREAD);
}

public LoadSkills(playerid)
{	
	new query[128];
	format(query, 128, "SELECT * FROM %sskills WHERE cid = '%d'", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
	mysql_query(query);
	
	if(mysql_store_result() == 1)
	{
		if(mysql_num_rows() > 0)
		{
			new Field[64], str[12];			
			for(new i = 0; i < MAX_SKILLS; i++)
			{
				format(str, 12, "skill_%d", i);
				mysql_fetch_field_row(Field, str);
				pInfo[playerid][pSkill][i]	= strval(Field);
			}			
			mysql_free_result();	

			SetSkills(playerid);
		
			SendClientMessage(playerid, COLOR_GREEN, LANG_LOGGED_IN);
			pInfo[playerid][pLoggedIn] = 1;
			SpawnPlayer(playerid);		
			return 1;			
		}
		else
		{
			mysql_free_result();
			format(query, 128, "INSERT INTO %sskills(id, cid) VALUES(NULL, '%d');", MYSQL_PREFIX, pInfo[playerid][pSqlId]);
			mysql_query(query);
			SetTimerEx("LoadSkills", 500, 0, "i", playerid);
			return 1;
		}
	}
	
	SendClientMessage(playerid, COLOR_RED, LANG_STATSERROR);
	Kick(playerid);
	return 1;
}

public SaveSkills(playerid)
{	
	new sqlid = pInfo[playerid][pSqlId];
	new query[MAX_QUERY], table[32];
	format(table, 32, "%sskills", MYSQL_PREFIX);
	
	MysqlUpdateBuild(query, table);
	
	new str[12];			
	for(new i = 0; i < MAX_SKILLS; i++)
	{
		format(str, 12, "skill_%d", i);
		MysqlUpdateInt(query, str, pInfo[playerid][pSkill][i]);
	}
	
	MysqlUpdateFinish(query, "cid", sqlid);	
	return 1;
}

public XpAdd(playerid, skillId, amount)
{
	new xpNeeded;
	new oldLevel = GetLevel(skillId, pInfo[playerid][pSkill][skillId], xpNeeded);
	pInfo[playerid][pSkill][skillId] += amount;
	
	if( skillId == SKILL_PISTOL )
	{
	    if ( IsPlayerInAnyVehicle(playerid) || GetPlayerWeapon(playerid) != 22 )
		{
		    if( pInfo[playerid][pSkillTimer] != 0 )
		    {
				KillTimer(pInfo[playerid][pSkillTimer]);
				pInfo[playerid][pSkillTimer] = 0;
			}
			return 1;
		}
		SkillDelay[playerid][SKILL_PISTOL] = 1;
		SetTimerEx("ClearDelay", 285, 0, "ii", playerid, SKILL_PISTOL);
	}
	
	if(pInfo[playerid][pSkill][skillId] >= xpNeeded)
	{	
		OnLevelUp(playerid, skillId, (oldLevel+1), 1);
	}
	
	//UpdateSkillDraw(playerid, skillId, amount);
	return 1;
}

public SetSkills(playerid)
{
	for(new i = 0; i < MAX_SKILLS; i++)
	{
		new xpNeeded;
		new level = GetLevel(i, pInfo[playerid][pSkill][i], xpNeeded);
		OnLevelUp(playerid, i, level, 0);
	}
}

public OnLevelUp(playerid, skillId, newLevel, showMsg)
{
	if(showMsg == 1)
	{
		//	LevelAP
		new string[128];
		format(string, 128, LANG_LEVELUP, Skills[skillId][sName], newLevel, pInfo[playerid][pSkill][skillId]);
		SendClientMessage(playerid, COLOR_GREEN, string);
	}
	
	if(skillId < 11) SetPlayerSkillLevel(playerid, skillId, floatround(newLevel*10));
	return 1;
}

public ClearDelay(playerid, skillId)
{
	SkillDelay[playerid][skillId] = 0;
	return 1;
}

public CheckFalseDeadPlayers(playerid)
{
	new Float:health;
	for( new i = 0; i <= MAX_PLAYERS; i++ )
	{
	    if( IsPlayerConnected(i) && pInfo[i][pLoggedIn] )
	    {
	    	health = GetPlayerHealth(i, health);
	    	if( health < 1 )
	   		{
				SpawnPlayer(i);
	    	}
	    }
	}
}
/*
*    EOF
*/
