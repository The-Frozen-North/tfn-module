#include "inc_henchman"

void main()
{
    object oPlayer = GetPCSpeaker();

    IncrementPlayerStatistic(oPlayer, "henchman_recruited");
    SetMaster(OBJECT_SELF, oPlayer);

    ForceRest(OBJECT_SELF);
}
