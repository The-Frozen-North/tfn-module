#include "inc_quest"

void main()
{
    object oEntering = GetEnteringObject();
    if (!GetIsPC(oEntering)) { return; }
    if (GetQuestEntry(oEntering, "q_beholder_prot") == 1)
    {
        AssignCommand(oEntering, SpeakString("Looking toward the light from above, you see the opening of a Beholder tunnel."));
        AssignCommand(oEntering, DelayCommand(2.0, SpeakString("You wonder why a tunnel would end here, in front of an object draining so much magical power.")));
        AssignCommand(oEntering, DelayCommand(4.0, SpeakString("It seems like there is no way up, but the obelisk may be worth investigating.")));
        SetQuestEntry(oEntering, "q_beholder_prot", 2);
    }
}
