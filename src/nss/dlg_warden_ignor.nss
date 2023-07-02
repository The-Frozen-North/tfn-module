void main()
{
    object oPC = GetPCSpeaker();

    SetLocalInt(OBJECT_SELF, "bluffed_"+GetPCPublicCDKey(oPC)+GetName(oPC), 1);
}
