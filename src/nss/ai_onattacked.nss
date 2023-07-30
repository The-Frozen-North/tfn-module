#include "inc_ai_combat"
#include "inc_ai_event"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_PHYSICAL_ATTACKED));

    if (GetLocalInt(OBJECT_SELF, "combat") == 0)
        SetLocalInt(OBJECT_SELF, "combat", 1);

    object oAttacker = GetLastAttacker();
    if (GetIsPC(oAttacker) || GetIsPC(GetMaster(oAttacker))) SetLocalInt(OBJECT_SELF, "player_tagged", 1);


    string sAttackScript = GetLocalString(OBJECT_SELF, "attack_script");
    if (sAttackScript != "")
        ExecuteScript(sAttackScript);

    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);

    // chance for a range attacker to go melee
    if  (d2() == 1 && GetLocalInt(OBJECT_SELF, "melee_attacked") == 0 && GetDistanceToObject(oAttacker) < 3.0 && GetWeaponRanged(oWeapon))
    {
        SetLocalInt(OBJECT_SELF, "melee_attacked", 1);
        //SendMessageToPC(oAttacker, GetName(oAttacker)+" attempting to go melee");
        EquipMelee();

        ActionDoCommand(_gsCBTalentAttack(oAttacker, FALSE));
        gsCBDetermineCombatRound(oAttacker);
        return;

        DelayCommand(7.0, DeleteLocalInt(OBJECT_SELF, "melee_attacked"));
    }

    // just an issue for attackers (we dont need to worry abou spellcasters), don't do anything below so we keep the same attack target
    if (gsCBGetHasAttackTarget())
    {
        return;
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

