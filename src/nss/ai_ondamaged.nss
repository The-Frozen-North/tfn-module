#include "inc_ai_combat"
#include "inc_ai_combat2"
//#include "gs_inc_effect"
#include "inc_ai_event"
#include "inc_general"

void main()
{

    SetLocalInt(OBJECT_SELF, "reset_timer", 1);

    object oDamager = GetLastDamager();

    PlayNonMeleePainSound(oDamager);

    if (GetIsPC(oDamager) || GetIsPC(GetMaster(oDamager))) SetLocalInt(OBJECT_SELF, "player_tagged", 1);


    if (GetCurrentHitPoints(OBJECT_SELF) <= GetMaxHitPoints(OBJECT_SELF)/3)
    {
        DoMoraleCheck(OBJECT_SELF, 10);
    }

    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_DAMAGED));

 //   gsFXBleed();
    gsC2SetDamage();

    object oHighestDamager = gsC2GetHighestDamager();
    object oLastDamager    = gsC2GetLastDamager();

    if (GetObjectType(oHighestDamager) == OBJECT_TYPE_AREA_OF_EFFECT)
        oHighestDamager = GetAreaOfEffectCreator(oHighestDamager);
    if (GetObjectType(oLastDamager) == OBJECT_TYPE_AREA_OF_EFFECT)
        oLastDamager    = GetAreaOfEffectCreator(oLastDamager);

    if (gsCBGetHasAttackTarget())
    {
        object oTarget = gsCBGetLastAttackTarget();

        if (GetIsObjectValid(oHighestDamager) &&
            oHighestDamager != oTarget)
        {
            gsCBDetermineCombatRound(oHighestDamager);
        }
    }
    else
    {
        gsCBDetermineCombatRound(oHighestDamager);
    }
}
