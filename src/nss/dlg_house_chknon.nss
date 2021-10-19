#include "inc_housing"

int StartingConditional()
{
    if (GetIsPlayerHomeless(GetPCSpeaker()))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
