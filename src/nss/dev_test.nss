#include "inc_areadist"

void main()
{
    object oArea = GetArea(GetFirstPC());
    //PrepareAreaTransitionDB();
    SpeakString(JsonDump(GetAreasWithinDistance(oArea, 1000)));
}