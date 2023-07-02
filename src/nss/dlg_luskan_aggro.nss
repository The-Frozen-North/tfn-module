#include "inc_ai_combat"

void main()
{
    object oPC = GetPCSpeaker();

    PlayVoiceChat(VOICE_CHAT_ATTACK, OBJECT_SELF);

    float fRadius = 30.0;
    location lLocation = GetLocation(OBJECT_SELF);

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
       if (!GetIsDead(oTarget) && GetObjectSeen(oPC, oTarget) && GetFactionEqual(oTarget, OBJECT_SELF))
       {
           SetIsTemporaryEnemy(oPC,oTarget, TRUE);
           AssignCommand(oTarget, gsCBDetermineCombatRound(oPC));
       }
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    }

    SetIsTemporaryEnemy(oPC, OBJECT_SELF, TRUE);
    gsCBDetermineCombatRound(oPC);
}
