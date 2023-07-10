#include "inc_debug"
#include "nwnx_area"
#include "nwnx_creature"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        vector vPosition = GetPosition(oPC);
        int nSurfaceMaterial = GetSurfaceMaterial(GetLocation(oPC));
        SendMessageToPC(oPC, "x: " + FloatToString(vPosition.x) + "| y: " + FloatToString(vPosition.y) + "| z: " + FloatToString(vPosition.z));
        SendMessageToPC(oPC, "TileResRef: " + NWNX_Area_GetTileModelResRef(GetArea(OBJECT_SELF), vPosition.x, vPosition.y));
        SendMessageToPC(oPC, "Surface Material: " + IntToString(nSurfaceMaterial) + " " + Get2DAString("surfacemat", "Label", nSurfaceMaterial));
        SendMessageToPC(oPC, "Movement Rate Factor: " + FloatToString(NWNX_Creature_GetMovementRateFactor(OBJECT_SELF)));
    }
}

