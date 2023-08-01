#include "nwnx_creature"
#include "inc_rand_spell"
#include "inc_rand_feat"
#include "inc_rand_appear"
#include "inc_rand_equip"

// Users:
// bandit "Bandit"                  - ranged
// bandit_fighter "Bandit Thug"     - melee
// bandit_outlaw "Bandit Outlaw"    - ranged
// bandit_brute "Bandit Brute"      - melee
// bandit_mage "Bandit Mage"

void main()
{
    RandomiseGenderAndAppearance(OBJECT_SELF);
    RandomiseCreatureSoundset_Rough(OBJECT_SELF);
    int bRanged = 0;
    string sResRef = GetResRef(OBJECT_SELF);
    if (sResRef == "bandit" || sResRef == "bandit_outlaw")
    {
        bRanged = 1;
        SetLocalInt(OBJECT_SELF, RAND_EQUIP_GIVE_RANGED, 1);
    }
    int nHD = GetHitDice(OBJECT_SELF);
    int nNumFeats;
    
    int nFighter = GetLevelByClass(CLASS_TYPE_FIGHTER, OBJECT_SELF);
    if (nFighter > 0)
    {
        nNumFeats = 1 + (nFighter/2);
        AddRandomFeats(OBJECT_SELF, RAND_FEAT_LIST_FIGHTER_BONUS, nNumFeats);
    }
    
    nNumFeats = 1 + (nHD/3);
    if (GetRacialType(OBJECT_SELF) == RACIAL_TYPE_HUMAN)
    {
        nNumFeats++;
    }
    
    int nFeatList = RAND_FEAT_LIST_RANDOM;
    if (GetLevelByClass(CLASS_TYPE_SORCERER, OBJECT_SELF)) { nFeatList = RAND_FEAT_LIST_CASTER; }
    
    AddRandomFeats(OBJECT_SELF, nFeatList, nNumFeats);
    
    if (GetLevelByClass(CLASS_TYPE_SORCERER, OBJECT_SELF))
    {
        if (d3() == 1)
        {
            SetLocalString(OBJECT_SELF, "quest1", "02_b_gem");
            SetLocalString(OBJECT_SELF, "quest_item", "b_gem_power");
        }
        if (SeedingSpellbooks(CLASS_TYPE_SORCERER, OBJECT_SELF))
        {
            int i;
            for (i=0; i<RAND_SPELL_NUM_SPELLBOOKS; i++)
            {
                RandomSpellbookPopulate(RAND_SPELL_ARCANE_EVOKER_SINGLE_TARGET, OBJECT_SELF, CLASS_TYPE_SORCERER);
            }
            SeedingSpellbooksComplete(OBJECT_SELF);
        }
        else
        {
            LoadSpellbook(CLASS_TYPE_SORCERER, OBJECT_SELF);
        }
    }

    
    int nMaxAC;
    int nRoll = Random(10) + 1;
    
    if (sResRef == "bandit_fighter" || sResRef == "bandit_brute")
    {
        if (nRoll < 5) { nMaxAC = 3; }
        else if (nRoll <= 7) { nMaxAC = 4; }
        else if (nRoll <= 9) { nMaxAC = 5; }
        else { nMaxAC = 6; }
    }
    else if (sResRef == "bandit_mage")
    {
        nMaxAC = 0;
    }
    else if (sResRef == "bandit_outlaw")
    {
        if (nRoll < 4) { nMaxAC = 4; }
        else if (nRoll <= 7) { nMaxAC = 5; }
        else if (nRoll <= 9) { nMaxAC = 6; }
        else { nMaxAC = 7; }
    }
    else if (sResRef == "bandit")
    {
        if (nRoll < 5) { nMaxAC = 1; }
        else if (nRoll <= 7) { nMaxAC = 2; }
        else if (nRoll <= 9) { nMaxAC = 3; }
        else { nMaxAC = 4; }
    }
    
    
    int nAC = GetACOfArmorToEquip(OBJECT_SELF, nMaxAC);
    //WriteTimestampedLogEntry("Max AC = " + IntToString(nMaxAC) + " -> " + IntToString(nAC));

    // rare bandits have static armor
    if (sResRef != "bandit_leader" && sResRef != "bandit_captain")
    {
        TryEquippingRandomArmorOfTier(nAC, 1 + (d100() > 95), 2, OBJECT_SELF);
    }

    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    
    object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, 1 + (d100() > 95), 2, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    TryEquippingRandomItemOfTier(rwr.nOffHand, 1 + (d100() > 95), 2, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
    if (rwr.nBackupMeleeWeapon != BASE_ITEM_INVALID)
    {
        object oBackup = TryEquippingRandomItemOfTier(rwr.nBackupMeleeWeapon, 1, 1, OBJECT_SELF, -1);
        SetLocalObject(OBJECT_SELF, "melee_weapon", oBackup);
        SetLocalObject(OBJECT_SELF, "ranged_weapon", oMain);
    }
    else
    {
        SetLocalObject(OBJECT_SELF, "melee_weapon", oMain);
    }
    TryEquippingRandomApparelOfTier(1 + (d100() > 95), 2, OBJECT_SELF);
}
