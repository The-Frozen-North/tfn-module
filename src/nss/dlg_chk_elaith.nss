#include "inc_sql"

int StartingConditional()
{
    if (SQLocalsPlayer_GetInt(GetPCSpeaker(), "elaith") == 1)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
