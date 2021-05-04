#include "inc_ai_event"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_BLOCKED));

    object oDoor = GetBlockingDoor();

    if (GetLocalObject(OBJECT_SELF, "GS_AI_ACTION_TARGET") != oDoor)
    {
        if (GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 6)
        {
            if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN))
                DoDoorAction(oDoor, DOOR_ACTION_OPEN);
        }
        else
        {
            if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_BASH))
                DoDoorAction(oDoor, DOOR_ACTION_BASH);
        }
    }
}

