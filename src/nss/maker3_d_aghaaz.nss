// Aghaaz on death script

#include "inc_quest"

void main()
{
	location lSelf = GetLocation(OBJECT_SELF);
	object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 30.0, lSelf);
	while (GetIsObjectValid(oTest))
	{
		if (GetIsPC(oTest))
		{
			int nPCStage = GetQuestEntry(oTest, "q_golems");
			if (nPCStage < 10)
			{
				// Heard Ferron's offer
				if (nPCStage == 2 || nPCStage == 4)
				{
					AdvanceQuest(OBJECT_SELF, oTest, 6);
				}
				// Haven't heard Ferron's offer
				else
				{
					AdvanceQuest(OBJECT_SELF, oTest, 5);
				}
			}
		}
		oTest = GetNextObjectInShape(SHAPE_SPHERE, 30.0, lSelf);
	}
	
}