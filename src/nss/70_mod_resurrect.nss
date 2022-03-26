//::///////////////////////////////////////////////
//:: Community Patch OnResurrect event script
//:: 70_mod_resurrect
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Serves primarily as an easy way to enforce persistency, add extra effects,
penalties or whatever.

Fires after target is resurrected, to prevent resurrect to happen you need to use
spellhook.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 28-12-2015
//:://////////////////////////////////////////////

void main()
{
    //declare major variables
    object oCaster = OBJECT_SELF;
    object oTarget = GetLocalObject(oCaster,"SPELL_TARGET_OVERRIDE");
    if(!GetIsObjectValid(oTarget)) oTarget = GetSpellTargetObject();

    //do something
}
