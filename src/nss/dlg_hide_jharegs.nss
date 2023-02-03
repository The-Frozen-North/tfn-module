#include "nwnx_visibility"

void main()
{
        object oPC = GetPCSpeaker();

        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_quint"), NWNX_VISIBILITY_HIDDEN);
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_karlat"), NWNX_VISIBILITY_HIDDEN);
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_belial"), NWNX_VISIBILITY_HIDDEN);
}
