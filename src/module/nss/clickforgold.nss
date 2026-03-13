void main()
{
      object oPC = GetPlaceableLastClickedBy();
      GiveGoldToCreature(oPC, 30000);
      FloatingTextStringOnCreature("Granted Gold",oPC,FALSE);
}
