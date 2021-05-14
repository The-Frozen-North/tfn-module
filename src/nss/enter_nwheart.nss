#include "inc_quest"
#include "nwnx_visibility"

void main()
{
    object oPC = GetEnteringObject();

    if (GetIsObjectValid(oPC))
    {
        object oElaina = GetObjectByTag("elaina");
        if (GetQuestEntry(oPC, "q_dryad") < 4)
        {
            NWNX_Visibility_SetVisibilityOverride(oPC, oElaina, NWNX_VISIBILITY_HIDDEN);
        }
        else
        {
            NWNX_Visibility_SetVisibilityOverride(oPC, oElaina, NWNX_VISIBILITY_DEFAULT);
        }
    }
}
