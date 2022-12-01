using Godot;

public partial class float_modifier : stat_modifier<float>
{
  public new float GetMax() => base.GetMax;
  public new float GetMin() => base.GetMin;

  public new void Add(float v)
  {
    base.Add(v);
  }
}