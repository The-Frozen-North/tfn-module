// TRUE if PC's level is between params "minlvl" and "maxlvl" inclusive.
// One of the two params may be omitted to assume 0 or infinite respectively

#include "inc_xp"

int StartingConditional()
{
    int nMax = StringToInt(GetScriptParam("maxlvl"));
    int nMin = StringToInt(GetScriptParam("minlvl"));

    int nPCLevel = GetLevelFromXP(GetXP(GetPCSpeaker()));

    if (nMax > 0 && nMin > 0)
    {
        return (nPCLevel >= nMin && nPCLevel <= nMax);
    }
    else if (nMax > 0)
    {
        return (nPCLevel <= nMax);
    }
    else if (nMin > 0)
    {
        return (nPCLevel >= nMin);
    }


    // No params sent
    return 1;
}
