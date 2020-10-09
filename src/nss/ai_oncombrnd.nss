#include "inc_ai_combat"
#include "inc_ai_event"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_COMBAT_ROUND_END));

    gsCBDetermineCombatRound();
}

