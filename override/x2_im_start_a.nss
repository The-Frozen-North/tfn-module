/*
Patch 1.72
- fixed loss of undroppable/cursed flag
Patch 1.71
- fixed light not being properly removed
- fixed loss of local variables
*/
#include "x2_inc_craft"
void main()
{

    StoreCameraFacing();

    object oPC = GetPCSpeaker();

    // * Make the camera float near the PC
    float fFacing  = GetFacing(oPC) + 180.0;
    if (fFacing > 359.0)
    {
        fFacing -=359.0;
    }
    SetCameraFacing(fFacing, 3.5f, 75.0,CAMERA_TRANSITION_TYPE_FAST ) ;

    CISetCurrentModMode(GetPCSpeaker(),X2_CI_MODMODE_ARMOR );
    SetCustomToken(X2_CI_MODIFYARMOR_GP_CTOKENBASE,"0");
    SetCustomToken(X2_CI_MODIFYARMOR_GP_CTOKENBASE+1,"0");

    object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    object oBackup = CopyItem(oItem,IPGetIPWorkContainer(),TRUE);
    SetItemCursedFlag(oBackup,GetItemCursedFlag(oItem));
    CISetCurrentModBackup(oPC, oBackup);
    CISetCurrentModItem(oPC, oItem);

    //* TODO: Light model to make changes easier to see
    effect eLight = EffectVisualEffect( VFX_DUR_LIGHT_WHITE_20);

    //* Immobilize player while crafting
    effect eImmob = EffectLinkEffects(EffectCutsceneImmobilize(),eLight);
    eImmob = ExtraordinaryEffect(eImmob);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT,eImmob,oPC);
}
