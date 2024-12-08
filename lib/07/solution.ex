defmodule DaySeven do
  defmodule Calibration do
    def calibrate(value, [], total), do: total === value

    def calibrate(value, [head | tail], total) do
      calibrate(value, tail, total + head) or calibrate(value, tail, total * head)
    end

    def calibrate_with_concat(value, [], total), do: total === value

    def calibrate_with_concat(value, [head | tail], total) do
      calibrate_with_concat(value, tail, total + head) or
        calibrate_with_concat(value, tail, total * head) or
        calibrate_with_concat(value, tail, concat(total, head))
    end

    defp concat(a, b),
      do:
        (Integer.to_string(a) <> Integer.to_string(b))
        |> String.to_integer()
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ":"))
    |> Stream.map(fn [value, operands] ->
      {value |> String.to_integer(),
       operands |> String.trim() |> String.split(~r/\s+/) |> Enum.map(&String.to_integer/1)}
    end)
    |> Enum.to_list()
    |> Enum.filter(fn {value, operands} -> Calibration.calibrate(value, operands, 0) end)
    |> Enum.map(fn {value, _} -> value end)
    |> Enum.sum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ":"))
    |> Stream.map(fn [value, operands] ->
      {value |> String.to_integer(),
       operands |> String.trim() |> String.split(~r/\s+/) |> Enum.map(&String.to_integer/1)}
    end)
    |> Enum.to_list()
    |> Enum.filter(fn {value, operands} ->
      Calibration.calibrate_with_concat(value, operands, 0)
    end)
    |> Enum.map(fn {value, _} -> value end)
    |> Enum.sum()
  end
end
