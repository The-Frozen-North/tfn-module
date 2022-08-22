void WebLoop(string sTagTarget, string sVarStem)
{
    object oWP = GetFirstObjectInArea(OBJECT_SELF);
	while (GetIsObjectValid(oWP))
	{
		if (GetObjectType(oWP) == OBJECT_TYPE_WAYPOINT)
		{
			string sTag = GetTag(oWP);
			if (sTag == sTagTarget)
			{
				location lWP = GetLocation(oWP);
				string sVar = sVarStem;
				SetLocalInt(OBJECT_SELF, sVar, GetLocalInt(OBJECT_SELF, sVar) + 1);
				sVar += IntToString(GetLocalInt(OBJECT_SELF, sVar));
				SetLocalLocation(OBJECT_SELF, sVar, lWP);			
                DestroyObject(oWP);
			}
		}
		oWP = GetNextObjectInArea(OBJECT_SELF);
	}
}


void main()
{
    WebLoop("LargeWeb", "largewebs");
    WebLoop("SmallWeb", "smallwebs");
	
}