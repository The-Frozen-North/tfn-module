#include "inc_quest"
#include "nwnx_creature"

void main()
{
    AdvanceQuestSphere(OBJECT_SELF, 1);

    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "flee_q_janis");

    NWNX_Creature_SetMovementRate(OBJECT_SELF, 100);
    SetPlotFlag(OBJECT_SELF, FALSE);

    if (!GetHasEffect(EFFECT_TYPE_HASTE))
        ActionCastSpellAtObject(SPELL_HASTE, OBJECT_SELF, METAMAGIC_ANY, TRUE);

    ActionMoveToObject(GetWaypointByTag("EXIT_JANIS"));
    ActionDoCommand(DestroyObject(OBJECT_SELF));
    SetCommandable(FALSE);
}
