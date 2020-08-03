int StartingConditional()
{
    if (GetHitDice(GetPCSpeaker()) >= 2)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
