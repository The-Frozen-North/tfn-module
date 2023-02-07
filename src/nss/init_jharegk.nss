#include "nwnx_object"

const float PEDESTAL_DUMMY_Z = 1.3;

void main()
{
	int i;
	// Create invisible objects above every pedestal we can make VFX from later
	for (i=1; i<=5; i++)
	{
		string sPedestal = "jhareg_pentagram" + IntToString(i);
		if (i == 5)
		{
			sPedestal = "jhareg_brazier";
		}
		object oPedestal = GetObjectByTag(sPedestal);
		vector vPos = GetPosition(oPedestal);
		vector vFinal = Vector(vPos.x, vPos.y, PEDESTAL_DUMMY_Z);
		location lFinal = Location(GetArea(oPedestal), vFinal, 0.0);
		CreateObject(OBJECT_TYPE_PLACEABLE, "invisibleobject", lFinal, FALSE, "jhareg_pedestal_dummy" + IntToString(i));
	}
	// Candelabra 1 is part of the tileset, so need a invisible object there too
    // Not used in the final iteration
	//object oWP = GetWaypointByTag("jhareg_candelabra_1_spawn");
	//CreateObject(OBJECT_TYPE_PLACEABLE, "invisibleobject", GetLocation(oWP), FALSE, "jhareg_candelabra_1");
    
    // Brazier should not be static
    NWNX_Object_SetPlaceableIsStatic(GetObjectByTag("jhareg_brazier"), FALSE);
}