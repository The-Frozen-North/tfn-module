/*

    Henchman Inventory And Battle AI

    This file contains a modified form of the original TalentMeleeAttack.
    Major modification to not randomly pick feats to use.

*/

#include "inc_hai_equip"

// void main() {    }


int GetItemAttackBonus(object oTarget, object oItem)
{
    int nReturnVal = 0;

    itemproperty oProp = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(oProp))
    {
        int bGetSetting = FALSE;
        switch (GetItemPropertyType(oProp))
        {
        case ITEM_PROPERTY_ENHANCEMENT_BONUS:
        case ITEM_PROPERTY_ATTACK_BONUS:
            bGetSetting = TRUE;
            break;
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP:
        case ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP:
            switch (GetItemPropertySubType(oProp))
            {
            case IP_CONST_ALIGNMENTGROUP_NEUTRAL:
                bGetSetting = (GetAlignmentGoodEvil(oTarget) == ALIGNMENT_NEUTRAL) ||
                    (GetAlignmentLawChaos(oTarget) == ALIGNMENT_NEUTRAL);
                break;
            case IP_CONST_ALIGNMENTGROUP_LAWFUL:
                bGetSetting = GetAlignmentLawChaos(oTarget) == ALIGNMENT_LAWFUL;
                break;
            case IP_CONST_ALIGNMENTGROUP_CHAOTIC:
                bGetSetting = GetAlignmentLawChaos(oTarget) == ALIGNMENT_CHAOTIC;
                break;
            case IP_CONST_ALIGNMENTGROUP_GOOD:
                bGetSetting = GetAlignmentGoodEvil(oTarget) == ALIGNMENT_GOOD;
                break;
            case IP_CONST_ALIGNMENTGROUP_EVIL:
                bGetSetting = GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL;
                break;
            }
            break;
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP:
        case ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP:
            bGetSetting = GetItemPropertySubType(oProp) == GetRacialType(oTarget);
            break;
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT:
        case ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT:
            {
                int iSpecificAlignment = GetItemPropertySubType(oProp);
                switch (iSpecificAlignment % 3)
                {
                case 0:
                    bGetSetting = GetAlignmentGoodEvil(oTarget) == ALIGNMENT_GOOD;
                    break;
                case 1:
                    bGetSetting = GetAlignmentGoodEvil(oTarget) == ALIGNMENT_NEUTRAL;
                    break;
                case 2:
                    bGetSetting = GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL;
                    break;
                }
                if (bGetSetting)
                {
                    bGetSetting = FALSE;
                    switch (iSpecificAlignment / 3)
                    {
                    case 0:
                        bGetSetting = GetAlignmentLawChaos(oTarget) == ALIGNMENT_LAWFUL;
                        break;
                    case 1:
                        bGetSetting = GetAlignmentLawChaos(oTarget) == ALIGNMENT_NEUTRAL;
                        break;
                    case 2:
                        bGetSetting = GetAlignmentLawChaos(oTarget) == ALIGNMENT_CHAOTIC;
                        break;
                    }
                }
            }
            break;
        }
        if (bGetSetting)
        {
            int itemPropValue = GetItemPropertyCostTableValue(oProp);
            if (itemPropValue > nReturnVal)
            {
                nReturnVal = itemPropValue;
            }
        }
        oProp = GetNextItemProperty(oItem);
    }
    return nReturnVal;
}


int GetMeleeAttackBonus(object oCreature, object oWeaponRight, object oTarget)
{
    int nReturn = 0;
    // Finesse only if we are using a proper weapon
    int nStrMod = GetAbilityModifier(ABILITY_STRENGTH, oCreature);
    int nDexMod = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    int bCanFinesse = GetHasFeat(FEAT_WEAPON_FINESSE, oCreature) && (nDexMod > nStrMod);

    if (GetIsObjectValid(oWeaponRight))
    {
        nReturn += GetItemAttackBonus(oTarget, oWeaponRight);
        if (bCanFinesse)
        {
            switch (GetBaseItemType(oWeaponRight))
            {
                // only these weapons can be finessed
            case BASE_ITEM_DAGGER:
            case BASE_ITEM_HANDAXE:
            case BASE_ITEM_KAMA:
            case BASE_ITEM_KUKRI:
            case BASE_ITEM_LIGHTHAMMER:
            case BASE_ITEM_LIGHTMACE:
            case BASE_ITEM_RAPIER:
            case BASE_ITEM_SHORTSWORD:
            case BASE_ITEM_SHURIKEN:
            case BASE_ITEM_SICKLE:
            case BASE_ITEM_THROWINGAXE:
                break;
            default:
                bCanFinesse = FALSE;
            }
        }
    }
    else
    {
            // note: creature weapons can be finessed
        oWeaponRight = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oCreature);
        if (GetIsObjectValid(oWeaponRight))
        {
            nReturn += GetItemAttackBonus(oTarget, oWeaponRight);
        }
        else
        {
            oWeaponRight = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oCreature);
            if (GetIsObjectValid(oWeaponRight))
            {
                nReturn += GetItemAttackBonus(oTarget, oWeaponRight);
            }
            else
            {
                oWeaponRight = GetItemInSlot(INVENTORY_SLOT_ARMS, oCreature);
                if (GetIsObjectValid(oWeaponRight))
                {
                    nReturn += GetItemAttackBonus(oTarget, oWeaponRight);
                }
            }
        }
    }
    object oWeaponLeft = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature);
    int nOffHandWeaponSize = GetMeleeWeaponSize(oWeaponLeft);
    if (nOffHandWeaponSize > 0)
    {
        if (nOffHandWeaponSize == GetCreatureSize(oCreature))
        {
            nReturn -= 2;
        }
        else
        {
            // TODO more could be done here
            nReturn -= 4;
        }
    }
    if(bCanFinesse)
    {
        nReturn += nDexMod;
    }
    else
    {
        nReturn += nStrMod;
    }
    return nReturn;
}


int GetRangeAttackBonus(object oCreature, object oRangedWeapon, object oTarget)
{
    int nReturn = GetItemAttackBonus(oTarget, oRangedWeapon);
    int nDexMod = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    int nWisMod = GetAbilityModifier(ABILITY_WISDOM, oCreature);
    if (GetHasFeat(FEAT_ZEN_ARCHERY, oCreature) && (nWisMod > nDexMod))
    {
        nReturn += nWisMod;
    }
    else
    {
        nReturn += nDexMod;
    }
    int itemType = GetBaseItemType(oRangedWeapon);
    if ((itemType == BASE_ITEM_LONGBOW) || (itemType  == BASE_ITEM_SHORTBOW))
    {
        int nLevel = GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCreature);
        if (nLevel > 0)
        {
            nReturn += ((nLevel+1)/2);
        }
    }
    return nReturn;
}


int GetAttackBonus(object oCreature, object oTarget)
{
    object oRightWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    if (GetWeaponRanged(oRightWeapon))
    {
        return GetRangeAttackBonus(oCreature, oRightWeapon, oTarget);
    }
    return GetMeleeAttackBonus(oCreature, oRightWeapon, oTarget);
}


void HenchDoTalentMeleeAttack(object oTarget, float fThresholdDistance, int iCreatureType)
{
    int iIntCheck = GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) - 2;
    if (iIntCheck < 6)
    {
        // have less smart creatures not use best combat feats all the time
        if (iIntCheck < 1)
        {
            iIntCheck = 1;
        }
        if (iIntCheck < d6())
        {
            UseCombatAttack(oTarget);
            return;
        }
    }
    object oRightWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    int bRangedWeapon = GetWeaponRanged(oRightWeapon);

    int iAC = GetAC(oTarget);
    int iNewBAB = GetBaseAttackBonus(OBJECT_SELF) + 5 + d4(2);

    if(bRangedWeapon)
    {
        // At a -2 to hit, this can disarm the arms or legs...speed or attack bonus
        if(d8() == 1 && GetHasFeat(FEAT_CALLED_SHOT) && !GetHasFeatEffect(FEAT_CALLED_SHOT, oTarget)
            && !GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT, OBJECT_SELF) && !GetIsDisabled(oTarget))
        {
            iNewBAB += GetRangeAttackBonus(OBJECT_SELF, oRightWeapon, oTarget);
            if((iNewBAB - 2) >= iAC)
            {
                UseCombatAttack(oTarget, FEAT_CALLED_SHOT);
                return;
            }
        }
        // Always use if present
        if(GetHasFeat(FEAT_RAPID_SHOT))
        {
            int iItemType = GetBaseItemType(oRightWeapon);
            if (iItemType == BASE_ITEM_SHORTBOW || iItemType == BASE_ITEM_LONGBOW)
            {
                UseCombatAttack(oTarget, FEAT_RAPID_SHOT);
                return;
            }
        }
        ActionAttack(oTarget);
        return;
    }
    iNewBAB += GetMeleeAttackBonus(OBJECT_SELF, oRightWeapon, oTarget);

    float relativeChallenge;
    if (iCreatureType == 0)
    {
        // mosters always use best feat
        relativeChallenge = -10.0;
    }
    else
    {
        relativeChallenge = iCreatureType == 1 ? IntToFloat(GetHitDice(OBJECT_SELF)) * HENCH_HITDICE_TO_CR : GetChallengeRating(OBJECT_SELF);
        relativeChallenge -= GetIsPC(oTarget) || GetAssociateType(oTarget) == ASSOCIATE_TYPE_HENCHMAN ?
            IntToFloat(GetHitDice(oTarget))  * HENCH_HITDICE_TO_CR : GetChallengeRating(oTarget);
    }

    // For use against them evil pests! Top - one use only anyway.
    if(GetHasFeat(FEAT_SMITE_EVIL) && GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL &&
        relativeChallenge <= 2.0)
    {
        UseCombatAttack(oTarget, FEAT_SMITE_EVIL);
        return;
    }
    if(GetHasFeat(FEAT_SMITE_GOOD) && GetAlignmentGoodEvil(oTarget) == ALIGNMENT_GOOD &&
        relativeChallenge <= 2.0)
    {
        UseCombatAttack(oTarget, FEAT_SMITE_GOOD);
        return;
    }

    // * only the playable races have whirlwind attack
    // * Attempt to Use Whirlwind Attack
    if (GetHasFeat(FEAT_WHIRLWIND_ATTACK) && GetOKToWhirl(OBJECT_SELF))
    {
        int iAttackThreshold;
        if (GetCurrentHitPoints(oTarget) <= (GetMeleeAttackBonus(OBJECT_SELF, oRightWeapon, oTarget) + 5))
        {
            // a single hit is likely to kill target, check if any other targets are available
            iAttackThreshold = 2;
        }
        else
        {
            // set number of whirlwind targets needed equal to the number of attacks per round
            iAttackThreshold = GetBaseAttackBonus(OBJECT_SELF);
            if (GetHitDice(OBJECT_SELF) > 20)
            {
                iAttackThreshold -= GetHitDice(OBJECT_SELF) / 2;
            }
            iAttackThreshold = (iAttackThreshold + 4) / 5;
        }
        float fThresholdDistance;
        int iSizeThreshold;
        if (GetHasFeat(FEAT_IMPROVED_WHIRLWIND))
        {
            fThresholdDistance = 10.0;
            iSizeThreshold = CREATURE_SIZE_HUGE;
        }
        else
        {
            fThresholdDistance = 3.0;
            iSizeThreshold = CREATURE_SIZE_MEDIUM;
        }
        int enemyIndex = 1;
        object oTestTarget = GetNearestEnemy(OBJECT_SELF, enemyIndex++);
        while (GetIsObjectValid(oTestTarget))
        {
            if ((GetDistanceToObject(oTestTarget) <= fThresholdDistance) &&
                (GetCreatureSize(oTestTarget) <= iSizeThreshold))
            {
                --iAttackThreshold;
                if (iAttackThreshold <= 0)
                {
                    break;
                }
            }
            oTestTarget = GetNearestEnemy(OBJECT_SELF, enemyIndex++);
        }
//      Jug_Debug(GetName(OBJECT_SELF) + " num attacks " + IntToString((GetBaseAttackBonus(OBJECT_SELF) + 1) / 5) + " count is " + IntToString(iAttackThreshold));
        if (iAttackThreshold <= 0)
        {
            UseCombatAttack(OBJECT_SELF, FEAT_WHIRLWIND_ATTACK);
            return;
        }
    }
        // TODO update for HotU, dwarven defender (is same as barb rage?)
    if (relativeChallenge <= 2.0 && TryKiDamage(oTarget))
    {
        return;
    }

    if (d6() == 1 && !GetIsImmune(oTarget, IMMUNITY_TYPE_CRITICAL_HIT, OBJECT_SELF) && (iNewBAB >= iAC))
    {
        int bHasQuiveringPalm = GetHasFeat(FEAT_QUIVERING_PALM);
        int bHasStunningFist = GetHasFeat(FEAT_STUNNING_FIST);
        int bHasSAP = GetHasFeat(FEAT_SAP);
        int bHasCalledShot = GetHasFeat(FEAT_CALLED_SHOT) && d3() == 1;
        if ((bHasQuiveringPalm || bHasStunningFist || bHasSAP || bHasCalledShot) &&
            relativeChallenge <= 2.0  &&
            (GetCharacterLevel(OBJECT_SELF) / 2 + 10 + GetAbilityModifier(ABILITY_WISDOM) >=
            GetFortitudeSavingThrow(oTarget) + 5 + Random(15)))
        {
            if(!GetIsDisabled(oTarget))
            {
                if (bHasQuiveringPalm && !GetIsObjectValid(oRightWeapon))
                {
                    UseCombatAttack(oTarget, FEAT_QUIVERING_PALM);
                    return;
                }
                if (bHasStunningFist)
                {
                    int iMod = iNewBAB;
                    if (GetIsObjectValid(oRightWeapon) || (GetLevelByClass(CLASS_TYPE_MONK) == 0))
                    {
                        iMod -= 4;
                    }
                    if (iMod >= iAC)
                    {
                        UseCombatAttack(oTarget, FEAT_STUNNING_FIST);
                        return;
                    }
                }
                // OK, not for PCs, but may be on an NPC. -4 Attack. Above the one below.
                if(bHasSAP)
                {
                    if((iNewBAB - 4) >= iAC)
                    {
                        UseCombatAttack(oTarget, FEAT_SAP);
                        return;
                    }
                }
                if (bHasCalledShot)
                {
                    // At a -2 to hit, this can disarm the arms or legs...speed or attack bonus
                    if(((iNewBAB - 2) >= iAC) && !GetHasFeatEffect(FEAT_CALLED_SHOT, oTarget))
                    {
                        UseCombatAttack(oTarget, FEAT_CALLED_SHOT);
                        return;
                    }
                }
            }
        }
    }

    int bHasImprovedKnockdown = GetHasFeat(FEAT_IMPROVED_KNOCKDOWN);
    if((bHasImprovedKnockdown || GetHasFeat(FEAT_KNOCKDOWN)) &&
        !GetIsImmune(oTarget, IMMUNITY_TYPE_KNOCKDOWN, OBJECT_SELF) &&
        !GetHasFeatEffect(FEAT_KNOCKDOWN, oTarget) &&
        !GetHasFeatEffect(FEAT_IMPROVED_KNOCKDOWN, oTarget))
    {
        // By far the BEST feat to use - knocking them down lets you freely attack them!
        // These return 1-5, based on size.
        int iOurSize = GetCreatureSize(OBJECT_SELF);
        int iTheirSize = GetCreatureSize(oTarget);
        if (bHasImprovedKnockdown)
        {
            iOurSize++;
        }
        int bUse = iOurSize > iTheirSize;
        if (!bUse && ((iOurSize + 1) >= iTheirSize))
        {
            int iMod = iNewBAB - 4;
                // check if one size larger
            if (iOurSize != iTheirSize)
            {
                iMod -= 4;
            }
            if(iMod >= iAC)
            {
                bUse = iMod > GetSkillRank(SKILL_DISCIPLINE, oTarget);
            }
        }
        if(bUse)
        {
            UseCombatAttack(oTarget, bHasImprovedKnockdown ? FEAT_IMPROVED_KNOCKDOWN : FEAT_KNOCKDOWN);
            return;
        }
    }
    // start using expertise if have under 50% hit points
    if (GetPercentageHPLoss(OBJECT_SELF) < 50 &&
        (GetHasFeat(FEAT_EXPERTISE) || GetHasFeat(FEAT_IMPROVED_EXPERTISE)))
    {
        // get estimation of opponent attack vs. my AC
        int iMyAC = GetAC(OBJECT_SELF);
        int iTargetsBAB = GetBaseAttackBonus(oTarget) + 5 + d4(2) + GetAttackBonus(oTarget, OBJECT_SELF);

        if(GetHasFeat(FEAT_IMPROVED_EXPERTISE) && (iTargetsBAB - 5) >= iMyAC)
        {
            UseCombatAttack(oTarget, -1, ACTION_MODE_IMPROVED_EXPERTISE);
            return;
        }
        if(iTargetsBAB >= iMyAC)
        {
            UseCombatAttack(oTarget, -1, ACTION_MODE_EXPERTISE);
            return;
        }
    }

    // Only use parry on an active melee attacker, and
    // only if our parry skill > our AC - 10
    // JE, Apr.14,2004: Bugfix to make this actually work. Thanks to the message board
    // members who investigated this.
    if (GetSkillRank(SKILL_PARRY) > (GetAC(OBJECT_SELF) - 10))
    {
        object oTargetRightWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if (GetAttackTarget(oTarget) == OBJECT_SELF &&
            GetIsObjectValid(oTargetRightWeapon) &&
            !GetWeaponRanged(oTargetRightWeapon))
        {
            int iAttackChance = GetBaseAttackBonus(oTarget) + GetAttackBonus(oTarget, OBJECT_SELF) - GetAC(OBJECT_SELF);
            if ((iAttackChance > -20) && (GetPercentageHPLoss(OBJECT_SELF) < 65))
            {
                object oNearestFriend = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
                if (GetIsObjectValid(oNearestFriend) && GetDistanceToObject(oNearestFriend) <= 5.0)
                {
                    UseCombatAttack(oTarget, -1, ACTION_MODE_PARRY);
                    return;
                }
            }
        }
    }

//
// Auldar: Give 10% chance to Taunt if target is within 3.5 meters and is a challenge, if Skill points have been
// spent in Taunt skill indicating intention to use, and a taunt isn't in effect
//
    if ((d10 () == 1) && ((relativeChallenge <= 2.0) ||
        (GetCharacterLevel(oTarget) > (GetCharacterLevel(OBJECT_SELF) - 2)))
        && (GetDistanceToObject(oTarget) <= 3.5))
    {
    // Auldar: Adding a check for the Taunt skill, and ensuring that noone with ONLY a CHA mod to
    // Taunt will use the skill.
    // This confirms that some points are spent in the skill indicating an intention for the NPC to use them.
    // Also using 69MEH69's idea to check for a negative modifier so we don't subtract a negative number (ie add)
    // to the skill check
        if ((GetSkillRank(SKILL_TAUNT, OBJECT_SELF, TRUE) > 0) && ((GetSkillRank(SKILL_TAUNT) + 5 + d4(2)) > GetSkillRank(SKILL_CONCENTRATION, oTarget)))
        {
            ActionUseSkill(SKILL_TAUNT, oTarget);
            return;
        }
    }

    if(d4() == 1 && (GetHasFeat(FEAT_IMPROVED_DISARM) || GetHasFeat(FEAT_DISARM)) &&
        GetIsCreatureDisarmable(oTarget) &&
        ((GetIsObjectValid(oRightWeapon) && !GetWeaponRanged(oRightWeapon)) || !GetIsObjectValid(oRightWeapon)))
    {
        object oTargetRightWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if (GetIsObjectValid(oTargetRightWeapon) && !GetWeaponRanged(oTargetRightWeapon))
        {
            int iWeaponSize;
            if (GetIsObjectValid(oRightWeapon))
            {
                iWeaponSize = GetMeleeWeaponSize(oRightWeapon);
            }
            else
            {
                iWeaponSize = GetCreatureSize(OBJECT_SELF);
            }
            int iTargetWeaponSize = GetMeleeWeaponSize(oTargetRightWeapon);

            // No AOO, and only a -4 penalty to hit.
            if(GetHasFeat(FEAT_IMPROVED_DISARM))
            {
                // Apply weapon size penalites/bonuses to check - Use right weapons.
                int iMod = iWeaponSize - iTargetWeaponSize;
                if(iMod != 0) iMod += (iMod * 4);
                if(((iNewBAB - 4 + iMod) >= iAC) && (iMod > GetSkillRank(SKILL_DISCIPLINE, oTarget)))
                {
                    UseCombatAttack(oTarget, FEAT_IMPROVED_DISARM);
                    return;
                }
            }
            // Provokes an AOO. Improved does not, but this is -6, and bonuses depend on weapons used (sizes)
            else if(d2() == 1)
            {
                // Apply weapon size penalites/bonuses to check - Use right weapons.
                int iMod = iWeaponSize - iTargetWeaponSize;
                if(iMod != 0) iMod += (iMod * 4);
                if(((iNewBAB - 6 + iMod) >= iAC) && (iMod > GetSkillRank(SKILL_DISCIPLINE, oTarget)))
                {
                    UseCombatAttack(oTarget, FEAT_DISARM);
                    return;
                }
            }
        }
    }

    // This activates an extra attack, at -2 to hit. Of course, only unarmed and kama
    if(GetHasFeat(FEAT_FLURRY_OF_BLOWS) && ((iNewBAB - 2) >= iAC) && (!GetIsObjectValid(oRightWeapon) ||
        (GetBaseItemType(oRightWeapon) == BASE_ITEM_KAMA)))
    {
        UseCombatAttack(oTarget, FEAT_FLURRY_OF_BLOWS);
        return;
    }
    // -10 to hit - make sure by extra 5
    if(GetHasFeat(FEAT_IMPROVED_POWER_ATTACK) && ((iNewBAB - 15) >= iAC))
    {
        UseCombatAttack(oTarget, FEAT_IMPROVED_POWER_ATTACK);
        return;
    }
    // is a -5 to hit - make sure by extra 5
    if(GetHasFeat(FEAT_POWER_ATTACK) && ((iNewBAB - 10) >= iAC))
    {
        UseCombatAttack(oTarget, FEAT_POWER_ATTACK);
        return;
    }
    // extra damage with only one attack
    if (GetHasFeat(FEAT_DIRTY_FIGHTING) && GetBaseAttackBonus(OBJECT_SELF) < 8)
    {
        UseCombatAttack(oTarget, FEAT_DIRTY_FIGHTING);
        return;
    }

    UseCombatAttack(oTarget);
}


void ActionContinueMeleeAttack(object oTarget, float fThresholdDistance, int iCreatureType, int iCallNumber)
{
    if (GetLocalInt(OBJECT_SELF, "UseRangedWeapons"))
    {
        if (!EquipRangedWeapon(oTarget, iCreatureType == 1, iCallNumber))
        {
            ActionDoCommand(ActionContinueMeleeAttack(oTarget, fThresholdDistance, iCreatureType, iCallNumber + 1));
            return;
        }
    }
    else
    {
        if (!EquipMeleeWeapons(oTarget, iCreatureType == 1, iCallNumber))
        {
            ActionDoCommand(ActionContinueMeleeAttack(oTarget, fThresholdDistance, iCreatureType, iCallNumber + 1));
            return;
        }
    }
    HenchDoTalentMeleeAttack(oTarget, fThresholdDistance, iCreatureType);
}


// MELEE ATTACK OTHERS
/*
    ISSUE 1: Talent Melee Attack should set the Last Spell Used to 0 so that melee casters can use
    a single special ability.

    Auldar: Made changes here to use Taunt when appropriate as well as more accurate calculations for
    To-Hit vs Target AC.

    Tony: Made major changes in using attack feats. Heavily modified code from Jasperre.
*/

int HenchTalentMeleeAttack(object oIntruder, float fThresholdDistance, int iMeleeAttackers, int iCreatureType, int bPolymorphed)
{
    object oTarget = oIntruder;

    if (iCreatureType == 0)
    {
       MonsterBattleCry();
    }
    else if (iCreatureType == 1)
    {
       HenchBattleCry();
    }

    // allow sneak attack to use other feats
    if(GetHasFeat(FEAT_SNEAK_ATTACK))
    {
            //Sneak Attack Flanking attack
        float fRange = iMeleeAttackers ? 3.5 : /* bRangedWeapon*/ TRUE ? 50.0 : 5.0;
        int iEnemyAC, iAC = 100;
        object oRealMaster = GetRealMaster();
        int bEnemyMaster = FALSE;
        object oLastSneakTarget = GetLocalObject(OBJECT_SELF, "LastSneakTarget");
        object oAttackTarget;
        int nCnt = 1;
        object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, nCnt, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
        object oBest = OBJECT_INVALID;
        while(GetIsObjectValid(oEnemy) && GetDistanceToObject(oEnemy) <= fRange)
        {
            if(!GetPlotFlag(oEnemy) && !GetIsImmune(oEnemy, IMMUNITY_TYPE_SNEAK_ATTACK, OBJECT_SELF))
            {
                oAttackTarget = GetAttackTarget(oEnemy);
                if(oAttackTarget != OBJECT_SELF)
                {
                    if (oEnemy == oLastSneakTarget)
                    {
                        oBest = oEnemy;
                        break;
                    }
                    iEnemyAC = GetAC(oEnemy);
                    if (oAttackTarget == oRealMaster)
                    {
                        if (!bEnemyMaster)
                        {
                            bEnemyMaster = TRUE;
                            iAC = iEnemyAC;
                            oBest = oEnemy;
                        }
                        else if(iAC > iEnemyAC)
                        {
                            iAC = iEnemyAC;
                            oBest = oEnemy;
                        }
                    }
                    else if(iAC > iEnemyAC)
                    {
                        iAC = iEnemyAC;
                        oBest = oEnemy;
                    }
                }
            }
            nCnt++;
            oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, nCnt, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
        }

        if (GetIsObjectValid(oBest))
        {
            oTarget = oBest;
            SetLocalObject(OBJECT_SELF, "LastSneakTarget", oBest);
        }
    }

    if (!HenchEquipAppropriateWeapons(oTarget, fThresholdDistance, iCreatureType == 1, bPolymorphed))
    {
        ActionDoCommand(ActionContinueMeleeAttack(oTarget, fThresholdDistance, iCreatureType, 2));
    }
    else
    {
        HenchDoTalentMeleeAttack(oTarget, fThresholdDistance, iCreatureType);
    }

    return TRUE;
}

