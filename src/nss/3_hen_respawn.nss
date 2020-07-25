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
}
