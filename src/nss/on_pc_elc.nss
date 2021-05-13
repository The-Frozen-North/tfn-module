#include "nwnx_elc"
#include "inc_nwnx"

void main()
{

    object oPC = OBJECT_SELF;
    int nType = NWNX_ELC_GetValidationFailureType();
    int nSubType = NWNX_ELC_GetValidationFailureSubType();
    int nStrRef = NWNX_ELC_GetValidationFailureMessageStrRef();

    string sMessage = "ELC: FAIL: " + GetName(oPC) +
                        " -> Type = " +IntToString(nType) +
                        ", SubType = " +IntToString(nSubType) +
                        ", StrRef = " + GetStringByStrRef(nStrRef);

    SendDiscordLogMessage(sMessage);
    WriteTimestampedLogEntry(sMessage);

    if (nType == NWNX_ELC_VALIDATION_FAILURE_TYPE_ITEM)
    {
        object oItem = NWNX_ELC_GetValidationFailureItem();

        // Unequip the item instead of having the player unable to login
        if (GetIsObjectValid(oItem))
            ActionUnequipItem(oItem);

        NWNX_ELC_SkipValidationFailure();
    }
}
