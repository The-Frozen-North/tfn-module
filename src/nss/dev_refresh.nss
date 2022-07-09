#include "inc_debug"

// run this via dm_runscript

void main()
{
	if (GetIsDeveloper(OBJECT_SELF))
	{
		ExecuteScript("area_refresh", GetArea(OBJECT_SELF));
	}
}