#include "inc_loot"

void main()
{
	object oUser = GetLastUsedBy();
	string sOwnerKey = GetLocalString(OBJECT_SELF, "owner");
	if (GetPCPublicCDKey(oUser) != sOwnerKey)
	{
		FloatingTextStringOnCreature("This isn't your treasure!", oUser, FALSE);
		return;
	}
    ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN);
	
	int nGenerated = GetLocalInt(OBJECT_SELF, "doneloot");
	if (!nGenerated)
	{
		SetLocalInt(OBJECT_SELF, "boss", 1);
		int i;
		int nTries = d2(2);
		for (i=0; i<nTries; i++)
		{
			SetScriptParam("exclusivelooter", ObjectToString(oUser));
			ExecuteScript("party_credit");
			DeleteLocalInt(OBJECT_SELF, "no_credit");
		}
		SetLocalInt(OBJECT_SELF, "doneloot", 1);
	}

	ExecuteScript("loot_open");
}