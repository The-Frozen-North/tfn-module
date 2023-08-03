#include "inc_housing"

void main ()
{
    object oPC = NuiGetEventPlayer();
    int    nToken  = NuiGetEventWindow();
    string sEvent  = NuiGetEventType();
    string sElem   = NuiGetEventElement();
    //int    nIdx    = NuiGetEventArrayIndex();
    string sWndId  = NuiGetWindowId(oPC, nToken);

    if (!IsInOwnHome(oPC)) return;

    if (sWndId == "namepet")
    {
        if (sEvent == "click" && sElem == "btn_name_save")
        {
            string sDB = GetPCPublicCDKey(oPC);
            string sTarget = IntToString(GetLocalInt(oPC, "pet_target"));

            object oPet = GetObjectByTag(GetPCPublicCDKey(oPC)+"_pet"+sTarget);

            string sNewName = JsonGetString(NuiGetBind(oPC, nToken, "name_value"));
            //SendMessageToPC(GetFirstPC(), "new name: "+sNewName);
            //SendMessageToPC(GetFirstPC(), "tag: "+GetPCPublicCDKey(oPC)+"_pet"+sTarget);
            //SendMessageToPC(GetFirstPC(), "valid object: "+IntToString(GetIsObjectValid(oPet)));

            if (sNewName == "") return;
            if (sTarget == "") return;
            if (!GetIsObjectValid(oPet)) return;

            SetName(oPet, sNewName);

            SetCampaignString(sDB, "pet"+sTarget+"_name", GetName(oPet));

            NuiDestroy(oPC, nToken);
        }
    }
}
