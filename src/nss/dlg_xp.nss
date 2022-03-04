#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        GiveXPToCreature(oPC, 100000);
    }
}
