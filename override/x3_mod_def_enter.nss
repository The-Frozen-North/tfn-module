//::///////////////////////////////////////////////
//:: Default On Enter for Module
//:: x3_mod_def_enter
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
     This script adds the horse menus to the PCs.
*/
//:://////////////////////////////////////////////
//:: Created By: Deva B. Winblood
//:: Created On: Dec 30th, 2007
//:: Last Update: April 21th, 2008
//:://////////////////////////////////////////////

#include "x3_inc_horse"

void main()
{
    object oPC=GetEnteringObject();
    ExecuteScript("x3_mod_pre_enter",OBJECT_SELF); // Override for other skin systems
    if(HorseGetIsMounted(oPC) && !GetLocalInt(oPC,"bX3_HORSE_MODIFIERS"))//1.72: player lost horse related effects, recreate them
    {
        SetLocalInt(oPC,"nX3_RiderHP",GetCurrentHitPoints(oPC));
        HORSE_SupportIncreaseSpeed(oPC,OBJECT_INVALID);
        HORSE_SupportAdjustMountedArcheryPenalty(oPC);
        HORSE_SupportApplyMountedSkillDecreases(oPC);
        if (GetLocalInt(OBJECT_SELF,"X3_ENABLE_MOUNT_DB")) SetLocalInt(oPC,"bX3_STORE_MOUNT_INFO",TRUE);
        SetLocalInt(oPC,"bX3_HORSE_MODIFIERS",TRUE);
    }
    if ((GetIsPC(oPC)||GetIsDM(oPC))&&!GetHasFeat(FEAT_HORSE_MENU,oPC))
    { // add horse menu
        HorseAddHorseMenu(oPC);
        if (GetLocalInt(GetModule(),"X3_ENABLE_MOUNT_DB"))
        { // restore PC horse status from database
            DelayCommand(2.0,HorseReloadFromDatabase(oPC,X3_HORSE_DATABASE));
        } // restore PC horse status from database
    } // add horse menu
    if (GetIsPC(oPC) && !GetHasEffect(EFFECT_TYPE_POLYMORPH,oPC))//1.71: fix for changing polymorph appearance
    { // more details
        // restore appearance in case you export your character in mounted form, etc.
        if (!GetSkinInt(oPC,"bX3_IS_MOUNTED")) HorseIfNotDefaultAppearanceChange(oPC);
        // pre-cache horse animations for player as attaching a tail to the model
        HorsePreloadAnimations(oPC);
        DelayCommand(3.0,HorseRestoreHenchmenLocations(oPC));
    } // more details
}
