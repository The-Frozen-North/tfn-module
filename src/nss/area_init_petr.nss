void main()
{
	object oWP = GetFirstObjectInArea(OBJECT_SELF);
	while (GetIsObjectValid(oWP))
	{
		if (GetObjectType(oWP) == OBJECT_TYPE_WAYPOINT)
		{
			string sTag = GetTag(oWP);
			if (GetStringLeft(sTag, 9) == "Petrified")
			{
				location lWP = GetLocation(oWP);
				string sVar = "petrified_" + sTag;
				SetLocalInt(OBJECT_SELF, sVar, GetLocalInt(OBJECT_SELF, sVar) + 1);
				sVar += IntToString(GetLocalInt(OBJECT_SELF, sVar));
				SetLocalLocation(OBJECT_SELF, sVar, lWP);			
                DestroyObject(oWP);
			}
		}
		oWP = GetNextObjectInArea(OBJECT_SELF);
	}
}