#include "inc_ai_combat"
#include "inc_ai_event"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_PHYSICAL_ATTACKED));

    if (GetLocalInt(OBJECT_SELF, "combat") == 0)
        SetLocalInt(OBJECT_SELF, "combat", 1);

    object oAttacker = GetLastAttacker();
    if (GetIsPC(oAttacker) || GetIsPC(GetMaster(oAttacker))) SetLocalInt(OBJECT_SELF, "player_tagged", 1);

// 50% chance for range attackers to go melee immediately if attacked in melee
    if  (GetLocalInt(OBJECT_SELF, "range") == 1 && d2() == 1 && GetDistanceToObject(oAttacker) < 2.0 && GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oAttacker)))
    {
        SetLocalInt(OBJECT_SELF, "melee_attacked", 1);
        ActionEquipMostDamagingMelee(oAttacker);
        if (GetLocalInt(OBJECT_SELF, "offhand") == 1)
            ActionEquipMostDamagingMelee(oAttacker, TRUE);

        DelayCommand(7.0, DeleteLocalInt(OBJECT_SELF, "melee_attacked"));
    }


    if (gsCBGetHasAttackTarget())
    {
        object oTarget = gsCBGetLastAttackTarget();

// attack whoever attacked me!
        SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);

        if (oAttacker != oTarget &&
            (gsCBGetIsFollowing() ||
             GetDistanceToObject(oAttacker) <=
             GetDistanceToObject(oTarget) + 5.0))
        {
            gsCBDetermineCombatRound(oAttacker);
        }
    }
    else
    {
        gsCBDetermineCombatRound(oAttacker);
    }
}

