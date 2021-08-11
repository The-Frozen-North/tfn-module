//Give the player the second journal entries for
//Maker and Mirror plots
//Set Variable marking these have been given
//Drew Karpyshyn, Sept. 22, 2003

void main()
{
 AddJournalQuestEntry("q2_maker",10,GetPCSpeaker());
 AddJournalQuestEntry("q2_mirror",10,GetPCSpeaker());

 SetLocalInt(GetModule(),"Valen_Journal",10);
}

