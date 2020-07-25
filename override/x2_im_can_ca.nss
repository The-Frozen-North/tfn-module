#include "x2_inc_itemprop"

int StartingConditional()
{
    object oA = GetItemInSlot(INVENTORY_SLOT_CHEST,GetPCSpeaker());
    if (!GetIsObjectValid(oA))
    {
        return FALSE;
    }
    else if (GetPlotFlag(oA))
    {
        return FALSE;
    }
    else if (GetLocalInt(GetModule(),"X2_L_DO_NOT_ALLOW_MODIFY_ARMOR") || GetLocalInt(oA,"X2_L_DO_NOT_ALLOW_MODIFY_ARMOR"))
    {
        return FALSE;//71: added missing variable check
    }
    else if (!GetHasSkill(SKILL_CRAFT_ARMOR,GetPCSpeaker()))
    {
       return FALSE;
    }
    return TRUE;
}
