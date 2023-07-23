#include "inc_henchman"

void main()
{

    object oPC = GetPCSpeaker();
    if (GetHenchmanCount(oPC) == 0)
    {
        IncrementPlayerStatistic(oPC, "henchman_recruited");
        SetMaster(OBJECT_SELF, oPC);
    }
}
