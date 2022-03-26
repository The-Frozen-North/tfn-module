//::///////////////////////////////////////////////
//:: High AI default OnSpawn script
//:: 70_c2_aihigh9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script will set the AI level of creature to AI_LEVEL_HIGH. That will enable the
1.70 AI feature of handling Black Blade of Disaster. A creature will either try to dispell
it, if she have a dismissal or mordenkainen's disjunction spell, or ignore and focus on
other targets (unless there are no other targets).
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 07-11-2011
//:://////////////////////////////////////////////

void main()
{
    SetAILevel(OBJECT_SELF, AI_LEVEL_HIGH);
    // Execute xp2 OnSpawn script.
    ExecuteScript("x2_def_spawn", OBJECT_SELF);
}
