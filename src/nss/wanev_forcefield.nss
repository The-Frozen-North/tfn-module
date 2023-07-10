void main()
{
        object oPC = GetEnteringObject();

        if (GetIsPC(oPC))
            FloatingTextStringOnCreature("This forcefield repels you. It is likely warded to only allow certain individuals to pass through.", oPC, FALSE);
}
