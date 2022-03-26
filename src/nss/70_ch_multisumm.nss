//::///////////////////////////////////////////////
//:: Multiple summon workaround
//:: 70_ch_multisumm
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This is a workaround for a two issues with enforcing multiple summons feature.

1) In OnSpawn event, GetMaster is invalid and there is no way to check who was the
sumonning pc
2) When delay 0.0 is used to workaround first issue, master is valid, but the problem
is that the first summon of the master has to be set as not destroyable, yet AssignCommand
adds another small delay and the action will not be executed before game destroys him.

This script is solution. While assigning the SetDestroyable would be executed with delay,
executing a script will not. And executing a script forces to get proper OBJECT_SELF which
is required as the SetIsDestroyable works only on OBJECT_SELF.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 01-01-2016
//:://////////////////////////////////////////////

void main()
{
SetIsDestroyable(FALSE,FALSE,FALSE);
DelayCommand(0.0,SetIsDestroyable(TRUE,FALSE,FALSE));
}
