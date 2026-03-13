void main()
{
      object oPC = GetPlaceableLastClickedBy();
      GiveXPToCreature(oPC, 30000);
      FloatingTextStringOnCreature("Granted XP",oPC,FALSE);
}
