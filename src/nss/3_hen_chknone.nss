#include "1_inc_henchman"

int StartingConditional()
{
    if (GetHenchmanCount(GetPCSpeaker()) == 0)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }

}
