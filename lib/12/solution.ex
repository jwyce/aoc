defmodule DayTwelve do
  defmodule GardenGrouper do
    def components(garden, seen, groups) do
      garden
      |> Enum.with_index()
      |> Enum.reduce({groups, seen}, fn {row, y}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {cell, x}, {groups, seen} ->
          key = cell <> inspect({x, y})

          if not MapSet.member?(seen, {x, y}) do
            components = flood_fill(garden, {x, y}, MapSet.new())
            new_groups = Map.put(groups, key, components)
            new_seen = MapSet.union(seen, components)
            {new_groups, new_seen}
          else
            {groups, seen}
          end
        end)
      end)
    end

    def flood_fill(garden, {x, y}, seen) do
      seen = MapSet.put(seen, {x, y})

      neighbors =
        neighbors({x, y}, garden)
        |> Enum.reject(&MapSet.member?(seen, &1))

      if length(neighbors) == 0 do
        seen
      else
        neighbors
        |> Enum.reduce(seen, fn {x, y}, seen ->
          MapSet.union(seen, flood_fill(garden, {x, y}, seen))
        end)
      end
    end

    def perimeter(garden, group) do
      group
      |> Enum.map(fn {x, y} -> 4 - length(neighbors({x, y}, garden)) end)
      |> Enum.sum()
    end

    def sides(garden, group) do
      group
      |> Enum.map(fn {x, y} ->
        cell = at(garden, x, y)
        neighbors = fences({x, y}, garden, cell)
        right = fences({x + 1, y}, garden, cell)
        down = fences({x, y + 1}, garden, cell)

        up_or_down_sub =
          case Enum.count([:up, :down], fn dir -> dir in neighbors and dir in right end) do
            0 -> 0
            1 -> 1
            2 -> 2
          end

        left_or_right_sub =
          case Enum.count([:left, :right], fn dir -> dir in neighbors and dir in down end) do
            0 -> 0
            1 -> 1
            2 -> 2
          end

        length(neighbors) - up_or_down_sub - left_or_right_sub
      end)
      |> Enum.sum()
    end

    defp neighbors({x, y}, garden) do
      component = at(garden, x, y)

      [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
      |> Enum.filter(fn {x, y} ->
        in_bounds(garden, x, y) && at(garden, x, y) == component
      end)
    end

    defp fences({x, y}, garden, cell) do
      component = at(garden, x, y)

      if component != cell do
        []
      else
        [{x, y - 1, :up}, {x, y + 1, :down}, {x - 1, y, :left}, {x + 1, y, :right}]
        |> Enum.filter(fn {x, y, _} ->
          !in_bounds(garden, x, y) || at(garden, x, y) != component
        end)
        |> Enum.map(fn {_, _, dir} -> dir end)
      end
    end

    defp in_bounds(garden, x, y) do
      x >= 0 && x < Enum.count(garden) && y >= 0 && y < Enum.count(garden)
    end

    defp at(grid, x, y) do
      if in_bounds(grid, x, y) do
        grid |> Enum.at(y) |> Enum.at(x)
      end
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    garden =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()

    {cc, _} =
      garden
      |> GardenGrouper.components(MapSet.new(), %{})

    cc
    |> Enum.map(fn {key, group} ->
      {key, MapSet.size(group), GardenGrouper.perimeter(garden, group)}
    end)
    |> Enum.map(fn {_, area, perimeter} -> area * perimeter end)
    |> Enum.sum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    garden =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()

    {cc, _} =
      garden
      |> GardenGrouper.components(MapSet.new(), %{})

    cc
    |> Enum.map(fn {key, group} ->
      {key, MapSet.size(group), GardenGrouper.sides(garden, group)}
    end)
    |> Enum.map(fn {_, area, perimeter} -> area * perimeter end)
    |> Enum.sum()
  end
end
