// Do a check against the area tag the NPC is in.
// Params:
// "areatag" - the area tag to check against. This is true only when in an area with this tag
// "not" - any value inverts the check, making this condition true whe NOT in an area with that tag

int StartingConditional()
{
    object oArea = GetArea(OBJECT_SELF);
    string sAreaTag = GetScriptParam("areatag");
    string sNot = GetScriptParam("not");

    int nMatches = GetTag(oArea) == sAreaTag;
    if (sNot == "")
    {
        if (nMatches)
        {
            return 1;
        }
        return 0;
    }
    if (nMatches)
    {
        return 0;
    }
    return 1;
}
