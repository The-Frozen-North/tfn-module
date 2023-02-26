// Check for a PC BIC db-stored int variable int on the PC
// "var" - variable to check

#include "inc_persist"

int StartingConditional()
{
    int nVar = SQLocalsPlayer_GetInt(GetPCSpeaker(), GetScriptParam("var"));
    if (nVar)
    {
        return 1;
    }
    return 0;
}
