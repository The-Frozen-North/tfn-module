// Set a PC BIC db-stored int variable int on the PC
// "var" - variable to check
// "value" - what to set it to

#include "inc_persist"

void main()
{
    SQLocalsPlayer_SetInt(GetPCSpeaker(), GetScriptParam("var"), StringToInt(GetScriptParam("value")));
}
