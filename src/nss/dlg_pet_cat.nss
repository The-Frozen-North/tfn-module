#include "inc_xp"

void main()
{
    object oPC = GetPCSpeaker();

    ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 2.0);
    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, 2.0));

    string sVar = GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_petted";

    if (GetLocalInt(OBJECT_SELF, sVar) != 1)
    {
        SetLocalInt(OBJECT_SELF, sVar, 1);
        DelayCommand(600.0, DeleteLocalInt(OBJECT_SELF, sVar));
        GiveXPToPC(oPC, 1.0);
    }
}
