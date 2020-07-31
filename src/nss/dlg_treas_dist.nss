#include "inc_debug"
#include "inc_treasure"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        OpenStore(GetObjectByTag(TREASURE_DISTRIBUTION), oPC);
    }
}
