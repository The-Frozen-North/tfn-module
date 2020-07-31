#include "inc_henchman"

void main()
{
    object oPlayer = GetPCSpeaker();

    SetMaster(OBJECT_SELF, oPlayer);
}
