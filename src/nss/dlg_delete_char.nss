#include "nwnx_admin"

void main()
{
    object oPC = GetPCSpeaker();
    string sPlayerName = GetPCPlayerName (oPC);
    string sName = GetName(oPC);

    NWNX_Administration_DeletePlayerCharacter(oPC);
    NWNX_Administration_DeleteTURD(sPlayerName, sName);
}
