void main()
{
    object oPC = GetPCSpeaker();
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, "_unstucker", GetLocation(oPC));

    AssignCommand(oPC, JumpToLocation(GetLocation(oCreature)));

    DestroyObject(oCreature);
}
