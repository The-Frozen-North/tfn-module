#include "inc_ai_combat"
#include "inc_ai_combat2"
//#include "gs_inc_effect"
#include "inc_ai_event"
#include "inc_general"

void main()
{
    if (GetLocalInt(OBJECT_SELF, "combat") == 0)
        SetLocalInt(OBJECT_SELF, "combat", 1);

    object oDamager = GetLastDamager();

    PlayNonMeleePainSound(oDamager);

    if (GetIsPC(oDamager) || GetIsPC(GetMaster(oDamager))) SetLocalInt(OBJECT_SELF, "player_tagged", 1);


    if (GetCurrentHitPoints(OBJECT_SELF) <= GetMaxHitPoints(OBJECT_SELF)/MORALE_PANIC_HEALTH_DIVIDE_FACTOR)
    {
        DoMoraleCheck(OBJECT_SELF, MORALE_PANIC_DAMAGE_DC);
    }

        string sAttackScript = GetLocalString(OBJECT_SELF, "attack_script");
    if (sAttackScript != "")
        ExecuteScript(sAttackScript);

    string sScript = GetLocalString(OBJECT_SELF, "damage_script");
    if (sScript != "")
        ExecuteScript(sScript);

    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_DAMAGED));

// just an issue for attackers (we dont need to worry abou spellcasters), don't do anything below so we keep the same attack target
    if (gsCBGetHasAttackTarget())
    {
        return;
    }

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

// if the latest damager is is greater than the last damager, only switch to that target 25% of the time if already attacking
        if (GetIsObjectValid(oHighestDamager) &&
            oHighestDamager != oTarget &&
            d4() == 1
            )
        {
            gsCBDetermineCombatRound(oHighestDamager);
        }
    }
    else
    {
        gsCBDetermineCombatRound(oHighestDamager);
    }
}
