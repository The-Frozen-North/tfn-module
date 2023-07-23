#include "nwnx_damage"
#include "util_i_math"
#include "inc_general"

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
                IncrementPlayerStatistic(oAttacker, "attacks_of_opportunity_made");
                if (bHit)
                {
                    IncrementPlayerStatistic(oAttacker, "attacks_of_opportunity_hit");
                }
            }
            if (GetIsPC(sAttack.oTarget))
            {
                IncrementPlayerStatistic(sAttack.oTarget, "attacks_of_opportunity_targeted_by");
                if (bHit)
                {
                    IncrementPlayerStatistic(sAttack.oTarget, "attacks_of_opportunity_hit_by");
                }
            }
        }
        if (sAttack.iSneakAttack > 0) // sneak and/or death attack
        {
            if (GetIsPC(oAttacker))
            {
                IncrementPlayerStatistic(oAttacker, "sneak_attacks_made");
                if (bHit)
                {
                    IncrementPlayerStatistic(oAttacker, "sneak_attacks_hit");
                }
            }
            if (GetIsPC(sAttack.oTarget))
            {
                IncrementPlayerStatistic(sAttack.oTarget, "sneak_attacks_targeted_by");
                if (bHit)
                {
                    IncrementPlayerStatistic(sAttack.oTarget, "sneak_attacks_hit_by");
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
    }
}