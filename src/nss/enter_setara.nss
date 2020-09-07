#include "inc_quest"
#include "nwnx_visibility"

void main()
{
    object oPC = GetEnteringObject();

    if (GetIsObjectValid(oPC) && GetQuestEntry(oPC, "q_druid_bree") != 1) NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("BREE"), NWNX_VISIBILITY_HIDDEN);
}
