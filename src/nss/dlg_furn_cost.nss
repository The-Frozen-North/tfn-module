#include "inc_ctoken"

int StartingConditional()
{
    int nCost = GetMaxHitPoints(OBJECT_SELF);

    SetCustomToken(CTOKEN_PLACEABLE_PRICE, IntToString(nCost));

    return TRUE;
}
