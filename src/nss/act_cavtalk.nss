//::///////////////////////////////////////////////
//::act_cavtalk
//:://////////////////////////////////////////////
//::
//::
//:: Increments the Cavallas talk variable
//::
//::
//::
//:://////////////////////////////////////////////
//::
//:: Created By: Drew Karpyshyn
//:: Created On: Oct. 29, 2003
//::
//:://////////////////////////////////////////////

void main()
{
    SetLocalInt(GetModule(),"Cavallas_Talk", GetLocalInt(GetModule(),"Cavallas_Talk") + 1);
}

