#include "inc_adventurer"
#include "inc_adv_assassin"
#include "inc_ai_combat"

// Adventurer party 1 (assassin) actions script
// Somehow this only ended up needing to do one thing

void main()
{
	object oPC = GetPCSpeaker();
	if (GetScriptParam("attack") != "")
	{;
		int i;
		int nPartySize = GetAdventurerPartySize(OBJECT_SELF);
		for (i=1; i<=nPartySize; i++)
		{
			object oAdventurer = GetAdventurerPartyMemberByIndex(OBJECT_SELF, i);
			ChangeToStandardFaction(oAdventurer, STANDARD_FACTION_HOSTILE);
			SetIsTemporaryEnemy(oPC, oAdventurer);
			AssignCommand(oAdventurer, gsCBDetermineCombatRound(oPC));
        }
	}
}