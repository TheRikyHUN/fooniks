#include <a_npc>
#include <foreach>
#include <sscanf_NPC>

#define MY_NAME "Jann"

#define DEFAULT_NOANWSER	"ok siis"

#include <smart_npc>

public OnNPCModeInit()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT, "Recycle");
	SetTimer("SmartInit", 3000, 0);
}	

public SmartInit()
{
	MakeSmart(MY_NAME, 242, 2441.3633, -1422.0017, 24.0, 270.0);
	SetMaxMood(3);	
	
	AddDefaultMessage(0, "R��gi ARUSAADAVALT!");
	AddDefaultMessage(0, "MIDA!??");
	AddDefaultMessage(1, "Oota, Misasja?");
	AddDefaultMessage(1, "Ma ei m�ista su keelt?");
	AddDefaultMessage(2, "Ma ei saa sust aru.");
	AddDefaultMessage(2, "R��gi arusaadavalt.");
	AddDefaultMessage(3, "Palun r��gi selgemalt.");
	AddDefaultMessage(3, "Palun r��gi arusaadavalt.");
	
	new tGroup1 = AddTriggerGroup(1);
	AddTriggerWord(tGroup1, "tere");
	AddTriggerWord(tGroup1, "j�u");
	AddTriggerWord(tGroup1, "jou");
	AddTriggerWord(tGroup1, "jann");
	AddTriggerWord(tGroup1, "hey");
	AddTriggerWord(tGroup1, "hei");
	new tempSentenceId;
	
	AddSentence(tGroup1, 0, "Kasi minema!");
	AddSentence(tGroup1, 0, "Kao �ra!");
	AddSentence(tGroup1, 0, "Ma l�petan oma suitsu �ra ja tulen �petan sind v�heke!");
	
	AddSentence(tGroup1, 1, "Ole vait!");
	AddSentence(tGroup1, 1, "J�ta mind rahule, niigi raske p�ev olnud.");
	
	AddSentence(tGroup1, 2, "Tere tere.");
	AddSentence(tGroup1, 2, "Tervist noorh�rra!");
	AddSentence(tGroup1, 2, "Tere. Ilus p�ev t�na, v�i mis?");
	
	AddSentence(tGroup1, 3, "Tere, t��d tahad?");
	AddSentence(tGroup1, 3, "Tere jah, ma olen Jann.");	
	
	new tGroup2 = AddTriggerGroup(-1);
	AddTriggerWord(tGroup2, "munn");
	AddTriggerWord(tGroup2, "pede");
	AddTriggerWord(tGroup2, "homo");
	AddTriggerWord(tGroup2, "gey");
	AddTriggerWord(tGroup2, "lits");
	AddTriggerWord(tGroup2, "hoor");
	AddTriggerWord(tGroup2, "munn");
	AddTriggerWord(tGroup2, "hoor");
	
	AddSentence(tGroup2, 0, "Ma tapan su �ra!");
	AddSentence(tGroup2, 0, "Kui ma su k�tte saan, raisk!");
	AddSentence(tGroup2, 0, "K�I PERSE RAISK, NOLK SELLINE, KAO MINEMA!");
	
	AddSentence(tGroup2, 1, "Ole parem vait.");
	AddSentence(tGroup2, 1, "K�i �ige kuradile!");
	AddSentence(tGroup2, 1, "Samad s�nad.");	
	
	AddSentence(tGroup2, 2, "Sama sullegi.");
	AddSentence(tGroup2, 2, "Edu.");
	AddSentence(tGroup2, 2, "Kuradi lohh, ole vait parem.");
	
	AddSentence(tGroup2, 3, "Lohh");
	
	new tGroup3 = AddTriggerGroup(0);
	AddTriggerWord(tGroup3, "t��d");
	AddTriggerWord(tGroup3, "tahan");
	AddTriggerWord(tGroup3, "teha");	
	AddTriggerWord(tGroup3, "k�ll");	
	AddTriggerWord(tGroup3, "ikka");	
	
	AddSentence(tGroup3, 0, "Ei saa sa mingit t��d...");
	AddSentence(tGroup3, 0, "Sina ja t��d, Ahh k�i parem perse.");
	AddSentence(tGroup3, 1, "Kui sa v�he korralikumalt k�ituda m�istaksid siis ehk saaksid t��le.");
	AddSentence(tGroup3, 1, "Mul ei ole sulle k�ll t��d anda.");
	
	tempSentenceId = AddSentence(tGroup3, 0, "Ei annaks ka sulle.");
	SetNegative(tempSentenceId);
	tempSentenceId = AddSentence(tGroup3, 0, "Sulle ma ei annaks ka.");
	SetNegative(tempSentenceId);
	tempSentenceId = AddSentence(tGroup3, 1, "Mul ei oleks sulle anda ikka...");
	SetNegative(tempSentenceId);
	
	tempSentenceId = AddSentence(tGroup3, 2, "s�h, uuri lepingut.");
	AddSentenceJobFunction(tempSentenceId, 1);
	tempSentenceId = AddSentence(tGroup3, 2, "n�e uuri lepingut.");
	AddSentenceJobFunction(tempSentenceId, 1);
	tempSentenceId = AddSentence(tGroup3, 3, "Palun, uuri lepingut.");
	AddSentenceJobFunction(tempSentenceId, 1);	

	tempSentenceId = AddSentence(tGroup3, 2, "Kui ei taha, siis ei saa ka.");
	SetNegative(tempSentenceId);
	tempSentenceId = AddSentence(tGroup3, 3, "Kui ei taha, siis ei taha.");
	SetNegative(tempSentenceId);

	AddAutoMessage(0, "Mis sa siit otsid?");
	AddAutoMessage(1, "Mis vahid siin, kao minema!");
	AddAutoMessage(2, "Aega on? Mul oleks t��d pakkuda... Tahad?");
	AddAutoMessage(2, "T��d tahad?");
	AddAutoMessage(3, "Hei sina, t��d tahad?");
	AddAutoMessage(3, "Hei, t��d soovid?");
}

public OnRecordingPlaybackEnd()
{
    StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT, "Recycle");
}

public OnClientMessage(color, text[])
{
	if(color == SMART_COLOR)
	{
		if(!strcmp(text, "myPOS"))
		{
			SMARTSPAWN("%d %f %f %f %f", gMySelf[mySkin], gMySelf[myPosX], gMySelf[myPosY], gMySelf[myPosZ], gMySelf[myPosAng]);
			return 1;
		}
		
		new fromPlayer, text2[128];
		if(sscanf(text, "ds", fromPlayer, text2) == 0)
		{
			if(!strcmp(text2, "autoMessage"))
			{
				AutoMessage(fromPlayer);
				return 1;
			}
			else
			{			
				AnwserCheck(fromPlayer, text2);
				return 1;
			}
		}
	}
	return 0;
}