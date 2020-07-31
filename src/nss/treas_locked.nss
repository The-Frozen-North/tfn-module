// since it's not really a container, just emulate the lock UX
void main()
{
    object oPC = GetLastUsedBy();
    PlaySound("as_sw_genericlk1");
    FloatingTextStringOnCreature("*locked*", oPC, FALSE);
}
