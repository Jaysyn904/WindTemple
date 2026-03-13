void main()
{
      object oPC = GetPlaceableLastClickedBy();
      AdjustAlignment(oPC, ALIGNMENT_GOOD, 100);
      FloatingTextStringOnCreature("Made Good",oPC,FALSE);
}
