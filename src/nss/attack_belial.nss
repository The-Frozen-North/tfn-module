#include "inc_ai_combat"

void main()
{
    object oPC = GetPCSpeaker();
    SetIsTemporaryEnemy(OBJECT_SELF, oPC);
				SetIsTemporaryEnemy(oPC, OBJECT_SELF);
    if (!GetIsInCombat(OBJECT_SELF))
    {
        SpeakString(GetStringByStrRef(37522)); // "Foolish mortal, you have forgotten to cast your protection charm! Belial shall rule!"
					   gsCBDetermineCombatRound(oPC);
    }
}
