#include "x0_inc_henai"

int StartingConditional()
{
    if(!GetAssociateState(NW_ASC_USE_RANGED_WEAPON))
    {
        return TRUE;
    }
    return FALSE;
}
