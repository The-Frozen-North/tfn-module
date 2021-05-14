#include "inc_quest"
#include "nwnx_visibility"

void main()
{
    object oPC = GetEnteringObject();

    if (GetIsObjectValid(oPC))
    {
        object oTerari = GetObjectByTag("TERARI_HOME");
        if (GetQuestEntry(oPC, "q_druid_terari") < 2)
        {
            NWNX_Visibility_SetVisibilityOverride(oPC, oTerari, NWNX_VISIBILITY_HIDDEN);
        }
        else
        {
            NWNX_Visibility_SetVisibilityOverride(oPC, oTerari, NWNX_VISIBILITY_DEFAULT);
        }
    }
}
