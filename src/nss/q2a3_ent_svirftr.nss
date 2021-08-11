//::///////////////////////////////////////////////
//:: Name q2a3_ent_svirftrg
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    PC enters trigger which causes conversation between
    the two evil drow and the svirf slave
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
    //Get an invisible object to Talk - so conversation doesn't break
    //when one side or the other leaves
    object oTalker = GetObjectByTag("q2a3svirftalk");
    AssignCommand(oTalker, Talk("q2a3svirfdrink", oPC));

}

// Helper function
void Talk(string sConvFile, object oTalkTo)
{
    BeginConversation(sConvFile, oTalkTo);
}
