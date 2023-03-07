// Maker3 on attacked for the boss factions
// Attacking these should make all the followers hostile as well

#include "x0_i0_partywide"
#include "nwnx_creature"

void main()
{
    // The lookup is probably quite heavy, don't do it lots of times
    if (GetLocalInt(OBJECT_SELF, "maker3_adjustedfactions"))
    {
        return;
    }
    SetLocalInt(OBJECT_SELF, "maker3_adjustedfactions", 1);
    // If this creature is no longer valid, this failing doesn't matter at all
    DelayCommand(300.0, DeleteLocalInt(OBJECT_SELF, "maker3_adjustedfactions"));
    
    object oPC = GetLastAttacker();
    AdjustReputationWithFaction(oPC, OBJECT_SELF, -100);
	object oArea = GetObjectByTag("ud_maker3");
	int nMyFaction = NWNX_Creature_GetFaction(OBJECT_SELF);
	int nOtherFaction = -1;
	if (nMyFaction == GetLocalInt(oArea, "aghaazboss_faction"))
	{
		nOtherFaction = GetLocalInt(oArea, "aghaaz_faction");
	}
	else if (nMyFaction == GetLocalInt(oArea, "ferronboss_faction"))
	{
		nOtherFaction = GetLocalInt(oArea, "ferron_faction");
	}
	
	if (nOtherFaction > 0)
	{
		// Find something else of that faction to make angry
		int n=1;
		while (1)
		{
			object oTest = GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, n);
			if (NWNX_Creature_GetFaction(oTest) == nOtherFaction)
			{
				AdjustReputationWithFaction(oPC, oTest, -100);
				break;
			}
			n++;
			if (!GetIsObjectValid(oTest))
			{
				break;
			}
		}
	}
    SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
}
