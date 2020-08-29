void main()
{
    if (d4() == 1)
    {
        SetLocalString(OBJECT_SELF, "quest1", "02_b_gem");
        SetLocalInt(OBJECT_SELF, "quest_kill", 1);
        SetLocalString(OBJECT_SELF, "quest1_pc_script", "kill_bmage");
    }
}
