#include "x0_inc_henai"

void bkAttemptToOpenLockVoid(object oLock)
{
    bkAttemptToOpenLock(oLock);
}

// since it's not really a container, just emulate the lock UX
void main()
{
    PlaySound("as_sw_genericlk1");

    object oPC = GetLastUsedBy();

    if (!GetIsPC(oPC)) return;

    FloatingTextStringOnCreature("*locked*", oPC, FALSE);

    object oParty = GetFirstFactionMember(oPC, FALSE);

    while (GetIsObjectValid(oParty))
    {
        if (GetMaster(oParty) == oPC)
            AssignCommand(oParty, bkAttemptToOpenLockVoid(OBJECT_SELF));

       oParty = GetNextFactionMember(oPC, FALSE);
    }
}
