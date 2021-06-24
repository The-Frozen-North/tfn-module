int StartingConditional()
{
    int nSkill = StringToInt(GetScriptParam("skill"));
    int nValue = StringToInt(GetScriptParam("value"));

    if (nSkill == 0 || nValue == 0)
    {
        return FALSE;
    }

    if (GetSkillRank(nSkill, GetPCSpeaker()) >= nValue)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
