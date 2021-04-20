#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        GiveGoldToCreature(oPC, 100000);
    }
}
