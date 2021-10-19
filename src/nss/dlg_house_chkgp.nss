#include "inc_housing"

int StartingConditional()
{
    if (GetGold(GetPCSpeaker()) >= StringToInt(GetScriptParam("gold")))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
