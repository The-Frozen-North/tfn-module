#include "inc_debug"
#include "nwnx_util"
#include "inc_xp"
// run via dm_runscript
// Dump lots of numbers about xp from kills in all areas to the log
// You just then have to slice the timestamp prefix off and save as csv, and hope no other log lines were generated in the middle

void RunOnArea(object oArea)
{
    int nOldInstructionLimit = NWNX_Util_GetInstructionLimit();
    NWNX_Util_SetInstructionLimit(52428888);
    
    int nLevel;
    for (nLevel = 2; nLevel <= 12; nLevel++)
    {
        DeleteLocalFloat(oArea, "dev_xpvalues" + IntToString(nLevel));
    }
    
    
    object oTest = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oTest))
    {
        NWNX_Util_SetInstructionsExecuted(0);
        if (!GetIsDead(oTest) && GetIsObjectValid(oTest) && GetObjectType(oTest) == OBJECT_TYPE_CREATURE)
        {
            for (nLevel = 2; nLevel <= 12; nLevel++)
            {
                float fMultiplier = 1.0;
                if (GetLocalInt(oTest, "boss") == 1)
                {
                    fMultiplier = 3.0;
                }
                else if (GetLocalInt(oTest, "semiboss") == 1)
                {
                    fMultiplier = 2.0;
                }
                float fThis = GetPartyXPValue(oTest, 0, IntToFloat(nLevel), 1, fMultiplier);
                string sVar = "dev_xpvalues" + IntToString(nLevel);
                SetLocalFloat(oArea, sVar, GetLocalFloat(oArea, sVar) + fThis);
            }
        }
        oTest = GetNextObjectInArea(oArea);
    }
    
    string sLogEntry = GetTag(oArea) + "," + IntToString(GetLocalInt(oArea, "cr"));
    for (nLevel = 2; nLevel <=12; nLevel++)
    {
        float fThis = GetLocalFloat(oArea, "dev_xpvalues" + IntToString(nLevel));
        sLogEntry += "," + FloatToString(fThis, 8, 2);
    }
    
    WriteTimestampedLogEntry(sLogEntry);
    
    NWNX_Util_SetInstructionLimit(nOldInstructionLimit);
}

void main()
{
    object oDev = OBJECT_SELF;
    if (!GetIsDevServer())
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_xpvalues, but the server is not in developer mode");
        return;
    }

    if (!GetIsDeveloper(oDev))
    {
        SendMessageToAllDMs(GetName(oDev) + " tried to run dev_xpvalues, but they are not a developer");
        return;
    }
    SendMessageToAllDMs(GetName(oDev) + " is running dev_xpvalues");
    SendDiscordLogMessage(GetName(oDev) + " is running dev_xpvalues");
    
    WriteTimestampedLogEntry("========================================");
    WriteTimestampedLogEntry("areatag,areacr,2,3,4,5,6,7,8,9,10,11,12");

	int nAreaIndex = 0;
	float fDelay = 0.1*nAreaIndex;
	object oArea = GetFirstArea();
	while (GetIsObjectValid(oArea))
	{
		if (GetLocalInt(oArea, "cr") > 0)
		{
			fDelay = 0.1*nAreaIndex;
			nAreaIndex++;
			DelayCommand(fDelay, RunOnArea(oArea));
		}
		oArea = GetNextArea();
	}
	
}

