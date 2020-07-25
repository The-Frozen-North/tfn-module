#include "1_inc_debug"
#include "1_inc_treasure"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        OpenStore(GetObjectByTag(TREASURE_DISTRIBUTION), oPC);
    }
}
