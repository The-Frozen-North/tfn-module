#include "nwnx_admin"
#include "nwnx_events"
#include "nwnx_item"
#include "nwnx_player"
#include "inc_itemevent"

const string ILR_OVERLEVEL_COLOUR = "<c\xc8\xc8\xc8>";

string GetILROverlevelInfo(object oItem)
{
    int nILR = NWNX_Item_GetMinEquipLevel(oItem);
    if (nILR < 2)
    {
        return "";
    }
    return ILR_OVERLEVEL_COLOUR + "\n\n(Level Required: " + IntToString(nILR) + ")</c>";
}

void main()
{
    object oObject = StringToObject(NWNX_Events_GetEventData("EXAMINEE_OBJECT_ID"));

    if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && GetFactionEqual(oObject))
    {
        NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_EXAMINE_EFFECTS, TRUE);
    }
    else if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && GetIdentified(oObject))
    {      
        // Add ILR text
        string sILROverlevel = GetILROverlevelInfo(oObject);
        string sDesc = GetDescription(oObject);
        int nILR = NWNX_Item_GetMinEquipLevel(oObject);
        int nHD = GetHitDice(OBJECT_SELF);
        int nILRPos = FindSubString(sDesc, ILR_OVERLEVEL_COLOUR);
        if (nILRPos >= 0)
        {
            // If ILR text is present and PC is underlevelled, remove it because the game will display it
            sDesc = GetStringLeft(sDesc, nILRPos);
            SetDescription(oObject, sDesc);
        }
        if (nHD >= nILR)
        {
            // ILR text absent and PC is overlevelled, add it
            sDesc = sDesc + sILROverlevel;
            SetDescription(oObject, sDesc);
        }
        int bHasMaterial = 0;
        itemproperty ipTest = GetFirstItemProperty(oObject);
        while (GetIsItemPropertyValid(ipTest))
        {
            if (GetItemPropertyType(ipTest) == ITEM_PROPERTY_MATERIAL)
            {
                bHasMaterial = 1;
                break;
            }
            ipTest = GetNextItemProperty(oObject);
        }
        if (bHasMaterial)
        {
            json jReplacements = ItemEventGetCustomPropertyText(oObject);
            if (JsonGetLength(jReplacements) > 0)
            {
                int nNextOverrideIndex = 0;
                ipTest = GetFirstItemProperty(oObject);
                while (GetIsItemPropertyValid(ipTest))
                {
                    if (GetItemPropertyType(ipTest) == ITEM_PROPERTY_MATERIAL)
                    {
                        int nCostTableIndex = GetItemPropertyCostTableValue(ipTest);
                        int nNameString = StringToInt(Get2DAString("iprp_matcost", "Name", nCostTableIndex));
                        NWNX_Player_SetTlkOverride(OBJECT_SELF, nNameString, JsonGetString(JsonArrayGet(jReplacements, nNextOverrideIndex)));
                        nNextOverrideIndex++;
                    }
                    ipTest = GetNextItemProperty(oObject);
                }
            }
        }
    }
}
