void main()
{
    DestroyObject(GetObjectByTag("pedestal_cyric"));

    CreateObject(OBJECT_TYPE_PLACEABLE, "pedestal_cyric", GetLocation(GetObjectByTag("altar_cyric_wp")));
    CreateObject(OBJECT_TYPE_PLACEABLE, "plc_magicorange", GetLocation(GetObjectByTag("altar_cyric_wp")), FALSE, "pedestal_light");
}
