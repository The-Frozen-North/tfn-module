#include "inc_spells"
#include "inc_ai_combat"

// Belial HB: become hostile to everyone who isn't protected from evil
void main()
{
	object oPerceived = GetLastPerceived();
	if (GetLastPerceptionSeen())
	{
		if (!GetIsDead(oPerceived) && !GetIsEnemy(oPerceived) && !GetIsProtectedFromEvil(oPerceived))
		{
			SetIsTemporaryEnemy(OBJECT_SELF, oPerceived);
			SetIsTemporaryEnemy(oPerceived, OBJECT_SELF);
			if (!GetIsInCombat(OBJECT_SELF))
			{
				SpeakString(GetStringByStrRef(37522)); // "Foolish mortal, you have forgotten to cast your protection charm! Belial shall rule!"
				gsCBDetermineCombatRound(oPerceived);
			}
		}
	}
}
