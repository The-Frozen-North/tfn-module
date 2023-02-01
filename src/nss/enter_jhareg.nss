#include "inc_quest"
#include "nwnx_visibility"

void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsObjectValid(oPC)) return;

    // quest already completed
    if (GetQuestEntry(oPC, "q_charwood") == 3)
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_quint"), NWNX_VISIBILITY_HIDDEN);
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_karlat"), NWNX_VISIBILITY_HIDDEN);
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_belial"), NWNX_VISIBILITY_HIDDEN);

        return;
    }

    if (GetQuestEntry(oPC, "q_charwood_quint") == 1)
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_quint"), NWNX_VISIBILITY_DEFAULT);
    }
    else
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_quint"), NWNX_VISIBILITY_HIDDEN);
    }

    if (GetQuestEntry(oPC, "q_charwood_karlat") == 1)
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_karlat"), NWNX_VISIBILITY_DEFAULT);
    }
    else
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_karlat"), NWNX_VISIBILITY_HIDDEN);
    }

    if (GetQuestEntry(oPC, "q_charwood_belial") == 1)
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_belial"), NWNX_VISIBILITY_DEFAULT);
    }
    else
    {
        NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("quest_belial"), NWNX_VISIBILITY_HIDDEN);
    }
}
