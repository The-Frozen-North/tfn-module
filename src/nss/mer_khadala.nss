#include "inc_merchant"
#include "inc_loot"
#include "nwnx_item"

int GetRandomTier()
{
    int nRandom = d100();

    if (nRandom == 1)
    {
        return 5;
    }
    else if (nRandom <= 3)
    {
        return 4;
    }
    else if (nRandom <= 7)
    {
        return 3;
    }
    else if (nRandom <= 15)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

void CreatePlaceholderItem(object oItem)
{
    string sPlaceholderResRef;

    switch (GetBaseItemType(oItem))
    {
       case BASE_ITEM_GLOVES: sPlaceholderResRef = "gamble_gloves"; break;
       case BASE_ITEM_BRACER: sPlaceholderResRef = "gamble_bracers"; break;
       case BASE_ITEM_RING: sPlaceholderResRef = "gamble_ring"; break;
       case BASE_ITEM_AMULET: sPlaceholderResRef = "gamble_amulet"; break;
       case BASE_ITEM_CLOAK: sPlaceholderResRef = "gamble_cloak"; break;
       case BASE_ITEM_BELT: sPlaceholderResRef = "gamble_belt"; break;
       case BASE_ITEM_SMALLSHIELD: sPlaceholderResRef = "nw_ashsw001"; break;
       case BASE_ITEM_HELMET: sPlaceholderResRef = "nw_arhe006"; break;
       case BASE_ITEM_LARGESHIELD: sPlaceholderResRef = "nw_ashlw001"; break;
       case BASE_ITEM_TOWERSHIELD: sPlaceholderResRef = "nw_ashto001"; break;
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
       case BASE_ITEM_ARMOR:
          switch (NWNX_Item_GetBaseArmorClass(oItem))
          {
            case 0: sPlaceholderResRef = "nw_wbwsl001"; break;
            case 1: sPlaceholderResRef = "nw_aarcl009"; break;
            case 2: sPlaceholderResRef = "nw_aarcl001"; break;
            case 3: sPlaceholderResRef = "nw_aarcl002"; break;
            case 4: sPlaceholderResRef = "nw_aarcl012"; break;
            case 5: sPlaceholderResRef = "nw_aarcl004"; break;
            case 6: sPlaceholderResRef = "nw_aarcl005"; break;
            case 7: sPlaceholderResRef = "nw_aarcl006"; break;
            case 8: sPlaceholderResRef = "nw_aarcl007"; break;
          }
       break;
    }

    object oPlaceholderItem = CreateItemOnObject(sPlaceholderResRef, OBJECT_SELF, 1, "gamble");
    //NWNX_Item_SetBaseGoldPieceValue(oPlaceholderItem, 1000);
    NWNX_Item_SetAddGoldPieceValue(oPlaceholderItem, 1000);

    SetLocalObject(oPlaceholderItem, "item", oItem);
    string sDescription = "This item will be revealed when purchased.";

    SetDescription(oPlaceholderItem, sDescription);
    SetDescription(oPlaceholderItem, sDescription, FALSE);
    SetIdentified(oPlaceholderItem, FALSE);
}

void main()
{
    object oStorage = GetObjectByTag("khadala_storage");

    object oItemInStorage, oItemPlaceholder;

    int i;
    int nMax = d4(40);
    for (i = 0; i < nMax; i++)
    {
        oItemInStorage = GenerateTierItem(0, 0, oStorage, "Melee", GetRandomTier());
        CreatePlaceholderItem(oItemInStorage);
    }

    nMax = d4(40);
    for (i = 0; i < nMax; i++)
    {
        oItemInStorage = GenerateTierItem(0, 0, oStorage, "Range", GetRandomTier());
        CreatePlaceholderItem(oItemInStorage);
    }
    /*
    nMax = d4(40);
    for (i = 0; i < nMax; i++)
    {
        oItemInStorage = GenerateTierItem(0, 0, oStorage, "Armor", GetRandomTier(), TRUE);
        CreatePlaceholderItem(oItemInStorage);
    }
    */
    nMax = d4(60);
    for (i = 0; i < nMax; i++)
    {
        oItemInStorage = GenerateTierItem(0, 0, oStorage, "Apparel", GetRandomTier());
        CreatePlaceholderItem(oItemInStorage);
    }
}
