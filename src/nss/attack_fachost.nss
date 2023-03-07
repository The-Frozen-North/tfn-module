#include "x0_i0_partywide"

// Make everyone in the attacked creature's faction hate the PC that attacked them

void main()
{
    object oPC = GetLastAttacker();
    if (GetIsPC(oPC))
    {
        AdjustReputationWithFaction(oPC, OBJECT_SELF, -100);
        SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
    }
}
