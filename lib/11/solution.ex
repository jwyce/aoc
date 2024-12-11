defmodule DayEleven do
  defmodule QuantumStones do
    def blink_fast(stones, 0), do: stones

    def blink_fast(stones, times) when times > 0 do
      Enum.reduce(stones, %{}, fn {stone, count}, acc ->
        transform(stone)
        |> Enum.reduce(acc, fn new_stone, acc_inner ->
          Map.update(acc_inner, new_stone, count, &(&1 + count))
        end)
      end)
      |> blink_fast(times - 1)
    end

    def transform(stone) when is_number(stone) do
      str = Integer.to_string(stone)
      len = String.length(str)
      midpoint = div(len, 2)

      cond do
        stone == 0 ->
          [1]

        len |> rem(2) == 0 ->
          str |> String.split_at(midpoint) |> Tuple.to_list() |> Enum.map(&String.to_integer/1)

        true ->
          [stone * 2024]
      end
    end

    def blink(stone, 0), do: stone

    def blink(stone, _count) when is_number(stone), do: transform(stone)

    def blink(stones, count) when is_list(stones) and count > 0 do
      stones
      |> Enum.map(fn stone -> blink(stone, count) end)
      |> flatten()
      |> blink(count - 1)
    end

    def flatten([]), do: []

    def flatten([head | tail]) when is_list(head) do
      flatten(head) ++ flatten(tail)
    end

    def flatten([head | tail]) do
      [head | flatten(tail)]
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> Enum.at(0)
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> QuantumStones.blink(25)
    |> Enum.count()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> Enum.at(0)
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Map.new(fn x -> {x, 1} end)
    |> QuantumStones.blink_fast(75)
    |> Enum.reduce(0, fn {_, count}, sum -> sum + count end)
  end
end
