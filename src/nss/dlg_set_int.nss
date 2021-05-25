#include "inc_sql"

void main()
{
    int nInt = StringToInt(GetScriptParam("value"));
    string sName = GetScriptParam("name");

    if (nInt == 0)
        return;

    if (sName == "")
        return;

    SQLocalsPlayer_SetInt(GetPCSpeaker(), sName, nInt);
}
