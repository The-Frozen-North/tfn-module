//::///////////////////////////////////////////////
//:: Default: On Rested
//:: NW_C2_DEFAULTA
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    after having just rested.
*/
//:://////////////////////////////////////////////
//:: Created By: Don Moar
//:: Created On: April 28, 2002
//:://////////////////////////////////////////////
#include "nw_i0_generic"

void main()
{
     SetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY, TRUE);
     DeleteLocalInt(OBJECT_SELF, "rest");
}
