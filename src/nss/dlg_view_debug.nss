#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        AssignCommand(oPC, ActionExamine(GetObjectByTag("_debug")));
    }
}
