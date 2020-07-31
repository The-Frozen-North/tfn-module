void main()
{
    location lLocation = GetLocation(GetObjectByTag(GetLocalString(OBJECT_SELF, "warden_tele_wp")));
    AssignCommand(GetPCSpeaker(), JumpToLocation(lLocation));
}
