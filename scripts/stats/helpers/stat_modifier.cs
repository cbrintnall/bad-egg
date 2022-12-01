using Godot;
using C5;

public partial class stat_modifier<T> : Node where T : unmanaged
{
  IntervalHeap<T> heap;

  public stat_modifier()
  {
    heap = new();
  }

  public T GetMin => heap.FindMin();
  public T GetMax => heap.FindMax();
  public void Add(T val) => heap.Add(val);
}