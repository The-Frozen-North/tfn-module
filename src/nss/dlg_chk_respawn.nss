#include "inc_sql"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (SQLocalsPlayer_GetString(GetPCSpeaker(), "respawn") ==  GetScriptParam("respawn"))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
