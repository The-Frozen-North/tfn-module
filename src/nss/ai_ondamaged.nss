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

    ExecuteScript("remove_invis", OBJECT_SELF);

    PlayNonMeleePainSound(oDamager);

    if (GetIsPC(oDamager) || GetIsPC(GetMaster(oDamager))) SetLocalInt(OBJECT_SELF, "player_tagged", 1);


    if (GetCurrentHitPoints(OBJECT_SELF) <= GetMaxHitPoints(OBJECT_SELF)/MORALE_PANIC_HEALTH_DIVIDE_FACTOR)
    {
        DoMoraleCheck(OBJECT_SELF, MORALE_PANIC_DAMAGE_DC);
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

    if (GetImmortal() && GetLocalInt(OBJECT_SELF, "unconscious") == 0)
    {
        int nKnockdownHP = GetMaxHitPoints()/10;
        if (nKnockdownHP < 1)
            nKnockdownHP = 1;
        if (GetCurrentHitPoints() <= nKnockdownHP)
        {
            effect eKnockdown = EffectKnockdown();
            float fDuration = 60.0;
            //FloatingTextStringOnCreature(GetName(OBJECT_SELF)+" is now unconscious.", OBJECT_SELF, FALSE);
            SetLocalInt(OBJECT_SELF, "unconscious", 1);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, OBJECT_SELF, fDuration);
            DelayCommand(fDuration, DeleteLocalInt(OBJECT_SELF, "unconscious"));
        }
    }
    string sAttackScript = GetLocalString(OBJECT_SELF, "attack_script");
    if (sAttackScript != "")
        ExecuteScript(sAttackScript);

    string sScript = GetLocalString(OBJECT_SELF, "damage_script");
    if (sScript != "")
        ExecuteScript(sScript);
}
