//////////////////////////////////////////////////////////
/*
   Item Appearance Modification Conversation
   Cancel Conversation Script
*/
// created/updated 2003-06-24 Georg Zoeller, Bioware Corp
//////////////////////////////////////////////////////////
/*
Patch 1.72
- fixed loss of undroppable/cursed flag
Patch 1.71
- duped item is stripped from all its itemproperties, set as stolen and set for being destroyed
by x2_mod_def_aqu script
*/

#include "x2_inc_craft"
void main()
{
   object oPC =   GetPCSpeaker(); //GetLocalObject(OBJECT_SELF, "X2_TAILOR_OBJ");
   if (CIGetCurrentModMode(GetPCSpeaker()) != X2_CI_MODMODE_INVALID )
   {
        int valid = GetIsObjectValid(oPC);

        object oBackup =    CIGetCurrentModBackup(oPC);
        object oItem  = CIGetCurrentModItem(oPC);
        itemproperty ip = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ip))
        {
            RemoveItemProperty(oItem,ip);
            ip = GetNextItemProperty(oItem);
        }
        AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyLimitUseByClass(20),oItem);
        SetLocalInt(oItem,"DUPLICATED_ITEM",TRUE);
        SetDescription(oItem,"This item was duped!");
        SetStolenFlag(oItem,TRUE);
        //SetItemCursedFlag(oItem,TRUE);

        DeleteLocalInt(oPC,"X2_TAILOR_CURRENT_COST");
        DeleteLocalInt(oPC,"X2_TAILOR_CURRENT_DC");

        //Give Backup to Player
        object oNew = CopyItem(oBackup, oPC,TRUE);
        SetItemCursedFlag(oNew,GetItemCursedFlag(oBackup));
        DestroyObject(oItem);
        DestroyObject(oBackup);

        AssignCommand(oPC,ClearAllActions(TRUE));
        if (CIGetCurrentModMode(oPC) == X2_CI_MODMODE_ARMOR)
        {
               AssignCommand(oPC, ActionEquipItem(oNew,INVENTORY_SLOT_CHEST));
        }
        else if (CIGetCurrentModMode(oPC) == X2_CI_MODMODE_WEAPON)
        {
               AssignCommand(oPC, ActionEquipItem(oNew,INVENTORY_SLOT_RIGHTHAND));
        }
        CISetCurrentModMode(oPC,X2_CI_MODMODE_INVALID );
    }
    else
    {
       ClearAllActions();
    }

    // Remove custscene immobilize from player
    effect eEff = GetFirstEffect(oPC);
    while (GetIsEffectValid(eEff))
    {
         if (GetEffectType(eEff) == EFFECT_TYPE_CUTSCENEIMMOBILIZE
             && GetEffectCreator(eEff) == oPC
             && GetEffectSubType(eEff) == SUBTYPE_EXTRAORDINARY )
         {
            RemoveEffect(oPC,eEff);
         }
         eEff = GetNextEffect(oPC);
     }

    RestoreCameraFacing();
}
