// Ferron on death script

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
				// Heard Aghaaz's offer
				if (nPCStage == 3 || nPCStage == 4)
				{
                    FloatingTextStringOnCreature("You collect the head of the fallen golem.", oTest, FALSE);
					AdvanceQuest(OBJECT_SELF, oTest, 7);
				}
				// Haven't heard Aghaaz's offer
				else
				{
                    FloatingTextStringOnCreature("You collect the head of the fallen golem.", oTest, FALSE);
					AdvanceQuest(OBJECT_SELF, oTest, 6);
				}
			}
		}
		oTest = GetNextObjectInShape(SHAPE_SPHERE, 30.0, lSelf);
	}
	
}