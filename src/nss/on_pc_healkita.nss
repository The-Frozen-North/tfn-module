#include "nwnx_events"

void main()
{
    object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));
    if (GetLocalInt(oTarget, "healers_kit_cd") == 1 && GetIsInCombat(oTarget)) return;

    if (GetIsInCombat(oTarget))
    {
        SetLocalInt(oTarget, "healers_kit_cd", 1);
        DelayCommand(6.0, DeleteLocalInt(oTarget, "healers_kit_cd"));
    }

    float fDuration = 3.0;

    ActionPlayAnimation(ANIMATION_LOOPING_CONJURE1, 1.0, fDuration);
    if (GetLocalInt(oTarget, "healers_kit_cd") == 1)
    {
        SetCommandable(FALSE);
        DelayCommand(fDuration, SetCommandable(TRUE));
    }
}
