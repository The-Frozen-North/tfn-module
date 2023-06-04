/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_window
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Menu event script
    sEvent: close, click, mousedown, mouseup, watch (if bindwatch is set).
/*//////////////////////////////////////////////////////////////////////////////
#include "tmog_inc_layout"

// Locks/Unlocks specific buttons when an item has been changed.
/*
void LockItemInCraftingWindow (object oPlayer, object oItem, int nToken)
{
    NuiSetBind (oPlayer, nToken, "btn_copy", JsonBool (FALSE));
    NuiSetBind (oPlayer, nToken, "btn_copy_event", JsonBool (FALSE));
    SetLocalInt (oPlayer, "0_COPY_ITEM", FALSE);
    NuiSetBind (oPlayer, nToken, "item_combo_event", JsonBool (FALSE));
    SetLocalInt (oItem, "0_EQUIP_LOCKED", TRUE);
    NuiSetBind (oPlayer, nToken, "btn_cancel_label", JsonString ("Cancel"));

    // NO SKILL CHECKS NEEDED!
    // Check to see if the players has enough ranks.
    //int nRanks = GetSkillRank (SKILL_CRAFTING, oPlayer, TRUE);
    //int nRanksRequired = GetLocalInt (oPlayer, "0_RANKS_REQUIRED");
    //if (nRanksRequired > nRanks) NuiSetBind (oPlayer, nToken, "btn_save_event", JsonBool (FALSE));
    //else NuiSetBind (oPlayer, nToken, "btn_save_event", JsonBool (TRUE));

    NuiSetBind (oPlayer, nToken, "btn_save_event", JsonBool (TRUE));
}


// Locks/Unlocks specific buttons when an item has been cleared.
void ClearItemInCraftingWindow (object oPlayer, object oItem, int nToken)
{
    NuiSetBind (oPlayer, nToken, "btn_copy_event", JsonBool (TRUE));
    NuiSetBind (oPlayer, nToken, "btn_paste_event", JsonBool (FALSE));
    NuiSetBind (oPlayer, nToken, "btn_save_event", JsonBool (FALSE));
    NuiSetBind (oPlayer, nToken, "item_combo_event", JsonBool (TRUE));
    SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
    NuiSetBind (oPlayer, nToken, "btn_cancel_label", JsonString ("Exit"));
}
*/

// Change the button or item based on this buttons special function.
void DoSpecialButton (object oPlayer, object oItem, int nToken)
{
     int nItemSelected = GetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION");
     int nSpecial = GetLocalInt (oPlayer, "0_MODEL_SPECIAL") + 1;
     // Change button for armor (Left/Right/Linked).
     if (nItemSelected == 0)
     {
         if (nSpecial > 2) nSpecial = 0;
         if (nSpecial == 0) NuiSetBind (oPlayer, nToken, "btn_special_label", JsonString ("Left/Right Linked"));
         else if (nSpecial == 1) NuiSetBind (oPlayer, nToken, "btn_special_label", JsonString ("Right Model"));
         else NuiSetBind (oPlayer, nToken, "btn_special_label", JsonString ("Left Model"));
         SetLocalInt (oPlayer, "0_MODEL_SPECIAL", nSpecial);
         NuiSetBind (oPlayer, nToken, "btn_special_event", JsonBool (TRUE));
    }
    // Change button for cloak/helmets.
    else if (nItemSelected == 1 || nItemSelected == 2)
    {
        // Get the item to be visible/hidden.
        // Get the items state and set.
        int nHidden = GetHiddenWhenEquipped (oItem);
        if (nHidden)
        {
            SetLocalInt (oPlayer, "0_MODEL_SPECIAL", 3);
            NuiSetBind (oPlayer, nToken, "btn_special_label", JsonString ("Model Visible"));
            SetHiddenWhenEquipped (oItem, FALSE);
        }
        else
        {
            SetLocalInt (oPlayer, "0_MODEL_SPECIAL", 4);
            NuiSetBind (oPlayer, nToken, "btn_special_label", JsonString ("Model Hidden"));
            SetHiddenWhenEquipped (oItem, TRUE);
        }
        // LockItemInCraftingWindow (oPlayer, oItem, nToken);
        NuiSetBind (oPlayer, nToken, "btn_special_event", JsonBool (TRUE));
    }
}

// Saves the crafted item for the player removing the original.
/*
void SaveCraftedItem (object oPlayer, object oTarget, int nToken)
{
    int nItemSelected = GetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION");
    object oItem = GetSelectedItem (oTarget, nItemSelected);
    ClearItemInCraftingWindow (oPlayer, oItem, nToken);
    DestroyObject (GetLocalObject (oPlayer, "0_ORIGINAL_CRAFT_ITEM"));
    DeleteLocalObject (oPlayer, "0_ORIGINAL_CRAFT_ITEM");
    DeleteLocalInt (oPlayer, "0_RANKS_REQUIRED");
}
*/

void main()
{

    // Let the inspector handle what it wants.
    //HandleWindowInspectorEvent ();
    object oPlayer = NuiGetEventPlayer();
    int    nToken  = NuiGetEventWindow();
    string sEvent  = NuiGetEventType();
    string sElem   = NuiGetEventElement();
    int    nIdx    = NuiGetEventArrayIndex();
    string sWndId  = NuiGetWindowId (oPlayer, nToken);
    int bNumberRolls;

    if (sWndId == "plcraftwin")
    {
        // Delay crafting so it has time to equip and unequip as well as remove.
        if (GetLocalInt (oPlayer, "0_CRAFT_COOL_DOWN")) return;
        SetLocalInt (oPlayer, "0_CRAFT_COOL_DOWN", TRUE);
        DelayCommand (0.25f, DeleteLocalInt (oPlayer, "0_CRAFT_COOL_DOWN"));

        // Check if we are a DM then use our target.
        // object oTarget;
        // if (GetIsDM (oPlayer) || GetIsDMPossessed (oPlayer)) oTarget = GetLocalObject (oPlayer, "0_DM_Target");
        // else oTarget = oPlayer

        object oTarget = oPlayer;

        // Get the item we are crafting.
        int nItemSelected = GetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION");
        object oItem = GetSelectedItem (oTarget, nItemSelected);
        // They have selected a color.
        if (sEvent == "mousedown" && sElem == "color_pallet")
        {
            // Get the color they selected from the color pallet cell.
            int nColorId = GetColorPalletId (oPlayer);
            if (!GetIsWeapon (oItem) && !GetIsShield (oItem))
            {
                if (CanCraftItem (oPlayer, oItem, nToken))
                {
                    int nMaterialSelected = GetLocalInt (oPlayer, "0_CRAFT_MATERIAL_SELECTION");

                    // Unlock the item so we can swap the old for the new.
                    // SetLocalInt (oItem, "0_EQUIP_LOCKED", FALSE);
                    HideFeedbackForCraftText (oPlayer, TRUE);
                    object oNewItem = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nMaterialSelected, nColorId, TRUE);
                    DestroyObject (oItem);

                    // Lock the new item so they can't change it on the character.
                    // LockItemInCraftingWindow (oPlayer, oNewItem, nToken);

                    // Equip new item.
                    int iBaseItem = GetBaseItemType (oNewItem);
                    if (iBaseItem == BASE_ITEM_CLOAK) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CLOAK));
                    else if (iBaseItem == BASE_ITEM_HELMET) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_HEAD));
                    else if (iBaseItem == BASE_ITEM_ARMOR) AssignCommand (oTarget, ActionEquipItem (oNewItem, INVENTORY_SLOT_CHEST));
                    HideFeedbackForCraftText (oPlayer, FALSE);
                }
            }
        }
        // The player is changing the item they are crafting.
        if (sEvent == "watch" && sElem == "item_combo_selected")
        {
            int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
            SetLocalInt (oPlayer, "0_CRAFT_ITEM_SELECTION", nSelected);
            // Set special option.
            if (nSelected == 0)
            {
                int nSpecial = GetLocalInt (oPlayer, "0_MODEL_SPECIAL");
                if (nSpecial > 2) nSpecial = 0;
                SetLocalInt (oPlayer, "0_MODEL_SPECIAL", nSpecial);
            }
            // Set button for cloak and helms.
            else if (nSelected == 1 || nSelected == 2)
            {
                int nHidden = GetHiddenWhenEquipped (oItem);
                if (nHidden) SetLocalInt (oPlayer, "0_MODEL_SPECIAL", 4);
                else SetLocalInt (oPlayer, "0_MODEL_SPECIAL", 3);
            }

            // Remove any copy.
            // SetLocalInt (oPlayer, "0_COPY_ITEM", FALSE);

            NuiDestroy (oPlayer, nToken);
            PopUpCraftingGUIPanel (oPlayer);
        }
        // They have selected a part to change.
        else if (sEvent == "watch" && sElem == "model_combo_selected")
        {
            int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
            SetLocalInt (oPlayer, "0_CRAFT_MODEL_SELECTION", nSelected);
        }
        // They have changed the material (color item) for the item.
        else if (sEvent == "watch" && sElem == "material_combo_selected")
        {
            int nSelected = JsonGetInt (NuiGetBind (oPlayer, nToken, sElem));
            SetLocalInt (oPlayer, "0_CRAFT_MATERIAL_SELECTION", nSelected);
            // Change the pallet for the correct material.

            string sColorPallet;
            if (nSelected == 0 || nSelected == 1) sColorPallet = "cloth_pallet";
            else if (nSelected == 2 || nSelected == 3) sColorPallet = "leather_pallet";
            else sColorPallet = "armor_pallet";
            NuiSetBind (oPlayer, nToken, "color_pallet_image", JsonString (sColorPallet));
        }

        // copying/randomizing isn't supported atm
        /*
        // Copy the item they have selected.
        else if (sEvent == "click" && sElem == "btn_copy")
        {
            if (!GetLocalInt (oPlayer, "0_COPY_ITEM"))
            {
                CopyCraftingItem (oPlayer, oItem);
                NuiSetBind (oPlayer, nToken, "btn_paste_event", JsonBool (TRUE));
                SetLocalInt (oPlayer, "0_COPY_ITEM", TRUE);
            }
            NuiSetBind (oPlayer, nToken, "btn_copy", JsonBool (TRUE));
        }
        // Paste the copy item with the current item.
        else if (sEvent == "click" && sElem == "btn_paste")
        {
            if (CanCraftItem (oPlayer, oItem, nToken, TRUE))
            {
                oItem = PasteCraftingItem (oPlayer, oTarget, oItem);
                //LockItemInCraftingWindow (oPlayer, oItem, nToken);
                NuiSetBind (oPlayer, nToken, "btn_paste_event", JsonBool (FALSE));
            }
        }
        // Random button to change items looks randomly.
        else if (sEvent == "click" && sElem == "btn_rand")
        {
            if (CanCraftItem (oPlayer, oItem, nToken))
            {
                oItem = RandomizeItemsCraftAppearance (oPlayer, oTarget, nToken, oItem);
                //LockItemInCraftingWindow (oPlayer, oItem, nToken);
            }
        }
        */

        // Get the previous model of the selected item.
        else if (sEvent == "click" && sElem == "btn_prev")
        {
            if (CanCraftItem (oPlayer, oItem, nToken))
            {
                HideFeedbackForCraftText (oPlayer, TRUE);
                oItem = ChangeItemsAppearance (oPlayer, oTarget, nToken, oItem, -1);
                HideFeedbackForCraftText (oPlayer, FALSE);
                // LockItemInCraftingWindow (oPlayer, oItem, nToken);
            }
        }
        // Get the next model of the selected item.
        else if (sEvent == "click" && sElem == "btn_next")
        {
            if (CanCraftItem (oPlayer, oItem, nToken))
            {
                HideFeedbackForCraftText (oPlayer, TRUE);
                oItem = ChangeItemsAppearance (oPlayer, oTarget, nToken, oItem, 1);
                HideFeedbackForCraftText (oPlayer, FALSE);
                // LockItemInCraftingWindow (oPlayer, oItem, nToken);
            }
        }

        // no need to save
        /*
        // Save any changes made to the selected item.
        else if (sEvent == "click" && sElem == "btn_save")
        {
            //SaveCraftedItem (oPlayer, oTarget, nToken);
        }
        */

        // Do a specific tast based on selected item.
        // i.e. Left/Right/Link and disappear/visible.
        else if (sEvent == "click" && sElem == "btn_special")
        {
            if (CanCraftItem (oPlayer, oItem, nToken)) DoSpecialButton (oPlayer, oItem, nToken);
        }

        /* no need to cancel
        // Cancel any changes made to the selected item.
        else if (sEvent == "click" && sElem == "btn_cancel")
        {
            // If the button is on cancel then clear the item.
            if (JsonGetString (NuiGetBind (oPlayer, nToken, "btn_cancel_label")) == "Cancel")
            {
                CancelCraftedItem (oPlayer, oTarget);
                //ClearItemInCraftingWindow (oPlayer, oItem, nToken);
            }
            // If the button is on Exit not Cancel then exit.
            else
            {
                AssignCommand (oPlayer, RestoreCameraFacing());
                //RemoveTagedEffects (oPlayer, "0_FREEZE_CRAFTING");
                NuiDestroy (oPlayer, nToken);
            }
        }
        */
    }
}
