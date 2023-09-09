void main()
{
    object oPC = GetEnteringObject();

    if (GetIsPC(oPC))
    {
        DelayCommand(10.0, SetLocalInt(oPC, "warden_interrogation", 1));
    }
}
