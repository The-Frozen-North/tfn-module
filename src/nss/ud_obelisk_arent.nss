#include "inc_quest"

void main()
{
    object oPC = GetEnteringObject();
    if (GetIsPC(oPC))
    {
        SetLocalInt(OBJECT_SELF, "UDObeliskHasPlayers", 1);
        if (GetQuestEntry(oPC, "q_beholder_prot") < 3)
        {
            DelayCommand(3.0, AssignCommand(oPC, SpeakString("Something in this area is pulling the very magic out of the air.")));
        }
    }
}