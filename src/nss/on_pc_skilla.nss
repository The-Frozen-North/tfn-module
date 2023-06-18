#include "nwnx_events"
#include "nwnx_object"
#include "inc_horse"

void main()
{
    if (StringToInt(NWNX_Events_GetEventData("SKILL_ID")) == SKILL_PICK_POCKET)
    {
        AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_FIREFORGET_STEAL));
    }
    else if (StringToInt(NWNX_Events_GetEventData("SKILL_ID")) == SKILL_ANIMAL_EMPATHY)
    {
        object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));

// do not get master from the script function - this may be the PC that successfully used animal empathy
// instead, use the stored master
        object oMaster = GetLocalObject(oTarget, "master");

        SetIsTemporaryEnemy(OBJECT_SELF, oMaster);
    }
}
