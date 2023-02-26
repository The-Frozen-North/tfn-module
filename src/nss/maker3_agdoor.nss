// Maker3, if you open aghaaz door
// Attacking these should make both aghaazboss and aghaaz factions attack you

#include "x0_i0_partywide"
#include "nwnx_creature"
#include "inc_ai_combat"

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
    
    object oPC = GetLastOpenedBy();
    int i;
    object oArea = GetObjectByTag("ud_maker3");
    for (i=0; i<2; i++)
    {
        string sOtherFaction = i > 0 ? "aghaazboss_faction" : "aghaaz_faction";
        int nOtherFaction = GetLocalInt(oArea, sOtherFaction);
	
        if (nOtherFaction > 0)
        {
            // Find something else of that faction to make angry
            int n=1;
            while (1)
            {
                object oTest = GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, n);
                if (NWNX_Creature_GetFaction(oTest) == nOtherFaction)
                {
                    int nExisting = GetReputation(oPC, oTest);
                    AdjustReputationWithFaction(oPC, oTest, -nExisting);
                    AssignCommand(oTest, gsCBDetermineCombatRound(oPC));
                    SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
                    break;
                }
                n++;
                if (!GetIsObjectValid(oTest))
                {
                    break;
                }
            }
        }
    }
}
