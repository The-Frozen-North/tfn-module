#include "nwnx_creature"
#include "nwnx_object"

object CreateCreatureItem(int nSlot, string sResRef)
{
    DestroyObject(GetItemInSlot(nSlot));

    object oItem = CreateItemOnObject(sResRef);

    SetDroppableFlag(oItem, FALSE);
    SetPickpocketableFlag(oItem, FALSE);
    SetPlotFlag(oItem, TRUE);
    SetItemCursedFlag(oItem, TRUE);

    ActionEquipItem(oItem, nSlot);

    return oItem;
}

void ApplySneakAttackFeat(int nMasterHitDice)
{
        if (nMasterHitDice >= 11) { NWNX_Creature_AddFeat(OBJECT_SELF, 349); }
        else if (nMasterHitDice >= 9) { NWNX_Creature_AddFeat(OBJECT_SELF, 348); }
        else if (nMasterHitDice >= 7) { NWNX_Creature_AddFeat(OBJECT_SELF, 347); }
        else if (nMasterHitDice >= 5) { NWNX_Creature_AddFeat(OBJECT_SELF, 346); }
        else if (nMasterHitDice >= 3) { NWNX_Creature_AddFeat(OBJECT_SELF, 345); }
        else { NWNX_Creature_AddFeat(OBJECT_SELF, 221); }
}

// Create and applies damage progression to target creature weapon
object ApplyDamageProgression(string sResRef, int nSlot, int nStart, int nLevel, int nStrong = FALSE, int bAttackBonusOnly = FALSE);

object ApplyDamageProgression(string sResRef, int nSlot, int nStart, int nLevel, int nStrong = FALSE, int bAttackBonusOnly = FALSE)
{
    object oItem = CreateCreatureItem(nSlot, "cre_t"+sResRef);

    int nProperty, nCurrent;

    if (nStrong)
    {
        nCurrent = nStart + (nLevel / 6);
        if (nCurrent > 4) nCurrent = 4;
        if (nCurrent < 0) nCurrent = 1;
        switch (nCurrent)
        {
            case 1: nProperty = IP_CONST_MONSTERDAMAGE_2d4; break;
            case 2: nProperty = IP_CONST_MONSTERDAMAGE_2d6; break;
            case 3: nProperty = IP_CONST_MONSTERDAMAGE_2d8; break;
            case 4: nProperty = IP_CONST_MONSTERDAMAGE_2d10; break;
        }
    }
    else
    {
        nCurrent = nStart + (nLevel / 4);
        if (nCurrent > 7) nCurrent = 7;
        if (nCurrent < 0) nCurrent = 1;
        switch (nCurrent)
        {
            case 1: nProperty = IP_CONST_MONSTERDAMAGE_1d2; break;
            case 2: nProperty = IP_CONST_MONSTERDAMAGE_1d3; break;
            case 3: nProperty = IP_CONST_MONSTERDAMAGE_1d4; break;
            case 4: nProperty = IP_CONST_MONSTERDAMAGE_1d6; break;
            case 5: nProperty = IP_CONST_MONSTERDAMAGE_1d8; break;
            case 6: nProperty = IP_CONST_MONSTERDAMAGE_1d10; break;
            case 7: nProperty = IP_CONST_MONSTERDAMAGE_1d12; break;
        }
    }

    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyMonsterDamage(nProperty), oItem);

    if (nLevel >= 4)
    {
        if (bAttackBonusOnly)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(nLevel/4), oItem);
        }
        else
        {
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyEnhancementBonus(nLevel/4), oItem);
        }
    }

    return oItem;
}


void main()
{
    if (GetIsPC(OBJECT_SELF)) return;

    object oMaster = GetMaster(OBJECT_SELF);

// stop if no master
    if (oMaster == OBJECT_INVALID) return;

    int nAssociateType = GetAssociateType(OBJECT_SELF);

    int nMasterHitDice;
    switch (nAssociateType)
    {
        case ASSOCIATE_TYPE_ANIMALCOMPANION: nMasterHitDice = GetLevelByClass(CLASS_TYPE_RANGER, oMaster)+GetLevelByClass(CLASS_TYPE_DRUID, oMaster)+GetLevelByClass(CLASS_TYPE_SHIFTER, oMaster); break;
        case ASSOCIATE_TYPE_FAMILIAR: nMasterHitDice = GetLevelByClass(CLASS_TYPE_WIZARD, oMaster)+GetLevelByClass(CLASS_TYPE_SORCERER, oMaster)+GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oMaster)+GetLevelByClass(CLASS_TYPE_PALE_MASTER, oMaster); break;
        default: return; break; // Stop if not familiar or animal companion
    }

// Clear some feats.
    NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_EVASION);
    NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_IMPROVED_EVASION);
    NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_TOUGHNESS);
    NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_UNCANNY_DODGE_1);
    NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_UNCANNY_DODGE_2);
    NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_UNCANNY_DODGE_3);
    NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_UNCANNY_DODGE_4);
    NWNX_Creature_RemoveFeat(OBJECT_SELF, FEAT_UNCANNY_DODGE_5);

// Sneak attacks.
    NWNX_Creature_RemoveFeat(OBJECT_SELF, 221);
    int nSneak;
    for (nSneak = 345; nSneak <= 353; nSneak++)
    {
        NWNX_Creature_RemoveFeat(OBJECT_SELF, nSneak);
    }

    object oSkin = CreateCreatureItem(INVENTORY_SLOT_CARMOUR, "cre_tskin");

    if (nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION)
    {
        NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_EVASION);
        if (nMasterHitDice >= 12) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_IMPROVED_EVASION);
        if (nMasterHitDice >= 10) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_UNCANNY_DODGE_3);
        if (nMasterHitDice >= 5) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_UNCANNY_DODGE_2);
        if (nMasterHitDice >= 2) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_UNCANNY_DODGE_1);
    }
    else
    {
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusSpellResistance(nMasterHitDice/3), oSkin);
    }

    int nHitDice = nMasterHitDice-1;
    float fHitDice = IntToFloat(nHitDice);

    float fScaleLevel, fStrengthLevel, fDexterityLevel, fConstitutionLevel, fIntelligenceLevel, fWisdomLevel, fCharismaLevel;

    float fTranslationLevel = 0.0;
    float fTranslation = 0.0;

    float fScale = 1.0;

    float fACLevel = 1.0;

    int nDamage, nStrength, nDexterity, nConstitution, nIntelligence, nWisdom, nCharisma;
    int nBaseAC = 0;

    itemproperty ip1, ip2, ip3, ip4, ip5, ip6, ip7;

// Mephit specific stuff
    int nMephit = 1+nMasterHitDice/6;

    object oWeaponSpecial, oWeaponLeft, oWeaponRight;

    switch (GetAppearanceType(OBJECT_SELF))
    {
        case APPEARANCE_TYPE_BADGER:
            nBaseAC = 5;

            nStrength = 8;
            nDexterity = 17;
            nConstitution = 11;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;

            fConstitutionLevel = 0.5;
            fDexterityLevel = 1.0;
            fStrengthLevel = 0.5;

            fACLevel = 1.5;

            fScale = 1.2;
            fScaleLevel = 0.05;

            nDamage = 2;

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_FEAR), oSkin);

            oWeaponLeft = ApplyDamageProgression("claw", INVENTORY_SLOT_CWEAPON_L, nDamage, nMasterHitDice);
            oWeaponRight = ApplyDamageProgression("claw", INVENTORY_SLOT_CWEAPON_R, nDamage, nMasterHitDice);
            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 2, nMasterHitDice);

            ip1 = ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_WOUNDING, 1+nMasterHitDice/6);

            AddItemProperty(DURATION_TYPE_PERMANENT, ip1, oWeaponLeft);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip1, oWeaponRight);

        break;
        case APPEARANCE_TYPE_BAT:
            nBaseAC = 5;

            nStrength = 9;
            nDexterity = 15;
            nConstitution = 8;
            nIntelligence = 3;
            nWisdom = 14;
            nCharisma = 4;

            fConstitutionLevel = 0.25;
            fDexterityLevel = 0.75;
            fStrengthLevel = 0.25;

            fACLevel = 2.0;

            fScale = 2.0;
            fScaleLevel = 0.05;

            fTranslation = -1.5;
            fTranslationLevel = -0.15;

            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_BLINDSIGHT_60_FEET);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_BLIND_FIGHT);

            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 1, nMasterHitDice, FALSE, TRUE);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyVampiricRegeneration(1+nMasterHitDice/3), oWeaponSpecial);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_SONIC, 1+nMasterHitDice/6), oWeaponSpecial);
        break;
        case APPEARANCE_TYPE_BOAR_DIRE:
            nBaseAC = 4;

            nStrength = 13;
            nDexterity = 10;
            nConstitution = 13;
            nIntelligence = 3;
            nWisdom = 13;
            nCharisma = 4;

            fACLevel = 1.5;

            fConstitutionLevel = 0.75;
            fStrengthLevel = 0.75;

            fScale = 0.9;
            fScaleLevel = 0.04;

            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_TOUGHNESS);

            nDamage = 3;

            oWeaponSpecial = ApplyDamageProgression("gore", INVENTORY_SLOT_CWEAPON_B, 4, nMasterHitDice);
        break;
        case APPEARANCE_TYPE_BEAR_BROWN:

            nStrength = 15;
            nDexterity = 10;
            nConstitution = 14;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;

            fConstitutionLevel = 0.75;
            fDexterityLevel = 0.25;
            fStrengthLevel = 1.0;

            fScale = 0.7;
            fScaleLevel = 0.06;

            nDamage = 3;

            oWeaponLeft = ApplyDamageProgression("claw", INVENTORY_SLOT_CWEAPON_L, nDamage, nMasterHitDice);
            oWeaponRight = ApplyDamageProgression("claw", INVENTORY_SLOT_CWEAPON_R, nDamage, nMasterHitDice);
            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 1, nMasterHitDice, TRUE);
        break;
        case APPEARANCE_TYPE_BEHOLDER_EYEBALL:
            nBaseAC = 4;

            nStrength = 6;
            nDexterity = 14;
            nConstitution = 10;
            nIntelligence = 8;
            nWisdom = 10;
            nCharisma = 12;


            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;
            fCharismaLevel = 0.25;

            fScale = 1.0;
            fScaleLevel = 0.05;

            fTranslation = 0.0;
            fTranslationLevel = -0.075;

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyTrueSeeing(), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_BACKSTAB), oSkin);

            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 1, nMasterHitDice, TRUE);
        break;
        case APPEARANCE_TYPE_FAERIE_DRAGON:
            nBaseAC = 3;

            nStrength = 10;
            nDexterity = 16;
            nConstitution = 11;
            nIntelligence = 13;
            nWisdom = 12;
            nCharisma = 12;

            fACLevel = 1.5;

            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;

            fScale = 1.0;
            fScaleLevel = 0.04;

            fTranslation = 0.0;
            fTranslationLevel = -0.04;

           oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 1, nMasterHitDice, TRUE);
           AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnHitProps(IP_CONST_ONHIT_STUN, nMasterHitDice/6, IP_CONST_ONHIT_DURATION_50_PERCENT_2_ROUNDS), oWeaponSpecial);
        break;
        case APPEARANCE_TYPE_MEPHIT_FIRE:
            nBaseAC = 3;

            nStrength = 14;
            nDexterity = 12;
            nConstitution = 8;
            nIntelligence = 12;
            nWisdom = 12;
            nCharisma = 10;

            fStrengthLevel = 0.75;
            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.03;

            fTranslation = 0.0;
            fTranslationLevel = -0.03;

            nDamage = 2;

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyRegeneration(nMephit), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_FIRE, IP_CONST_DAMAGEIMMUNITY_100_PERCENT), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageVulnerability(IP_CONST_DAMAGETYPE_COLD, IP_CONST_DAMAGEVULNERABILITY_50_PERCENT), oSkin);

            oWeaponLeft = ApplyDamageProgression("slam", INVENTORY_SLOT_CWEAPON_L, nDamage, nMasterHitDice, FALSE, TRUE);
            oWeaponRight = ApplyDamageProgression("slam", INVENTORY_SLOT_CWEAPON_R, nDamage, nMasterHitDice, FALSE, TRUE);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_FIRE, nMephit), oWeaponLeft);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_FIRE, nMephit), oWeaponRight);
        break;
        case APPEARANCE_TYPE_MEPHIT_ICE:
            nBaseAC = 4;

            nStrength = 12;
            nDexterity = 14;
            nConstitution = 8;
            nIntelligence = 12;
            nWisdom = 12;
            nCharisma = 10;


            fStrengthLevel = 0.5;
            fDexterityLevel = 0.75;
            fConstitutionLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.03;

            fTranslation = 0.0;
            fTranslationLevel = -0.03;

            nDamage = 2;

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyRegeneration(nMephit), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_COLD, IP_CONST_DAMAGEIMMUNITY_100_PERCENT), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageVulnerability(IP_CONST_DAMAGETYPE_FIRE, IP_CONST_DAMAGEVULNERABILITY_50_PERCENT), oSkin);

            oWeaponLeft = ApplyDamageProgression("slam", INVENTORY_SLOT_CWEAPON_L, nDamage, nMasterHitDice, FALSE, TRUE);
            oWeaponRight = ApplyDamageProgression("slam", INVENTORY_SLOT_CWEAPON_R, nDamage, nMasterHitDice, FALSE, TRUE);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, nMephit), oWeaponLeft);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, nMephit), oWeaponRight);
        break;
        case APPEARANCE_TYPE_DOG_HELL_HOUND:
            nBaseAC = 2;

            nStrength = 14;
            nDexterity = 12;
            nConstitution = 11;
            nIntelligence = 6;
            nWisdom = 10;
            nCharisma = 6;


            fDexterityLevel = 0.75;
            fConstitutionLevel = 0.5;
            fStrengthLevel = 1.0;

            fScale = 0.9;
            fScaleLevel = 0.04;

            if (nMasterHitDice >= 3) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_CLEAVE);
            if (nMasterHitDice >= 6) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_KNOCKDOWN);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageImmunity(IP_CONST_DAMAGETYPE_COLD, IP_CONST_DAMAGEIMMUNITY_100_PERCENT), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageVulnerability(IP_CONST_DAMAGETYPE_FIRE, IP_CONST_DAMAGEVULNERABILITY_50_PERCENT), oSkin);

            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 3, nMasterHitDice, FALSE, TRUE);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_FIRE, 1+nMasterHitDice/6), oWeaponSpecial);
        break;
        case APPEARANCE_TYPE_SPIDER_GIANT:
            nBaseAC = 1;

            nStrength = 12;
            nDexterity = 14;
            nConstitution = 12;
            nIntelligence = 3;
            nWisdom = 10;
            nCharisma = 3;

            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;

            fScale = 0.7;
            fScaleLevel = 0.06;

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertySpellImmunitySpecific(IP_CONST_IMMUNITYSPELL_WEB), oSkin);

            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 1, nMasterHitDice, TRUE);

            if (nMasterHitDice >= 10)
            {
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_POISON, POISON_LARGE_SPIDER_VENOM), oWeaponSpecial);
            }
            else if (nMasterHitDice >= 5)
            {
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_POISON, POISON_MEDIUM_SPIDER_VENOM), oWeaponSpecial);
            }
            else
            {
                AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_POISON, POISON_SMALL_SPIDER_VENOM), oWeaponSpecial);
            }
        break;
        case APPEARANCE_TYPE_DOG_WOLF:
            nBaseAC = 2;

            nStrength = 12;
            nDexterity = 14;
            nConstitution = 12;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;

            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_CLEAVE);
            if (nMasterHitDice >= 6) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_GREAT_CLEAVE);
            if (nMasterHitDice >= 9) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_IMPROVED_CRITICAL_CREATURE);

            fDexterityLevel = 1.0;
            fConstitutionLevel = 0.75;
            fStrengthLevel = 0.75;

            fScale = 0.9;
            fScaleLevel = 0.04;

            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 3, nMasterHitDice);
        break;
        case APPEARANCE_TYPE_DOG_DIRE_WOLF:
            nBaseAC = 3;

            nStrength = 14;
            nDexterity = 12;
            nConstitution = 12;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 10;


            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.75;
            fStrengthLevel = 1.0;

            fScale = 0.7;
            fScaleLevel = 0.05;

            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_KNOCKDOWN);
            if (nMasterHitDice >= 6) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_IMPROVED_KNOCKDOWN);

            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 3, nMasterHitDice);
        break;
        case APPEARANCE_TYPE_RAT_DIRE:
            nBaseAC = 5;

            nStrength = 8;
            nDexterity = 19;
            nConstitution = 11;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;

            fConstitutionLevel = 0.5;
            fDexterityLevel = 1.0;
            fStrengthLevel = 0.5;

            fACLevel = 1.5;

            fScale = 1.0;
            fScaleLevel = 0.5;

            nDamage = 1;

            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_LIGHTNING_REFLEXES);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_HIDE_IN_PLAIN_SIGHT);

            oWeaponLeft = ApplyDamageProgression("claw", INVENTORY_SLOT_CWEAPON_L, nDamage, nMasterHitDice);
            oWeaponRight = ApplyDamageProgression("claw", INVENTORY_SLOT_CWEAPON_R, nDamage, nMasterHitDice);
            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, nDamage, nMasterHitDice);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_DISEASE, DISEASE_FILTH_FEVER), oWeaponSpecial);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_DISEASE, DISEASE_FILTH_FEVER), oWeaponLeft);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_DISEASE, DISEASE_FILTH_FEVER), oWeaponRight);
        break;
        case APPEARANCE_TYPE_FALCON:
            nBaseAC = 6;

            nStrength = 10;
            nDexterity = 17;
            nConstitution = 8;
            nIntelligence = 3;
            nWisdom = 14;
            nCharisma = 6;


            fDexterityLevel = 1.0;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.04;

            fTranslation = 0.0;
            fTranslationLevel = -0.04;

            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_DISARM);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_DODGE);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_MOBILITY);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_SPRING_ATTACK);
            if (nMasterHitDice >= 3) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_IMPROVED_DISARM);
            if (nMasterHitDice >= 6) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_OPPORTUNIST);
            if (nMasterHitDice >= 9) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_IMPROVED_CRITICAL_CREATURE);

            nDamage = 1;

            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 1, nMasterHitDice);
        break;
        case APPEARANCE_TYPE_CAT_PANTHER:
            nBaseAC = 2;

            nStrength = 12;
            nDexterity = 16;
            nConstitution = 9;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 10;


            fDexterityLevel = 1.0;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;

            fScale = 0.9;
            fScaleLevel = 0.04;

            nDamage = 2;

            ApplySneakAttackFeat(nMasterHitDice);

            oWeaponLeft = ApplyDamageProgression("claw", INVENTORY_SLOT_CWEAPON_L, nDamage, nMasterHitDice);
            oWeaponRight = ApplyDamageProgression("claw", INVENTORY_SLOT_CWEAPON_R, nDamage, nMasterHitDice);
            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 1, nMasterHitDice, TRUE);
        break;
        case APPEARANCE_TYPE_IMP:
            nBaseAC = 4;

            nStrength = 10;
            nDexterity = 14;
            nConstitution = 10;
            nIntelligence = 17;
            nWisdom = 12;
            nCharisma = 10;

            fIntelligenceLevel = 0.75;
            fDexterityLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.03;

            fTranslation = 0.0;
            fTranslationLevel = -0.03;

            nDamage = 1;

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyRegeneration(nMephit), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageReduction(1+nMephit, IP_CONST_DAMAGESOAK_5_HP), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_COLD, 1+nMephit), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_ELECTRICAL, 1+nMephit), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageResistance(IP_CONST_DAMAGETYPE_FIRE, 1+nMephit), oSkin);

            oWeaponLeft = ApplyDamageProgression("slam", INVENTORY_SLOT_CWEAPON_L, nDamage, nMasterHitDice);
            oWeaponRight = ApplyDamageProgression("slam", INVENTORY_SLOT_CWEAPON_R, nDamage, nMasterHitDice);
            oWeaponSpecial = ApplyDamageProgression("gore", INVENTORY_SLOT_CWEAPON_B, nDamage, nMasterHitDice);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_POISON, POISON_QUASIT_VENOM), oWeaponSpecial);
        break;
        case APPEARANCE_TYPE_FAIRY:
            nBaseAC = 3;

            nStrength = 5;
            nDexterity = 14;
            nConstitution = 6;
            nIntelligence = 16;
            nWisdom = 16;
            nCharisma = 16;


            fDexterityLevel = 1.0;

            fScale = 2.0;
            fScaleLevel = 0.03;

            ApplySneakAttackFeat(nMasterHitDice);

            fTranslation = -1.25;
            fTranslationLevel = -0.125;

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnHitProps(IP_CONST_ONHIT_SLEEP, nMasterHitDice/6, IP_CONST_ONHIT_DURATION_25_PERCENT_3_ROUNDS), GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));
        break;
        case APPEARANCE_TYPE_PSEUDODRAGON:
            nBaseAC = 3;

            nStrength = 11;
            nDexterity = 15;
            nConstitution = 13;
            nIntelligence = 16;
            nWisdom = 16;
            nCharisma = 16;


            fDexterityLevel = 0.75;
            fConstitutionLevel = 0.5;
            fStrengthLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.04;

            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_DODGE);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_MOBILITY);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_SPRING_ATTACK);
            if (nMasterHitDice >= 6) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_EPIC_WEAPON_SPECIALIZATION_CREATURE);
            if (nMasterHitDice >= 9) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_IMPROVED_CRITICAL_CREATURE);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyTrueSeeing(), oSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageReduction(1+nMephit, IP_CONST_DAMAGESOAK_5_HP), oSkin);

            fTranslation = 0.0;
            fTranslationLevel = -0.04;

            oWeaponRight = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 2, nMasterHitDice);
            oWeaponLeft = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 2, nMasterHitDice);
            oWeaponSpecial = ApplyDamageProgression("gore", INVENTORY_SLOT_CWEAPON_B, 2, nMasterHitDice);

            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyOnMonsterHitProperties(IP_CONST_ONMONSTERHIT_POISON, POISON_OIL_OF_TAGGIT), oWeaponSpecial);
        break;
        case APPEARANCE_TYPE_RAVEN:
            nBaseAC = 6;

            nStrength = 8;
            nDexterity = 19;
            nConstitution = 11;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;


            fDexterityLevel = 1.0;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;

            fScale = 1.0;
            fScaleLevel = 0.04;

            fTranslation = 0.0;
            fTranslationLevel = -0.04;

            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_DISARM);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_DODGE);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_MOBILITY);
            NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_SPRING_ATTACK);
            if (nMasterHitDice >= 3) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_IMPROVED_DISARM);
            if (nMasterHitDice >= 6) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_OPPORTUNIST);
            if (nMasterHitDice >= 9) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_IMPROVED_CRITICAL_CREATURE);

            oWeaponSpecial = ApplyDamageProgression("bite", INVENTORY_SLOT_CWEAPON_B, 1, nMasterHitDice);
        break;
    }

    if (nDexterity > nStrength) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_WEAPON_FINESSE);

    NWNX_Object_SetMaxHitPoints(OBJECT_SELF, (nHitDice+1)*8);
    NWNX_Object_SetCurrentHitPoints(OBJECT_SELF, GetMaxHitPoints(OBJECT_SELF));

    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, fScale+(fScaleLevel*fHitDice));

    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fTranslation+(fTranslationLevel*fHitDice));

    NWNX_Creature_SetLevelByPosition(OBJECT_SELF, 0, nHitDice+1);

    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_STRENGTH, nStrength+FloatToInt(fStrengthLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_DEXTERITY, nDexterity+FloatToInt(fDexterityLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_CONSTITUTION, nConstitution+FloatToInt(fConstitutionLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE, nIntelligence+FloatToInt(fIntelligenceLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_WISDOM, nWisdom+FloatToInt(fWisdomLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_CHARISMA, nCharisma+FloatToInt(fCharismaLevel*fHitDice));

    NWNX_Creature_SetBaseAC(OBJECT_SELF, nBaseAC+FloatToInt(fACLevel*fHitDice));
}
