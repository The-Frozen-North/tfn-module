// Shared dialog action file for Ferron/Aghaaz
// which does things relating to faction reputations in the area

#include "x0_i0_partywide"
#include "nwnx_creature"
#include "inc_ai_combat"

void main()
{
    string sFacName = GetScriptParam("faction");
    int nMod = StringToInt(GetScriptParam("val"));
    
    int nFactionID = GetLocalInt(GetArea(OBJECT_SELF), sFacName);
    object oPC = GetPCSpeaker();
    
    // Find a member of the faction ID to make angry
    int n=1;
    while (1)
    {
        object oTest = GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, n);
        if (NWNX_Creature_GetFaction(oTest) == nFactionID)
        {
            int nExisting = GetReputation(oPC, oTest);
            int nDiff = nMod - nExisting;
            AdjustReputationWithFaction(oPC, oTest, nDiff);
            if (nMod < 10)
            {
                AssignCommand(oTest, gsCBDetermineCombatRound(oPC));
                SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
            }
            break;
        }
        n++;
        if (!GetIsObjectValid(oTest))
        {
            break;
        }
    }
    
}