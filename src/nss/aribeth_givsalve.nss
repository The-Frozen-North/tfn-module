#include "nwnx_item"

// Salve of Stone to Flesh has a gold value too high
// and gets a level restriction of 16!

const string SALVE_RESREF = "salveofstonetofl";
const string SALVE_TAG = "salve_stoneflesh";

void main()
{
    object oPC = GetPCSpeaker();
    int bHasSalve = 0;
    object oTest = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oTest))
    {
        if (GetResRef(oTest) == SALVE_RESREF)
        {
            bHasSalve = 1;
            break;
        }
        oTest = GetNextItemInInventory(oPC);
    }
    if (!bHasSalve)
    {
        object oSalve = CreateItemOnObject(SALVE_RESREF, oPC);
        SetItemCursedFlag(oSalve, TRUE);
        SetIdentified(oSalve, TRUE);
        SetDroppableFlag(oSalve, FALSE);
        SetPickpocketableFlag(oSalve, FALSE);
        SetPlotFlag(oSalve, TRUE);
        NWNX_Item_SetBaseGoldPieceValue(oSalve, 5000);
    }
}
