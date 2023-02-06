#include "inc_spells"
#include "inc_ai_combat"

// Belial HB: become hostile to everyone who isn't protected from evil
void main()
{
	if (GetAILevel() > AI_LEVEL_VERY_LOW)
	{
		location lSelf = GetLocation(OBJECT_SELF);
		object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lSelf, OBJECT_TYPE_CREATURE);
		while (GetIsObjectValid(oTest))
		{
			if (oTest != OBJECT_SELF && !GetIsDead(oTest) && !GetIsEnemy(oTest) && !GetIsProtectedFromEvil(oTest))
			{
				SetIsTemporaryEnemy(OBJECT_SELF, oTest);
				SetIsTemporaryEnemy(oTest, OBJECT_SELF);
				if (!GetIsInCombat(OBJECT_SELF))
				{
					SpeakString(GetStringByStrRef(37522)); // "Foolish mortal, you have forgotten to cast your protection charm! Belial shall rule!"
					gsCBDetermineCombatRound(oTest);
				}
			}
            oTest = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lSelf, OBJECT_TYPE_CREATURE);
		}
	}
}