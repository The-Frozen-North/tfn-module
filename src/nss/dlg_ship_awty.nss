int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (!GetIsObjectValid(oPC)) return FALSE;

    object oArea = GetArea(OBJECT_SELF);

    int nTravelTime = GetLocalInt(oArea, "travel_time");

    string sString = "We've just started on our voyage! It'll be a while until we get to land.";

    if (nTravelTime < 5)
    {
        sString = "We're almost at port. Just be patient.";
    }
    else if (nTravelTime < 10)
    {
        sString = "We're getting close.";
    }
    else if (nTravelTime < 20)
    {
        sString = "Aye, we're more than halfway there.";
    }

    SetCustomToken(4503, sString);

    return TRUE;
}
