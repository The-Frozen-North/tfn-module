#include "inc_housing"

int StartingConditional()
{
    if (GetIsPlayerHomeless(GetPCSpeaker())) return TRUE;

    return FALSE;
}
