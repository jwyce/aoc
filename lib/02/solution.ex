defmodule DayTwo do
  defmodule ListUtils do
    def monotonic?(list) when is_list(list) do
      case list do
        [] ->
          true

        [_] ->
          true

        _ ->
          increasing? =
            Enum.chunk_every(list, 2, 1, :discard)
            |> Enum.all?(fn [a, b] -> a < b end)

          decreasing? =
            Enum.chunk_every(list, 2, 1, :discard)
            |> Enum.all?(fn [a, b] -> a > b end)

          increasing? or decreasing?
      end
    end

    def within_step_tolerance?(list, min, max) when is_list(list) do
      case list do
        [] ->
          true

        [_] ->
          true

        _ ->
          min? =
            Enum.chunk_every(list, 2, 1, :discard)
            |> Enum.all?(fn [a, b] -> abs(a - b) >= min end)

          max? =
            Enum.chunk_every(list, 2, 1, :discard)
            |> Enum.all?(fn [a, b] -> abs(a - b) <= max end)

          min? and max?
      end
    end
  end

  def dampened?(list) when is_list(list) do
    if ListUtils.monotonic?(list) and ListUtils.within_step_tolerance?(list, 1, 3),
      do: true,
      else:
        weak_check(list, fn list ->
          ListUtils.monotonic?(list) and ListUtils.within_step_tolerance?(list, 1, 3)
        end)
  end

  defp weak_check(list, func) do
    Enum.any?(0..(length(list) - 1), fn index ->
      list
      |> List.delete_at(index)
      |> func.()
    end)
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    report =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.split(&1, ~r/\s+/))
      |> Stream.map(fn parts -> parts |> Enum.map(&String.to_integer/1) end)
      |> Enum.to_list()

    monotonic_results = report |> Enum.map(&ListUtils.monotonic?/1)
    step_results = report |> Enum.map(&ListUtils.within_step_tolerance?(&1, 1, 3))

    Enum.zip(monotonic_results, step_results)
    |> Enum.map(fn {a, b} -> a and b end)
    |> Enum.count(fn x -> x == true end)
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    report =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.split(&1, ~r/\s+/))
      |> Stream.map(fn parts -> parts |> Enum.map(&String.to_integer/1) end)
      |> Enum.to_list()

    report
    |> Enum.map(&dampened?/1)
    |> Enum.count(fn x -> x == true end)
  end
end
