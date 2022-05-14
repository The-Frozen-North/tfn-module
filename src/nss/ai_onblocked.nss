#include "inc_ai_event"
#include "inc_ai_combat"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_BLOCKED));

    object oDoor = GetBlockingDoor();

    if (GetLocalObject(OBJECT_SELF, "GS_AI_ACTION_TARGET") != oDoor)
    {
        // used to attack nearby creatures if they bump into them, supposedly if they are invisible
        if (GetObjectType(oDoor) == OBJECT_TYPE_CREATURE && GetIsEnemy(oDoor) && (GetObjectSeen(oDoor) || GetObjectHeard(oDoor)))
        {
            gsCBDetermineCombatRound(oDoor);
        }
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

