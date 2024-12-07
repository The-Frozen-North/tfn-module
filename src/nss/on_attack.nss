#include "nwnx_damage"
#include "util_i_math"
#include "inc_general"
#include "inc_itemevent"

void main()
{
    object oAttacker = OBJECT_SELF;
    struct NWNX_Damage_AttackEventData sAttack = NWNX_Damage_GetAttackEventData();
    if (GetIsPC(oAttacker) || GetIsPC(sAttack.oTarget))
    {
        int bHit = sAttack.iAttackResult == 1 || sAttack.iAttackResult == 3 || sAttack.iAttackResult == 7 || sAttack.iAttackResult == 10;
        if (sAttack.iAttackType == 65002) // attack of opportunity
        {
            if (GetIsPC(oAttacker))
            {
                if (bHit)
                {
                    IncrementPlayerStatistic(oAttacker, "attacks_of_opportunity_hit");
                }
                else
                {
                    IncrementPlayerStatistic(oAttacker, "attacks_of_opportunity_missed");
                }
            }
            if (GetIsPC(sAttack.oTarget))
            {
                if (bHit)
                {
                    IncrementPlayerStatistic(sAttack.oTarget, "attacks_of_opportunity_hit_by");
                }
                else
                {
                    IncrementPlayerStatistic(sAttack.oTarget, "attacks_of_opportunity_missed_by");
                }
            }
        }
        if (sAttack.iSneakAttack > 0) // sneak and/or death attack
        {
            if (GetIsPC(oAttacker))
            {
                if (bHit)
                {
                    IncrementPlayerStatistic(oAttacker, "sneak_attacks_hit");
                }
                else
                {
                    IncrementPlayerStatistic(oAttacker, "sneak_attacks_missed");
                }
            }
            if (GetIsPC(sAttack.oTarget))
            {
                if (bHit)
                {
                    IncrementPlayerStatistic(sAttack.oTarget, "sneak_attacks_hit_by");
                }
                else
                {
                    IncrementPlayerStatistic(sAttack.oTarget, "sneak_attacks_missed_by");
                }
            }
        }
        if (sAttack.iAttackResult == 3) // Critical hits
        {
            if (GetIsPC(oAttacker))
            {
                IncrementPlayerStatistic(oAttacker, "critical_hits_landed");
            }
            if (GetIsPC(sAttack.oTarget))
            {
                IncrementPlayerStatistic(sAttack.oTarget, "critical_hits_taken");
            }
        }
        if (sAttack.iToHitRoll == 1 && GetIsPC(oAttacker))
        {
            IncrementPlayerStatistic(oAttacker, "natural_one_attack_rolls");
        }
        if (bHit)
        {
            if (GetIsPC(oAttacker))
            {
                IncrementPlayerStatistic(oAttacker, "attacks_hit");
            }
            if (GetIsPC(sAttack.oTarget))
            {
                IncrementPlayerStatistic(sAttack.oTarget, "attacks_hit_by");
            }
        }
        else
        {
            if (GetIsPC(oAttacker))
            {
                IncrementPlayerStatistic(oAttacker, "attacks_missed");
            }
            if (GetIsPC(sAttack.oTarget))
            {
                IncrementPlayerStatistic(sAttack.oTarget, "attacks_missed_by");
            }
        }
    }
    ItemEventCallSubscribersForCreature(ITEM_EVENT_WEARER_ATTACKS, oAttacker);
    ItemEventCallSubscribersForCreature(ITEM_EVENT_WEARER_ATTACKED, sAttack.oTarget);
}