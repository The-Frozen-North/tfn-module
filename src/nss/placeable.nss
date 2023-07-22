#include "nwnx_object"
#include "inc_housing"
//#include "nwnx_player"

void main()
{
    object oItem = GetItemActivated();
    object oPC = GetItemActivator();

    if (!IsInOwnHome(oPC))
    {
        FloatingTextStringOnCreature("*Placeables can only placed in your own home.*", oPC, FALSE);
        return;
    }

    int nAppearanceType = GetLocalInt(oItem, "appearance_type");
    string sName = GetLocalString(oItem, "name");
    string sDescription = GetLocalString(oItem, "description");
    string sType = GetLocalString(oItem, "type");
    string sUUID = GetLocalString(oItem, "uuid");

    int bCreateRecord = FALSE;

    object oPlaceable = CopyPlaceable(sName, sDescription, sType, GetItemActivatedTargetLocation(), nAppearanceType, sUUID);

    if (GetLocalInt(GetArea(oPC), "edit") == 1)
    {
        SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "placeable_edit");
        //NWNX_Player_SetPlaceableUsable(oPC, oPlaceable, TRUE);
        SetUseableFlag(oPlaceable, TRUE);
    }

    if (!GetIsObjectValid(oPlaceable))
    {
        SendMessageToPC(oPC, "Something went wrong and the placeable was not created.");
        return;
    }


        sqlquery sql = SqlPrepareQueryCampaign("house_placeables",
            "INSERT INTO placeables " +
            "(uuid, appearance_type, cd_key, position, facing, name, description, type) " +
            "VALUES (@uuid, @appearance_type, @cd_key, @position, @facing, @name, @description, @type)");
        BindPlaceableForSQL(oPlaceable, GetPosition(oPlaceable), GetFacing(oPlaceable), sql);
        SqlBindString(sql, "@cd_key", GetPCPublicCDKey(oPC));
        SqlBindString(sql, "@uuid", sUUID);
        SqlStep(sql);


    DestroyObject(oItem);
}
