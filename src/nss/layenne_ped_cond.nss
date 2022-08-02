// Conversation conditional script for layenne's tomb pedastals

// LocalInt - "layenne_gem" - string, one of "amethyst" "sapphire" "emerald" "diamond"
// This is set by the area refresh script
// LocalInt - "layenne_filled" - int, 1 if this pedastal has taken its gem

// Script params:

// "filled" - return 1 if filled otherwise 0
// "gem" - return 1 if the correct gem for the pedastal matches the param value
// "hasgem" - return 1 if the PC has the gem that matches the param value

#include "inc_key"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int bReturn = TRUE;
    string sFilledState = GetScriptParam("filled");
    if (GetStringLength(sFilledState) > 0)
    {
        bReturn = GetLocalInt(OBJECT_SELF, "layenne_filled");
    }
    if (!bReturn) { return 0; }
    string sHasGem = GetScriptParam("hasgem");
    string sMyGem = GetLocalString(OBJECT_SELF, "layenne_gem");
    if (GetStringLength(sHasGem) > 0)
    {
        string sGemTag;
        if (sHasGem == "amethyst")
        {
            sGemTag = "q_gemofmisery";
        }
        else if (sHasGem == "diamond")
        {
            sGemTag = "q_gemofhonor";
        }
        else if (sHasGem == "emerald")
        {
            sGemTag = "q_gemofduty";
        }
        else if (sHasGem == "sapphire")
        {
            sGemTag = "q_gemofpain";
        }
        bReturn = GetHasKey(oPC, sGemTag);
    }
    if (!bReturn) { return 0; }
    string sTargetGem = GetScriptParam("gem");
    if (GetStringLength(sTargetGem) > 0)
    {
        return sTargetGem == sMyGem;
    }
    return TRUE;
}
