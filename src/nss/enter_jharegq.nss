#include "inc_quest"
#include "nwnx_visibility"

void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsObjectValid(oPC)) return;

    if (GetQuestEntry(oPC, "q_charwood_quint") == 1)
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quint"), NWNX_VISIBILITY_HIDDEN);
    }
    else
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quint"), NWNX_VISIBILITY_DEFAULT);
    }
}
