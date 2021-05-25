#include "inc_sql"

int StartingConditional()
{
    int nInt = StringToInt(GetScriptParam("value"));
    string sName = GetScriptParam("name");

    if (nInt == 0)
        return FALSE;

    if (sName == "")
        return FALSE;

    if (SQLocalsPlayer_GetInt(GetPCSpeaker(), sName) == nInt)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
