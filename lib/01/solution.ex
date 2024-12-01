defmodule Aoc.D1 do
  def a do
    file_path = Path.join(__DIR__, "input.txt")

    case File.read(file_path) do
      {:ok, content} ->
        # IO.puts(content)

        lines = String.split(content, "\n")

        groups =
          for line <- lines,
              line != "",
              do:
                line |> String.split(~r/\s+/) |> Enum.map(&String.to_integer/1) |> List.to_tuple()

        group_one = groups |> Enum.map(&elem(&1, 0)) |> Enum.sort()
        group_two = groups |> Enum.map(&elem(&1, 1)) |> Enum.sort()

        Enum.zip(group_one, group_two)
        |> Enum.map(fn {a, b} -> abs(a - b) end)
        |> Enum.sum()

      {:error, reason} ->
        IO.puts("Failed to read file: #{reason}")
    end
  end

  def b do
    file_path = Path.join(__DIR__, "input.txt")

    case File.read(file_path) do
      {:ok, content} ->
        # IO.puts(content)

        lines = String.split(content, "\n")

        groups =
          for line <- lines,
              line != "",
              do:
                line |> String.split(~r/\s+/) |> Enum.map(&String.to_integer/1) |> List.to_tuple()

        group_one = groups |> Enum.map(&elem(&1, 0)) |> Enum.sort()
        frequencies = groups |> Enum.map(&elem(&1, 1)) |> Enum.frequencies()

        group_one
        |> Enum.map(&(&1 * Map.get(frequencies, &1, 0)))
        |> Enum.sum()

      {:error, reason} ->
        IO.puts("Failed to read file: #{reason}")
    end
  end
end
