//::///////////////////////////////////////////////
//:: Name q2a_ud_rebtrn2
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Rebel Training Soldier User Defined
    Attack combat dummy if PC is in the house
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Sept 23/03
//:://////////////////////////////////////////////

void main()
{
    if (GetAILevel(OBJECT_SELF) == AI_LEVEL_VERY_LOW)
        return;

    //if Not obstructed by a PC - fire at target - else yell
    object oTarget = GetObjectByTag("q2arebdummy");
    ActionAttack(oTarget);




    DelayCommand(4.0 + IntToFloat(Random(4)), SignalEvent(OBJECT_SELF, EventUserDefined(99)));
}
