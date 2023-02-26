int StartingConditional()
{
    string sSkill = GetScriptParam("skill");
    int nSkill = StringToInt(sSkill);
    int nValue = StringToInt(GetScriptParam("value"));

    // Animal empathy is skill 0!
    if ((nSkill == 0 && sSkill == "") || nValue == 0)
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
