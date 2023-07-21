//::///////////////////////////////////////////////
//:: Utility Include: Item Property Functions
//:: util_i_itemprop.nss
//:://////////////////////////////////////////////
/*
    This contains a loose collection of utility functions for item properties.
*/
//:://////////////////////////////////////////////
//:: Part of the nwscript_utility_scripts project; see for dates/creator info
//:: https://github.com/Finaldeath/nwscript_utility_scripts
//:://////////////////////////////////////////////

// This checks if a item is usable by ourselves based on any item restrictions on it (class/race/alignment).
// If any restriction item properties are on there it checks we have at least 1 level in that class. Must have at least one match if any exist
// This is not optimal to run often without caching
// * oItem - Item to check
int GetCanUseItemDueToItemRestrictions(object oItem);

// Check if we can use the charges of the spellcasting property ip on oItem
// * ip - Item property to check
// * oItem - Item to check
int GetItemSpellChargesAreUsable(itemproperty ip, object oItem);

// Can we use this item - which is potentially a spell scroll - if a wizard-like spell school restrictions?
// Returns TRUE if not a spell scroll or the item property isn't restricted
// * ip - Should be a valid castable item property
// * oItem - the item being tested
int GetItemScrollUsable(itemproperty ip, object oItem);

// Returns the same string you would get if you examined the item in-game
// Uses 2da & tlk lookups and should work for custom itemproperties too
string ItemPropertyToString(itemproperty ipItemProperty);



// This checks if a item is usable by ourselves based on any item restrictions on it (class/race/alignment).
// If any restriction item properties are on there it checks we have at least 1 level in that class. Must have at least one match if any exist
// This is not optimal to run often without caching
// * oItem - Item to check
int GetCanUseItemDueToItemRestrictions(object oItem)
{
    // Check all item properties and look for ones we CAN'T match so a negative check. If none are found of course it's free to use/no restrictions.
    // We are NOT checking for Use Any Device kind of feats yet. AI can cheat those but lets do it properly sometime.
    itemproperty ip = GetFirstItemProperty(oItem);
    int nItemPropertyType;
    while (GetIsItemPropertyValid(ip))
    {
        nItemPropertyType = GetItemPropertyType(ip);
        switch(nItemPropertyType)
        {
            // Uses IPRP_ALIGNGRP.2da
            case ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP:
            {
                switch(GetItemPropertySubType(ip))
                {
                    case IP_CONST_ALIGNMENTGROUP_ALL:
                        // Do nothing!
                    break;
                    case IP_CONST_ALIGNMENTGROUP_NEUTRAL:
                        // Any alignment axis can be neutral for this to work so both have to not be it for it to not work.
                        if(GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_NEUTRAL && GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_NEUTRAL) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENTGROUP_LAWFUL:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_LAWFUL) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENTGROUP_CHAOTIC:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_CHAOTIC) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENTGROUP_GOOD:
                        if(GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_GOOD) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENTGROUP_EVIL:
                        if(GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_EVIL) return FALSE;
                    break;
                }
            }
            break;
            // Uses classes.2da list (although it won't include "monster" classes)
            case ITEM_PROPERTY_USE_LIMITATION_CLASS:
                if(GetLevelByClass(GetItemPropertySubType(ip)) == 0) return FALSE;
            break;
            // Uses racialtypes.2da 
            case ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE:
                if(GetRacialType(OBJECT_SELF) != GetItemPropertySubType(ip)) return FALSE;
            break;
            // Uses IPRP_ALIGNMENT.2da
            case ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT:
            {
                switch(GetItemPropertySubType(ip))
                {
                    // Must match exactly these...
                    case IP_CONST_ALIGNMENT_LG:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_LAWFUL || GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_GOOD) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENT_LN:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_LAWFUL || GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_NEUTRAL) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENT_NG:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_NEUTRAL || GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_GOOD) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENT_TN:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_NEUTRAL || GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_NEUTRAL) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENT_NE:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_NEUTRAL || GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_EVIL) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENT_CG:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_CHAOTIC || GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_GOOD) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENT_CN:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_CHAOTIC || GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_NEUTRAL) return FALSE;
                    break;
                    case IP_CONST_ALIGNMENT_CE:
                        if(GetAlignmentLawChaos(OBJECT_SELF) != ALIGNMENT_CHAOTIC || GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_EVIL) return FALSE;
                    break;
                }
            }
            break;
            // Would use IPRP_TERRAINTYPE which is blank.
            // While this is defined, nothing can have this set on it in itemprops.2da
            // I highly suspect it is buggy, duff, too risky for Bioware to enable (hakpack tileset)
            // OR just they never needed it :)
            //case ITEM_PROPERTY_USE_LIMITATION_TILESET:
        }
        ip = GetNextItemProperty(oItem);
    }
    return TRUE;
}

// Check if we can use the charges of the spellcasting property ip on oItem
// * ip - Item property to check
// * oItem - Item to check
int GetItemSpellChargesAreUsable(itemproperty ip, object oItem)
{
    // What kind of thing is it, and therefore we need to check charges etc.
    int nCostTable = GetItemPropertyCostTableValue(ip);
    switch(nCostTable)
    {
        // Scrolls, potions mainly
        case IP_CONST_CASTSPELL_NUMUSES_SINGLE_USE:
        // 2 sorts of "unlimited use". Need to test if 0 charges/use at 0 charges works though.
        case IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE:
        case IP_CONST_CASTSPELL_NUMUSES_0_CHARGES_PER_USE:
            return TRUE;
        break;
        // 5 charges/use
        case IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE:
            if(GetItemCharges(oItem) >= 5) return TRUE;
        break;
        // 4 charges/use
        case IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE:
            if(GetItemCharges(oItem) >= 4) return TRUE;
        break;
        // 3 charges/use
        case IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE:
            if(GetItemCharges(oItem) >= 3) return TRUE;
        break;
        // 2 charges/use
        case IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE:
            if(GetItemCharges(oItem) >= 2) return TRUE;
        break;
        // 1 charges/use
        case IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE:
            if(GetItemCharges(oItem) >= 1) return TRUE;
        break;
        // Uses/Day need some left
        case IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY:
        case IP_CONST_CASTSPELL_NUMUSES_2_USES_PER_DAY:
        case IP_CONST_CASTSPELL_NUMUSES_3_USES_PER_DAY:
        case IP_CONST_CASTSPELL_NUMUSES_4_USES_PER_DAY:
        case IP_CONST_CASTSPELL_NUMUSES_5_USES_PER_DAY:
            if(GetItemPropertyUsesPerDayRemaining(oItem, ip) > 0) return TRUE;
        break;
    }
    // Either an error or not enough charges/uses.
    return FALSE;
}

// Can we use this item - which is potentially a spell scroll - if a wizard-like spell school restrictions?
// Returns TRUE if not a spell scroll or the item property isn't restricted
// * ip - Should be a valid castable item property
// * oItem - the item being tested
int GetItemScrollUsable(itemproperty ip, object oItem)
{
    // Scrolls only are affected by this (hardcoded)
    int nItemType = GetBaseItemType(oItem);
    if(nItemType == BASE_ITEM_SCROLL || 
       nItemType == BASE_ITEM_ENCHANTED_SCROLL ||
       nItemType == BASE_ITEM_SPELLSCROLL)
    {
        // PickSchool in NWNEE allows classes to pick a spell school so we check all 3 of our classes for it
        int nClassPosition = 1;
        int nClass = GetClassByPosition(nClassPosition);
        while(nClass != CLASS_TYPE_INVALID)
        {
            if(Get2DAString("classes", "PickSchool", nClass) == "1")
            {
                // Check spell school of the spell item property
                // This returns an ID from iprp_spells - ie; it is a spell, but the level / spell ID is codified in another 2DA. So look it up.
                int nSpellID = StringToInt(Get2DAString("iprp_spells","SpellIndex",GetItemPropertySubType(ip)));
                string sSpellSchool = Get2DAString("spells", "School", nSpellID);

                // General spells can be cast by any wizard
                if(sSpellSchool != "G")
                {
                    // Check specalization
                    int nSpecalization = GetSpecialization(OBJECT_SELF, nClass);
                    // Look up the opposed school
                    int nOpposedSchool = StringToInt(Get2DAString("spellschools", "Opposition", nSpecalization));

                    // 0 is blank or "General"
                    if(nOpposedSchool > 0)
                    {
                        // Get opposed school ID, if it is equal we can't cast it
                        if(sSpellSchool == Get2DAString("spellschools", "Letter", nOpposedSchool))
                        {
                            return FALSE;
                        }
                    }
                }
            }
            nClassPosition++;
            nClass = GetClassByPosition(nClassPosition);
        }
    }
    // Not a wizard-type user or not applicable item
    return TRUE;
}

// Gets the first item property, if any, matching nSpellID and returns it, or an invalid item property if none are found (charges, spell school, or just not existing)
// This is useful to return for returning to use on ActionUseItemOnObject() or ActionUseItemAtLocation()
// nSpellID - SPELL_* constant to match
// oItem - The item to test
itemproperty GetFirstItemPropertyOnItemWithSpell(int nSpellID, object oItem)
{
    int nItemSpell;
    itemproperty ipInvalid;
    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL)
        {
            // This returns an ID from iprp_spells - ie; it is a spell, but the level / spell ID is codified in another 2DA. So look it up.
            nItemSpell = StringToInt(Get2DAString("iprp_spells","SpellIndex",GetItemPropertySubType(ip)));

            // Check if valid. If it is do we have charges etc.
            if(nItemSpell == nSpellID)
            {
                // Usable charges?
                if(GetItemSpellChargesAreUsable(ip, oItem) && GetItemScrollUsable(ip, oItem))
                {
                    return ip;
                }
            }
        }
        ip = GetNextItemProperty(oItem);
    }
    return ipInvalid;
}


// Returns the same string you would get if you examined the item in-game
// Uses 2da & tlk lookups and should work for custom itemproperties too
string ItemPropertyToString(itemproperty ipItemProperty)
{
    int nIPType = GetItemPropertyType(ipItemProperty);
    string sName = GetStringByStrRef(StringToInt(Get2DAString("itempropdef", "GameStrRef", nIPType)));
    if(GetItemPropertySubType(ipItemProperty) != -1)//nosubtypes
    {
        string sSubTypeResRef = Get2DAString("itempropdef", "SubTypeResRef", nIPType);
        int nTlk = StringToInt(Get2DAString(sSubTypeResRef, "Name", GetItemPropertySubType(ipItemProperty)));
        if(nTlk > 0)
            sName += " " + GetStringByStrRef(nTlk);
    }
    if(GetItemPropertyParam1(ipItemProperty) != -1)
    {
        string sParamResRef = Get2DAString("iprp_paramtable", "TableResRef", GetItemPropertyParam1(ipItemProperty));
        if(Get2DAString("itempropdef", "SubTypeResRef", nIPType) != "" && 
           Get2DAString(Get2DAString("itempropdef", "SubTypeResRef", nIPType), "TableResRef", GetItemPropertyParam1(ipItemProperty)) != "")
            sParamResRef = Get2DAString(Get2DAString("itempropdef", "SubTypeResRef", nIPType), "TableResRef", GetItemPropertyParam1(ipItemProperty));
        int nTlk = StringToInt(Get2DAString(sParamResRef, "Name", GetItemPropertyParam1Value(ipItemProperty)));
        if(nTlk > 0)
            sName += " " + GetStringByStrRef(nTlk);
    }
    if(GetItemPropertyCostTable(ipItemProperty) != -1)
    {
        string sCostResRef = Get2DAString("iprp_costtable", "Name", GetItemPropertyCostTable(ipItemProperty));
        int nTlk = StringToInt(Get2DAString(sCostResRef, "Name", GetItemPropertyCostTableValue(ipItemProperty)));
        if(nTlk > 0)
            sName += " " + GetStringByStrRef(nTlk);
    }
    return sName;
}