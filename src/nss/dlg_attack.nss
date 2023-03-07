#include "inc_ai_combat"

void main()
{
    ChangeToStandardFaction(OBJECT_SELF, STANDARD_FACTION_HOSTILE);
    FastBuff();
    SetIsTemporaryEnemy(GetPCSpeaker());
    gsCBDetermineCombatRound(GetPCSpeaker());
}
