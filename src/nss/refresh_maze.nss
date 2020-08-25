#include "inc_debug"

void main()
{
    string sTag = "WP_MELDANEN_BOOK"+IntToString(d10());

    SendDebugMessage("Chosen WP: "+sTag);

    object oWP = GetObjectByTag(sTag);

    object oArea = GetArea(oWP);

    vector vWP = GetPosition(oWP);
    vector vBook = Vector(vWP.x, vWP.y-0.7, vWP.z);
    vector vCorpse = Vector(vWP.x, vWP.y, vWP.z);

    DestroyObject(GetObjectByTag("meldanen_apprentice"));
    DestroyObject(GetObjectByTag("meldanen_book"));
    DestroyObject(GetObjectByTag("meldanen_allip"));

    CreateObject(OBJECT_TYPE_PLACEABLE, "meldanen_book", Location(oArea, vBook, 0.0));
    CreateObject(OBJECT_TYPE_PLACEABLE, "meldanen_apprent", Location(oArea, vCorpse, 0.0));
    CreateObject(OBJECT_TYPE_CREATURE, "allip", Location(oArea, vCorpse, 0.0), FALSE, "meldanen_allip");
}
