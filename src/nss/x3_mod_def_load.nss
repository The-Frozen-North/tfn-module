//::///////////////////////////////////////////////
//:: Example XP3 OnLoad Script
//:: x3_mod_def_load
//:: (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Put into: OnModuleLoad Event

    This example script demonstrates how to tweak the
    behavior of several subsystems in your module.

    For more information, please check x2_inc_switches
    which holds definitions for several variables that
    can be set on modules, creatures, doors or waypoints
    to change the default behavior of Bioware scripts.

    Warning:
    Using some of these switches may change your games
    balancing and may introduce bugs or instabilities. We
    recommend that you only use these switches if you
    know what you are doing. Consider these features
    unsupported!

    Please do NOT report any bugs you experience while
    these switches have been changed from their default
    positions.

    Make sure you visit the forums at nwn.bioware.com
    to find out more about these scripts.

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-16
//:://////////////////////////////////////////////
/*
     Example settings for horses at the bottom.
*/
//:://////////////////////////////////////////////
//:: Updated By: Azbest
//:: Last Update: April 18th, 2008
//:://////////////////////////////////////////////

void main()
{
    //1.72: call default script instead of copy&paste everything from it here
    ExecuteScript("x2_mod_def_load",OBJECT_SELF);

    // * In the following section there are examples for setting various options
    // * in horse package. For more information look in the "x3_inc_horse".

    // * Ignores terrain height differencies while deciding whether to play mounting
    // * animation or not (if the elevation difference between rider and horse in
    // * hilly terrain is large, clipping occurs and the rider animates either above
    // * the horse or sinks in the horse during animation, which may look funny).
    SetLocalInt(GetModule(),"bX3_MOUNT_NO_ZAXIS",TRUE);

    // * This tells how long you have left in seconds before you will be force-mounted
    // * if you got stuck while moving to horse in mounting procedure, unless you
    // * are using X3_HORSE_ACT_VS_DELAY method, where you can interrupt your movement
    // * before reaching the mounting spot.
    //SetLocalFloat(GetModule(),"fX3_TIMEOUT_TO_MOUNT",12.0f);

    // * Once per fX3_FREQUENCY (default = 1.0s) seconds character will retry to
    // * get on the right path when moving to horse in case he gets stuck or
    // * something makes him temporarily stuck, if he doesnt get to horse in
    // * fX3_TIMEOUT_TO_MOUNT seconds, he is forced to mount.
    //SetLocalFloat(GetModule(),"fX3_FREQUENCY",2.0);

    // * Use this if you want characters to be able to interrupt the mounting
    // * procedure before they get to the horse (ie. by clicking on the ground).
    //SetLocalInt(GetModule(),"X3_HORSE_ACT_VS_DELAY",TRUE);

    // * Use horse's inventory as a storage for saddlebag content.
    //SetLocalInt(GetModule(),"X3_HORSE_ENABLE_SADDLEBAGS",TRUE);

    // * Dont forget to place the storage waypoint for this to work!
    //SetLocalString(GetModule(),"X3_SADDLEBAG_DATABASE","NAME");

    // * Doesnt apply speed bonus when mounted.
    //SetLocalInt(GetModule(),"X3_HORSE_DISABLE_SPEED",TRUE);

    // * Mounts are allowed in exterior areas only.
    //SetLocalInt(GetModule(),"X3_MOUNTS_EXTERNAL_ONLY",TRUE);

    // * No horses are allowed underground.
    //SetLocalInt(GetModule(),"X3_MOUNTS_NO_UNDERGROUND",TRUE);

    // * Possible trouble-shoot for situation when players would be left in an
    // * uncommandable state (it should never happen however)
    //SetLocalInt(GetModule(),"X3_NO_MOUNT_COMMANDABLE",TRUE);
}
