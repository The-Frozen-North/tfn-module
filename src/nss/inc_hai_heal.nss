/*

    Henchman Inventory And Battle AI

    This file routines are used for healing and curing conditions.
    Contains modified forms of the TalentCureCondition, TalentHealingSelf,
    and TalentHeal

*/

#include "inc_hai_spells"
#include "inc_hai_assoc"


// void main() {    }


const int HENCH_BLEED_NEGHPS = -10;

const int HENCH_HEAL_NO_MINOR   = 0x1;
const int HENCH_HEAL_FORCE      = 0x2;
const int HENCH_HEAL_NO_POTIONS = 0x4;



object GetBestHealingKit()
{
    object oKit = OBJECT_INVALID;
    int iRunningValue = 0;
    int iItemValue, iStackSize;

    object oItem = GetFirstItemInInventory();
    while(GetIsObjectValid(oItem))
    {
        // skip past any items in a container
        if (GetHasInventory(oItem))
        {
            object oContainer = oItem;
            object oSubItem = GetFirstItemInInventory(oContainer);
            oItem = GetNextItemInInventory();
            while (GetIsObjectValid(oSubItem))
            {
                oItem = GetNextItemInInventory();
                oSubItem = GetNextItemInInventory(oContainer);
            }
            continue;
        }
        if(GetBaseItemType(oItem) == BASE_ITEM_HEALERSKIT)
        {
            iItemValue = GetGoldPieceValue(oItem);
            iStackSize = GetNumStackedItems(oItem);
            // Stacked kits be worth what they should be separately.
            iItemValue = iItemValue/iStackSize;
            if(iItemValue > iRunningValue)
            {
                iRunningValue = iItemValue;
                oKit = oItem;
            }
        }
        oItem = GetNextItemInInventory();
    }
    return oKit;
}


int CompareHealTalent(int iTestHealAmount, int iHealAmount, int iHealNeeded)
{
    if (iTestHealAmount == iHealAmount)
    {
        return FALSE;
    }
    if (iTestHealAmount < iHealNeeded)
    {
        if (iTestHealAmount < iHealAmount)
        {
            return FALSE;
        }
        return TRUE;
    }
    if (iTestHealAmount < iHealAmount)
    {
        if (iTestHealAmount >= iHealNeeded)
        {
            return TRUE;
        }
        return FALSE;
    }
    if (iHealAmount >= iHealNeeded)
    {
        return FALSE;
    }
    return TRUE;
}


int GetHealingInfo(int iSpellID, int bUseItem)
{
    int bEnableEmpower = FALSE;
    int returnValue;
    switch(iSpellID)
    {
// RANK - NAME = D8 AMOUNTs + RANGE OF CLERIC LEVELS ADDED. MAX. AVERAGE OF DICE. ABOUT 2/3 OF MODIFIERS.
    case SPELL_CURE_MINOR_WOUNDS:
        bEnableEmpower = GetHasFeat(FEAT_HEALING_DOMAIN_POWER);
    case SPELL_INFLICT_MINOR_WOUNDS:
        //  Max of 4. Take as 4. Take modifiers as 0.
        returnValue = 4;
        break;
    case SPELL_CURE_LIGHT_WOUNDS:
        bEnableEmpower = GetHasFeat(FEAT_HEALING_DOMAIN_POWER);
    case SPELLABILITY_LESSER_BODY_ADJUSTMENT:
    case SPELL_INFLICT_LIGHT_WOUNDS:
        // 1d8 + 1-5. Max of 8. Take as 5.
        if (bUseItem)
        {
            returnValue = 7;
        }
        else if (nMySpellCasterLevel > 5)
        {
            returnValue = 10;
        }
        else
        {
            returnValue =  5 + nMySpellCasterLevel;
        }
        break;
    case SPELL_CURE_MODERATE_WOUNDS:
        bEnableEmpower = GetHasFeat(FEAT_HEALING_DOMAIN_POWER);
    case SPELL_INFLICT_MODERATE_WOUNDS:
        // 2d8 + 3-10. Max of 16. Take as 9.
        if (bUseItem)
        {
            returnValue = 12;
        }
        else if (nMySpellCasterLevel > 10)
        {
            returnValue = 19;
        }
        else
        {
            returnValue =  9 + nMySpellCasterLevel;
        }
        break;
    case SPELL_CURE_SERIOUS_WOUNDS:
        bEnableEmpower = GetHasFeat(FEAT_HEALING_DOMAIN_POWER);
    case SPELL_INFLICT_SERIOUS_WOUNDS:
        // 3d8 + 5-15. Max of 24. Take as 14.
        if (bUseItem)
        {
            returnValue = 19;
        }
        else if (nMySpellCasterLevel > 15)
        {
            returnValue = 29;
        }
        else
        {
            returnValue = 14 + nMySpellCasterLevel;
        }
        break;
    case SPELL_CURE_CRITICAL_WOUNDS:
        bEnableEmpower = GetHasFeat(FEAT_HEALING_DOMAIN_POWER);
    case SPELL_INFLICT_CRITICAL_WOUNDS:
    case SPELL_HENCH_Cure_Critical_Wounds_Others:
        //  4d8 + 7-20. Max of 32. Take as 18.
        if (bUseItem)
        {
            returnValue = 25;
        }
        else if (nMySpellCasterLevel > 20)
        {
            returnValue = 38;
        }
        else
        {
            returnValue = 18 + nMySpellCasterLevel;
        }
        break;
    case SPELL_HEALING_CIRCLE:
    case SPELL_CIRCLE_OF_DOOM:
        // 1d8 + 9-20. Max of 8. Take as 5.
        if (bUseItem)
        {
            return 14;
        }
        if (nMySpellCasterLevel > 20)
        {
            return 20;
        }
        return 5 + nMySpellCasterLevel;
    case SPELL_NEGATIVE_ENERGY_BURST:
        // 1d8 + (casterlevel / 4). No max caster level. Take as 5. Take modifiers as 5
        if (bUseItem)
        {
            return 10;
        }
        return 5 + (nMySpellCasterLevel / 4);
    case SPELL_HEAL:
    case SPELL_MASS_HEAL:
    case SPELL_HARM:
    case SPELL_HENCH_UndeadSelfHarm:
        // max out for heal spells
        return 2000;
    case SPELL_NEGATIVE_ENERGY_RAY:
        // ((casterlevel +  1) / 2)d6 Max caster of 9. Take as 1.
        if (bUseItem)
        {
            return 4;
        }
        if (nMySpellCasterLevel > 8)
        {
            return 18;
        }
        return (nMySpellCasterLevel + 1) * 7 / 4;
    }
    if (bEnableEmpower)
    {
        return returnValue + (returnValue / 2);
    }
    return returnValue;
}


int GetHealingSpellLevel(int iSpellID)
{
    switch(iSpellID)
    {
    case SPELL_CURE_MINOR_WOUNDS:
    case SPELL_INFLICT_MINOR_WOUNDS:
        return 0;
    case SPELL_CURE_LIGHT_WOUNDS:
    case SPELLABILITY_LESSER_BODY_ADJUSTMENT:
    case SPELL_INFLICT_LIGHT_WOUNDS:
    case SPELL_NEGATIVE_ENERGY_RAY:
        return 1;
    case SPELL_CURE_MODERATE_WOUNDS:
    case SPELL_INFLICT_MODERATE_WOUNDS:
        return 2;
    case SPELL_NEGATIVE_ENERGY_BURST:
    case SPELL_CURE_SERIOUS_WOUNDS:
    case SPELL_INFLICT_SERIOUS_WOUNDS:
        return 3;
    case SPELL_CURE_CRITICAL_WOUNDS:
    case SPELL_INFLICT_CRITICAL_WOUNDS:
    case SPELL_HENCH_Cure_Critical_Wounds_Others:
        return 4;
    case SPELL_HEALING_CIRCLE:
    case SPELL_CIRCLE_OF_DOOM:
        return 5;
    case SPELL_HEAL:
    case SPELL_HARM:
    case SPELL_HENCH_UndeadSelfHarm:
        return 6;
    case SPELL_MASS_HEAL:
        return 8;
    }
    // error
    return 3;
}


const int HENCH_HEAL_USE_SPELL = 1;
const int HENCH_HEAL_USE_ITEM = 2;
const int HENCH_HEAL_USE_FEAT = 3;

const int HENCH_FEAT_USE_HEALING_KIT = -200;


/*::///////////////////////////////////////////////
   HEAL SELF WITH POTIONS AND SPELLS
    Uses the best it can.
    1. If it is heal, they need to be under half HP and under 40 HP
    2. If not, it has to be under half HP and not be heal/mass heal
    3. Testing to see if harm will be cast by undead
//::////////////////////////////////////////////*/
int HenchTalentHeal(object oHeal, int iCurEffects, int iHealFlags)
{
    int iCurrent = GetCurrentHitPoints(oHeal);
    int iBase = GetMaxHitPoints(oHeal);
    if (iCurrent >= iBase)
    {
        return FALSE;
    }
    int bForce = iHealFlags & HENCH_HEAL_FORCE;
    if (!bForce && (iCurrent >= iBase / 2))
    {
        return FALSE;
    }
    // If current is under 1/2
    int bIsSelf = (oHeal == OBJECT_SELF);
    if (bIsSelf)
    {
        // reset flag to assume will find healing
        SetLocalInt(OBJECT_SELF, HENCH_HEAL_SELF_STATE, HENCH_HEAL_SELF_WAIT);
    }
    int iBeBelow =  iBase - iCurrent;

    talent tHealBest;
    int iSelectHealType = 0;
    int iHealSpell = 0;
    int iHealAmount = 0;
    int iHealWeight = 0;
    object oHealingKit;

    if (GetRacialType(oHeal) != RACIAL_TYPE_UNDEAD)
    {
        // Note: Feat Lesser Bodily Adjustment uses cure light wounds spell script.
        // Odd classes mean no potions or healing kits.
        int bUseItems = GetIsObjectValid(GetRealMaster()) || GetCreatureUseItems(OBJECT_SELF);
        int iSpellHealAmount;
        // check for healing spells
        if (!(iCurEffects & HENCH_HAS_POLYMORPH_EFFECT))
        {
            int healCount;

            while (TRUE)
            {
                int iTestSpell;
                int bUseCureTest = TRUE;

                switch (healCount++)
                {
                case 0:
                    iTestSpell = SPELL_MASS_HEAL;
                    bUseCureTest = FALSE;
                    break;
                case 1:
                    iTestSpell = SPELL_HEAL;
                    bUseCureTest = FALSE;
                    break;
                case 2:
                    iTestSpell = SPELL_CURE_CRITICAL_WOUNDS;
                    break;
                case 3:
                    if (!bIsSelf)
                    {
                        iTestSpell = SPELL_HENCH_Cure_Critical_Wounds_Others;
                        bUseCureTest = FALSE;
                        break;
                    }
                    // skip if self
                    healCount++;
                case 4:
                    iTestSpell = SPELL_CURE_SERIOUS_WOUNDS;
                    break;
                case 5:
                    iTestSpell = SPELL_CURE_MODERATE_WOUNDS;
                    break;
                case 6:
                    iTestSpell = SPELL_HEALING_CIRCLE;
                    bUseCureTest = FALSE;
                    break;
                case 7:
                    iTestSpell = SPELLABILITY_LESSER_BODY_ADJUSTMENT;
                    bUseCureTest = FALSE;
                    break;
                case 8:
                    iTestSpell = SPELL_CURE_LIGHT_WOUNDS;
                    break;
                case 9:
                    iTestSpell = SPELL_CURE_MINOR_WOUNDS;
                    break;
                default:
                    iTestSpell = -1;
                }
                if (iTestSpell == -1)
                {
                    break;
                }
                if (bUseCureTest ? GetHasCureSpell(iTestSpell) :
                    (GetHasFixedSpell(iTestSpell) && !bFoundItemSpell))
                {
                    int iTestHealAmount = GetHealingInfo(iTestSpell, FALSE);
                    if (CompareHealTalent(iTestHealAmount, iSpellHealAmount, iBeBelow))
                    {
                        iSpellHealAmount = iTestHealAmount;
                        iHealSpell = iTestSpell;
                    }
                    // exit if already below limit
                    if (!bForce || (iTestHealAmount <= iBeBelow))
                    {
                        break;
                    }
                }
            }
        }
        if (iSpellHealAmount)
        {
            iHealAmount = iSpellHealAmount;
            if (iHealAmount > iBeBelow)
            {
                iHealWeight = iBeBelow;
            }
            else
            {
                iHealWeight = iHealAmount;
            }
            iSelectHealType = HENCH_HEAL_USE_SPELL;
         }
        // next check for potions or items
        int iItemHealSpell;
        int iItemHealAmount;
        int itemSearchIndex = 0;

        // check for heal potion or item
        while (TRUE)
        {
            int itemTalentCategory;

            itemSearchIndex ++;
            if (itemSearchIndex == 1)
            {
                if (bIsSelf && !(iHealFlags & HENCH_HEAL_NO_POTIONS) &&
                    (bUseItems || (iCurEffects & HENCH_HAS_POLYMORPH_EFFECT)))
                {
                    itemTalentCategory = TALENT_CATEGORY_BENEFICIAL_HEALING_POTION;
                }
                else
                {
                    itemSearchIndex ++;
                }
            }
            if (itemSearchIndex == 2)
            {
                if (!(iCurEffects & HENCH_HAS_POLYMORPH_EFFECT) && bUseItems)
                {
                    itemTalentCategory = TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH;
                }
                else
                {
                    itemSearchIndex ++;
                }
            }
            if (itemSearchIndex > 2)
            {
                break;
            }

            int iMaxItemTestCount = 0;
            talent tItemHeal;

            tItemHeal = GetCreatureTalentBest(itemTalentCategory, 20);

            while (GetIsTalentValid(tItemHeal))
            {
                int iTestSpell = GetIdFromTalent(tItemHeal);
                int iTestHealAmount = GetHealingInfo(iTestSpell, TRUE);
                if (CompareHealTalent(iTestHealAmount, iItemHealAmount, iBeBelow))
                {
                    iItemHealAmount = iTestHealAmount;
                    iItemHealSpell = iTestSpell;
                    tHealBest = tItemHeal;
                }
                    // exit if first test below limit
                if ((iMaxItemTestCount == 0) && (!bForce || (iItemHealAmount <= iBeBelow)))
                {
                    break;
                }
                iMaxItemTestCount ++;
                if (iMaxItemTestCount > 4)
                {
                    break;
                }
                tItemHeal = GetCreatureTalentRandom(itemTalentCategory);
            }
        }
        if (iItemHealAmount)
        {
            int iTestWeight = iItemHealAmount;
            if (iTestWeight > iBeBelow)
            {
                iTestWeight = iBeBelow;
            }
            if (nGlobalMeleeAttackers)
            {
                iTestWeight *= 3;
                iTestWeight /= 2;
            }
            if (iTestWeight > iHealWeight)
            {
                iHealSpell = iItemHealSpell;
                iHealAmount = iItemHealAmount;
                iHealWeight = iTestWeight;
                iSelectHealType = HENCH_HEAL_USE_ITEM;
            }
        }

        // check for misc feats or skills (no AoO for these)
        int iOtherHeal;
        int iOtherHealAmount;

        // If we can heal self with feats...use them! No AOO
        if (bIsSelf && GetHasFeat(FEAT_WHOLENESS_OF_BODY))
        {
            iOtherHealAmount = GetLevelByClass(CLASS_TYPE_MONK, OBJECT_SELF) * 2;
            iOtherHeal = FEAT_WHOLENESS_OF_BODY;
        }
        if (GetHasFeat(FEAT_LAY_ON_HANDS))
        {
           // This does the actual formula...note, putting ones to stop DIVIDE BY ZERO errors
            int nChr = GetAbilityModifier(ABILITY_CHARISMA);
            if (nChr < 1) nChr = 0;
            int nLevel = GetLevelByClass(CLASS_TYPE_PALADIN) + GetLevelByClass(CLASS_TYPE_DIVINECHAMPION);
            if (nLevel < 1) nLevel = 1;
            // calculate the amount needed to be at, to use.
            int iTestHealAmount = nLevel * nChr;
            if (iTestHealAmount <= 0)
            {
                iTestHealAmount = 1;
            }
            if (CompareHealTalent(iTestHealAmount, iOtherHealAmount, iBeBelow))
            {
                iOtherHealAmount = iTestHealAmount;
                iOtherHeal = FEAT_LAY_ON_HANDS;
            }
        }
        if (bUseItems && (GetSkillRank(SKILL_HEAL) > 0) && !(iCurEffects & HENCH_HAS_POLYMORPH_EFFECT))
        {
            oHealingKit = GetBestHealingKit();
            if (GetIsObjectValid(oHealingKit))
            {
                int iTestHealAmount = 11 + GetSkillRank(SKILL_HEAL) + IPGetWeaponEnhancementBonus(oHealingKit);
                if (!nGlobalMeleeAttackers)
                {
                    // take 20
                    iTestHealAmount += 9;
                }
                if (CompareHealTalent(iTestHealAmount, iOtherHealAmount, iBeBelow))
                {
                    iOtherHealAmount = iTestHealAmount;
                    iOtherHeal = HENCH_FEAT_USE_HEALING_KIT;
                }
            }
        }
        if (iOtherHealAmount)
        {
            int iTestWeight = iOtherHealAmount;
            if (iTestWeight > iBeBelow)
            {
                iTestWeight = iBeBelow;
            }
            if (nGlobalMeleeAttackers)
            {
                iTestWeight *= 2;
            }
            if (iTestWeight > iHealWeight)
            {
                iHealSpell = iOtherHeal;
                iHealAmount = iOtherHealAmount;
                iHealWeight = iTestWeight;
                iSelectHealType = HENCH_HEAL_USE_FEAT;
            }
        }
    }
    else
    {
        if (GetHasFixedSpell(SPELL_HARM))
        {
            iHealSpell = SPELL_HARM;
        }
        else if (GetHasSpell(SPELL_HENCH_UndeadSelfHarm))
        {
            iHealSpell = SPELL_HENCH_UndeadSelfHarm;
        }
        else if (GetHasInflictSpell(SPELL_INFLICT_CRITICAL_WOUNDS))
        {
            iHealSpell = SPELL_INFLICT_CRITICAL_WOUNDS;
        }
        else if (GetHasInflictSpell(SPELL_INFLICT_SERIOUS_WOUNDS))
        {
            iHealSpell = SPELL_INFLICT_SERIOUS_WOUNDS;
        }
        else if (GetHasInflictSpell(SPELL_INFLICT_MODERATE_WOUNDS))
        {
            iHealSpell = SPELL_INFLICT_MODERATE_WOUNDS;
        }
        // TODO check allies??
        else if (GetHasFixedSpell(SPELL_CIRCLE_OF_DOOM))
        {
            iHealSpell = SPELL_CIRCLE_OF_DOOM;
        }
        else if (!bIsSelf && GetHasFixedSpell(SPELL_NEGATIVE_ENERGY_RAY))
        {
            iHealSpell = SPELL_NEGATIVE_ENERGY_RAY;
        }
        // TODO check allies??
        else if (GetHasFixedSpell(SPELL_NEGATIVE_ENERGY_BURST))
        {
            iHealSpell = SPELL_NEGATIVE_ENERGY_BURST;
        }
        else if (GetHasInflictSpell(SPELL_INFLICT_LIGHT_WOUNDS))
        {
            iHealSpell = SPELL_INFLICT_LIGHT_WOUNDS;
        }
        else if (GetHasInflictSpell(SPELL_INFLICT_MINOR_WOUNDS))
        {
            iHealSpell = SPELL_INFLICT_MINOR_WOUNDS;
        }
        if (iHealSpell)
        {
            iHealAmount = GetHealingInfo(iHealSpell, bFoundItemSpell);
            iHealWeight = bFoundItemSpell ? iHealAmount * 3 / 2 : iHealAmount;
            iSelectHealType = HENCH_HEAL_USE_SPELL;
        }
    }
    int bCanHeal = FALSE;
       // heal spell
    if ((iHealSpell == SPELL_HEAL) || (iHealSpell == SPELL_MASS_HEAL) || (iHealSpell == SPELL_HARM) || (iHealSpell == SPELL_HENCH_UndeadSelfHarm))
    {
        bCanHeal = TRUE;
        if (bForce || (iCurrent < 40) || (iCurrent < (iBase / 3)))
        {
            SetLocalInt(OBJECT_SELF, HENCH_HEAL_SELF_STATE, HENCH_HEAL_SELF_IN_PROG);
            if (!bForce && nGlobalMeleeAttackers)
            {
                if (HenchTalentHide(iCurEffects, nGlobalMeleeAttackers))
                {
                    return TRUE;
                }
            }
            if (iSelectHealType == HENCH_HEAL_USE_ITEM)
            {
                ActionUseTalentOnObject(tHealBest, oHeal);
            }
            else if (iHealSpell == SPELL_HENCH_UndeadSelfHarm)
            {
                ActionCastSpellAtObject(SPELL_HENCH_UndeadSelfHarm, oHeal);
            }
            else
            {
                CastFixedSpellOnObject(iHealSpell, oHeal, GetHealingSpellLevel(iHealSpell));
            }
            return TRUE;
        }
    }
        // other cure spell
    else if ((iHealAmount > 0) && (!(iHealFlags & HENCH_HEAL_NO_MINOR) || (iHealWeight >= (iBase / (nGlobalMeleeAttackers ?  8 : 15)))))
    {
        bCanHeal = TRUE;
//        Jug_Debug(GetName(OBJECT_SELF) + " can heal " + IntToString(iHealAmount) + " type " + IntToString(iSelectHealType) + " spell " + IntToString(iHealSpell));
            // If the current HP is under the damage that is healed.
        if(bForce || (iCurrent <= iBase - iHealAmount) || (iCurrent < ((iBase * 2) / 5)))
        {
            SetLocalInt(OBJECT_SELF, HENCH_HEAL_SELF_STATE, HENCH_HEAL_SELF_IN_PROG);
            if (!bForce && nGlobalMeleeAttackers)
            {
                if (HenchTalentHide(iCurEffects, nGlobalMeleeAttackers))
                {
                    return TRUE;
                }
            }
            if (iSelectHealType == HENCH_HEAL_USE_ITEM)
            {
                ActionUseTalentOnObject(tHealBest, oHeal);
            }
            else if (iSelectHealType == HENCH_HEAL_USE_SPELL)
            {
                CastFixedSpellOnObject(iHealSpell, oHeal, GetHealingSpellLevel(iHealSpell));
            }
            else if (iHealSpell == HENCH_FEAT_USE_HEALING_KIT)
            {
                ActionUseSkill(SKILL_HEAL, oHeal, 0, oHealingKit);
            }
            else
            {
                CastFeatOnObject(iHealSpell, oHeal);
            }
            return TRUE;
        }
    }
    if (bIsSelf && !bCanHeal)
    {
        // indicate that unable to heal
        SetLocalInt(OBJECT_SELF, HENCH_HEAL_SELF_STATE, HENCH_HEAL_SELF_CANT);
    }
    return FALSE;
}


// HEAL ALL ALLIES
// Only if they are in sight, and are under 50%. Always nearest...
// Also, it casts AOE healing spells as well!
int HenchTalentHealAllies(int iCurEffects, int iHealFlags)
{
    object oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, 1,
        CREATURE_TYPE_IS_ALIVE, FALSE, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
    if(GetGeneralOptions(HENCH_GENAI_ENABLERAISE) & HENCH_GENAI_ENABLERAISE)
    {
        if(GetIsObjectValid(oTarget) && GetIsDead(oTarget))
        {
            if (GetHasFixedSpell(SPELL_RESURRECTION))
            {
                CastFixedSpellOnObject(SPELL_RESURRECTION, oTarget, 7);
                return TRUE;
            }
            if (GetHasFixedSpell(SPELL_RAISE_DEAD))
            {
                CastFixedSpellOnObject(SPELL_RAISE_DEAD, oTarget, 5);
                return TRUE;
            }
        }
    }

    // * change target
    // * find nearest friend to heal.
    object oMaster = GetRealMaster();

    object oHeal = OBJECT_INVALID;
    int nMaxDiff = 0;
    object oUndead = OBJECT_INVALID;
    int nMaxUndeadDiff = 0;

    InitializeAllyTargets();

    int curCount;
    if (GetIsObjectValid(oTarget) && GetCurrentHitPoints(oTarget) > HENCH_BLEED_NEGHPS)
    {
        curCount = -1;
    }
    else
    {
        curCount = 0;
    }
    int bForce = iHealFlags & HENCH_HEAL_FORCE;
    for (; curCount < nNumAlliesFound; curCount++)
    {
        if (curCount >= 0)
        {
            oTarget = GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curCount);
        }
//        Jug_Debug(GetName(OBJECT_SELF) + " is checking heal target " + GetName(oTarget));
        int nCurrent = GetCurrentHitPoints(oTarget);
        int nAdjusted = nCurrent;
        if (!bForce)
        {
            nAdjusted *= 2;
        }
        int nBase = GetMaxHitPoints(oTarget);
        int nAssocType = GetAssociateType(oTarget);
        // note : ignore dominated creatures
        if (nAdjusted < nBase && oTarget != OBJECT_SELF && oTarget != oMaster &&
            nAssocType != ASSOCIATE_TYPE_DOMINATED  && (bForce || GetIsDead(oTarget) ||
            GetLocalInt(oTarget, HENCH_HEAL_SELF_STATE) <= HENCH_HEAL_SELF_CANT))
        {
            int nDiff = nBase - nCurrent;
            // summoned don't count as much
            if (nAssocType == ASSOCIATE_TYPE_SUMMONED)
            {
                nDiff *= 3;
                nDiff /= 4;
            }
            if (GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
            {
                if (nDiff > nMaxUndeadDiff)
                {
                    nMaxUndeadDiff = nDiff;
                    oUndead = oTarget;
                }
            }
            else
            {
                if (nDiff > nMaxDiff)
                {
                    nMaxDiff = nDiff;
                    oHeal = oTarget;
                }
            }
                // bleeding - give priority
            if (GetIsDead(oTarget))
            {
                nMaxDiff *= 5;
            }
        }
    }
    if (nMaxDiff > nMaxUndeadDiff && GetIsObjectValid(oHeal))
    {
        if (HenchTalentHeal(oHeal, iCurEffects, iHealFlags))
        {
            return TRUE;
        }
    }
    if (GetIsObjectValid(oUndead))
    {
        if (HenchTalentHeal(oUndead, iCurEffects, iHealFlags))
        {
            return TRUE;
        }
    }
    if (nMaxDiff <= nMaxUndeadDiff && GetIsObjectValid(oHeal))
    {
        if (HenchTalentHeal(oHeal, iCurEffects, iHealFlags))
        {
            return TRUE;
        }
    }

    return FALSE;
}


// HEAL SELF & OTHERS
int HenchTalentHealAll(int iCurEffects, int iHealFlags)
{
    object oRealMaster = GetRealMaster();

    if(((iHealFlags & HENCH_HEAL_FORCE) || GetAssociateHealMaster()) && GetObjectSeen(oRealMaster) &&
        (GetCurrentHitPoints(oRealMaster) > HENCH_BLEED_NEGHPS))
    {
        if (HenchTalentHeal(oRealMaster, iCurEffects, iHealFlags))
        {
            return TRUE;
        }
    }
    if (HenchTalentHeal(OBJECT_SELF, iCurEffects, iHealFlags))
    {
        return TRUE;
    }
    return HenchTalentHealAllies(iCurEffects, iHealFlags);
}


/*::///////////////////////////////////////////////
   CURE SELF FULLY WITH POTIONS AND SPELLS
    Uses the best healing at the mo. Heals self out of battle...
    No area of effect spells at the moment. Works OK...
//::////////////////////////////////////////////*/
// CURE DISEASE, POISON ETC

const int nCurse        = 0x00000001;
const int nPoison       = 0x00000002;
const int nDisease      = 0x00000004;
const int nAbilityDrain = 0x00000008;
const int nDrained      = 0x00000010;
const int nBlindDeaf    = 0x00000020;
const int nParalsis     = 0x00000040;
const int nSlow         = 0x00000080;
const int nFreedom      = 0x00000100;
const int nFear         = 0x00000200;
const int nClarity      = 0x00000400;
const int nDarkness     = 0x00000800;
const int nSleep        = 0x00001000;
const int nPetrified    = 0x00002000;
const int nDominated    = 0x00004000;
const int nMindBlank    = 0x00008000;




const int bFlagMindBlank        = 0x00000001;
const int bFlagLesserMindBlank  = 0x00000002;
const int bFlagGreaterRest      = 0x00000004;
const int bFlagGreaterDispel    = 0x00000008;
const int bFlagDispel           = 0x00000010;
const int bFlagLesserDispel     = 0x00000020;
const int bFlagStoneToFlesh     = 0x00000040;
const int bFlagRemoveFear       = 0x00000080;
const int bFlagRemoveDisease    = 0x00000100;
const int bFlagNeutPoison       = 0x00000200;
const int bFlagRemoveCurse      = 0x00000400;
const int bFlagRemoveBlindDeaf  = 0x00000800;
const int bFlagRemoveParalysis  = 0x00001000;
const int bFlagLesserRest       = 0x00002000;
const int bFlagFreeMovement     = 0x00004000;
const int bFlagClarity          = 0x00008000;
const int bFlagTrueSeeing       = 0x00010000;
const int bFlagDarkvision       = 0x00020000;
const int bFlagRestoration      = 0x00040000;
const int bFlagRestOthers       = 0x00080000;



// CURE DISEASE, POISON ETC
int HenchTalentCureCondition(object oTarget = OBJECT_INVALID)
{
    if (GetSpellUnknownFlag(HENCH_CURE_COND_SPELL))
    {
        // quick exit for the spell-less
        return FALSE;
    }
    int bTargetSet = GetIsObjectValid(oTarget);

    int nSpellsKnownSelf = 0;
    int nSpellsKnownOther = 0;

    if (GetHasFixedSpell(SPELL_MIND_BLANK))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagMindBlank;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagMindBlank;
        }
    }
    if (GetHasFixedSpell(SPELL_LESSER_MIND_BLANK))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagLesserMindBlank;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagLesserMindBlank;
        }
    }
    if (GetHasFixedSpell(SPELL_GREATER_RESTORATION))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagGreaterRest;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagGreaterRest;
        }
    }
    if (GetHasFixedSpell(SPELL_GREATER_DISPELLING))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagGreaterDispel;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagGreaterDispel;
        }
    }
    if (GetHasFixedSpell(SPELL_DISPEL_MAGIC))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagDispel;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagDispel;
        }
    }
    if (GetHasFixedSpell(SPELL_LESSER_DISPEL))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagLesserDispel;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagLesserDispel;
        }
    }
    if (GetHasFixedSpell(SPELL_STONE_TO_FLESH))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagStoneToFlesh;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagStoneToFlesh;
        }
    }
    if (GetHasFixedSpell(SPELL_REMOVE_FEAR))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagRemoveFear;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagRemoveFear;
        }
    }
    if (GetHasFixedSpell(SPELL_REMOVE_DISEASE))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagRemoveDisease;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagRemoveDisease;
        }
    }
    if (GetHasFixedSpell(SPELL_NEUTRALIZE_POISON))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagNeutPoison;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagNeutPoison;
        }
    }
    if (GetHasFixedSpell(SPELL_REMOVE_CURSE))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagRemoveCurse;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagRemoveCurse;
        }
    }
    if (GetHasFixedSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagRemoveBlindDeaf;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagRemoveBlindDeaf;
        }
    }
    if (GetHasFixedSpell(SPELL_REMOVE_PARALYSIS))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagRemoveParalysis;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagRemoveParalysis;
        }
    }
    if (GetHasFixedSpell(SPELL_LESSER_RESTORATION))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagLesserRest;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagLesserRest;
        }
    }
    if (GetHasFixedSpell(SPELL_FREEDOM_OF_MOVEMENT))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagFreeMovement;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagFreeMovement;
        }
    }
    if (GetHasFixedSpell(SPELL_CLARITY))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagClarity;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagClarity;
        }
    }
    if (GetHasFixedSpell(SPELL_TRUE_SEEING))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagTrueSeeing;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagTrueSeeing;
        }
    }
    if (GetHasFixedSpell(SPELL_DARKVISION))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagDarkvision;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagDarkvision;
        }
    }
    if (GetHasFixedSpell(SPELL_RESTORATION))
    {
        nSpellsKnownSelf = nSpellsKnownSelf | bFlagRestoration;
        if (!bFoundPotionOnly)
        {
            nSpellsKnownOther = nSpellsKnownOther | bFlagRestoration;
        }
    }
    if (GetHasFixedSpell(SPELL_HENCH_Restoration_Others))
    {
        nSpellsKnownOther = nSpellsKnownOther | bFlagRestOthers;
    }

    if (nSpellsKnownSelf == 0 && nSpellsKnownOther == 0)
    {
        if (bNoSpellDisabledDueToEffectOrHench)
        {
            SetSpellUnknownFlag(HENCH_CURE_COND_SPELL);
        }
        return FALSE;
    }

    InitializeAllyTargets();
    int curCount = bTargetSet ? -5 : -2;

    while (TRUE)
    {
        int nSum = 0;
        int nDispelSum = 0;

        if (curCount == -5)
        {
        }
        else if (curCount == -4)
        {
            break;
        }
        else if (curCount == -2)
        {
            oTarget = OBJECT_SELF;
        }
        else if (curCount == -1)
        {
            // test if anything can be done about domination
            if (nSpellsKnownOther & (bFlagMindBlank | bFlagLesserMindBlank | bFlagGreaterRest |
                bFlagGreaterDispel | bFlagDispel| bFlagLesserDispel))
            {
                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
                int iEnemyIndex = 2;
                while (GetIsObjectValid(oTarget) && (GetDistanceToObject(oTarget) < 20.0) && (iEnemyIndex <= 10))
                {
                    if (GetAssociateType(oTarget) == ASSOCIATE_TYPE_DOMINATED)
                    {
                        effect eEffect = GetFirstEffect(oTarget);
                        while (GetIsEffectValid(eEffect))
                        {
                            if(GetEffectType(eEffect) == EFFECT_TYPE_DOMINATED)
                            {
                                nSum = nDominated;
                                if (GetEffectSubType(eEffect) == SUBTYPE_MAGICAL)
                                {
                                    nDispelSum = nDominated;
                                }
                                break;
                            }
                            eEffect = GetNextEffect(oTarget);
                        }
                        if (nSum)
                        {
                            break;
                        }
                    }
                    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, iEnemyIndex++, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
                }
                if (nSum)
                {
                    if (nSpellsKnownOther & bFlagMindBlank)
                    {
                        CastFixedSpellOnObject(SPELL_MIND_BLANK, oTarget, 8);
                        return TRUE;
                    }
                    if (nSpellsKnownOther & bFlagLesserMindBlank)
                    {
                        CastFixedSpellOnObject(SPELL_LESSER_MIND_BLANK, oTarget, 5);
                        return TRUE;
                    }
                    if (nSpellsKnownOther & bFlagGreaterRest)
                    {
                        CastFixedSpellOnObject(SPELL_GREATER_RESTORATION, oTarget, 7);
                        return TRUE;
                    }
                    if (nDispelSum == nDominated && !GetLocalInt(OBJECT_SELF, sHenchDontDispel))
                    {
                        if (nSpellsKnownOther & bFlagGreaterDispel)
                        {
                            CastFixedSpellOnObject(SPELL_GREATER_DISPELLING, oTarget, 6);
                            return TRUE;
                        }
                        if (nSpellsKnownOther & bFlagDispel)
                        {
                            CastFixedSpellOnObject(SPELL_DISPEL_MAGIC, oTarget, 3);
                            return TRUE;
                        }
                        if (nSpellsKnownOther & bFlagLesserDispel)
                        {
                            CastFixedSpellOnObject(SPELL_LESSER_DISPEL, oTarget, 2);
                            return TRUE;
                        }
                    }
                    nSum = 0;
                    nDispelSum = 0;
                }
            }
            curCount++;
        }
        if (curCount >= nNumAlliesFound)
        {
            break;
        }
        else if (curCount >= 0)
        {
            oTarget = GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curCount);
        }
        curCount++;

        int nSpellsKnown;

        if (oTarget == OBJECT_SELF)
        {
            if (nSpellsKnownSelf == 0)
            {
                continue;
            }
            nSpellsKnown = nSpellsKnownSelf;
        }
        else
        {
            if (nSpellsKnownOther == 0)
            {
                break;
            }
            nSpellsKnown = nSpellsKnownOther;
        }

        effect eEffect = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eEffect))
        {
            int nNewSum = 0;

            switch (GetEffectType(eEffect))
            {
            case EFFECT_TYPE_DISEASE:
                nNewSum = nDisease;
                break;
            case EFFECT_TYPE_FRIGHTENED:
                nNewSum = nFear;
                break;
            case EFFECT_TYPE_POISON:
                nNewSum = nPoison;
                break;
            case EFFECT_TYPE_CURSE:
                nNewSum = nCurse;
                break;
            case EFFECT_TYPE_NEGATIVELEVEL:
                nNewSum = nDrained;
                break;
            case EFFECT_TYPE_AC_DECREASE:
                if (GetEffectSpellId(eEffect) == SPELLABILITY_BARBARIAN_RAGE)
                {
                    break;  // don't do anything about barbarian rage
                }
            case EFFECT_TYPE_ABILITY_DECREASE:
            case EFFECT_TYPE_ATTACK_DECREASE:
            case EFFECT_TYPE_DAMAGE_DECREASE:
            case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
            case EFFECT_TYPE_SAVING_THROW_DECREASE:
            case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
            case EFFECT_TYPE_SKILL_DECREASE:
                nNewSum = nAbilityDrain;
                break;
            case EFFECT_TYPE_PARALYZE:
                nNewSum = nParalsis;
                break;
            case EFFECT_TYPE_SLOW:
                nNewSum = nSlow;
                break;
            case EFFECT_TYPE_CHARMED:
            case EFFECT_TYPE_DAZED:
            case EFFECT_TYPE_CONFUSED:
            case EFFECT_TYPE_STUNNED:
                nNewSum = nClarity;
                break;
            case EFFECT_TYPE_BLINDNESS:
            case EFFECT_TYPE_DEAF:
                 nNewSum = nBlindDeaf;
                break;
            case EFFECT_TYPE_ENTANGLE:
            case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
                nNewSum = nFreedom;
                break;
            case EFFECT_TYPE_SLEEP:
                nNewSum = nSleep;
                break;
            case EFFECT_TYPE_DARKNESS:
                if (!GetHasSpellEffect(SPELL_DARKVISION, oTarget) &&
                    !GetHasSpellEffect(SPELL_TRUE_SEEING, oTarget) &&
                    !GetHasFeat(FEAT_BLINDSIGHT_60_FEET, oTarget) &&
                    !GetCreatureHasItemProperty(ITEM_PROPERTY_TRUE_SEEING, oTarget))
                {
                    nNewSum = nDarkness;
                }
                break;
            case EFFECT_TYPE_PETRIFY:
                nNewSum = nPetrified;
                break;

            // TODO add EFFECT_TYPE_SILENCE?
            }

            nSum = nSum | nNewSum;
            if (GetEffectSubType(eEffect) == SUBTYPE_MAGICAL)
            {
                nDispelSum = nDispelSum | nNewSum;
            }
            eEffect = GetNextEffect(oTarget);
        }
        if (GetHasSpellEffect(SPELL_BANE, oTarget) || GetHasSpellEffect(SPELL_FEEBLEMIND, oTarget))
        {
            // feeblemind and bane cured by mind blank
            nSum = nSum | nMindBlank;
        }
        if (nSum != 0)
        {
            if (GetLocalInt(OBJECT_SELF, sHenchDontDispel))
            {
                nDispelSum = 0;
            }
            else
            {
                // only use dispel for some effects
                nDispelSum = nDispelSum & (nClarity | nFear | nParalsis);
            }
            // test for single effect or fear (only remove fear works)
            // i.e. don't waste good spells
            if (nSum & nPetrified)
            {
                if (nSpellsKnown & bFlagStoneToFlesh)
                {
                    CastFixedSpellOnObject(SPELL_STONE_TO_FLESH, oTarget, 6);
                    return TRUE;
                }
                else
                {
                    nSum = 0;
                }
            }
            if ((nSum & nFear) && (nSpellsKnown & bFlagRemoveFear))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_FEAR, oTarget, 1);
                return TRUE;
            }
            if ((nSum == nDisease) && (nSpellsKnown & bFlagRemoveDisease))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_DISEASE, oTarget, 3);
                return TRUE;
            }
            if (((nSum & ~(nDisease | nPoison)) == 0) && (nSpellsKnown & bFlagNeutPoison))
            {
                CastFixedSpellOnObject(SPELL_NEUTRALIZE_POISON, oTarget, 3);
                return TRUE;
            }
            if ((nSum == nCurse) && (nSpellsKnown & bFlagRemoveCurse))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_CURSE, oTarget, 3);
                return TRUE;
            }
            if ((nSum == nBlindDeaf) && (nSpellsKnown & bFlagRemoveBlindDeaf))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS, oTarget, 3);
                return TRUE;
            }
            if ((nSum == nParalsis) && (nSpellsKnown & bFlagRemoveParalysis))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_PARALYSIS, oTarget, 2);
                return TRUE;
            }
            if ((nSum == nAbilityDrain) && (nSpellsKnown & bFlagLesserRest))
            {
                CastFixedSpellOnObject(SPELL_LESSER_RESTORATION, oTarget, 2);
                return TRUE;
            }
            if(((nSum & ~(nParalsis | nFreedom | nSlow)) == 0) && (nSpellsKnown & bFlagFreeMovement))
            {
                CastFixedSpellOnObject(SPELL_FREEDOM_OF_MOVEMENT, oTarget, 4);
                return TRUE;
            }
            if ((nSum & ~(nClarity | nSleep | nSlow | nMindBlank)) == 0)
            {
                if (nSpellsKnown & bFlagMindBlank)
                {
                    CastFixedSpellOnObject(SPELL_MIND_BLANK, oTarget, 8);
                    return TRUE;
                }
                if (nSpellsKnown & bFlagLesserMindBlank)
                {
                    CastFixedSpellOnObject(SPELL_LESSER_MIND_BLANK, oTarget, 5);
                    return TRUE;
                }
            }
            if (((nSum & ~(nClarity | nSleep)) == 0) && (nSpellsKnown & bFlagClarity))
            {
                CastFixedSpellOnObject(SPELL_CLARITY, oTarget, 2);
                return TRUE;
            }
            if ((nSum & (nFear | nSlow | nClarity | nParalsis | nCurse)) && (nSpellsKnown & bFlagGreaterRest))
            {
                CastFixedSpellOnObject(SPELL_GREATER_RESTORATION, oTarget, 7);
                return TRUE;
            }
            if ((nSum & nDarkness) && (nSpellsKnown & bFlagTrueSeeing))
            {
                CastFixedSpellOnObject(SPELL_TRUE_SEEING, oTarget, 5);
                return TRUE;
            }
            if ((nSum & nDarkness) && (nSpellsKnown & bFlagDarkvision))
            {
                CastFixedSpellOnObject(SPELL_DARKVISION, oTarget, 2);
                return TRUE;
            }
            if ((nSum & (nBlindDeaf | nParalsis | nDrained)))
            {
                if (nSpellsKnown & bFlagRestoration)
                {
                    CastFixedSpellOnObject(SPELL_RESTORATION, oTarget, 4);
                    return TRUE;
                }
                if (nSpellsKnown & bFlagRestOthers)
                {
                    CastFixedSpellOnObject(SPELL_HENCH_Restoration_Others, oTarget, 4);
                    return TRUE;
                }
                if (nSpellsKnown & bFlagGreaterRest)
                {
                    CastFixedSpellOnObject(SPELL_GREATER_RESTORATION, oTarget, 7);
                    return TRUE;
                }
            }
            if (nDispelSum)
            {
                if (nSpellsKnown & bFlagGreaterDispel)
                {
                    CastFixedSpellOnObject(SPELL_GREATER_DISPELLING, oTarget, 6);
                    return TRUE;
                }
                if (nSpellsKnown & bFlagDispel)
                {
                    CastFixedSpellOnObject(SPELL_DISPEL_MAGIC, oTarget, 3);
                    return TRUE;
                }
                if (nSpellsKnown & bFlagLesserDispel)
                {
                    CastFixedSpellOnObject(SPELL_LESSER_DISPEL, oTarget, 2);
                    return TRUE;
                }
            }
            // after this point try to get rid of anything doing worst first
            if (nSum & (nClarity | nSleep | nSlow | nMindBlank))
            {
                if (nSpellsKnown & bFlagMindBlank)
                {
                    CastFixedSpellOnObject(SPELL_MIND_BLANK, oTarget, 8);
                    return TRUE;
                }
                if (nSpellsKnown & bFlagLesserMindBlank)
                {
                    CastFixedSpellOnObject(SPELL_LESSER_MIND_BLANK, oTarget, 5);
                    return TRUE;
                }
            }
            if ((nSum & (nClarity | nSleep)) && (nSpellsKnown & bFlagClarity))
            {
                CastFixedSpellOnObject(SPELL_CLARITY, oTarget, 2);
                return TRUE;
            }
            if ((nSum & (nParalsis | nFreedom | nSlow)) && (nSpellsKnown & bFlagFreeMovement))
            {
                CastFixedSpellOnObject(SPELL_FREEDOM_OF_MOVEMENT, oTarget, 4);
                return TRUE;
            }
            if ((nSum & nParalsis) && (nSpellsKnown & bFlagRemoveParalysis))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_PARALYSIS, oTarget, 2);
                return TRUE;
            }
            if ((nSum & nBlindDeaf) && (nSpellsKnown & bFlagRemoveBlindDeaf))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS, oTarget, 3);
                return TRUE;
            }
            if ((nSum & nCurse) && (nSpellsKnown & bFlagRemoveCurse))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_CURSE, oTarget, 3);
                return TRUE;
            }
            if ((nSum & nAbilityDrain) && (nSpellsKnown & bFlagLesserRest))
            {
                CastFixedSpellOnObject(SPELL_LESSER_RESTORATION, oTarget, 2);
                return TRUE;
            }
            if ((nSum & nPoison) && (nSpellsKnown & bFlagNeutPoison))
            {
                CastFixedSpellOnObject(SPELL_NEUTRALIZE_POISON, oTarget, 3);
                return TRUE;
            }
            if ((nSum & nDisease) && (nSpellsKnown & bFlagRemoveDisease))
            {
                CastFixedSpellOnObject(SPELL_REMOVE_DISEASE, oTarget, 3);
                return TRUE;
            }
            if ((nSum & nDisease) && (nSpellsKnown & bFlagNeutPoison))
            {
                CastFixedSpellOnObject(SPELL_NEUTRALIZE_POISON, oTarget, 3);
                return TRUE;
            }
            if ((nSum & (nPoison | nDisease | nAbilityDrain)) && (nSpellsKnown & bFlagGreaterRest))
            {
                CastFixedSpellOnObject(SPELL_GREATER_RESTORATION, oTarget, 7);
                return TRUE;
            }
            if (nSum & nAbilityDrain)
            {
                if (nSpellsKnown & bFlagRestoration)
                {
                    CastFixedSpellOnObject(SPELL_RESTORATION, oTarget, 4);
                    return TRUE;
                }
                if (nSpellsKnown & bFlagRestOthers)
                {
                    CastFixedSpellOnObject(SPELL_HENCH_Restoration_Others, oTarget, 4);
                    return TRUE;
                }
            }
        }
        if (bTargetSet)
        {
            break;
        }
    }
    return FALSE;
}


