//:://////////////////////////////////////////////////
//:: X0_D2_HEN_INTER17
//:: Copyright (c) 2003 BioWare
//:://////////////////////////////////////////////////
/*
Does the henchman have this interjection set to say.
 */
//:://////////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: August 2003
//:://////////////////////////////////////////////////

#include "x0_i0_henchman"

int StartingConditional()
{
    if (GetInterjectionSet(GetPCSpeaker()) == 17     )
        return TRUE;
    return FALSE;
}