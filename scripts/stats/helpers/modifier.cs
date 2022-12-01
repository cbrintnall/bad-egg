using Godot;
using C5;

public partial class Modifier<T> : Node where T : unmanaged
{
  IntervalHeap<T> heap;

  public Modifier()
  {
    heap = new();
  }

  public T GetMin => heap.FindMin();
  public T GetMax => heap.FindMax();
  public void Add(T val) => heap.Add(val);
}