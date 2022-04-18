#include "nw_i0_generic"

void main()
{
    ChangeToStandardFaction(OBJECT_SELF, STANDARD_FACTION_HOSTILE);
    SetIsTemporaryEnemy(GetPCSpeaker());
    DetermineCombatRound();
}
