void main()
{
    if (!GetIsObjectValid(GetObjectByTag("hen_daelan")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_daelan", GetLocation(GetObjectByTag("hen_daelan_spawn_point")));
    if (!GetIsObjectValid(GetObjectByTag("hen_linu")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_linu", GetLocation(GetObjectByTag("hen_linu_spawn_point")));
    if (!GetIsObjectValid(GetObjectByTag("hen_sharwyn")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_sharwyn", GetLocation(GetObjectByTag("hen_sharwyn_spawn_point")));
    if (!GetIsObjectValid(GetObjectByTag("hen_tomi")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_tomi", GetLocation(GetObjectByTag("hen_tomi_spawn_point")));
    if (!GetIsObjectValid(GetObjectByTag("hen_grimgnaw")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_grimgnaw", GetLocation(GetObjectByTag("hen_grimgnaw_spawn_point")));
    if (!GetIsObjectValid(GetObjectByTag("hen_boddyknock")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_boddyknock", GetLocation(GetObjectByTag("hen_boddyknock_spawn_point")));
    if (!GetIsObjectValid(GetObjectByTag("hen_valen")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_valen", GetLocation(GetObjectByTag("hen_valen_spawn_point")));
    if (!GetIsObjectValid(GetObjectByTag("hen_nathyrra")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_nathyrra", GetLocation(GetObjectByTag("hen_nathyrra_spawn_point")));
    if (!GetIsObjectValid(GetObjectByTag("hen_bim")))
        CreateObject(OBJECT_TYPE_CREATURE, "hen_bim", GetLocation(GetObjectByTag("hen_bim_spawn_point")));
}
