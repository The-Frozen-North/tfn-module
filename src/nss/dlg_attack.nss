#include "NW_I0_GENERIC"

void main()
{
    ChangeToStandardFaction(OBJECT_SELF, STANDARD_FACTION_HOSTILE);
    SetIsTemporaryEnemy(GetPCSpeaker());
    DetermineCombatRound();
}
