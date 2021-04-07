//::///////////////////////////////////////////////
//:: Name x2_sp_is_dred
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Ioun Stone Power: Deep Red
    Gives the user 1 hours worth of +2 Dexterity bonus.
    Cancels any other Ioun stone powers in effect
    on the PC.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Dec 13/02
//:://////////////////////////////////////////////
/*
Patch 1.72
- no longer dispellable
Patch 1.70
- script rewrited a bit to use constants/be more efficient
*/

void main()
{
    ExecuteScript("70_s3_iounstone",OBJECT_SELF);
}
