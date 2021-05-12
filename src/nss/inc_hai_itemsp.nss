/*

    Henchman Inventory And Battle AI

    This file contains routines used for using items (potions,
    scrolls, and rods by henchman and monsters. Uses talents along
    with silence to actually get the item spells into arrays for
    later use by GetHasFixedSpell. These talent spells are then cast
    by CastFixedSpellOnObject and CastFixedSpellAtLocation.

    Also deals with creatures with a negative effect on them that
    impacts spellcasting (silence, primary ability drain)

*/

#include "inc_hai_generic"
#include "inc_hai_equip"

// void main() {    }

const string sLastSpellTargetObject = "HenchLastSpellTarget";


int bNoSpellDisabledDueToEffectOrHench;

int potionsFound;
int potionCount;
const int maxPotionCount = 5;
talent potionTalent1, potionTalent2, potionTalent3, potionTalent4, potionTalent5;
int potionSpellID1, potionSpellID2, potionSpellID3, potionSpellID4, potionSpellID5;

int HasPotionTalentSpell(int spellID)
{
    if (potionCount < 1)
    {
        return FALSE;
    }
    if (spellID == potionSpellID1)
    {
        return TRUE;
    }
    if (potionCount < 2)
    {
        return FALSE;
    }
    if (spellID == potionSpellID2)
    {
        return TRUE;
    }
    if (potionCount < 3)
    {
        return FALSE;
    }
    if (spellID == potionSpellID3)
    {
        return TRUE;
    }
    if (potionCount < 4)
    {
        return FALSE;
    }
    if (spellID == potionSpellID4)
    {
        return TRUE;
    }
    if (potionCount < 5)
    {
        return FALSE;
    }
    if (spellID == potionSpellID5)
    {
        return TRUE;
    }
    return FALSE;
}


talent GetPotionTalentSpell(int spellID)
{
    if (potionCount < 1)
    {
        return potionTalent1;
    }
    if (spellID == potionSpellID1)
    {
        return potionTalent1;
    }
    if (spellID == potionSpellID2)
    {
        return potionTalent2;
    }
    if (spellID == potionSpellID3)
    {
        return potionTalent3;
    }
    if (spellID == potionSpellID4)
    {
        return potionTalent4;
    }
    if (spellID == potionSpellID5)
    {
        return potionTalent5;
    }
    return potionTalent1;
}


void AddPotionTalentSpell(talent talentSpellFound)
{
    if (potionCount >= maxPotionCount)
    {
        return;
    }
    potionCount ++;
    int spellID = GetIdFromTalent(talentSpellFound);
    if (potionCount == 1)
    {
        potionTalent1 = talentSpellFound;
        potionSpellID1 = spellID;
        return;
    }
    if (potionCount == 2)
    {
        potionTalent2 = talentSpellFound;
        potionSpellID2 = spellID;
        return;
    }
    if (potionCount == 3)
    {
        potionTalent3 = talentSpellFound;
        potionSpellID3 = spellID;
        return;
    }
    if (potionCount == 4)
    {
        potionTalent4 = talentSpellFound;
        potionSpellID4 = spellID;
        return;
    }
    if (potionCount == 5)
    {
        potionTalent5 = talentSpellFound;
        potionSpellID5 = spellID;
        return;
    }
}


int FindPotionTalentsByCategory(int nCategory, int maximumToAdd)
{
    int nTry, dupsFound, spellsFound;

    if (maximumToAdd > maxPotionCount)
    {
        maximumToAdd = maxPotionCount;
    }
    talent tBest = GetCreatureTalentBest(nCategory, 20);
    talent tLast = TalentSkill(SKILL_HEAL);
    while (nTry < 10 && potionCount < maximumToAdd && GetIsTalentValid(tBest))
    {
        if (tBest == tLast)
        {
            dupsFound++;
        }
        else
        {
            dupsFound = 0;
        }
        if (dupsFound > 2)
        {
            break;
        }
        int nType = GetTypeFromTalent(tBest);
        if (nType == TALENT_TYPE_SPELL)
        {
            int nNewSpellID = GetIdFromTalent(tBest);
            if (!HasPotionTalentSpell(nNewSpellID))
            {
                AddPotionTalentSpell(tBest);
                spellsFound ++;
                potionsFound = TRUE;
                dupsFound = 0;
            }
        }
        nTry ++;
        if (spellsFound > 2)
        {
            break;
        }
        tLast = tBest;
        tBest = GetCreatureTalentRandom(nCategory);
    }
    return spellsFound;
}


void InitializePotionTalents()
{
    if (GetLocalInt(OBJECT_SELF, henchNoPotionStr))
    {
        return;
    }
    FindPotionTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_PROTECTION_POTION, maxPotionCount);
    if (potionCount == maxPotionCount)
    {
        return;
    }
    FindPotionTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_POTION, maxPotionCount);
    if (potionCount == maxPotionCount)
    {
        return;
    }
    FindPotionTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_POTION, maxPotionCount);
    if (potionCount == maxPotionCount)
    {
        return;
    }
    if (bNoSpellDisabledDueToEffectOrHench && potionCount == 0)
    {
        SetLocalInt(OBJECT_SELF, henchNoPotionStr, TRUE);
    }
}


int itemSpellsFound;
int onlyUseTalents;
int itemTalentSpellCount;
int itemTalentBoundary;
const int maxItemTalentSpellCount = 15;
talent itemTalent1, itemTalent2, itemTalent3, itemTalent4, itemTalent5,
        itemTalent6, itemTalent7, itemTalent8, itemTalent9, itemTalent10,
        itemTalent11, itemTalent12, itemTalent13, itemTalent14, itemTalent15;
int itemSpellID1, itemSpellID2, itemSpellID3, itemSpellID4, itemSpellID5,
        itemSpellID6, itemSpellID7, itemSpellID8, itemSpellID9, itemSpellID10,
        itemSpellID11, itemSpellID12, itemSpellID13, itemSpellID14, itemSpellID15;

int HasItemTalentSpell(int spellID)
{
    if (itemTalentSpellCount < 1)
    {
        return FALSE;
    }
    if (spellID == itemSpellID1)
    {
        return 1;
    }
    if (itemTalentSpellCount < 2)
    {
        return FALSE;
    }
    if (spellID == itemSpellID2)
    {
        return 2;
    }
    if (itemTalentSpellCount < 3)
    {
        return FALSE;
    }
    if (spellID == itemSpellID3)
    {
        return 3;
    }
    if (itemTalentSpellCount < 4)
    {
        return FALSE;
    }
    if (spellID == itemSpellID4)
    {
        return 4;
    }
    if (itemTalentSpellCount < 5)
    {
        return FALSE;
    }
    if (spellID == itemSpellID5)
    {
        return 5;
    }
    if (itemTalentSpellCount < 6)
    {
        return FALSE;
    }
    if (spellID == itemSpellID6)
    {
        return 6;
    }
    if (itemTalentSpellCount < 7)
    {
        return FALSE;
    }
    if (spellID == itemSpellID7)
    {
        return 7;
    }
    if (itemTalentSpellCount < 8)
    {
        return FALSE;
    }
    if (spellID == itemSpellID8)
    {
        return 8;
    }
    if (itemTalentSpellCount < 9)
    {
        return FALSE;
    }
    if (spellID == itemSpellID9)
    {
        return 9;
    }
    if (itemTalentSpellCount < 10)
    {
        return FALSE;
    }
    if (spellID == itemSpellID10)
    {
        return 10;
    }
    if (itemTalentSpellCount < 11)
    {
        return FALSE;
    }
    if (spellID == itemSpellID11)
    {
        return 11;
    }
    if (itemTalentSpellCount < 12)
    {
        return FALSE;
    }
    if (spellID == itemSpellID12)
    {
        return 12;
    }
    if (itemTalentSpellCount < 13)
    {
        return FALSE;
    }
    if (spellID == itemSpellID13)
    {
        return 13;
    }
    if (itemTalentSpellCount < 14)
    {
        return FALSE;
    }
    if (spellID == itemSpellID14)
    {
        return 14;
    }
    if (itemTalentSpellCount < 15)
    {
        return FALSE;
    }
    if (spellID == itemSpellID15)
    {
        return 15;
    }
    return FALSE;
}


talent GetItemTalentSpell(int spellID)
{
    if (itemTalentSpellCount < 1)
    {
        return itemTalent1;
    }
    if (spellID == itemSpellID1)
    {
        return itemTalent1;
    }
    if (spellID == itemSpellID2)
    {
        return itemTalent2;
    }
    if (spellID == itemSpellID3)
    {
        return itemTalent3;
    }
    if (spellID == itemSpellID4)
    {
        return itemTalent4;
    }
    if (spellID == itemSpellID5)
    {
        return itemTalent5;
    }
    if (spellID == itemSpellID6)
    {
        return itemTalent6;
    }
    if (spellID == itemSpellID7)
    {
        return itemTalent7;
    }
    if (spellID == itemSpellID8)
    {
        return itemTalent8;
    }
    if (spellID == itemSpellID9)
    {
        return itemTalent9;
    }
    if (spellID == itemSpellID10)
    {
        return itemTalent10;
    }
    if (spellID == itemSpellID11)
    {
        return itemTalent11;
    }
    if (spellID == itemSpellID12)
    {
        return itemTalent12;
    }
    if (spellID == itemSpellID13)
    {
        return itemTalent13;
    }
    if (spellID == itemSpellID14)
    {
        return itemTalent14;
    }
    if (spellID == itemSpellID15)
    {
        return itemTalent15;
    }
    return itemTalent1;
}


void AddItemTalentSpell(talent talentSpellFound)
{
    if (itemTalentSpellCount >= maxItemTalentSpellCount)
    {
        return;
    }
    itemTalentSpellCount ++;
    int spellID = GetIdFromTalent(talentSpellFound);

    if (itemTalentSpellCount == 1)
    {
        itemTalent1 = talentSpellFound;
        itemSpellID1 = spellID;
        return;
    }
    if (itemTalentSpellCount == 2)
    {
        itemTalent2 = talentSpellFound;
        itemSpellID2 = spellID;
        return;
    }
    if (itemTalentSpellCount == 3)
    {
        itemTalent3 = talentSpellFound;
        itemSpellID3 = spellID;
        return;
    }
    if (itemTalentSpellCount == 4)
    {
        itemTalent4 = talentSpellFound;
        itemSpellID4 = spellID;
        return;
    }
    if (itemTalentSpellCount == 5)
    {
        itemTalent5 = talentSpellFound;
        itemSpellID5 = spellID;
        return;
    }
    if (itemTalentSpellCount == 6)
    {
        itemTalent6 = talentSpellFound;
        itemSpellID6 = spellID;
        return;
    }
    if (itemTalentSpellCount == 7)
    {
        itemTalent7 = talentSpellFound;
        itemSpellID7 = spellID;
        return;
    }
    if (itemTalentSpellCount == 8)
    {
        itemTalent8 = talentSpellFound;
        itemSpellID8 = spellID;
        return;
    }
    if (itemTalentSpellCount == 9)
    {
        itemTalent9 = talentSpellFound;
        itemSpellID9 = spellID;
        return;
    }
    if (itemTalentSpellCount == 10)
    {
        itemTalent10 = talentSpellFound;
        itemSpellID10 = spellID;
        return;
    }
    if (itemTalentSpellCount == 11)
    {
        itemTalent11 = talentSpellFound;
        itemSpellID11 = spellID;
        return;
    }
    if (itemTalentSpellCount == 12)
    {
        itemTalent12 = talentSpellFound;
        itemSpellID12 = spellID;
        return;
    }
    if (itemTalentSpellCount == 13)
    {
        itemTalent13 = talentSpellFound;
        itemSpellID13 = spellID;
        return;
    }
    if (itemTalentSpellCount == 14)
    {
        itemTalent14 = talentSpellFound;
        itemSpellID14 = spellID;
        return;
    }
    if (itemTalentSpellCount == 15)
    {
        itemTalent15 = talentSpellFound;
        itemSpellID15 = spellID;
        return;
    }
}


int FindItemSpellTalentsByCategory(int nCategory, int maximumToAdd)
{
    int nTry, dupsFound, spellsFound;

    if (maximumToAdd > maxItemTalentSpellCount)
    {
        maximumToAdd = maxItemTalentSpellCount;
    }
    talent tBest = GetCreatureTalentBest(nCategory, 20);
    talent tLast = TalentSkill(SKILL_HEAL);
    while (nTry < 10 && itemTalentSpellCount < maximumToAdd && GetIsTalentValid(tBest))
    {
        if (tBest == tLast)
        {
            dupsFound++;
        }
        else
        {
            dupsFound = 0;
        }
        if (dupsFound > 2)
        {
            break;
        }
        int nType = GetTypeFromTalent(tBest);
        if (nType == TALENT_TYPE_SPELL)
        {
            int nNewSpellID = GetIdFromTalent(tBest);

            if (!HasItemTalentSpell(nNewSpellID))
            {
                AddItemTalentSpell(tBest);
                spellsFound ++;
                itemSpellsFound = TRUE;
                dupsFound = 0;
            }
        }
        nTry ++;
        if (spellsFound > 4)
        {
            break;
        }
        tLast = tBest;
        tBest = GetCreatureTalentRandom(nCategory);
    }
    return spellsFound;
}


void InitializeHealingSpellTalents(int iCheckIfNone = TRUE)
{
    int maximumToAdd = itemTalentSpellCount + 1;
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    maximumToAdd = itemTalentSpellCount + 1;
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
}


void InitializeAttackSpellTalents(int iCheckIfNone = TRUE)
{
    if (iCheckIfNone && GetLocalInt(OBJECT_SELF, henchNoAttackSpStr))
    {
        return;
    }
    int maximumToAdd = itemTalentSpellCount + 10;
    int origItemTalentSpellCount = itemTalentSpellCount;
    if (maximumToAdd > maxItemTalentSpellCount)
    {
        maximumToAdd = maxItemTalentSpellCount;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_HARMFUL_RANGED, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_HARMFUL_TOUCH, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    maximumToAdd = itemTalentSpellCount + 1;
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_OBTAIN_ALLIES, maximumToAdd);
    if (iCheckIfNone && bNoSpellDisabledDueToEffectOrHench && origItemTalentSpellCount == itemTalentSpellCount)
    {
        SetLocalInt(OBJECT_SELF, henchNoAttackSpStr, TRUE);
    }
}


void InitializeEnhanceSpellTalents(int iCheckIfNone = TRUE)
{
    if (iCheckIfNone && GetLocalInt(OBJECT_SELF, henchNoEnhanceSpStr))
    {
        return;
    }
    int maximumToAdd = itemTalentSpellCount + 10;
    int origItemTalentSpellCount = itemTalentSpellCount;
    if (maximumToAdd > maxItemTalentSpellCount)
    {
        maximumToAdd = maxItemTalentSpellCount;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SELF, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE, maximumToAdd);
    if (iCheckIfNone && bNoSpellDisabledDueToEffectOrHench && itemTalentSpellCount == origItemTalentSpellCount)
    {
        SetLocalInt(OBJECT_SELF, henchNoEnhanceSpStr, TRUE);
    }
}


void InitializeConditionalSpellTalents(int iCheckIfNone = TRUE)
{
    if (iCheckIfNone && GetLocalInt(OBJECT_SELF, henchNoCondSpStr))
    {
        return;
    }
    int maximumToAdd = itemTalentSpellCount + 5;
    int origItemTalentSpellCount = itemTalentSpellCount;
    if (maximumToAdd > maxItemTalentSpellCount)
    {
        maximumToAdd = maxItemTalentSpellCount;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_AREAEFFECT, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    FindItemSpellTalentsByCategory(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE, maximumToAdd);
    if (itemTalentSpellCount == maximumToAdd)
    {
        return;
    }
    // 0 talent category is misc spells (***** category in spells.2da)
    FindItemSpellTalentsByCategory(0, maximumToAdd);
    if (iCheckIfNone && bNoSpellDisabledDueToEffectOrHench && itemTalentSpellCount == origItemTalentSpellCount)
    {
        SetLocalInt(OBJECT_SELF, henchNoCondSpStr, TRUE);
    }
}


void InitializeTrapAndLockSpellTalents()
{
    int nTry = 0;
    talent tCurrent = GetCreatureTalentBest(0, 20);
    while (nTry < 20 && GetIsTalentValid(tCurrent))
    {
        int nType = GetTypeFromTalent(tCurrent);
        if (nType == TALENT_TYPE_SPELL)
        {
            int iSpell = GetIdFromTalent(tCurrent);
            if (iSpell == SPELL_FIND_TRAPS && !HasItemTalentSpell(SPELL_FIND_TRAPS))
            {
                AddItemTalentSpell(tCurrent);
            }
            if (iSpell == SPELL_KNOCK && !HasItemTalentSpell(SPELL_KNOCK))
            {
                AddItemTalentSpell(tCurrent);
            }
        }
        nTry ++;
        tCurrent = GetCreatureTalentRandom(0);
    }
    // note that magic missile and other spells are not done because placeables
    //  can't be targeted with ActionUseTalentOnObject
}


// caster level (spell resistance)
int nMySpellCasterLevel;
int nMySpellCasterSpellPenetrationBonus;
int nMySpellCasterSpellPenetration;
// DC for spells
int nMySpellAbilityLevel1;
int nMySpellAbilityLevel12;
int nMySpellAbilityLevel14;
int nMySpellCasterDC;
int nMySpellCasterDCAdjust;

int nGlobalMeleeAttackers;
int bAnySpellcastingClasses;


int InitializeClassByPosition(int iPosition)
{
    int iAbility, iAbilityMod;
    int nClass = GetClassByPosition(iPosition);
    int nClassLevel = GetLevelByPosition(iPosition);

    switch (nClass)
    {
        case CLASS_TYPE_INVALID:
            return FALSE;
        case CLASS_TYPE_FIGHTER:
        case CLASS_TYPE_ROGUE:
        case CLASS_TYPE_MONK:
        case CLASS_TYPE_DIVINE_CHAMPION:
        case CLASS_TYPE_WEAPON_MASTER:
        case CLASS_TYPE_PALE_MASTER:
        case CLASS_TYPE_SHIFTER:
        case CLASS_TYPE_DWARVEN_DEFENDER:
        case CLASS_TYPE_DRAGON_DISCIPLE:
            break;
        case CLASS_TYPE_PALADIN:
        case CLASS_TYPE_RANGER:
            if (nClassLevel < 4)
            {
                break;
            }
        case CLASS_TYPE_CLERIC:
        case CLASS_TYPE_DRUID:
            if (nMySpellCasterLevel < nClassLevel)
            {
                nMySpellCasterLevel = nClassLevel;
            }
            iAbilityMod = GetAbilityModifier(ABILITY_WISDOM);
            if (nMySpellCasterDC < iAbilityMod)
            {
                nMySpellCasterDC = iAbilityMod;
            }
            bAnySpellcastingClasses = TRUE;
            break;
        case CLASS_TYPE_WIZARD:
            if (nMySpellCasterLevel < nClassLevel)
            {
                nMySpellCasterLevel = nClassLevel;
            }
            iAbilityMod = GetAbilityModifier(ABILITY_INTELLIGENCE);
            if (nMySpellCasterDC < iAbilityMod)
            {
                nMySpellCasterDC = iAbilityMod;
            }
            bAnySpellcastingClasses = TRUE;
            break;
        case CLASS_TYPE_BARD:
        case CLASS_TYPE_SORCERER:
            if (nMySpellCasterLevel < nClassLevel)
            {
                nMySpellCasterLevel = nClassLevel;
            }
            iAbilityMod = GetAbilityModifier(ABILITY_CHARISMA);
            if (nMySpellCasterDC < iAbilityMod)
            {
                nMySpellCasterDC = iAbilityMod;
            }
            bAnySpellcastingClasses = TRUE;
            break;
        default:
            if (GetCasterLevel(OBJECT_SELF) > 0)
            {
                nMySpellCasterLevel = GetCasterLevel(OBJECT_SELF);
            }
            else if (nMySpellCasterLevel < GetHitDice(OBJECT_SELF))
            {
                nMySpellCasterLevel = GetHitDice(OBJECT_SELF);
                if (nMySpellCasterLevel > 15)
                {
                    // special abilities now limited to 15
                    nMySpellCasterLevel = 15;
                }
            }
            iAbilityMod = GetAbilityModifier(ABILITY_CHARISMA);
            if (nMySpellCasterDC < iAbilityMod)
            {
                nMySpellCasterDC = iAbilityMod;
            }
    }

    // fix for OC Ch 2 - bugbear shaman has spells it can't use
    return GetTag(OBJECT_SELF) == "M2Q05CBUGBEAR2";
}


int InitializeSpellCasting()
{
    int bResult1 = InitializeClassByPosition(1);
    int bResult2 = InitializeClassByPosition(2);
    int bResult3 = InitializeClassByPosition(3);

    int bLowIntel = GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) < 9;

    if (d20() == 1 || bLowIntel)
    {
        nMySpellCasterDCAdjust = 1000;
    }
    else
    {
        // note this is one above for 1 to 20 roll for save
        nMySpellCasterDCAdjust = 1 - d4(2);
    }
    nMySpellCasterDC += 10 + nMySpellCasterDCAdjust;
    nMySpellAbilityLevel1 = 10 + nMySpellCasterDCAdjust;
    nMySpellAbilityLevel12 = nMySpellAbilityLevel1;
    nMySpellAbilityLevel14 = nMySpellAbilityLevel1;
    nMySpellAbilityLevel1 += GetHitDice(OBJECT_SELF);
    nMySpellAbilityLevel12 += GetHitDice(OBJECT_SELF)/2;
    nMySpellAbilityLevel14 += GetHitDice(OBJECT_SELF)/4;

    if (GetHasFeat(FEAT_EPIC_SPELL_PENETRATION))
    {
        nMySpellCasterSpellPenetrationBonus = 6;
    }
    else if (GetHasFeat(FEAT_GREATER_SPELL_PENETRATION))
    {
        nMySpellCasterSpellPenetrationBonus = 4;
    }
    else if (GetHasFeat(FEAT_SPELL_PENETRATION))
    {
        nMySpellCasterSpellPenetrationBonus = 2;
    }

    if (bLowIntel)
    {
        nMySpellCasterSpellPenetration = 1000;
    }
    else
    {
        nMySpellCasterSpellPenetration = nMySpellCasterLevel + nMySpellCasterSpellPenetrationBonus + d4(2) + 4;
    }

    return bResult1 || bResult2 || bResult3;
}


const int HENCH_HEALING_CURE_SPELL_START =          0x00000001;
const int HENCH_HEALING_INFLICT_SPELL_START =       0x00000100;

const int HENCH_HEALING_ALLOW_SPONTANEOUS_CURE =    0x00020000;
const int HENCH_HEALING_ALLOW_SPONTANEOUS_INFLICT = 0x00040000;
const int HENCH_HEALING_CHECK_CLERIC_SPONTANEOUS =  0x00060000;

const int HENCH_CHEAT_CHECK_SHADES =                0x00080000;
const int HENCH_CHEAT_CHECK_SHADOW_CONJ =           0x00100000;
const int HENCH_CHEAT_CHECK_GREATER_SHADOW_CONJ =   0x00200000;
const int HENCH_CHEAT_CHECK_HOLY_AURA =             0x00400000;
const int HENCH_CHEAT_CHECK_MAGIC_CIRCLE =          0x00800000;
const int HENCH_CHEAT_CHECK_PROT_ALIGN =            0x01000000;


int gCheatCastInformation;


// note after calling this many Talent* calls will not work since the cutscene immobilize
// remains in effect.

const int HENCH_INIT_ALL_SPELLS     = 0;
const int HENCH_INIT_BUFF_SPELLS    = 1;
const int HENCH_INIT_LOCK_SPELLS    = 2;

void InitializeItemSpells(int nClass, int bPolymorphed, int nInitType)
{
    SetLocalObject(OBJECT_SELF, sLastSpellTargetObject, OBJECT_SELF);

    itemSpellsFound = FALSE;
    onlyUseTalents = FALSE;
    itemTalentSpellCount = 0;

    int bArcaneSpellFailure = FALSE;
    if (nClass == CLASS_TYPE_SORCERER || nClass == CLASS_TYPE_WIZARD)
    {
        if (GetArcaneSpellFailure(OBJECT_SELF) > 20)
        {
            bArcaneSpellFailure = TRUE;
        }
    }
    else if (nClass == CLASS_TYPE_BARD)
    {
        if (GetArcaneSpellFailure(OBJECT_SELF) > 35)
        {
            bArcaneSpellFailure = TRUE;
        }
    }

    int bDisablingEffect = GetHasAnyEffect2(EFFECT_TYPE_SILENCE, EFFECT_TYPE_SPELL_FAILURE);
    bNoSpellDisabledDueToEffectOrHench = GetAssociateType(OBJECT_SELF) != ASSOCIATE_TYPE_HENCHMAN &&
        !bPolymorphed && !bDisablingEffect;

    nGlobalMeleeAttackers = GetNumberOfMeleeAttackers();

    int bSpellCastingProblem = InitializeSpellCasting();

    if (bPolymorphed)
    {
        // polymorphed creatues can only use potions
        onlyUseTalents = TRUE;
        if (GetIsObjectValid(GetFirstItemInInventory()))
        {
            InitializePotionTalents();
        }
        return;
    }

    if (bArcaneSpellFailure)
    {
        onlyUseTalents = TRUE;
    }
    else if (!bDisablingEffect && !bSpellCastingProblem)
    {
        if ((GetLevelByClass(CLASS_TYPE_CLERIC) > 0) && (nInitType == HENCH_INIT_ALL_SPELLS))
        {
            int iAlignment = GetAlignmentGoodEvil(OBJECT_SELF);
            if (iAlignment == ALIGNMENT_GOOD)
            {
                gCheatCastInformation = HENCH_HEALING_ALLOW_SPONTANEOUS_CURE;
            }
            else if (iAlignment == ALIGNMENT_EVIL)
            {
                gCheatCastInformation = HENCH_HEALING_ALLOW_SPONTANEOUS_INFLICT;
            }
            else
            {
                if (!GetIsEnemy(GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC)))
                {
                    gCheatCastInformation = HENCH_HEALING_ALLOW_SPONTANEOUS_CURE;
                }
                else
                {
                    gCheatCastInformation = HENCH_HEALING_ALLOW_SPONTANEOUS_INFLICT;
                }
            }
            int testIndex;
            int bitSetPosition = HENCH_HEALING_CURE_SPELL_START;
            // test if actually memorized cure spell
            for (testIndex = SPELL_CURE_CRITICAL_WOUNDS /* 31 */; testIndex < 36; testIndex++)
            {
                if (GetCreatureHasTalent(TalentSpell(testIndex)))
                {
                    gCheatCastInformation = gCheatCastInformation | bitSetPosition;
                }
                bitSetPosition *= 2;
            }
            bitSetPosition = HENCH_HEALING_INFLICT_SPELL_START;
            // test if actually memorized inflict spell
            for (testIndex = SPELL_INFLICT_MINOR_WOUNDS /*431*/; testIndex < 436; testIndex++)
            {
                if (GetCreatureHasTalent(TalentSpell(testIndex)))
                {
                    gCheatCastInformation = gCheatCastInformation | bitSetPosition;
                }
                bitSetPosition *= 2;
            }
        }

        if (nInitType == HENCH_INIT_ALL_SPELLS)
        {
            if (GetHasSpell(SPELL_SHADES_SUMMON_SHADOW) && GetCreatureHasTalent(TalentSpell(SPELL_SHADES_SUMMON_SHADOW)))
            {
                gCheatCastInformation = gCheatCastInformation | HENCH_CHEAT_CHECK_SHADES;
            }
            if (GetHasSpell(SPELL_SHADOW_CONJURATION_SUMMON_SHADOW) && GetCreatureHasTalent(TalentSpell(SPELL_SHADOW_CONJURATION_SUMMON_SHADOW)))
            {
                gCheatCastInformation = gCheatCastInformation | HENCH_CHEAT_CHECK_SHADOW_CONJ;
            }
            if (GetHasSpell(SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW) && GetCreatureHasTalent(TalentSpell(SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW)))
            {
                gCheatCastInformation = gCheatCastInformation | HENCH_CHEAT_CHECK_GREATER_SHADOW_CONJ;
            }
        }

        if ((nInitType == HENCH_INIT_ALL_SPELLS) || (nInitType == HENCH_INIT_BUFF_SPELLS))
        {
            if (GetHasSpell(SPELL_HOLY_AURA) && GetCreatureHasTalent(TalentSpell(SPELL_HOLY_AURA)))
            {
                gCheatCastInformation = gCheatCastInformation | HENCH_CHEAT_CHECK_HOLY_AURA;
            }
            if (GetHasSpell(SPELL_MAGIC_CIRCLE_AGAINST_EVIL) && GetCreatureHasTalent(TalentSpell(SPELL_MAGIC_CIRCLE_AGAINST_EVIL)))
            {
                gCheatCastInformation = gCheatCastInformation | HENCH_CHEAT_CHECK_MAGIC_CIRCLE;
            }
            if (GetHasSpell(SPELL_PROTECTION_FROM_EVIL) && GetCreatureHasTalent(TalentSpell(SPELL_PROTECTION_FROM_EVIL)))
            {
                gCheatCastInformation = gCheatCastInformation | HENCH_CHEAT_CHECK_PROT_ALIGN;
            }
        }
    }
    else
    {
        if (nInitType == HENCH_INIT_LOCK_SPELLS)
        {
            InitializeTrapAndLockSpellTalents();
        }
        else
        {
            if (nInitType == HENCH_INIT_ALL_SPELLS)
            {
                InitializeHealingSpellTalents(FALSE);
            }
            InitializeConditionalSpellTalents(FALSE);
            if (nInitType == HENCH_INIT_ALL_SPELLS)
            {
                InitializeAttackSpellTalents(FALSE);
            }
            InitializeEnhanceSpellTalents(FALSE);
        }
        onlyUseTalents = TRUE;
    }

    itemTalentBoundary = itemTalentSpellCount;
    if (GetIsObjectValid(GetFirstItemInInventory()) && GetCreatureUseItems(OBJECT_SELF))
    {
        int bCutSceneImmobile = GetHasEffect(EFFECT_TYPE_CUTSCENEIMMOBILIZE);

        InitializePotionTalents();

        if (!bCutSceneImmobile)
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneImmobilize(), OBJECT_SELF, 10.0);
        }
        if (nInitType == HENCH_INIT_LOCK_SPELLS)
        {
            InitializeTrapAndLockSpellTalents();
        }
        else
        {
            if (nInitType == HENCH_INIT_ALL_SPELLS)
            {
                InitializeHealingSpellTalents();
            }
            InitializeConditionalSpellTalents();
            if (nInitType == HENCH_INIT_ALL_SPELLS)
            {
                InitializeAttackSpellTalents();
            }
            InitializeEnhanceSpellTalents();
        }
        if (!bCutSceneImmobile)
        {
            effect eCurrent = GetFirstEffect(OBJECT_SELF);
            while(GetIsEffectValid(eCurrent))
            {
                if(GetEffectType(eCurrent) == EFFECT_TYPE_CUTSCENEIMMOBILIZE)
                {
                   RemoveEffect(OBJECT_SELF, eCurrent);
                }
                eCurrent = GetNextEffect(OBJECT_SELF);
            }
        }
    }
}


int bFoundPotionOnly;
int bFoundItemSpell;
int bFoundSpellGlobal;

int GetHasFixedSpell(int spellID)
{
    if (!onlyUseTalents && GetHasSpell(spellID))
    {
        bFoundSpellGlobal = TRUE;
        bFoundItemSpell = FALSE;
        bFoundPotionOnly = FALSE;
        return TRUE;
    }
    if (HasItemTalentSpell(spellID))
    {
        bFoundSpellGlobal = TRUE;
        bFoundPotionOnly = FALSE;
        // best guess if have spell, then no item
        bFoundItemSpell = !GetHasSpell(spellID);
        return TRUE;
    }
    if (HasPotionTalentSpell(spellID))
    {
        bFoundSpellGlobal = TRUE;
        bFoundItemSpell = TRUE;
        bFoundPotionOnly = TRUE;
        return TRUE;
    }
    return FALSE;
}


int GetHasCureSpell(int spellID)
{
    if (!onlyUseTalents)
    {
        if (gCheatCastInformation & HENCH_HEALING_ALLOW_SPONTANEOUS_INFLICT)
        {
            // cleric must have previously set bit array for cure
            if (gCheatCastInformation & (HENCH_HEALING_CURE_SPELL_START << (spellID - SPELL_CURE_CRITICAL_WOUNDS)))
            {
                bFoundSpellGlobal = TRUE;
                bFoundItemSpell = FALSE;
                bFoundPotionOnly = FALSE;
                return TRUE;
            }
        }
        else
        {
            if (GetHasSpell(spellID))
            {
                bFoundSpellGlobal = TRUE;
                bFoundItemSpell = FALSE;
                bFoundPotionOnly = FALSE;
                return TRUE;
            }
        }
    }
    if (HasItemTalentSpell(spellID))
    {
        bFoundSpellGlobal = TRUE;
        bFoundPotionOnly = FALSE;
        // best guess if have spell, then no item
        bFoundItemSpell = !GetHasSpell(spellID);
        return TRUE;
    }
    return FALSE;
}


int GetHasInflictSpell(int spellID)
{
    if (!onlyUseTalents)
    {
        if (gCheatCastInformation & HENCH_HEALING_ALLOW_SPONTANEOUS_CURE)
        {
            // cleric must have previously set bit array for inflict
            if (gCheatCastInformation & (HENCH_HEALING_INFLICT_SPELL_START << (spellID - SPELL_INFLICT_MINOR_WOUNDS)))
            {
                bFoundSpellGlobal = TRUE;
                bFoundItemSpell = FALSE;
                bFoundPotionOnly = FALSE;
                return TRUE;
            }
        }
        else
        {
            if (GetHasSpell(spellID))
            {
                bFoundSpellGlobal = TRUE;
                bFoundItemSpell = FALSE;
                bFoundPotionOnly = FALSE;
                return TRUE;
            }
        }
    }
    if (HasItemTalentSpell(spellID))
    {
        bFoundSpellGlobal = TRUE;
        bFoundPotionOnly = FALSE;
        // best guess if have spell, then no item
        bFoundItemSpell = !GetHasSpell(spellID);
        return TRUE;
    }
    return FALSE;
}


void CheckCastingMode(int nSpellLevel, int nSpell)
{
    int bCurrentDefCastMode = GetActionMode(OBJECT_SELF, ACTION_MODE_DEFENSIVE_CAST);
    int bNewDefCastMode;

    if (!nGlobalMeleeAttackers || GetHasFeat(FEAT_EPIC_IMPROVED_COMBAT_CASTING) ||
    // shadow spells don't work with defensive casting
        (nSpell >= SPELL_SHADES_SUMMON_SHADOW && nSpell <= SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE))
    {
        bNewDefCastMode = FALSE;
    }
    else
    {
        int nConcentration = GetSkillRank(SKILL_CONCENTRATION);
        if (nConcentration > 13 + nSpellLevel)
        {
            bNewDefCastMode = TRUE;
        }
    }
    if (bCurrentDefCastMode != bNewDefCastMode)
    {
        ActionDoCommand(SetActionMode(OBJECT_SELF, ACTION_MODE_DEFENSIVE_CAST, bNewDefCastMode));
    }
}



void CheckDefense(int bSpell)
{
    if (!GetIsObjectValid(GetNearestSeenOrHeardEnemy()))
    {
        return;
    }

    // TODO check if in combat
    if (GetLevelByClass(CLASS_TYPE_WIZARD) <= 0 && GetLevelByClass(CLASS_TYPE_SORCERER) <= 0 &&
        GetLevelByClass(CLASS_TYPE_BARD) <= 0)
    {
        EquipShield(FALSE);
    }

    if (bSpell)
    {
        return;
    }
    // this works with feats and spell abilities
    if (GetHasFeat(FEAT_IMPROVED_EXPERTISE))
    {
        SetCombatMode(ACTION_MODE_IMPROVED_EXPERTISE);
    }
    else if (GetHasFeat(FEAT_EXPERTISE))
    {
        SetCombatMode(ACTION_MODE_EXPERTISE);
    }
}


void ActionCastFixedSpellOnObject(int nSpell, object oTarget)
{
    CheckDefense(TRUE);

    int bUseCheat = FALSE;
    int nMainSpell;
    // first test if cleric possibly doing spontaneous casting
    if (gCheatCastInformation & HENCH_HEALING_CHECK_CLERIC_SPONTANEOUS)
    {
        switch(nSpell)
        {
        case SPELL_CURE_MINOR_WOUNDS:
        case SPELL_CURE_LIGHT_WOUNDS:
        case SPELL_CURE_MODERATE_WOUNDS:
        case SPELL_CURE_SERIOUS_WOUNDS:
        case SPELL_CURE_CRITICAL_WOUNDS:
            if (!(gCheatCastInformation & (HENCH_HEALING_CURE_SPELL_START << (nSpell - SPELL_CURE_CRITICAL_WOUNDS))))
            {
                bUseCheat = TRUE;
                if (nSpell == SPELL_CURE_MODERATE_WOUNDS && GetHasSpell(SPELL_AID))
                {
                    nMainSpell = SPELL_AID;
                }
                else
                {
                    nMainSpell = nSpell;
                }
            }
            break;
        case SPELL_INFLICT_CRITICAL_WOUNDS:
        case SPELL_INFLICT_MINOR_WOUNDS:
        case SPELL_INFLICT_LIGHT_WOUNDS:
        case SPELL_INFLICT_MODERATE_WOUNDS:
        case SPELL_INFLICT_SERIOUS_WOUNDS:
            if (!(gCheatCastInformation & (HENCH_HEALING_INFLICT_SPELL_START << (nSpell - SPELL_INFLICT_MINOR_WOUNDS))))
            {
                bUseCheat = TRUE;
                if (nSpell == SPELL_INFLICT_MODERATE_WOUNDS && GetHasSpell(SPELL_AID))
                {
                    nMainSpell = SPELL_AID;
                }
                else
                {
                    nMainSpell = nSpell;
                }
            }
            break;
        }
    }
    switch(nSpell)
    {
    case SPELL_HOLY_AURA:
    case SPELL_UNHOLY_AURA:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_HOLY_AURA))
        {
            bUseCheat = TRUE;
            nMainSpell = 323;
        }
        break;
    case SPELL_MAGIC_CIRCLE_AGAINST_EVIL:
    case SPELL_MAGIC_CIRCLE_AGAINST_GOOD:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_MAGIC_CIRCLE))
        {
            bUseCheat = TRUE;
            nMainSpell = 322;
        }
        break;
    case SPELL_PROTECTION_FROM_EVIL:
    case SPELL_PROTECTION_FROM_GOOD:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_PROT_ALIGN))
        {
            bUseCheat = TRUE;
            nMainSpell = 321;
        }
        break;
    case SPELL_SHADES_SUMMON_SHADOW:
    case SPELL_SHADES_CONE_OF_COLD:
    case SPELL_SHADES_FIREBALL:
    case SPELL_SHADES_STONESKIN:
    case SPELL_SHADES_WALL_OF_FIRE:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_SHADES))
        {
            bUseCheat = TRUE;
            nMainSpell = 158;
        }
        break;
    case SPELL_SHADOW_CONJURATION_SUMMON_SHADOW:
    case SPELL_SHADOW_CONJURATION_DARKNESS:
    case SPELL_SHADOW_CONJURATION_INIVSIBILITY:
    case SPELL_SHADOW_CONJURATION_MAGE_ARMOR:
    case SPELL_SHADOW_CONJURATION_MAGIC_MISSILE:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_SHADOW_CONJ))
        {
            bUseCheat = TRUE;
            nMainSpell = 159;
        }
        break;
    case SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW:
    case SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW:
    case SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE:
    case SPELL_GREATER_SHADOW_CONJURATION_WEB:
    case SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_GREATER_SHADOW_CONJ))
        {
            bUseCheat = TRUE;
            nMainSpell = 71;
        }
        break;
    }
    if (bUseCheat)
    {
        ActionCastSpellAtObject(nSpell, oTarget, METAMAGIC_ANY, TRUE);
        ActionDoCommand(DecrementRemainingSpellUses(OBJECT_SELF, nMainSpell));
    }
    else
    {
//        Jug_Debug(GetName(OBJECT_SELF) + " cast spell at object");
        ActionCastSpellAtObject(nSpell, oTarget);
    }
}


void CastFixedSpellOnObject(int nSpell, object oTarget, int nSpellLevel)
{
    SetLocalObject(OBJECT_SELF, sLastSpellTargetObject, oTarget);

    int bHasSpell = GetHasSpell(nSpell);
    int bEnableDefensivecasting = bAnySpellcastingClasses && bHasSpell;
    if (bEnableDefensivecasting)
    {
        // probably casting check if use of defensive casting
        CheckCastingMode(nSpellLevel, nSpell);
    }
    if (!nGlobalMeleeAttackers && !onlyUseTalents && bHasSpell)
    {
        ActionCastFixedSpellOnObject(nSpell, oTarget);
        return;
    }
    if (oTarget == OBJECT_SELF && HasPotionTalentSpell(nSpell))
    {
        ActionUseTalentOnObject(GetPotionTalentSpell(nSpell), OBJECT_SELF);
        return;
    }
    int itemPosition = HasItemTalentSpell(nSpell);
    if (itemPosition)
    {
        if (itemPosition <= itemTalentBoundary)
        {
            // probably casting check if use of defensive casting
            CheckCastingMode(nSpellLevel, nSpell);
        }
        ActionUseTalentOnObject(GetItemTalentSpell(nSpell), oTarget);
        return;
    }
    ActionCastFixedSpellOnObject(nSpell, oTarget);
}


void ActionCastFixedSpellAtLocation(int nSpell, location loc)
{
    CheckDefense(TRUE);

    int bUseCheat = FALSE;
    int nMainSpell;

    switch(nSpell)
    {
    case SPELL_SHADES_SUMMON_SHADOW:
    case SPELL_SHADES_CONE_OF_COLD:
    case SPELL_SHADES_FIREBALL:
    case SPELL_SHADES_WALL_OF_FIRE:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_SHADES))
        {
            bUseCheat = TRUE;
            nMainSpell = 158;
        }
        break;
    case SPELL_SHADOW_CONJURATION_SUMMON_SHADOW:
    case SPELL_SHADOW_CONJURATION_DARKNESS:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_SHADOW_CONJ))
        {
            bUseCheat = TRUE;
            nMainSpell = 159;
        }
        break;
    case SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW:
    case SPELL_GREATER_SHADOW_CONJURATION_WEB:
        if (!(gCheatCastInformation & HENCH_CHEAT_CHECK_GREATER_SHADOW_CONJ))
        {
            bUseCheat = TRUE;
            nMainSpell = 71;
        }
        break;
    }
    if (bUseCheat)
    {
        ActionCastSpellAtLocation(nSpell, loc, METAMAGIC_ANY, TRUE);
        ActionDoCommand(DecrementRemainingSpellUses(OBJECT_SELF, nMainSpell));
    }
    else
    {
//        Jug_Debug(GetName(OBJECT_SELF) + " cast spell at object");
        ActionCastSpellAtLocation(nSpell, loc);
    }
}


void CastFixedSpellAtLocation(int nSpell, location loc, int nSpellLevel)
{
    int bHasSpell = GetHasSpell(nSpell);
    int bEnableDefensivecasting = bAnySpellcastingClasses && bHasSpell;
    if (bEnableDefensivecasting)
    {
        // probably casting check if use of defensive casting
        CheckCastingMode(nSpellLevel, nSpell);
    }
    if (!nGlobalMeleeAttackers && !onlyUseTalents && bHasSpell)
    {
        ActionCastFixedSpellAtLocation(nSpell, loc);
        return;
    }
    int itemPosition = HasItemTalentSpell(nSpell);
    if (itemPosition)
    {
        if (itemPosition <= itemTalentBoundary)
        {
            // probably casting check if use of defensive casting
            CheckCastingMode(nSpellLevel, nSpell);
        }
        ActionUseTalentAtLocation(GetItemTalentSpell(nSpell), loc);
        return;
    }
    ActionCastFixedSpellAtLocation(nSpell, loc);
}

