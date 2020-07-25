#include "1_inc_persist"
#include "x3_inc_string"

void main()
{
    object oPC = GetPCSpeaker();

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"dlg_talked_"+StringReplace(GetName(OBJECT_SELF), " ", "_"), 1, -1.0);
}
