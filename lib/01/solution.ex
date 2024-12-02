defmodule DayOne do
  def a do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ~r/\s+/))
    |> Stream.map(fn parts -> parts |> Enum.map(&String.to_integer/1) end)
    |> Stream.zip()
    |> Stream.map(fn list ->
      list
      |> Tuple.to_list()
      |> Enum.sort()
    end)
    |> Enum.to_list()
    |> Enum.zip()
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    [group_one, group_two] =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.split(&1, ~r/\s+/))
      |> Stream.map(fn parts -> parts |> Enum.map(&String.to_integer/1) end)
      |> Stream.zip()
      |> Stream.map(fn list ->
        list
        |> Tuple.to_list()
        |> Enum.sort()
      end)
      |> Enum.to_list()

    frequencies = Enum.frequencies(group_two)

    group_one
    |> Enum.map(&(&1 * Map.get(frequencies, &1, 0)))
    |> Enum.sum()
  end
end
