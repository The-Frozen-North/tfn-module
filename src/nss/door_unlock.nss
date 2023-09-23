#include "inc_xp"

void main()
{
    object oUnlocker = GetLastUnlocked();

    if (GetObjectType(oUnlocker) == OBJECT_TYPE_CREATURE) PlaySound("gui_picklockopen");

    // check if unlocked by a possessed pixie
    if (!GetIsPC(oUnlocker)) oUnlocker = GetMaster(oUnlocker);

    // do nothing if not a PC still
    if (!GetIsPC(oUnlocker)) return;

    GiveUnlockXP(oUnlocker, GetLockUnlockDC(OBJECT_SELF));
    IncrementPlayerStatistic(oUnlocker, "locks_unlocked");
}

