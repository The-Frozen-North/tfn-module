//::///////////////////////////////////////////////
//:: Name q2a2_oncon_train
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On Conversation script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////

void main()
{
   /* ClearAllActions(TRUE);
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    DelayCommand(0.2, ActionStartConversation(oPC));
    */
    ExecuteScript("nw_c2_default4", OBJECT_SELF);
}
