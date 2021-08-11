int StartingConditional()
{
    object oPC = GetPCSpeaker();
    if (GetLocalInt(oPC, "X2_Q2A3_FightProvoker") != 1)
        return TRUE;
    return FALSE;
}
