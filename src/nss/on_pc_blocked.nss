#include "inc_ai_combat"

void main()
{

    object oDoor = GetBlockingDoor();

    // if the PC bumps into an enemy and they detect them, make the enemy attack
    if (GetObjectType(oDoor) == OBJECT_TYPE_CREATURE && GetIsEnemy(OBJECT_SELF, oDoor) && (GetObjectSeen(OBJECT_SELF, oDoor) || GetObjectHeard(OBJECT_SELF, oDoor)))
    {
        AssignCommand(oDoor, gsCBDetermineCombatRound(OBJECT_SELF));
    }
}

