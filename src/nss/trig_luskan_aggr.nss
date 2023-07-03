#include "inc_ai_combat"

void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC)) return;

    float fRadius = 40.0;
    location lLocation = GetLocation(oPC);

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    object oFactionDummy = GetObjectByTag("FACTION_LUSKANCITY");

    while (GetIsObjectValid(oTarget))
    {
       if (!GetIsDead(oTarget) && GetObjectSeen(oPC, oTarget) && GetFactionEqual(oTarget, oFactionDummy))
       {
           SetIsTemporaryEnemy(oPC,oTarget, TRUE);
           // AssignCommand(oTarget, gsCBDetermineCombatRound(oPC));
       }
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    }
}
