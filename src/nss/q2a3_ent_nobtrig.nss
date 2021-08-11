//::///////////////////////////////////////////////
//:: Name q2a3_ent_nobtrig
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    PC enters trigger which causes conversation between
    the two hostile sets of nobles and the PC
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: August 27/03
//:://////////////////////////////////////////////
void Talk(string sConvFile, object oTalkTo);
void main()
{
    if (GetLocalInt(OBJECT_SELF, "nTriggered") == 1)
        return;

    object oPC = GetEnteringObject();
    if (GetIsDM(oPC) == TRUE)
        return;
    if (GetIsPC(oPC) == FALSE)
        return;

    SetLocalInt(OBJECT_SELF, "nTriggered", 1);
    object oNoble1 = GetObjectByTag("q2a3evilguard1");
    //AssignCommand(oNoble1, ActionDoCommand(BeginConversation("q2a3barfight")));
    AssignCommand(oNoble1, Talk("q2a3barfight", oPC));
}

// Helper function
void Talk(string sConvFile, object oTalkTo)
{
    BeginConversation(sConvFile, oTalkTo);
}
