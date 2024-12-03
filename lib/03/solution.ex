defmodule DayThree do
  defmodule Parser do
    def parse(input) do
      regex = ~r/(?:do\(\)|don't\(\))|mul\((\d{1,3}),(\d{1,3})\)/

      for match <- Regex.scan(regex, input) do
        case match do
          ["do()"] -> {:do}
          ["don't()"] -> {:dont}
          [_, x, y] -> {:mul, String.to_integer(x), String.to_integer(y)}
        end
      end
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.flat_map(&Parser.parse/1)
    |> Enum.to_list()
    |> Enum.filter(&(elem(&1, 0) == :mul))
    |> Enum.map(fn {:mul, x, y} -> x * y end)
    |> Enum.sum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.flat_map(&Parser.parse/1)
    |> Enum.to_list()
    |> Enum.reduce({[], true}, fn
      {:do}, {acc, _} -> {acc, true}
      {:dont}, {acc, _} -> {acc, false}
      element, {acc, true} -> {[element | acc], true}
      _, {acc, false} -> {acc, false}
    end)
    |> elem(0)
    |> Enum.map(fn {:mul, x, y} -> x * y end)
    |> Enum.sum()
  end
end
