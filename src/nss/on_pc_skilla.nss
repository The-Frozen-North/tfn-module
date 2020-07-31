#include "nwnx_events"
#include "nwnx_object"
#include "inc_horse"

void main()
{
    if (StringToInt(NWNX_Events_GetEventData("SKILL_ID")) == SKILL_PICK_POCKET)
    {
        AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_FIREFORGET_STEAL));
    }
}
