#include "inc_quest"

void main()
{
    object oEntering = GetEnteringObject();
    if (!GetIsPC(oEntering)) { return; }
    if (GetQuestEntry(oEntering, "q_beholder_prot") == 1)
    {
        AssignCommand(oEntering, FloatingTextStringOnCreature("Looking toward the light from above, you see the opening of a Beholder tunnel.", oEntering, FALSE));
        AssignCommand(oEntering, DelayCommand(2.0, FloatingTextStringOnCreature("You wonder why a tunnel would end here, in a place drained of magical power.", oEntering, FALSE)));
        AssignCommand(oEntering, DelayCommand(4.0, FloatingTextStringOnCreature("It seems like there is no way up, but the cavern may be worth investigating...", oEntering, FALSE)));
        SetQuestEntry(oEntering, "q_beholder_prot", 2);
    }
}
