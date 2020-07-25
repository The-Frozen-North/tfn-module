#include "1_inc_follower"

int StartingConditional()
{
    if (GetFollowerCount(GetPCSpeaker()) == 0)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }

}
