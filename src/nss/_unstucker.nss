void main()
{
    object oPC = GetItemActivator();

    if (GetIsInCombat(oPC))
    {
        FloatingTextStringOnCreature("*You can't use this while in combat!*", oPC, FALSE);
        return;
    }

    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, "_unstucker", GetLocation(oPC));

    AssignCommand(oPC, JumpToLocation(GetLocation(oCreature)));

    DestroyObject(oCreature);
}
