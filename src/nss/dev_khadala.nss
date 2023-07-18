#include "inc_debug"
#include "inc_loot"

// This calculates stuff relating to Khadala.

string GetFakeItemResref(int nBaseItem)
{
    string sPlaceholderResRef = "";
    switch (nBaseItem)
    {
       case BASE_ITEM_SPELLSCROLL: sPlaceholderResRef = "gamble_scroll"; break;
       case BASE_ITEM_GLOVES: sPlaceholderResRef = "gamble_gloves"; break;
       case BASE_ITEM_BRACER: sPlaceholderResRef = "gamble_bracers";  break;
       case BASE_ITEM_RING: sPlaceholderResRef = "gamble_ring"; break;
       case BASE_ITEM_AMULET: sPlaceholderResRef = "gamble_amulet"; break;
       case BASE_ITEM_CLOAK: sPlaceholderResRef = "gamble_cloak"; break;
       case BASE_ITEM_BELT: sPlaceholderResRef = "gamble_belt";  break;
       case BASE_ITEM_SMALLSHIELD: sPlaceholderResRef = "nw_ashsw001";  break;
       case BASE_ITEM_HELMET: sPlaceholderResRef = "nw_arhe006";break;
       case BASE_ITEM_LARGESHIELD: sPlaceholderResRef = "nw_ashlw001";  break;
       case BASE_ITEM_TOWERSHIELD: sPlaceholderResRef = "nw_ashto001";  break;
       case BASE_ITEM_BASTARDSWORD: sPlaceholderResRef = "nw_wswbs001"; break;
       case BASE_ITEM_BATTLEAXE: sPlaceholderResRef = "nw_waxbt001"; break;
       case BASE_ITEM_CLUB: sPlaceholderResRef = "nw_wblcl001"; break;
       case BASE_ITEM_DAGGER: sPlaceholderResRef = "nw_wswdg001"; break;
       case BASE_ITEM_LONGSWORD: sPlaceholderResRef = "nw_wswls001"; break;
       case BASE_ITEM_SHORTSWORD: sPlaceholderResRef = "nw_wswss001"; break;
       case BASE_ITEM_WARHAMMER: sPlaceholderResRef = "nw_wblhw001"; break;
       case BASE_ITEM_LIGHTMACE: sPlaceholderResRef = "nw_wblml001"; break;
       case BASE_ITEM_HANDAXE: sPlaceholderResRef = "nw_waxhn001"; break;
       case BASE_ITEM_QUARTERSTAFF: sPlaceholderResRef = "nw_wdbqs001"; break;
       case BASE_ITEM_LONGBOW: sPlaceholderResRef = "nw_wbwln001"; break;
       case BASE_ITEM_SHORTBOW: sPlaceholderResRef = "nw_wbwsh001"; break;
       case BASE_ITEM_LIGHTFLAIL: sPlaceholderResRef = "nw_wblfl001"; break;
       case BASE_ITEM_LIGHTHAMMER: sPlaceholderResRef = "nw_wblhl001"; break;
       case BASE_ITEM_HALBERD: sPlaceholderResRef = "nw_wplhb001"; break;
       case BASE_ITEM_SHORTSPEAR: sPlaceholderResRef = "nw_wplss001"; break;
       case BASE_ITEM_GREATSWORD: sPlaceholderResRef = "nw_wswgs001"; break;
       case BASE_ITEM_GREATAXE: sPlaceholderResRef = "nw_waxgr001"; break;
       case BASE_ITEM_HEAVYFLAIL: sPlaceholderResRef = "nw_wblfh001"; break;
       case BASE_ITEM_DWARVENWARAXE: sPlaceholderResRef = "x2_wdwraxe00"; break;
       case BASE_ITEM_MORNINGSTAR: sPlaceholderResRef = "nw_wblms001"; break;
       case BASE_ITEM_HEAVYCROSSBOW: sPlaceholderResRef = "nw_wbwxh001"; break;
       case BASE_ITEM_LIGHTCROSSBOW: sPlaceholderResRef = "nw_wbwxl001"; break;
       case BASE_ITEM_DIREMACE: sPlaceholderResRef = "nw_wdbma001"; break;
       case BASE_ITEM_DOUBLEAXE: sPlaceholderResRef = "nw_wdbax001"; break;
       case BASE_ITEM_RAPIER: sPlaceholderResRef = "nw_wswrp001"; break;
       case BASE_ITEM_SCIMITAR: sPlaceholderResRef = "nw_wswsc001"; break;
       case BASE_ITEM_KATANA: sPlaceholderResRef = "nw_wswka001"; break;
       case BASE_ITEM_KAMA: sPlaceholderResRef = "nw_wspka001"; break;
       case BASE_ITEM_SCYTHE: sPlaceholderResRef = "nw_wplsc001"; break;
       case BASE_ITEM_TWOBLADEDSWORD: sPlaceholderResRef = "nw_wdbsw001"; break;
       case BASE_ITEM_WHIP: sPlaceholderResRef = "x2_it_wpwhip"; break;
       //case BASE_ITEM_TRIDENT: sPlaceholderResRef = ""; break;
       case BASE_ITEM_KUKRI: sPlaceholderResRef = "nw_wspku001"; break;
       case BASE_ITEM_SICKLE: sPlaceholderResRef = "nw_wspsc001"; break;
       case BASE_ITEM_SLING: sPlaceholderResRef = "nw_wbwsl001"; break;
       case BASE_ITEM_MAGICWAND: sPlaceholderResRef = "gamble_wand";  break;
    }
    return sPlaceholderResRef;
}

string GetFakeArmorResref(int nAC)
{
    string sPlaceholderResRef = "";
    int nMultiplier; // don't care about this
    switch (nAC)
    {
        case 0: sPlaceholderResRef = "gamble_clothing"; nMultiplier = 2; break;
        case 1: sPlaceholderResRef = "nw_aarcl009"; nMultiplier = 2; break;
        case 2: sPlaceholderResRef = "nw_aarcl001"; nMultiplier = 3; break;
        case 3: sPlaceholderResRef = "nw_aarcl002"; nMultiplier = 4; break;
        case 4: sPlaceholderResRef = "nw_aarcl012"; nMultiplier = 5; break;
        case 5: sPlaceholderResRef = "nw_aarcl004"; nMultiplier = 6; break;
        case 6: sPlaceholderResRef = "nw_aarcl005";  nMultiplier = 7; break;
        case 7: sPlaceholderResRef = "nw_aarcl006"; nMultiplier = 8; break;
        case 8: sPlaceholderResRef = "nw_aarcl007"; nMultiplier = 10; break;
    }
    return sPlaceholderResRef;
}


int GetMultiplierForBaseItemType(int nBaseItem)
{
    int nMultiplier = 1;
    if (nBaseItem == BASE_ITEM_SMALLSHIELD) { nMultiplier = 2; }
    else if (nBaseItem == BASE_ITEM_SPELLSCROLL) { nMultiplier = 0; }
    else if (nBaseItem == BASE_ITEM_GLOVES) { nMultiplier = 3; }
    else if (nBaseItem == BASE_ITEM_BRACER) { nMultiplier = 3; }
    else if (nBaseItem == BASE_ITEM_RING) { nMultiplier = 5; }
    else if (nBaseItem == BASE_ITEM_AMULET) { nMultiplier = 6; }
    else if (nBaseItem == BASE_ITEM_CLOAK) { nMultiplier = 3; }
    else if (nBaseItem == BASE_ITEM_BELT) { nMultiplier = 3; }
    else if (nBaseItem == BASE_ITEM_HELMET) { nMultiplier = 3; }
    else if (nBaseItem == BASE_ITEM_LARGESHIELD) { nMultiplier = 3; }
    else if (nBaseItem == BASE_ITEM_TOWERSHIELD) { nMultiplier = 4; }
    else if (nBaseItem == BASE_ITEM_MAGICWAND) { nMultiplier = 8; }
    return nMultiplier;
}

int GetMultiplierForBaseAC(int nAC)
{
    int nMultiplier = 1;
    if (nAC == 0) { nMultiplier = 2; }
    else if (nAC == 1) { nMultiplier = 2; }
    else if (nAC == 2) { nMultiplier = 3; }
    else if (nAC == 3) { nMultiplier = 4; }
    else if (nAC == 4) { nMultiplier = 5; }
    else if (nAC == 5) { nMultiplier = 6; }
    else if (nAC == 6) { nMultiplier = 7; }
    else if (nAC == 7) { nMultiplier = 8; }
    else if (nAC == 8) { nMultiplier = 10; }
    return nMultiplier;
}

float GetAverageChestValue(object oChest)
{
    if (!GetIsObjectValid(oChest))
    {
        return -1.0;
    }
    int nTotal = 0;
    int nNumItems = 0;
    object oTest = GetFirstItemInInventory(oChest);
    while (GetIsObjectValid(oTest))
    {
        nTotal += GetIdentifiedItemCost(oTest);
        nNumItems++;
        oTest = GetNextItemInInventory(oChest);
    }
    if (nNumItems == 0) { return -1.0; }
    return IntToFloat(nTotal)/IntToFloat(nNumItems);
}


float GetAverageValueOfItemsOfType(int nBaseItem, int nTier, int nUnique)
{
    string sChestName = "_BaseItem" + IntToString(nBaseItem) + "T" + IntToString(nTier);
    object oChest;
    object oOut;
    int i;
    for (i=0; i<2; i++)
    {
        if (i == 0 && !nUnique)
        {
            continue;
        }
        if (i == 1)
        {
            sChestName += "NonUnique";
        }
        oChest = GetObjectByTag(sChestName);
        return GetAverageChestValue(oChest);
    }
    return -1.0;
}

float GetAverageValueOfArmorOfType(int nAC, int nTier, int nUnique)
{
    string sChestName = "_BaseItem" + IntToString(BASE_ITEM_ARMOR) + "T" + IntToString(nTier) + "AC" + IntToString(nAC);
    object oChest;
    object oOut;
    int i;
    for (i=0; i<2; i++)
    {
        if (i == 0 && !nUnique)
        {
            continue;
        }
        if (i == 1)
        {
            sChestName += "NonUnique";
        }
        oChest = GetObjectByTag(sChestName);
        return GetAverageChestValue(oChest);
    }
    return -1.0;
}

float GetAverageCostForBaseItem(int nBaseItem)
{
    int nMultiplier = GetMultiplierForBaseItemType(nBaseItem);
    
    int nRandom = d100();
    
    
    float fT5Chance = IntToFloat(1*nMultiplier)/100.0;
    float fT4Chance = IntToFloat(3*nMultiplier)/100.0;
    float fT3Chance = IntToFloat(7*nMultiplier)/100.0;
    
    
    float fT2Chance = 1.0 - (fT3Chance + fT4Chance + fT5Chance);
    
    
    
    
    float fUnique = IntToFloat(UNIQUE_ITEM_CHANCE)/100.0;
    float fNonUnique = 1.0 - fUnique;

    float fT2 = fT2Chance * ((fUnique * GetAverageValueOfItemsOfType(nBaseItem, 2, 1)) + (fNonUnique * GetAverageValueOfItemsOfType(nBaseItem, 2, 0)));
    float fT3 = fT3Chance * ((fUnique * GetAverageValueOfItemsOfType(nBaseItem, 3, 1)) + (fNonUnique * GetAverageValueOfItemsOfType(nBaseItem, 3, 0)));
    float fT4 = fT4Chance * ((fUnique * GetAverageValueOfItemsOfType(nBaseItem, 4, 1)) + (fNonUnique * GetAverageValueOfItemsOfType(nBaseItem, 4, 0)));
    float fT5 = fT5Chance * ((fUnique * GetAverageValueOfItemsOfType(nBaseItem, 5, 1)) + (fNonUnique * GetAverageValueOfItemsOfType(nBaseItem, 5, 0)));
    
    return fT2 + fT3 + fT4 + fT5;
}

float GetAverageCostForBaseAC(int nAC)
{
    int nMultiplier = GetMultiplierForBaseAC(nAC);
    int nRandom = d100();
    
    
    float fT5Chance = IntToFloat(1*nMultiplier)/100.0;
    float fT4Chance = IntToFloat(3*nMultiplier)/100.0;
    float fT3Chance = IntToFloat(7*nMultiplier)/100.0;
    
    float fT2Chance = 1.0 - (fT3Chance + fT4Chance + fT5Chance);
    
    float fUnique = IntToFloat(UNIQUE_ITEM_CHANCE)/100.0;
    float fNonUnique = 1.0 - fUnique;

    float fT2 = fT2Chance * ((fUnique * GetAverageValueOfArmorOfType(nAC, 2, 1)) + (fNonUnique * GetAverageValueOfArmorOfType(nAC, 2, 0)));
    float fT3 = fT3Chance * ((fUnique * GetAverageValueOfArmorOfType(nAC, 3, 1)) + (fNonUnique * GetAverageValueOfArmorOfType(nAC, 3, 0)));
    float fT4 = fT4Chance * ((fUnique * GetAverageValueOfArmorOfType(nAC, 4, 1)) + (fNonUnique * GetAverageValueOfArmorOfType(nAC, 4, 0)));
    float fT5 = fT5Chance * ((fUnique * GetAverageValueOfArmorOfType(nAC, 5, 1)) + (fNonUnique * GetAverageValueOfArmorOfType(nAC, 5, 0)));
    
    return fT2 + fT3 + fT4 + fT5;
}

int GetKhadalaCostForBaseItem(int nBaseItem)
{
    string sResRef = GetFakeItemResref(nBaseItem);
    if (sResRef == "") { return -1; }
    object oPlaceholder = CreateItemOnObject(sResRef, OBJECT_SELF, 1);
    if (!GetIsObjectValid(oPlaceholder)) { return -1; }
    
    int nMultiplier = GetMultiplierForBaseItemType(nBaseItem);
    
    int nRet = GetGoldPieceValue(oPlaceholder)+1500*nMultiplier;
    DestroyObject(oPlaceholder);
    return nRet;
}

int GetKhadalaCostForBaseAC(int nAC)
{
    string sResRef = GetFakeArmorResref(nAC);
    if (sResRef == "") { return -1; }
    object oPlaceholder = CreateItemOnObject(sResRef, OBJECT_SELF, 1);
    if (!GetIsObjectValid(oPlaceholder)) { return -1; }
    
    int nMultiplier = GetMultiplierForBaseAC(nAC);
    
    int nRet = GetGoldPieceValue(oPlaceholder)+1500*nMultiplier;
    DestroyObject(oPlaceholder);
    return nRet;
}

int GetBaseItemByIndex(int nIndex)
{
    if (nIndex == 00) { return BASE_ITEM_SPELLSCROLL    ; }
    else if (nIndex == 01) { return BASE_ITEM_GLOVES         ; }
    else if (nIndex == 02) { return BASE_ITEM_BRACER         ; }
    else if (nIndex == 03) { return BASE_ITEM_RING           ; }
    else if (nIndex == 04) { return BASE_ITEM_AMULET         ; }
    else if (nIndex == 05) { return BASE_ITEM_CLOAK          ; }
    else if (nIndex == 06) { return BASE_ITEM_BELT           ; }
    else if (nIndex == 07) { return BASE_ITEM_SMALLSHIELD    ; }
    else if (nIndex == 08) { return BASE_ITEM_HELMET         ; }
    else if (nIndex == 09) { return BASE_ITEM_LARGESHIELD    ; }
    else if (nIndex == 10) { return BASE_ITEM_TOWERSHIELD    ; }
    else if (nIndex == 11) { return BASE_ITEM_BASTARDSWORD   ; }
    else if (nIndex == 12) { return BASE_ITEM_BATTLEAXE      ; }
    else if (nIndex == 13) { return BASE_ITEM_CLUB           ; }
    else if (nIndex == 14) { return BASE_ITEM_DAGGER         ; }
    else if (nIndex == 15) { return BASE_ITEM_LONGSWORD      ; }
    else if (nIndex == 16) { return BASE_ITEM_SHORTSWORD     ; }
    else if (nIndex == 17) { return BASE_ITEM_WARHAMMER      ; }
    else if (nIndex == 18) { return BASE_ITEM_LIGHTMACE      ; }
    else if (nIndex == 19) { return BASE_ITEM_HANDAXE        ; }
    else if (nIndex == 20) { return BASE_ITEM_QUARTERSTAFF   ; }
    else if (nIndex == 21) { return BASE_ITEM_LONGBOW        ; }
    else if (nIndex == 22) { return BASE_ITEM_SHORTBOW       ; }
    else if (nIndex == 23) { return BASE_ITEM_LIGHTFLAIL     ; }
    else if (nIndex == 24) { return BASE_ITEM_LIGHTHAMMER    ; }
    else if (nIndex == 25) { return BASE_ITEM_HALBERD        ; }
    else if (nIndex == 26) { return BASE_ITEM_SHORTSPEAR     ; }
    else if (nIndex == 27) { return BASE_ITEM_GREATSWORD     ; }
    else if (nIndex == 28) { return BASE_ITEM_GREATAXE       ; }
    else if (nIndex == 29) { return BASE_ITEM_HEAVYFLAIL     ; }
    else if (nIndex == 30) { return BASE_ITEM_DWARVENWARAXE  ; }
    else if (nIndex == 31) { return BASE_ITEM_MORNINGSTAR    ; }
    else if (nIndex == 32) { return BASE_ITEM_HEAVYCROSSBOW  ; }
    else if (nIndex == 33) { return BASE_ITEM_LIGHTCROSSBOW  ; }
    else if (nIndex == 34) { return BASE_ITEM_DIREMACE       ; }
    else if (nIndex == 35) { return BASE_ITEM_DOUBLEAXE      ; }
    else if (nIndex == 36) { return BASE_ITEM_RAPIER         ; }
    else if (nIndex == 37) { return BASE_ITEM_SCIMITAR       ; }
    else if (nIndex == 38) { return BASE_ITEM_KATANA         ; }
    else if (nIndex == 39) { return BASE_ITEM_KAMA           ; }
    else if (nIndex == 40) { return BASE_ITEM_SCYTHE         ; }
    else if (nIndex == 41) { return BASE_ITEM_TWOBLADEDSWORD ; }
    else if (nIndex == 42) { return BASE_ITEM_WHIP           ; }
    else if (nIndex == 43) { return BASE_ITEM_KUKRI          ; }
    else if (nIndex == 44) { return BASE_ITEM_SICKLE         ; }
    else if (nIndex == 45) { return BASE_ITEM_SLING          ; }
    else if (nIndex == 46) { return BASE_ITEM_MAGICWAND      ; }
    return BASE_ITEM_INVALID;
}

void HowBadlyDoesKhadalaScamForItem(int nBaseItem)
{
    int nCost = GetKhadalaCostForBaseItem(nBaseItem);
    float fRealValue = GetAverageCostForBaseItem(nBaseItem);
    string sBaseItemName =  GetStringByStrRef(StringToInt(Get2DAString("baseitems", "Name", nBaseItem)));
    
    float fTimesOvercharged = IntToFloat(nCost)/fRealValue;
    
    WriteTimestampedLogEntry(sBaseItemName + ": Khadala Cost = " + IntToString(nCost) + "; Expected value = " + FloatToString(fRealValue, 8, 2) + "; Times overcharged = " + FloatToString(fTimesOvercharged, 8, 2));
}

void HowBadlyDoesKhadalaScamForArmor(int nAC)
{
    int nCost = GetKhadalaCostForBaseAC(nAC);
    float fRealValue = GetAverageCostForBaseAC(nAC);
    string sBaseItemName = "AC " + IntToString(nAC);
    
    float fTimesOvercharged = IntToFloat(nCost)/fRealValue;
    
    WriteTimestampedLogEntry(sBaseItemName + ": Khadala Cost = " + IntToString(nCost) + "; Expected value = " + FloatToString(fRealValue, 8, 2) + "; Times overcharged = " + FloatToString(fTimesOvercharged, 8, 2));
}

void main()
{
    if (!GetIsDevServer()) { return; }
    int nIndex = 0;
    float fDelay = 0.0;
    while (nIndex <= 46)
    {
        int nBaseItem = GetBaseItemByIndex(nIndex);
        DelayCommand(fDelay, HowBadlyDoesKhadalaScamForItem(nBaseItem));
        nIndex++;
        fDelay += 0.5;
    }
    nIndex = 0;
    while (nIndex <= 8)
    {
        DelayCommand(fDelay, HowBadlyDoesKhadalaScamForArmor(nIndex));
        nIndex++;
        fDelay += 0.5;
    }
}