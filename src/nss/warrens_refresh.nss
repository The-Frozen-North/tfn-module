void main()
{
    DestroyObject(GetObjectByTag("pedestal_cyric"));

    CreateObject(OBJECT_TYPE_PLACEABLE, "pedestal_cyric", GetLocation(GetObjectByTag("altar_of_cyric_wp")));
}
