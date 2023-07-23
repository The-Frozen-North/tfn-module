#include "inc_henchman"

void main()
{

    object oPC = GetPCSpeaker();
    if (GetHenchmanCount(oPC) == 0)
    {
        IncrementStat(oPC, "henchman_recruited");
        SetMaster(OBJECT_SELF, oPC);
    }
}
