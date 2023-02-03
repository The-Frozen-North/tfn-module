#include "nwnx_player"

void main()
{
    object oPC = GetLastUsedBy();

    if (!GetIsPC(oPC)) return;

    NWNX_Player_ForcePlaceableExamineWindow(oPC, GetLocalObject(OBJECT_SELF, "examine"));
}
