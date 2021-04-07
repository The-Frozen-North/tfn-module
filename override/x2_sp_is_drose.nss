//::///////////////////////////////////////////////
//:: Name x2_sp_is_drose
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Ioun Stone Power: Dusty Rose
    Gives the user 1 hours worth of +1 AC bonus,
    Deflection
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
- AC class changed to dodge
- script rewrited a bit to use constants/be more efficient
*/


#include "x2_inc_switches"

void main()
{
    ExecuteScript("70_s3_iounstone",OBJECT_SELF);
}
