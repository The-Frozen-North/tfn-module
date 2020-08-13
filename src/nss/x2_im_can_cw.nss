//------------------------------------------------------------------------------
// Condition: Can Craft Weapons?
//------------------------------------------------------------------------------
//
// Return TRUE when
//   ... Has a valid weapon in the right hand  AND
//   ... Weapon is NOT plot                    AND
//   ... Weapon is not intelligent             AND
//   ... Weapon is not a whip or sling (1 part item)
//------------------------------------------------------------------------------
// Last Updated: Oct 24, GZ: Can no longer modify an intelligent weapon
//------------------------------------------------------------------------------
#include "x2_inc_itemprop"

int StartingConditional()
{
    object oW = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,GetPCSpeaker());
    if (!GetIsObjectValid(oW))
    {
        return FALSE;
    }
    else if (GetPlotFlag(oW))
    {
        return FALSE;
    }
    else if (GetLocalInt(GetModule(),"X2_L_DO_NOT_ALLOW_MODIFY_WEAPON") || GetLocalInt(oW,"X2_L_DO_NOT_ALLOW_MODIFY_WEAPON"))
    {
        return FALSE;//71: added missing variable check
    }
    else if (!IPGetIsMeleeWeapon(oW)&& !IPGetIsRangedWeapon(oW))
    {
        return FALSE;
    }
    else if (IPGetIsIntelligentWeapon(oW))
    {
        return FALSE;
    }
    else
    {
        if (!GetHasSkill(SKILL_CRAFT_WEAPON,GetPCSpeaker()))
        {
           return FALSE;
        }

        //----------------------------------------------------------------------
        // Can't Modify Slings or Whips
        //----------------------------------------------------------------------
        switch(GetBaseItemType(oW))
        {
            case BASE_ITEM_WHIP:
            case BASE_ITEM_SLING:
            return FALSE;
        }

    }
    return TRUE;
}
