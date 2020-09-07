#include "inc_quest"
#include "nwnx_visibility"

void main()
{
    object oPC = GetEnteringObject();

    if (GetIsObjectValid(oPC) && GetQuestEntry(oPC, "q_rescue") != 1) NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("BALINDA"), NWNX_VISIBILITY_HIDDEN);
}
