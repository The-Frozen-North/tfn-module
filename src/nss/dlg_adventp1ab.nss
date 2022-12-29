#include "inc_adventurer"
#include "inc_adv_assassin"
#include "inc_ai_combat"

void main()
{
    object oPC = GetAdventurerPartyTarget(OBJECT_SELF, OBJECT_INVALID);
    object oLastSpeaker = GetLocalObject(OBJECT_SELF, "last_speaker");
    // If we saved a target, and they're the last speaker, we want to kill them
    if (oPC == oLastSpeaker)
    {
        int i;
        int nPartySize = GetAdventurerPartySize(OBJECT_SELF);
        for (i=1; i<=nPartySize; i++)
        {
            // Don't attack after successful intimidate
            object oAdventurer = GetAdventurerPartyMemberByIndex(OBJECT_SELF, i);
            if (!GetLocalInt(oAdventurer, "no_attack"))
            {
                ChangeToStandardFaction(oAdventurer, STANDARD_FACTION_HOSTILE);
                SetIsTemporaryEnemy(oPC, oAdventurer);
                AssignCommand(oAdventurer, FastBuff());
                AssignCommand(oAdventurer, gsCBDetermineCombatRound(oPC));
            }
        }
    }
}