#include "inc_treasure"

// This function determines the AC from the armor given
int GetBaseArmorAC(object oArmor)
{
  return
  StringToInt
  (
    Get2DAString
    (
      "parts_chest",
      "ACBONUS",
      GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_TORSO)
    )
  );
}

void DistributeTreasureToStores(object oItem)
{
   object oContainer = GetObjectByTag(TREASURE_DISTRIBUTION);
   object oNewItem;
   string sTier, sType, sName, sResRef, sRarity, sNonUnique;
   int nBaseArmorAC, nBaseType, nValue, nEnchantValue;

   int nIdentified = GetLocalInt(oItem, "identified"); // Store the identified state for use later.

   SetIdentified(oItem, TRUE); // Need to identify them for now so we get the proper gold value.

   sResRef = GetResRef(oItem);
   nBaseType = GetBaseItemType(oItem);
   nEnchantValue = GetEnchantValue(oItem);
   sName = GetName(oItem);

   int nCount = GetLocalInt(oContainer, "count");
   nCount = nCount + 1;
   SetLocalInt(oContainer, "count", nCount);
   //SendDebugMessage("distributed "+IntToString(nCount)+" "+sName);

   if (GetTag(oItem) == "non_unique") sNonUnique = "NonUnique";
   if (GetLocalInt(oItem, "non_unique") == 1) sNonUnique = "NonUnique";

   if (GetBaseItemType(oItem) == BASE_ITEM_ARMOR)
   {
       nBaseArmorAC = GetBaseArmorAC(oItem);
   }
   else
   {
       nBaseArmorAC = 0;
   }

// Apply the enchanted weight reduction at this point.
   AddEnchantedWeightReduction(oItem);

// only get gold value after the weight reduction
   nValue = GetGoldPieceValue(oItem);
   switch (nBaseType)
   {
       case BASE_ITEM_SPELLSCROLL:
          nValue = nValue * 4;
       break;
       case BASE_ITEM_TRAPKIT:
       case BASE_ITEM_SHURIKEN:
       case BASE_ITEM_THROWINGAXE:
       case BASE_ITEM_DART:
          nValue = nValue * 8;
       break;
       case BASE_ITEM_ARROW:
       case BASE_ITEM_BULLET:
       case BASE_ITEM_BOLT:
          nValue = nValue * 10;
       break;
   }

   switch (nBaseType)
   {
       case BASE_ITEM_SPELLSCROLL:
       case BASE_ITEM_GEM:
       case BASE_ITEM_POTIONS:
          nIdentified = 1;
       break;
   }


// Apply a multiplier for misc items (junk and art)
       if (TestStringAgainstPattern("**misc**", sResRef)) nValue = nValue * 5;

// Enchanted full plate mail is considered 1 tier higher.
       if (nEnchantValue > 0 && nBaseArmorAC == 8) nEnchantValue++;

// Raise an error if there is an item that exceeded the maximum value.
       if (nValue > 22000)
       {
           CopyItemToExistingTarget(oItem, GetObjectByTag("_overvalue"));
       }

// Sort by item value
       if (nValue >= MIN_VALUE_T5) {sTier = "T5";}
       else if (nValue >= MIN_VALUE_T4) {sTier = "T4";}
       else if (nValue >= MIN_VALUE_T3) {sTier = "T3";}
       else if (nValue >= MIN_VALUE_T2) {sTier = "T2";}
       else {sTier = "T1";}

// special rule to bump up unidentified items to the next tier, too much magic gear encountered at low level
       if (sTier == "T1" && nIdentified == 0) sTier = "T2";

// High quality/composite range items are always T2
       if (nEnchantValue == 0 && (GetStringLeft(sName, 12) == "High Quality" || GetStringLeft(sName, 9) == "Composite"))
       {
           sTier = "T2";
       }

       if (nBaseType == BASE_ITEM_TRAPKIT || GetStringLeft(sResRef, 4) == "misc") {sType = "Misc";}
       else if (nBaseType == BASE_ITEM_SPELLSCROLL) {sType = "Scrolls";}
       else if (GetStringLeft(sResRef, 7) == "apparel")
       {
          sType = "Apparel";
          switch (nBaseType)
          {
               case BASE_ITEM_BELT:
               case BASE_ITEM_BOOTS:
               case BASE_ITEM_BRACER:
               case BASE_ITEM_CLOAK:
               case BASE_ITEM_GLOVES:
                  sRarity = "Common";
               break;
               case BASE_ITEM_RING:
                  sRarity = "Uncommon";
               break;
               case BASE_ITEM_AMULET:
                  sRarity = "Rare";
               break;
           }
       }
// all armors, including shields and helmets
       else if (nBaseType == BASE_ITEM_HELMET || nBaseType == BASE_ITEM_ARMOR || nBaseType == BASE_ITEM_TOWERSHIELD || nBaseType == BASE_ITEM_LARGESHIELD || nBaseType == BASE_ITEM_SMALLSHIELD)
       {
          sType = "Armor";

           switch (nBaseType)
           {
             case BASE_ITEM_ARMOR:
                  switch (nBaseArmorAC)
                  {
                     case 1:
                     case 2:
                         sRarity = "Common";
                     break;
                     case 3:
                     case 4:
                     case 5:
                         sRarity = "Uncommon";
                     break;
                     case 0:
                     case 6:
                     case 7:
                     case 8:
                         sRarity = "Rare";
                     break;
                   }
             break;
             case BASE_ITEM_SMALLSHIELD:
             case BASE_ITEM_HELMET:
                  sRarity = "Common";
             break;
             case BASE_ITEM_LARGESHIELD:
                  sRarity = "Uncommon";
             break;
             case BASE_ITEM_TOWERSHIELD:
                  sRarity = "Rare";
             break;
           }

         }
         else if (GetStringLeft(sResRef, 6) == "weapon" || GetMeleeWeapon(oItem) || GetWeaponRanged(oItem) || nBaseType == BASE_ITEM_ARROW || nBaseType == BASE_ITEM_BULLET || nBaseType == BASE_ITEM_BOLT)
         {
            sType = "Melee";

            if (GetWeaponRanged(oItem) || nBaseType == BASE_ITEM_ARROW || nBaseType == BASE_ITEM_BULLET || nBaseType == BASE_ITEM_BOLT) sType = "Range";

            switch (nBaseType)
            {
               case BASE_ITEM_BASTARDSWORD:
               case BASE_ITEM_BATTLEAXE:
               case BASE_ITEM_CLUB:
               case BASE_ITEM_DAGGER:
               case BASE_ITEM_LONGSWORD:
               case BASE_ITEM_SHORTSWORD:
               case BASE_ITEM_WARHAMMER:
               case BASE_ITEM_LIGHTMACE:
               case BASE_ITEM_HANDAXE:
               case BASE_ITEM_QUARTERSTAFF:
               case BASE_ITEM_LONGBOW:
               case BASE_ITEM_SHORTBOW:
               case BASE_ITEM_THROWINGAXE:
               case BASE_ITEM_ARROW:
                  sRarity = "Common";
               break;
               case BASE_ITEM_LIGHTFLAIL:
               case BASE_ITEM_LIGHTHAMMER:
               case BASE_ITEM_HALBERD:
               case BASE_ITEM_SHORTSPEAR:
               case BASE_ITEM_GREATSWORD:
               case BASE_ITEM_GREATAXE:
               case BASE_ITEM_HEAVYFLAIL:
               case BASE_ITEM_DWARVENWARAXE:
               case BASE_ITEM_MORNINGSTAR:
               case BASE_ITEM_HEAVYCROSSBOW:
               case BASE_ITEM_LIGHTCROSSBOW:
               case BASE_ITEM_DART:
               case BASE_ITEM_BOLT:
                  sRarity = "Uncommon";
               break;
               case BASE_ITEM_GLOVES:
               case BASE_ITEM_DIREMACE:
               case BASE_ITEM_DOUBLEAXE:
               case BASE_ITEM_RAPIER:
               case BASE_ITEM_SCIMITAR:
               case BASE_ITEM_KATANA:
               case BASE_ITEM_KAMA:
               case BASE_ITEM_SCYTHE:
               case BASE_ITEM_TWOBLADEDSWORD:
               case BASE_ITEM_WHIP:
               case BASE_ITEM_TRIDENT:
               case BASE_ITEM_KUKRI:
               case BASE_ITEM_SICKLE:
               case BASE_ITEM_MAGICROD:
               case BASE_ITEM_MAGICSTAFF:
               case BASE_ITEM_MAGICWAND:
               case BASE_ITEM_SLING:
               case BASE_ITEM_SHURIKEN:
               case BASE_ITEM_BULLET:
                  sRarity = "Rare";
               break;
             }
          }
        SendDebugMessage("_"+sType+sRarity+sTier+sNonUnique);
        oNewItem = CopyItemToExistingTarget(oItem, GetObjectByTag("_"+sType+sRarity+sTier+sNonUnique));
        if (nIdentified != 1) SetIdentified(oNewItem, FALSE);

        DestroyObject(oItem);
}

void CountItemsThroughTiers()
{
    int nItems;
    object oItem;

    object oArea = GetObjectByTag("_TREASURE");
    object oContainer = GetFirstObjectInArea(oArea);

    while (GetIsObjectValid(oContainer))
    {
        if (GetHasInventory(oContainer) && (GetObjectType(oContainer) == OBJECT_TYPE_PLACEABLE))
        {
            nItems = 0;
            oItem = GetFirstItemInInventory(oContainer);
            while (GetIsObjectValid(oItem) == TRUE)
            {
                nItems = nItems + 1;
                SetItemStackSize(oItem, 1);
                oItem = GetNextItemInInventory(oContainer);
            }

            if (nItems == 0)
            {
                DestroyObject(oContainer);
            }
            else
            {
                SetLocalInt(oContainer, "item_count", nItems);
                SetName(oContainer, GetName(oContainer)+" - Count:"+IntToString(nItems));
            }
        }

        oContainer = GetNextObjectInArea(oArea);
    }
}

void main()
{
    object oContainer = GetObjectByTag(TREASURE_DISTRIBUTION);
    object oItem = GetFirstItemInInventory(oContainer);

// stop at 2000, it could be an infinite loop at this point
    if (GetLocalInt(oContainer, "count")  >= 3000)
    {
        return;
    }
    else if (!GetIsObjectValid(oItem))
    {
        CountItemsThroughTiers();
        SendDebugMessage("Treasure distribution finished", TRUE);
        DelayCommand(TREASURE_CREATION_DELAY, ExecuteScript("gtreas_merch", OBJECT_SELF));
    }
    else
    {
       DistributeTreasureToStores(oItem);
       DelayCommand(TREASURE_CREATION_DELAY, ExecuteScript("gtreas_distrib", OBJECT_SELF));
    }
}
