void main()
{
    DeleteLocalInt(GetArea(OBJECT_SELF), "ambushed");

    DestroyObject(GetObjectByTag("helm_ambush", 0));
    DestroyObject(GetObjectByTag("helm_ambush", 1));
    DestroyObject(GetObjectByTag("helm_ambush", 2));
    DestroyObject(GetObjectByTag("helm_ambush", 3));
    DestroyObject(GetObjectByTag("helm_ambush", 4));
}
