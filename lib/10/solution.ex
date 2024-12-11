defmodule DayTen do
  defmodule TrailBlazer do
    def score(head, trail) do
      score(head, trail, 0) |> MapSet.new() |> MapSet.size()
    end

    defp score(head, trail, height) do
      if height == 9 do
        [head]
      else
        neighbors = neighbors(head, trail, height)

        if length(neighbors) > 0 do
          neighbors
          |> Enum.flat_map(&score(&1, trail, height + 1))
        else
          []
        end
      end
    end

    def rating(head, trail) do
      rating(head, trail, 0)
    end

    defp rating(head, trail, height) do
      if height == 9 do
        1
      else
        neighbors = neighbors(head, trail, height)

        if length(neighbors) > 0 do
          neighbors
          |> Enum.map(&rating(&1, trail, height + 1))
          |> Enum.sum()
        else
          0
        end
      end
    end

    defp neighbors({x, y}, trail, height) do
      [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
      |> Enum.filter(fn {x, y} -> in_bounds(trail, x, y) and at(trail, x, y) - height == 1 end)
    end

    defp in_bounds(trail, x, y) do
      x >= 0 && x < Enum.count(trail) && y >= 0 && y < Enum.count(trail)
    end

    defp at(grid, x, y) do
      if in_bounds(grid, x, y) do
        grid |> Enum.at(y) |> Enum.at(x)
      end
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    trail =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Enum.to_list()
      |> Enum.map(fn row ->
        Enum.map(String.graphemes(row), &String.to_integer/1)
      end)

    trail
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} -> if cell == 0, do: {x, y} end)
    end)
    |> Enum.filter(&is_tuple/1)
    |> Enum.map(&TrailBlazer.score(&1, trail))
    |> Enum.sum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    trail =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Enum.to_list()
      |> Enum.map(fn row ->
        Enum.map(String.graphemes(row), &String.to_integer/1)
      end)

    trail
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} -> if cell == 0, do: {x, y} end)
    end)
    |> Enum.filter(&is_tuple/1)
    |> Enum.map(&TrailBlazer.rating(&1, trail))
    |> Enum.sum()
  end
end
