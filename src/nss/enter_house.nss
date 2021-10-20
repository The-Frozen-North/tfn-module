void main()
{
    object oPC = GetEnteringObject();

    if (GetIsPC(oPC))
        ExploreAreaForPlayer(OBJECT_SELF, oPC);
}
