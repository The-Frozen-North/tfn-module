#include "inc_quest"
#include "nwnx_visibility"

void main()
{
    object oPC = GetEnteringObject();

    if (GetIsObjectValid(oPC) && GetQuestEntry(oPC, "q_druid_terari") < 2) NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("TERARI_HOME"), NWNX_VISIBILITY_HIDDEN);
}
