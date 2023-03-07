#include "inc_sqlite_time"

void main()
{
    object oPC = GetLastPerceived();
    if (!GetIsPC(oPC)) return;
	if (!GetLastPerceptionSeen()) return;
	
	int nNow = SQLite_GetTimeStamp();
	int nLast = GetLocalInt(OBJECT_SELF, "last_code");
	if (nNow - nLast >= 10)
	{
		object oArea = GetObjectByTag("ud_maker2");
		int nID = GetLocalInt(oArea, "scavenger_id");
		if (GetResRef(OBJECT_SELF) == "makerguardgolem")
		{
			nID = GetLocalInt(oArea, "guardian_id");
		}
		string sID = IntToString(nID);
		string sFirst = GetStringLeft(sID, 1);
		string sSecond = GetStringRight(sID, 1);
		if (nID < 10)
		{
			sSecond = sFirst;
			sFirst = "0";
		}
		int nFirst = StringToInt(sFirst);
		int nSecond = StringToInt(sSecond);
		string sSpeech = GetLocalString(oArea, "word_" + IntToString(nFirst));
		sSpeech += " " + GetLocalString(oArea, "word_" + IntToString(nSecond)) + "!";
		SpeakString(sSpeech);
		SetLocalInt(OBJECT_SELF, "last_code", nNow);
	}
}
