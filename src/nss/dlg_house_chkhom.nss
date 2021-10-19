#include "inc_housing"

int StartingConditional()
{
    if (GetIsPlayerHomeless(GetPCSpeaker()))
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}
