// this script is called when a treasure object is used but locked
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
            ExecuteScript("hen_picknearest", oParty);

       oParty = GetNextFactionMember(oPC, FALSE);
    }
}
