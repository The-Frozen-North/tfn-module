#include "nwnx_creature"
#include "inc_rand_spell"
#include "inc_rand_feat"
#include "inc_rand_appear"
#include "inc_rand_equip"

void main()
{
    RandomiseGenderAndAppearance(OBJECT_SELF);
    RandomiseCreatureSoundset_Rough(OBJECT_SELF);
    int bRanged = 0;
    string sResRef = GetResRef(OBJECT_SELF);
    if (sResRef == "smuggler_archer")
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
    
    if (sResRef == "smuggler_archer" || sResRef == "smuggler_pois")
    {
        nMaxAC = 3;
    }
    else if (sResRef == "smuggler_mage")
    {
        nMaxAC = 0;
    }
    else if (sResRef == "smuggler_brute")
    {
        if (nRoll < 2) { nMaxAC = 4; }
        else if (nRoll <= 4) { nMaxAC = 5; }
        else if (nRoll <= 6) { nMaxAC = 6; }
        else if (nRoll <= 9) { nMaxAC = 7; }
        else { nMaxAC = 8; }
    }
    
    
    int nAC = GetACOfArmorToEquip(OBJECT_SELF, nMaxAC);
    //WriteTimestampedLogEntry("Max AC = " + IntToString(nMaxAC) + " -> " + IntToString(nAC));
    TryEquippingRandomArmorOfTier(nAC, 1 + (d100() > 50) + (d100() > 95), 2, OBJECT_SELF);
    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(OBJECT_SELF);
    
    object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, 1 + (d100() > 50) + (d100() > 95), 2, OBJECT_SELF, INVENTORY_SLOT_RIGHTHAND);
    TryEquippingRandomItemOfTier(rwr.nOffHand, 1 + (d100() > 50) + (d100() > 95), 2, OBJECT_SELF, INVENTORY_SLOT_LEFTHAND);
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
    
    if (sResRef == "smuggler_pois")
    {
        if (!GetLocalInt(oMain, "unique"))
        {
            int nRoll = Random(3);
            if (nRoll == 0)
            {
                IPSafeAddItemProperty(oMain, ItemPropertyOnHitProps(IP_CONST_ONHIT_ITEMPOISON, IP_CONST_ONHIT_SAVEDC_14, IP_CONST_POISON_1D2_STRDAMAGE));
            }
            else if (nRoll == 1)
            {
                IPSafeAddItemProperty(oMain, ItemPropertyOnHitProps(IP_CONST_ONHIT_ITEMPOISON, IP_CONST_ONHIT_SAVEDC_14, IP_CONST_POISON_1D2_DEXDAMAGE));
            }
            else if (nRoll == 2)
            {
                IPSafeAddItemProperty(oMain, ItemPropertyOnHitProps(IP_CONST_ONHIT_ITEMPOISON, IP_CONST_ONHIT_SAVEDC_14, IP_CONST_POISON_1D2_CONDAMAGE));
            }
        }
    }
    
    TryEquippingRandomApparelOfTier(1 + (d100() > 50) + (d100() > 95), 4, OBJECT_SELF);
}
