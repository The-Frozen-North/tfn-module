#include "inc_key"

void main()
{
    object oPC = GetClickingObject();
    if (GetHasKey(oPC, "key_ud_obelisk"))
    {
        if (d3() == 1)
        {
            SpeakString("The Twisted Key has broken when opening the gate. Fortunately, the lock still opened.");
        }
        else
        {
            SpeakString("The Twisted Key has opened the lock, but is now stuck in the gate.");
        }
        RemoveKeyFromPlayer(oPC, "key_ud_obelisk");
        SetLocked(OBJECT_SELF, 0);
        AssignCommand(OBJECT_SELF, ActionOpenDoor(OBJECT_SELF));
    }
}