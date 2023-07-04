#include "inc_ai_combat"

void main()
{
    string sResRef = GetResRef(OBJECT_SELF);

    if (sResRef != "hawk_soldier" && sResRef != "hawk_footman") return;

    object oDummy = GetNearestObjectByTag("luskan_combat_dummy");


    if (gsCBGetHasAttackTarget()) return;

    if (GetDistanceToObject(oDummy) > 5.0) return;

    ActionAttack(oDummy);
}
