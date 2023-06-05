/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_crafting
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include file that holds the servers crafting and enchanting system.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "inc_general"
#include "nwnx_feedback"
#include "inc_debug"

const string TEMP_CHEST = "_crafting";

// Used in the crafting GUI to copy an item to be pasted to another item later.
// void CopyCraftingItem (object oPC, object oItem);

// Used in the crafting GUI to paste a copy of an item to another item.
// object PasteCraftingItem (object oPC, object oTarget, object oItem);

int GetItemSelectedEquipSlot (int nItemSelected);

int GetArmorModelSelected (object oPC);

object ChangeItemsAppearance (object oPC, object oTarget, int nToken, object oItem, int nDirection);

// Checks to see if the item can be crafted.
// bPasteCheck is a special check when an item is being pasted.
int CanCraftItem (object oPC, object oItem, int nToken, int bPasteCheck = FALSE);

// object RandomizeItemsCraftAppearance (object oPlayer, object oTarget, int nToken, object oItem);

// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem (object oTarget, int nItemSelected);

// Cancels the crafted item for the player and restoring the original.
// void CancelCraftedItem (object oPlayer, object oTarget);

// Returns TRUE/FALSE if item has temporary item property.
int CheckForTemporaryItemProperty (object oItem)
{
    itemproperty ipProperty;
    ipProperty = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ipProperty))
    {
        // Check to see if the item is temporary enchanted.
        if (GetItemPropertyDurationType (ipProperty) == DURATION_TYPE_TEMPORARY) return TRUE;
        ipProperty = GetNextItemProperty (oItem);
    }
    return FALSE;
}

string IntToPaddedString(int nX, int nLength = 3, int nSigned = FALSE)
{
    if(nSigned)
        nLength--; // To allow for sign
    string sResult = IntToString(nX);
    // Trunctate to nLength rightmost characters
    if(GetStringLength(sResult) > nLength)
        sResult = GetStringRight(sResult, nLength);
    // Pad the left side with zero
    while(GetStringLength(sResult) < nLength)
    {
        sResult = "0" + sResult;
    }
    if(nSigned)
    {
        if(nX >= 0)
            sResult = "+" + sResult;
        else
            sResult = "-" + sResult;
    }
    return sResult;
}

void HideFeedbackForCraftText (object oPlayer, int bHidden)
{
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_RECEIVED, bHidden, oPlayer);
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_ITEM_LOST, bHidden, oPlayer);
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_EQUIP_SKILL_SPELL_MODIFIERS, bHidden, oPlayer);
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_EQUIP_ONE_HANDED_WEAPON, bHidden, oPlayer);
    NWNX_Feedback_SetFeedbackMessageHidden (NWNX_FEEDBACK_EQUIP_TWO_HANDED_WEAPON, bHidden, oPlayer);
}

// Returns true if the item is a  weapon.
int GetIsWeapon (object oItem)
{
   int iType = GetBaseItemType (oItem);
   switch (iType)
   {
      case BASE_ITEM_LONGSWORD: return TRUE;
      case BASE_ITEM_LONGBOW: return TRUE;
      case BASE_ITEM_RAPIER: return TRUE;
      case BASE_ITEM_DAGGER: return TRUE;
      case BASE_ITEM_GREATAXE: return TRUE;
      case BASE_ITEM_SHORTBOW: return TRUE;
      case BASE_ITEM_GREATSWORD: return TRUE;
      case BASE_ITEM_SHORTSWORD: return TRUE;
      case BASE_ITEM_MORNINGSTAR: return TRUE;
      case BASE_ITEM_LIGHTMACE: return TRUE;
      case BASE_ITEM_BATTLEAXE: return TRUE;
      case BASE_ITEM_BASTARDSWORD: return TRUE;
      case BASE_ITEM_SCIMITAR: return TRUE;
      case BASE_ITEM_SHORTSPEAR: return TRUE;
      case BASE_ITEM_QUARTERSTAFF: return TRUE;
      case BASE_ITEM_WARHAMMER: return TRUE;
      case BASE_ITEM_HALBERD: return TRUE;
      case BASE_ITEM_SICKLE: return TRUE;
      case BASE_ITEM_HANDAXE: return TRUE;
      case BASE_ITEM_THROWINGAXE: return TRUE;
      case BASE_ITEM_DWARVENWARAXE: return TRUE;
      case BASE_ITEM_HEAVYFLAIL: return TRUE;
      case BASE_ITEM_LIGHTFLAIL: return TRUE;
      case BASE_ITEM_LIGHTHAMMER: return TRUE;
      case BASE_ITEM_LIGHTCROSSBOW: return TRUE;
      case BASE_ITEM_HEAVYCROSSBOW: return TRUE;
      case BASE_ITEM_SLING: return TRUE;
      case BASE_ITEM_KATANA: return TRUE;
      case BASE_ITEM_BOLT: return TRUE;
      case BASE_ITEM_ARROW: return TRUE;
      case BASE_ITEM_BULLET: return TRUE;
      case BASE_ITEM_CLUB: return TRUE;
      case BASE_ITEM_DOUBLEAXE: return TRUE;
      case BASE_ITEM_TWOBLADEDSWORD: return TRUE;
      case BASE_ITEM_DIREMACE: return TRUE;
      case BASE_ITEM_KAMA: return TRUE;
      case BASE_ITEM_KUKRI: return TRUE;
      case BASE_ITEM_SCYTHE: return TRUE;
      case BASE_ITEM_SHURIKEN: return TRUE;
      case BASE_ITEM_TRIDENT: return TRUE;
      case BASE_ITEM_WHIP: return TRUE;
      case BASE_ITEM_MAGICSTAFF: return TRUE;
   }
   return FALSE;
}

/*
// Used in the crafting GUI to copy an item to be pasted to another item later.
void CopyCraftingItem (object oPC, object oItem)
{
    int nSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    if (GetIsWeapon (oItem))
    {
        // Copy the base item type;
        SetLocalInt (oPC, "0_Craft_Item_Type", GetBaseItemType (oItem));
        // Copy each model & save to variables.
        SetLocalInt (oPC, "0_Weapon_M_Top", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP));
        SetLocalInt (oPC, "0_Weapon_M_Middle", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE));
        SetLocalInt (oPC, "0_Weapon_M_Bottom", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM));
        // Copy each color and save to variables.
        SetLocalInt (oPC, "0_Weapon_C_Top", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP));
        SetLocalInt (oPC, "0_Weapon_C_Middle", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE));
        SetLocalInt (oPC, "0_Weapon_C_Bottom", GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM));
    }
    else if (nSelected == 0)
    {
        // Copy the armors AC so we can check it.
        SetLocalInt (oPC, "0_Armor_AC", GetBaseArmorAC (oItem));
        // Copy each model & save to variables.
        SetLocalInt (oPC, "0_Armor_Belt", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_BELT));
        SetLocalInt (oPC, "0_Armor_LBicep", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LBICEP));
        SetLocalInt (oPC, "0_Armor_LFoot", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT));
        SetLocalInt (oPC, "0_Armor_LForearm", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOREARM));
        SetLocalInt (oPC, "0_Armor_LHand", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND));
        SetLocalInt (oPC, "0_Armor_LShin", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN));
        SetLocalInt (oPC, "0_Armor_LShoulder", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHOULDER));
        SetLocalInt (oPC, "0_Armor_LThigh", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH));
        SetLocalInt (oPC, "0_Armor_Neck", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_NECK));
        SetLocalInt (oPC, "0_Armor_Pelvis", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_PELVIS));
        SetLocalInt (oPC, "0_Armor_RBicep", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RBICEP));
        SetLocalInt (oPC, "0_Armor_RFoot", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT));
        SetLocalInt (oPC, "0_Armor_RForearm", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOREARM));
        SetLocalInt (oPC, "0_Armor_RHand", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND));
        SetLocalInt (oPC, "0_Armor_Robe", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_ROBE));
        SetLocalInt (oPC, "0_Armor_RShin", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN));
        SetLocalInt (oPC, "0_Armor_RShoulder", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHOULDER));
        SetLocalInt (oPC, "0_Armor_RThigh", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH));
        SetLocalInt (oPC, "0_Armor_Torso", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO));
        // Copy each color and save to variables.
        SetLocalInt (oPC, "0_Armor_Cloth1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1));
        SetLocalInt (oPC, "0_Armor_Cloth2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2));
        SetLocalInt (oPC, "0_Armor_Leather1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1));
        SetLocalInt (oPC, "0_Armor_Leather2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2));
        SetLocalInt (oPC, "0_Armor_Metal1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1));
        SetLocalInt (oPC, "0_Armor_Metal2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2));
    }
    else
    {
        // Copy the base item type;
        SetLocalInt (oPC, "0_Craft_Item_Type", GetBaseItemType (oItem));
        // Copy each model & save to variables.
        SetLocalInt (oPC, "0_Item_Model", GetItemAppearance (oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0));
        // Copy each color and save to variables.
        SetLocalInt (oPC, "0_Item_C_Cloth_1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1));
        SetLocalInt (oPC, "0_Item_C_Cloth_2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2));
        SetLocalInt (oPC, "0_Item_C_Leather_1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1));
        SetLocalInt (oPC, "0_Item_C_Leather_2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2));
        SetLocalInt (oPC, "0_Item_C_Metal_1", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1));
        SetLocalInt (oPC, "0_Item_C_Metal_2", GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2));
    }
    // Send message that it has been copied.
    // SendMessages (GetName (oItem) + " appearance has been copied!", COLOR_GREEN, oPC);
}

// Used in the crafting GUI to paste a copy of an item to another item.
object PasteCraftingItem (object oPC, object oTarget, object oItem)
{
    int iMaxModel, iModelTop, iModelMiddle, iModelBottom, iColorTop;
    int iColorMiddle, iColorBottom, iModel, iColor;
    object oItemDone, oItem1, oItem2, oItem3, oItem4, oItem5, oItem6, oItem7;
    object oItem8, oItem9, oItem10, oItem11, oItem12, oItem13, oItem14, oItem15;
    object oItem16, oItem17, oItem18, oItem19, oItem20, oItem21, oItem22;
    object oItem23, oItem24, oItem25, oItem26, oBuildContainer;
    int nSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    if (GetIsWeapon (oItem))
    {
        // Get each model & save to variables.
        iModelTop = GetLocalInt (oPC, "0_Weapon_M_Top");
        iModelMiddle = GetLocalInt (oPC, "0_Weapon_M_Middle");
        iModelBottom = GetLocalInt (oPC, "0_Weapon_M_Bottom");
        // Get each color and save to variables.
        iColorTop = GetLocalInt (oPC, "0_Weapon_C_Top");
        iColorMiddle = GetLocalInt (oPC, "0_Weapon_C_Middle");
        iColorBottom = GetLocalInt (oPC, "0_Weapon_C_Bottom");
        // Move the weapon to a chest.
        // Get the Building container.
        oBuildContainer = GetObjectByTag (TEMP_CHEST);
        // Move the item to the building container.
        oItem1 = CopyItem (oItem, oBuildContainer, TRUE);
        // Remove the original item.
        DestroyObject (oItem);
        // Change the weapon.
        oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP, iModelTop, TRUE);
        DestroyObject (oItem1);
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE, iModelMiddle, TRUE);
        DestroyObject (oItem2, 0.2f);
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM, iModelBottom, TRUE);
        DestroyObject (oItem3, 0.4f);
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_TOP, iColorTop, TRUE);
        DestroyObject (oItem4, 0.6f);
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_MIDDLE, iColorMiddle, TRUE);
        DestroyObject (oItem5, 0.8f);
        oItem7 = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_WEAPON_COLOR, ITEM_APPR_WEAPON_COLOR_BOTTOM, iColorBottom, TRUE);
        DestroyObject (oItem6, 1.f);
        // Move the item back to the PC.
        // Put the item back.
        oItemDone = CopyItem (oItem7, oTarget, TRUE);
        DestroyObject (oItem7);
        // Equip new item.
        AssignCommand (oTarget, ActionEquipItem (oItemDone, INVENTORY_SLOT_RIGHTHAND));
    }
    // Armor.
    else if (nSelected == 0)
    {
        // Move the armor to a chest.
        // Get the Building container.
        oBuildContainer = GetObjectByTag (TEMP_CHEST);
        // Move the item to the building container.
        oItem1 = CopyItem (oItem, oBuildContainer, TRUE);
        // Remove the original item.
        DestroyObject (oItem);
        // Get each model & save to variables.
        iModel = GetLocalInt (oPC, "0_Armor_Belt");
        oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_BELT, iModel, TRUE);
        DestroyObject (oItem1);
        iModel = GetLocalInt (oPC, "0_Armor_LBicep");
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LBICEP, iModel, TRUE);
        DestroyObject (oItem2, 0.2f);
        iModel = GetLocalInt (oPC, "0_Armor_LFoot");
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT, iModel, TRUE);
        DestroyObject (oItem3, 0.4f);
        iModel = GetLocalInt (oPC, "0_Armor_LForearm");
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOREARM, iModel, TRUE);
        DestroyObject (oItem4, 0.6f);
        iModel = GetLocalInt (oPC, "0_Armor_LHand");
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND, iModel, TRUE);
        DestroyObject (oItem5, 0.8f);
        iModel = GetLocalInt (oPC, "0_Armor_LShin");
        oItem7 = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN, iModel, TRUE);
        DestroyObject (oItem6, 1.0f);
        iModel = GetLocalInt (oPC, "0_Armor_LShoulder");
        oItem8 = CopyItemAndModify (oItem7, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHOULDER, iModel, TRUE);
        DestroyObject (oItem7, 1.2f);
        iModel = GetLocalInt (oPC, "0_Armor_LThigh");
        oItem9 = CopyItemAndModify (oItem8, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH, iModel, TRUE);
        DestroyObject (oItem8, 1.4f);
        iModel = GetLocalInt (oPC, "0_Armor_Neck");
        oItem10 = CopyItemAndModify (oItem9, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_NECK, iModel, TRUE);
        DestroyObject (oItem9, 1.6f);
        iModel = GetLocalInt (oPC, "0_Armor_Pelvis");
        oItem11 = CopyItemAndModify (oItem10, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_PELVIS, iModel, TRUE);
        DestroyObject (oItem10, 1.8f);
        iModel = GetLocalInt (oPC, "0_Armor_RBicep");
        oItem12 = CopyItemAndModify (oItem11, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RBICEP, iModel, TRUE);
        DestroyObject (oItem11, 2.0f);
        iModel = GetLocalInt (oPC, "0_Armor_RFoot");
        oItem13 = CopyItemAndModify (oItem12, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT, iModel, TRUE);
        DestroyObject (oItem12, 2.2f);
        iModel = GetLocalInt (oPC, "0_Armor_RForearm");
        oItem14 = CopyItemAndModify (oItem13, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOREARM, iModel, TRUE);
        DestroyObject (oItem13, 2.4f);
        iModel = GetLocalInt (oPC, "0_Armor_RHand");
        oItem15 = CopyItemAndModify (oItem14, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND, iModel, TRUE);
        DestroyObject (oItem14, 2.6f);
        iModel = GetLocalInt (oPC, "0_Armor_Robe");
        oItem16 = CopyItemAndModify (oItem15, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_ROBE, iModel, TRUE);
        DestroyObject (oItem15, 2.8f);
        iModel = GetLocalInt (oPC, "0_Armor_RShin");
        oItem17 = CopyItemAndModify (oItem16, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN, iModel, TRUE);
        DestroyObject (oItem16, 3.0f);
        iModel = GetLocalInt (oPC, "0_Armor_RShoulder");
        oItem18 = CopyItemAndModify (oItem17, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHOULDER, iModel, TRUE);
        DestroyObject (oItem17, 3.2f);
        iModel = GetLocalInt (oPC, "0_Armor_RThigh");
        oItem19 = CopyItemAndModify (oItem18, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH, iModel, TRUE);
        DestroyObject (oItem18, 3.4f);
        iModel = GetLocalInt (oPC, "0_Armor_Torso");
        oItem20 = CopyItemAndModify (oItem19, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_TORSO, iModel, TRUE);
        DestroyObject (oItem19, 3.6f);
        // Change armors color.
        iColor = GetLocalInt (oPC, "0_Armor_Cloth1");
        oItem21 = CopyItemAndModify (oItem20, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, iColor, TRUE);
        DestroyObject (oItem20, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Cloth2");
        oItem22 = CopyItemAndModify (oItem21, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, iColor, TRUE);
        DestroyObject (oItem21, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Leather1");
        oItem23 = CopyItemAndModify (oItem22, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, iColor, TRUE);
        DestroyObject (oItem22, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Leather2");
        oItem24 = CopyItemAndModify (oItem23, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, iColor, TRUE);
        DestroyObject (oItem23, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Metal1");
        oItem25 = CopyItemAndModify (oItem24, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, iColor, TRUE);
        DestroyObject (oItem24, 3.6f);
        iColor = GetLocalInt (oPC, "0_Armor_Metal2");
        oItem26 = CopyItemAndModify (oItem25, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, iColor, TRUE);
        DestroyObject (oItem25, 3.6f);
        // Move the item back to the PC.
        // Put the item back.
        oItemDone = CopyItem (oItem26, oTarget, TRUE);
        DestroyObject (oItem26);
        // Equip new item.
        AssignCommand (oTarget, ActionEquipItem (oItemDone, INVENTORY_SLOT_CHEST));
    }
    else
    {
        // Move the item to a chest.
        // Get the Building container.
        oBuildContainer = GetObjectByTag (TEMP_CHEST);
        // Move the item to the building container.
        oItem1 = CopyItem (oItem, oBuildContainer, TRUE);
        // Remove the original item.
        DestroyObject (oItem);
        // Get each model & save to variables.
        iModel = GetLocalInt (oPC, "0_Item_Model");
        oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, iModel, TRUE);
        DestroyObject (oItem1);
        // Change item's color.
        iColor = GetLocalInt (oPC, "0_Item_C_Cloth_1");
        oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, iColor, TRUE);
        DestroyObject (oItem2, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Cloth_2");
        oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, iColor, TRUE);
        DestroyObject (oItem3, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Leather_1");
        oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, iColor, TRUE);
        DestroyObject (oItem4, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Leather_2");
        oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, iColor, TRUE);
        DestroyObject (oItem5, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Metal_1");
        oItem7 = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, iColor, TRUE);
        DestroyObject (oItem6, 3.6f);
        iColor = GetLocalInt (oPC, "0_Item_C_Metal_2");
        oItem8 = CopyItemAndModify (oItem7, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, iColor, TRUE);
        DestroyObject (oItem7, 3.6f);
        // Move the item back to the PC.
        // Put the item back.
        oItemDone = CopyItem (oItem8, oTarget, TRUE);
        DestroyObject (oItem8);
        // Equip new item.
        int iItemType = GetBaseItemType (oItemDone);
        if (iItemType == BASE_ITEM_CLOAK) AssignCommand (oTarget, ActionEquipItem (oItemDone, INVENTORY_SLOT_CLOAK));
        else if (iItemType == BASE_ITEM_HELMET) AssignCommand (oTarget, ActionEquipItem (oItemDone, INVENTORY_SLOT_HEAD));
    }
    // Send message that it has been copied.
    // AssignCommand (oPC, SendMessages (GetName (oItemDone) + " appearance has been changed!", COLOR_GREEN, oPC));
    return oItemDone;
}
*/
int GetItemSelectedEquipSlot (int nItemSelected)
{
    if (nItemSelected == 0) return INVENTORY_SLOT_CHEST;
    if (nItemSelected == 1) return INVENTORY_SLOT_CLOAK;
    if (nItemSelected == 2) return INVENTORY_SLOT_HEAD;
    if (nItemSelected == 3) return INVENTORY_SLOT_RIGHTHAND;
    if (nItemSelected == 4) return INVENTORY_SLOT_LEFTHAND;
    return INVENTORY_SLOT_CHEST;
}

int GetArmorModelSelected (object oPC)
{
    int nModelSelected = GetLocalInt (oPC, "0_CRAFT_MODEL_SELECTION");
    if (nModelSelected == 0) return ITEM_APPR_ARMOR_MODEL_NECK;
    if (nModelSelected == 1) return ITEM_APPR_ARMOR_MODEL_RSHOULDER;
    if (nModelSelected == 2) return ITEM_APPR_ARMOR_MODEL_RBICEP;
    if (nModelSelected == 3) return ITEM_APPR_ARMOR_MODEL_RFOREARM;
    if (nModelSelected == 4) return ITEM_APPR_ARMOR_MODEL_RHAND;
    if (nModelSelected == 5) return ITEM_APPR_ARMOR_MODEL_TORSO;
    if (nModelSelected == 6) return ITEM_APPR_ARMOR_MODEL_BELT;
    if (nModelSelected == 7) return ITEM_APPR_ARMOR_MODEL_PELVIS;
    if (nModelSelected == 8) return ITEM_APPR_ARMOR_MODEL_RTHIGH;
    if (nModelSelected == 9) return ITEM_APPR_ARMOR_MODEL_RSHIN;
    if (nModelSelected == 10) return ITEM_APPR_ARMOR_MODEL_RFOOT;
    return ITEM_APPR_ARMOR_MODEL_ROBE;
}

// Get the items max models and max colors.
// oItem is the item to check.
// sPart is the part to get for:
// TopModel, MiddleModel, BottomModel - Used for weapon models.
// Color - Used for weapon colors.
int GetItemsMaxModels (object oItem, string sPart)
{
    return StringToInt (Get2DAString ("tmog_smi_list", sPart, GetBaseItemType (oItem)));
}

object ChangeItemsAppearance (object oPC, object oTarget, int nToken, object oItem, int nDirection)
{
    // Get the item we are changing.
    int nModelSelected, nModel, nMaxModel, nColor, nMaxColor;
    int nItemSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    object oNewItem, oNewItem2;
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    // Weapons.
    if (GetIsWeapon (oItem))
    {
        string sColumn;
        nModelSelected = GetLocalInt (oPC, "0_CRAFT_MODEL_SELECTION");
        // Get the column so we can get the max model.
        if (nModelSelected == 0) sColumn = "BottomModel";
        else if (nModelSelected == 1) sColumn = "MiddleModel";
        else if (nModelSelected == 2) sColumn = "TopModel";
        // Get the maximum model and color for the weapon.
        nMaxModel = GetItemsMaxModels (oItem, sColumn);
        nMaxColor = GetItemsMaxModels (oItem, "Color");
        // Get the model and color of the weapon model.
        nModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelSelected);
        nColor = GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected);
        // Get next/previous color.
        nColor = nColor + nDirection;
        if (nColor > nMaxColor) nColor = 1;
        else if (nColor < 1) nColor = nMaxColor;
        // If the color rolls over to a new model then change the model.
        if ((nDirection == 1 && nColor == 1) || (nDirection == -1 && nColor == nMaxColor))
        {
            // Get next/previous model.
            nModel = nModel + nDirection;
            if (nModel > nMaxModel) nModel = 1;
            else if (nModel < 1) nModel = nMaxModel;
            if (JsonGetString (NuiGetBind (oPC, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
            {
                NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
            }

            oNewItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nModelSelected, nModel, TRUE);
            // failsafe, if the item does not exist assume creation failed and don't destroy the original item
            if (GetIsObjectValid(oNewItem2))
            {
                oNewItem = CopyItemAndModify (oNewItem2, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected, nColor, TRUE);
                // another failsafe
                if (GetIsObjectValid(oNewItem))
                {
                    // only destroy the original item if it succeeds at the end of the chain
                    DestroyObject (oItem);
                }
                else
                {
                    NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model limit reached"));
                }
                // this will need to be destroyed regardless
                DestroyObject(oNewItem2);
            }
            else
            {
                NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model limit reached"));
            }
        }
        else
        {
            oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nModelSelected, nColor, TRUE);
            // failsafe, if the item does not exist assume creation failed and don't destroy the original item
            if (GetIsObjectValid(oNewItem))
            {
                DestroyObject (oItem);
            }
            else
            {
                NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model limit reached"));
            }
        }

        if (GetIsObjectValid(oNewItem))
        {
            // Item selected 3 is the right hand, 4 is the left hand.
            if (nItemSelected == 3) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_RIGHTHAND));
            else AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_LEFTHAND));
        }
    }
    // Armor.
    else if (nItemSelected == 0)
    {
        // Get the selected model.
        nModelSelected = GetArmorModelSelected (oPC);
        // Hak... due to the fact Left/Right Thigh is backwards.
        if (nModelSelected == 5) nModelSelected == 4;
        // Get if we are doing the left/right or linking both together.
        int nModelSide = GetLocalInt (oPC, "0_MODEL_SPECIAL");
        // These models only have one side so make sure we are not linked.
        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_NECK ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_BELT ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_PELVIS ||
            nModelSelected == ITEM_APPR_ARMOR_MODEL_ROBE)
        {
            nModelSide = 1;
        }
        // If we are doing the left side then add one to get the left side.
        if (nModelSide == 2) nModelSelected = nModelSelected + 1;
        nMaxModel = StringToInt (Get2DAString ("tmog_armor_parts", "NumParts", nModelSelected));
        string sPart2daName = (Get2DAString ("tmog_armor_parts", "Part_Name", nModelSelected));
        nModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected);
        // Check for changes to the torso (base part of the armor linked to AC).
        if (nModelSelected == ITEM_APPR_ARMOR_MODEL_TORSO)
        {
            int nCurrentArmorBonus = GetBaseArmorAC (oItem);
            // Get the next or previous model that has the same AC and is valid.
            nModel = nModel + nDirection;
            if (nModel > nMaxModel) nModel = 0;
            else if (nModel < 0) nModel = nMaxModel;
            string sACBonus = Get2DAString (sPart2daName, "ACBONUS", nModel);
            int nACBonus = StringToInt (sACBonus);
            while (nACBonus != nCurrentArmorBonus || sACBonus == "")
            {
                nModel = nModel + nDirection;
                if (nModel > nMaxModel) nModel = 0;
                else if (nModel < 0) nModel = nMaxModel;
                sACBonus = Get2DAString (sPart2daName, "ACBONUS", nModel);
                nACBonus = StringToInt (sACBonus);
            }
            if (JsonGetString (NuiGetBind (oPC, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
            {
                NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
            }
            // Change the model.
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModel, TRUE);
            DestroyObject (oItem);
            AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
        }
        // Change all other parts of armor.
        else
        {
            // Get the next or previous model that is valid.
            nModel = nModel + nDirection;
            if (nModel > nMaxModel) nModel = 0;
            else if (nModel < 0) nModel = nMaxModel;
            string sACBonus = Get2DAString (sPart2daName, "ACBONUS", nModel);
            while (sACBonus == "")
            {
                nModel = nModel + nDirection;
                if (nModel > nMaxModel) nModel = 0;
                else if (nModel < 0) nModel = nMaxModel;
                sACBonus = Get2DAString (sPart2daName, "ACBONUS", nModel);
            }
            if (JsonGetString (NuiGetBind (oPC, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
            {
                NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
            }
            // We set which model is selected above.
            oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected, nModel, TRUE);
            DestroyObject (oItem);
            oItem = oNewItem;
            // If linked then change the left side too.
            if (nModelSide == 0)
            {
                oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nModelSelected + 1, nModel, TRUE);
                DestroyObject (oItem);
                AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
            }
            else AssignCommand (oTarget, ActionEquipItem (oItem, INVENTORY_SLOT_CHEST));
        }
    }
    // All other items.
    else
    {
        int nSlot, nBaseItem = GetBaseItemType (oItem);
        int nMinModel = 1;
        // Get max models and inventory slot.
        if (nBaseItem == BASE_ITEM_CLOAK)
        {
            nSlot = INVENTORY_SLOT_CLOAK;
        }
        else if (nBaseItem == BASE_ITEM_HELMET)
        {
            // nMaxModel = 35;
            nSlot = INVENTORY_SLOT_HEAD;
        }
        else if (nBaseItem == BASE_ITEM_LARGESHIELD || nBaseItem == BASE_ITEM_SMALLSHIELD ||
                 nBaseItem == BASE_ITEM_TOWERSHIELD || nBaseItem == BASE_ITEM_TORCH || nBaseItem == 94) // moon on a stick
        {
            nSlot = INVENTORY_SLOT_LEFTHAND;
            // if (nBaseItem == BASE_ITEM_SMALLSHIELD) // nMaxModel = 64;
            // else if (nBaseItem == BASE_ITEM_LARGESHIELD) // nMaxModel = 163;
            // else if (nBaseItem == BASE_ITEM_TOWERSHIELD) // nMaxModel = 124;

            nMinModel == 11;
        }

        nModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
        // nModel = nModel + nDirection;
        // if (nModel > nMaxModel) nModel = 0;
        // else if (nModel < 0) nModel = nMaxModel;

        // originally coded behavior for cloaks
        if (nBaseItem == BASE_ITEM_CLOAK)
        {
            nMaxModel = 16;
            nModel = nModel + nDirection;
            if (nModel < 0) nModel = nMaxModel;
            else if (nModel > nMaxModel) nModel = 1;
        }
        else
        {
            string sModelPrefix = Get2DAString("baseitems", "DefaultIcon", nBaseItem);
            // remove the first character, as we are not retrieving icons
            sModelPrefix = GetStringRight(sModelPrefix, GetStringLength(sModelPrefix) - 1);

            ResManGetAliasFor(sModelPrefix + IntToPaddedString(nModel, 3), RESTYPE_MDL);
            // get the next available model, look up to 12 models up or down depending on the direction
            int i, nCurrentModel;
            string sAlias, sModel;
            for (i = 1; i < 13; i++)
            {
                nCurrentModel = nModel + (nDirection * i); // 1, 2, 3, or -1, -2, -3, etc...
                sModel = sModelPrefix + "_" + IntToPaddedString(nCurrentModel, 3);
                // SendDebugMessage(sModel);
                sAlias = ResManGetAliasFor(sModel, RESTYPE_MDL);

                if (sAlias != "")
                {
                    // SendDebugMessage("Model found: " + sAlias);
                    nModel = nCurrentModel;
                    break;
                }
            }

            // if we reached the end without finding a valid model, show a warning
            if (i == 12 && sAlias == "") NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model limit reached"));
        }

        if (nModel < nMinModel) nMinModel = 1;

        if (JsonGetString (NuiGetBind (oPC, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
        {
            NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
        }
        oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nModel, TRUE);
        DestroyObject (oItem);
        AssignCommand (oTarget, ActionEquipItem (oNewItem, nSlot));
    }
    return oNewItem;
}

// Checks to see if the item can be crafted.
int CanCraftItem (object oPC, object oItem, int nToken, int bPasteCheck = FALSE)
{
    if (oItem == OBJECT_INVALID)
    {
         //SendMessages ("You must have an item equiped!", COLOR_RED, oPC);
         return FALSE;
    }
    // Plot items cannot be changed.
    if (GetPlotFlag (oItem))
    {
         //SendMessages (GetName (oItem) + "is a plot item and its appearance cannot be changed!", COLOR_RED, oPC);
         return FALSE;
    }
    // Check to see if the weapon can be changed i.e. special appearances.
    if (GetIsWeapon (oItem))
    {
        int nModel = GetItemAppearance (oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP);
        int nMaxModel = GetItemsMaxModels (oItem, "TopModel");
        if (nModel > nMaxModel)
        {
            //SendMessages (GetName (oItem) + "'s special appearance cannot be changed!", COLOR_RED, oPC);
            return FALSE;
        }
    }

    // Cannot change Head_Gear as they are visual effects and not Models.
    /*
    int nItemType = GetBaseItemType (oItem);
    if (nItemType == 23) //BASE_ITEM_HEAD_GEAR
    {
        //SendMessages (GetName (oItem) + " is a visual effect item and cannot be changed!", COLOR_RED, oPC);
        return FALSE;
    }
    */

    // Cannot change temorary enchanted items.
    if (CheckForTemporaryItemProperty (oItem))
    {
        // SendMessages (GetName (oItem) + " cannot be altered while it has a temporary enchantment.", COLOR_RED, oPC);
        return FALSE;
    }

    // Do special paste checks.
    if (bPasteCheck)
    {
        int nOldItemType = GetLocalInt (oPC, "0_Craft_Item_Type");
        int nNewItemType = GetBaseItemType (oItem);
        if (GetIsWeapon (oItem))
        {
            if (nOldItemType != nNewItemType)
            {
                string sOldBaseItem = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nOldItemType)));
                string sNewBaseItem = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nNewItemType)));
                //SendMessages ("You copied a " + sOldBaseItem + " and are trying to paste to a " + sNewBaseItem + "!", COLOR_RED, oPC);
                return FALSE;
            }
        }
        // Armor.
        else if (nNewItemType == BASE_ITEM_ARMOR)
        {
            if (GetLocalInt (oPC, "0_Armor_AC") != GetBaseArmorAC (oItem))
            {
                //SendMessages ("The armor you are trying to paste to is not the same type as the copy!", COLOR_RED, oPC);
                return FALSE;
            }
        }
        else if (nOldItemType == nNewItemType)
        {
            string sOldBaseItem = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nOldItemType)));
            string sNewBaseItem = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "Name", nNewItemType)));
            //SendMessages ("You copied a " + sOldBaseItem + " and are trying to paste to a " + sNewBaseItem + "!", COLOR_RED, oPC);
            return FALSE;
        }
    }
    /*
    if (GetLocalObject (oPC, "0_ORIGINAL_CRAFT_ITEM") == OBJECT_INVALID)
    {
        object oBuildContainer = GetObjectByTag (TEMP_CHEST);
        object oBackup = CopyItem (oItem, oBuildContainer, TRUE);
        // Save the original item to the PC.
        SetLocalObject (oPC, "0_ORIGINAL_CRAFT_ITEM", oBackup);
        // Check ranks required with characters ranks.
        int nRanksRequired;
        // Armor.
        if (nItemType == BASE_ITEM_ARMOR) nRanksRequired = GetBaseArmorAC (oItem);
        // All other items.
        else nRanksRequired = StringToInt (Get2DAString ("smi_list", "CraftDC", nItemType)) - 10;
        SetLocalInt (oPC, "0_RANKS_REQUIRED", nRanksRequired);
        NuiSetBind (oPC, nToken, "craft_required_label", JsonString ("Ranks required: " + IntToString (nRanksRequired)));
        // int nRanks = GetSkillRank (SKILL_CRAFTING, oPC, TRUE);
        // Check to see if the players has enough ranks.
        // if (nRanksRequired > nRanks) NuiSetBind (oPC, nToken, "craft_warning_label", JsonString ("CANNOT CRAFT!"));
        // else NuiSetBind (oPC, nToken, "craft_warning_label", JsonString (""));
        NuiSetBind (oPC, nToken, "craft_warning_label", JsonString (""));
    }
    */
    return TRUE;
}
/*
object RandomizeItemsCraftAppearance (object oPlayer, object oTarget, int nToken, object oItem)
{
    // Get the item we are changing.
    int nModelSelected, nModel, nMaxModel, nColor, nMaxColor;
    int nItemSelected = GetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION");
    object oNewItem;
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    if (GetIsWeapon (oItem))
    {
        // Get the items quality.
        // For craft randomizing just randomize from all options!
        itemproperty ipQuality = HasProperty (oItem, 86);
        int iQuality = GetItemPropertySubType (ipQuality);
        oNewItem = ChangeItemAppearance (oItem, iQuality);
        if (nItemSelected == 3) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_RIGHTHAND));
        else if (nItemSelected == 4) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_LEFTHAND));
    }
    // Armor.
    else if (nItemSelected == 0)
    {
        object oItem1 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random (175) + 1, TRUE);
        DestroyObject (oItem);
        object oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random (175) + 1, TRUE);
        DestroyObject (oItem1);
        object oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random (175) + 1, TRUE);
        DestroyObject (oItem2);
        object oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random (175) + 1, TRUE);
        DestroyObject (oItem3);
        object oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random (175) + 1, TRUE);
        DestroyObject (oItem4);
        oNewItem = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random (175) + 1, TRUE);
        DestroyObject (oItem5);
        AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
    }
    // All other items.
    else
    {
        int nSlot, nBaseItem = GetBaseItemType (oItem);
        // Get max models and inventory slot.
        if (nBaseItem == BASE_ITEM_CLOAK)
        {
            nMaxModel = 107;
            nSlot = INVENTORY_SLOT_CLOAK;
        }
        else if (nBaseItem == BASE_ITEM_HELMET)
        {
            nMaxModel = 62;
            nSlot = INVENTORY_SLOT_HEAD;
        }
        else if (nBaseItem == BASE_ITEM_LARGESHIELD || nBaseItem == BASE_ITEM_SMALLSHIELD ||
                 nBaseItem == BASE_ITEM_TOWERSHIELD)
        {
            nSlot = INVENTORY_SLOT_LEFTHAND;
            if (nBaseItem == BASE_ITEM_SMALLSHIELD) nMaxModel = 64;
            else if (nBaseItem == BASE_ITEM_LARGESHIELD) nMaxModel = 163;
            else if (nBaseItem == BASE_ITEM_TOWERSHIELD) nMaxModel = 124;
        }
        nModel = Random (nMaxModel) + 1;
        object oItem1 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nModel, TRUE);
        DestroyObject (oItem);
        if (nBaseItem == BASE_ITEM_CLOAK || nBaseItem == BASE_ITEM_HELMET)
        {
            object oItem2 = CopyItemAndModify (oItem1, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1, Random (175) + 1, TRUE);
            DestroyObject (oItem1);
            object oItem3 = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2, Random (175) + 1, TRUE);
            DestroyObject (oItem2);
            object oItem4 = CopyItemAndModify (oItem3, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1, Random (175) + 1, TRUE);
            DestroyObject (oItem3);
            object oItem5 = CopyItemAndModify (oItem4, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2, Random (175) + 1, TRUE);
            DestroyObject (oItem4);
            object oItem6 = CopyItemAndModify (oItem5, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1, Random (175) + 1, TRUE);
            DestroyObject (oItem5);
            oNewItem = CopyItemAndModify (oItem6, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2, Random (175) + 1, TRUE);
            DestroyObject (oItem6);
        }
        else
        {
            oNewItem = oItem1;
        }
        AssignCommand (oTarget, ActionEquipItem (oNewItem, nSlot));
        if (JsonGetString (NuiGetBind (oPlayer, nToken, "craft_warning_label")) != "CANNOT CRAFT!")
        {
            NuiSetBind (oPlayer, nToken, "craft_warning_label", JsonString ("Model # " + IntToString (nModel)));
        }
    }
    return oNewItem;
}
*/
// Returns the correct item based on the crafting menu selected item.
object GetSelectedItem (object oTarget, int nItemSelected)
{
    if (nItemSelected == 0) return GetItemInSlot (INVENTORY_SLOT_CHEST, oTarget);
    else if (nItemSelected == 1) return GetItemInSlot (INVENTORY_SLOT_CLOAK, oTarget);
    else if (nItemSelected == 2) return GetItemInSlot (INVENTORY_SLOT_HEAD, oTarget);
    else if (nItemSelected == 3) return GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oTarget);
    else if (nItemSelected == 4) return GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oTarget);
    return OBJECT_INVALID;
}

// Cancels the crafted item for the player and restoring the original.
/*
void CancelCraftedItem (object oPlayer, object oTarget)
{
    int nItemSelected = GetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION");
    object oItem = GetSelectedItem (oTarget, nItemSelected);
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    DeleteLocalInt (oPlayer, "0_RANKS_REQUIRED");
    object oOriginalItem = GetLocalObject (oPlayer, "0_ORIGINAL_CRAFT_ITEM");
    if (oOriginalItem != OBJECT_INVALID)
    {
        DestroyObject (oItem);
        int nSlot = GetItemSelectedEquipSlot (nItemSelected);
        // Give item Backup to Player
        oOriginalItem = CopyItem (oOriginalItem, oTarget, TRUE);
        DelayCommand (0.2f, AssignCommand (oTarget, ActionEquipItem (oOriginalItem, nSlot)));
        DeleteLocalObject (oPlayer, "0_ORIGINAL_CRAFT_ITEM");
    }
}
*/

// Returns true if the item is a shield.
int GetIsShield (object oItem)
{
   switch (GetBaseItemType (oItem))
   {
      case BASE_ITEM_SMALLSHIELD: return TRUE;
      case BASE_ITEM_LARGESHIELD: return TRUE;
      case BASE_ITEM_TOWERSHIELD: return TRUE;
   }
   return FALSE;
 }
