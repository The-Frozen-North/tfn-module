void main()
{
    object oPC = GetPCSpeaker();

    SendMessageToPC(oPC, "Tick count: "+IntToString(GetTickRate()));
}
