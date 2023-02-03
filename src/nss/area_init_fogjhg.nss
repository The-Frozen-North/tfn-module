#include "inc_debug"

// Fog for charwood/castle jhareg

void createFog(object oArea, int nStepSize) {
  int nAreaSizeX = GetAreaSize(AREA_WIDTH,  oArea);
  int nAreaSizeY = GetAreaSize(AREA_HEIGHT, oArea);
  int i, j;
  for (i = 0; i < nAreaSizeX * 10; i = i + nStepSize) {
    for (j = 0; j < nAreaSizeY * 10; j = j + nStepSize) {
      location lLocation = Location(oArea, Vector(IntToFloat(i), IntToFloat(j), 0.0), 0.0);
      object oFog = CreateObject(OBJECT_TYPE_PLACEABLE, "tm_pl_fog50_lo", lLocation, FALSE, "FOG_TAG");         
      SetPlotFlag(oFog, TRUE);
    }                                                  
  }                                                    
}      

void main()
{
    object oArea = OBJECT_SELF;
    if (GetArea(oArea) != oArea && GetIsDevServer())
    {
        oArea = GetArea(OBJECT_SELF);
    }
    if (!GetIsObjectValid(oArea)) { return; }
    createFog(oArea, 25);
}