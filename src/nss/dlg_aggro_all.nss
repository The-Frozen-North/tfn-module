#include "inc_ai_combat"

void main()
{
    object oPC = GetPCSpeaker();

    SetIsTemporaryEnemy(oPC, OBJECT_SELF, TRUE);
    gsCBDetermineCombatRound(oPC);

    object oAssociate = GetFirstFactionMember(oPC, FALSE);

    float fRadius = 15.0;

    location lLocation = GetLocation(OBJECT_SELF);

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    while(GetIsObjectValid(oTarget))
    {
        if(GetFactionEqual(oTarget, OBJECT_SELF))
        {
            SetIsTemporaryEnemy(oPC, oTarget, TRUE);
            SetLocalInt(oTarget, "combat", 1);
            
            if (!GetIsInCombat(oTarget))
            {
                AssignCommand(oTarget, FastBuff());
            }

            AssignCommand(oTarget, gsCBDetermineCombatRound(oPC));
        }
        //Get next target in area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    }
}
