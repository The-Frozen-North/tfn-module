#include "1_inc_henchman"

void main()
{

    object oPC = GetPCSpeaker();
    if (GetHenchmanCount(oPC) == 0) SetMaster(OBJECT_SELF, oPC);
}
