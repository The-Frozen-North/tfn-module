#include "inc_debug"
#include "nwnx_util"
#include "inc_loot"


struct LootableEntity
{
    int nCR;
    int nIsBoss;
    int nIsSemiboss;
    int nIsTreasure;
    int nAreaCR;
};

string ZFillInt(int nNum, int nNumPlaces=3)
{
    string sOut = IntToString(nNum);
    while (GetStringLength(sOut) < nNumPlaces)
    {
        sOut = "0" + sOut;
    }
    return sOut;
}

string LootableEntityToString(struct LootableEntity le)
{
    string sOut = ZFillInt(le.nCR) + ZFillInt(le.nIsBoss) + ZFillInt(le.nIsSemiboss) + ZFillInt(le.nIsTreasure) + ZFillInt(le.nAreaCR);
    return sOut;
}

struct LootableEntity StringToLootableEntity(string sLE)
{
    struct LootableEntity leOut;
    leOut.nCR = StringToInt(GetSubString(sLE, 0, 3));
    leOut.nIsBoss = StringToInt(GetSubString(sLE, 3, 3));
    leOut.nIsSemiboss = StringToInt(GetSubString(sLE, 6, 3));
    leOut.nIsTreasure = StringToInt(GetSubString(sLE, 9, 3));
    leOut.nAreaCR = StringToInt(GetSubString(sLE, 12, 3));
    return leOut;
}


void main()
{
    object oDev = OBJECT_SELF;
    if (!GetIsDevServer())
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_listloot, but the server is not in developer mode");
        return;
    }

    if (!GetIsDeveloper(oDev))
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_listloot, but they are not a developer");
        return;
    }
    SendMessageToAllDMs(GetName(oDev) + " is running dev_listloot in area: " + GetName(GetArea(oDev)) + ", tag: " + GetTag(GetArea(oDev)));
    SendDiscordLogMessage(GetName(oDev) + " is running dev_listloot in area: " + GetName(GetArea(oDev)) + ", tag: " + GetTag(GetArea(oDev)));

    // This is way easier than circumvention...
    int nOldInstructionLimit = NWNX_Util_GetInstructionLimit();
    NWNX_Util_SetInstructionLimit(52428888);

    object oArea = GetArea(oDev);
    object oTest = GetFirstObjectInArea(oArea);
    int nStartXP = GetXP(oDev);
	
	int nAreaCR = GetLocalInt(oArea, "cr");
	
	int nVarNumber = 0;
	string sVarTrackerStem = "dev_lootvalue_tracker";
	
    while (GetIsObjectValid(oTest))
    {
        int nObjType = GetObjectType(oTest);
        if (nObjType == OBJECT_TYPE_CREATURE)
        {
            if (!GetIsDead(oTest) && !GetIsPC(oTest))
            {
				struct LootableEntity leCreature;
				leCreature.nAreaCR = nAreaCR;
				leCreature.nCR = GetLocalInt(oTest, "cr");
				if (leCreature.nCR > 0 && !GetLocalInt(oTest, "no_credit"))
				{
					int nIsGoodRace = TRUE;
					int nRace = GetRacialType(oTest);
					switch (nRace)
					{
						case RACIAL_TYPE_MAGICAL_BEAST:
						case RACIAL_TYPE_ANIMAL:
						case RACIAL_TYPE_VERMIN:
						case RACIAL_TYPE_BEAST:
						   nIsGoodRace = FALSE;
						break;
					}
					if (nIsGoodRace)
					{
						leCreature.nIsBoss = GetLocalInt(oTest, "boss");
						leCreature.nIsSemiboss = GetLocalInt(oTest, "semiboss");
						leCreature.nIsTreasure = 0;
						string sVar = LootableEntityToString(leCreature);
						if (GetLocalInt(oDev, sVar) <= 0)
						{
                            SendMessageToPC(oDev, "Var index " + IntToString(nVarNumber) + ": " + GetName(oTest) + "-> " + sVar);
							SetLocalString(oDev, sVarTrackerStem + IntToString(nVarNumber), sVar);
							nVarNumber++;
						}
						SetLocalInt(oDev, sVar, GetLocalInt(oDev, sVar) + 1);
					}
				}
            }
        }
        else if (nObjType == OBJECT_TYPE_PLACEABLE)
        {
            if (GetLocalInt(oTest, "cr") > 0 && GetResRef(oTest) != "_loot_container")
            {
                struct LootableEntity leTreasure;
				leTreasure.nAreaCR = nAreaCR;
				leTreasure.nCR = GetLocalInt(oTest, "cr");
				leTreasure.nIsBoss = 0;
				leTreasure.nIsSemiboss = 0;
				leTreasure.nIsTreasure = 1;
				string sVar = LootableEntityToString(leTreasure);
				if (GetLocalInt(oDev, sVar) <= 0)
				{
					SetLocalString(oDev, sVarTrackerStem + IntToString(nVarNumber), sVar);
					nVarNumber++;
				}
				SetLocalInt(oDev, sVar, GetLocalInt(oDev, sVar) + 1);
            }
        }
        oTest = GetNextObjectInArea(oArea);
    }
    
	int i;
	for (i=0; i<nVarNumber; i++)
	{
		string sVarTracker = "dev_lootvalue_tracker" + IntToString(i);
		string sRealVar = GetLocalString(oDev, sVarTracker);
		DeleteLocalString(oDev, sVarTracker);
		struct LootableEntity le = StringToLootableEntity(sRealVar);
		int nNumIncidences = GetLocalInt(oDev, sRealVar);
		DeleteLocalInt(oDev, sRealVar);
		string sMessage = "Incidences= " + IntToString(nNumIncidences) + ", AreaCR=" + IntToString(le.nAreaCR) + ", CR=" + IntToString(le.nCR);
		if (le.nIsTreasure)
		{
			sMessage += ", IsTreasure";
		}
		if (le.nIsBoss)
		{
			sMessage += ", IsBoss";
		}
		if (le.nIsSemiboss)
		{
			sMessage += ", IsSemiboss";
		}
		SendMessageToPC(oDev, sMessage);
	}
	
	
    NWNX_Util_SetInstructionLimit(nOldInstructionLimit);
}

