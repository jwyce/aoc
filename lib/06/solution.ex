defmodule DaySix do
  defmodule Cartographer do
    def search(visited) do
      {MapSet.size(visited), :loop}
    end

    def search(_map, {x, y}, size, _dir, visited, _loop_count)
        when x < 0 or y < 0 or x >= size or y >= size do
      {MapSet.size(visited), :escaped}
    end

    def search(map, {x, y}, size, dir, visited, loop_count)
        when x >= 0 and y >= 0 and x < size and y < size do
      dir = next_dir(map, {x, y}, dir, 0)

      next =
        case(dir) do
          :up -> {x, y - 1}
          :down -> {x, y + 1}
          :left -> {x - 1, y}
          :right -> {x + 1, y}
          nil -> {x, y}
        end

      if 2 * MapSet.size(visited) < loop_count && loop_count > 0 do
        search(visited)
      else
        nlc = if MapSet.member?(visited, next), do: loop_count + 1, else: 0
        visited = MapSet.put(visited, next)
        search(map, next, size, dir, visited, nlc)
      end
    end

    defp next_dir(map, {x, y}, dir, count) do
      lookahead = %{
        :up => at(map, x, y - 1),
        :down => at(map, x, y + 1),
        :left => at(map, x - 1, y),
        :right => at(map, x + 1, y)
      }

      dir_map = %{
        :up => :right,
        :down => :left,
        :left => :up,
        :right => :down
      }

      if count >= 3 do
        nil
      else
        if Map.get(lookahead, dir) == "#",
          do: next_dir(map, {x, y}, Map.get(dir_map, dir), count + 1),
          else: dir
      end
    end

    defp at(grid, x, y) do
      if x < 0 || y < 0 || x >= Enum.count(grid) || y >= Enum.count(grid) do
        nil
      else
        grid |> Enum.at(y) |> Enum.at(x)
      end
    end

    def map_replace(map, start) do
      for y <- 0..(length(map) - 1),
          x <- 0..(length(Enum.at(map, 0)) - 1) do
        if {x, y} != start do
          replace_cell(map, x, y, "#")
        else
          map
        end
      end
    end

    defp replace_cell(map, x, y, value) do
      List.replace_at(map, x, List.replace_at(Enum.at(map, x), y, value))
    end
  end

  defmodule ConcurrentMapper do
    def map_concurrently(enum, func) do
      enum
      |> Task.async_stream(func, max_concurrency: System.schedulers_online(), timeout: :infinity)
      |> Enum.map(fn {:ok, result} -> result end)
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    map =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()

    start =
      map
      |> Enum.with_index()
      |> Enum.find_value(fn {row, y} ->
        case Enum.find_index(row, fn char -> char == "^" end) do
          nil -> nil
          x -> {x, y}
        end
      end)

    Cartographer.search(map, start, Enum.count(map), :up, MapSet.new(), 0)
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    map =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()

    start =
      map
      |> Enum.with_index()
      |> Enum.find_value(fn {row, y} ->
        case Enum.find_index(row, fn char -> char == "^" end) do
          nil -> nil
          x -> {x, y}
        end
      end)

    # speed up with gen server concurrency?
    (Cartographer.map_replace(map, start)
     |> ConcurrentMapper.map_concurrently(fn map ->
       Cartographer.search(map, start, Enum.count(map), :up, MapSet.new(), 0)
     end)
     |> Enum.filter(fn {_, type} -> type == :loop end)
     |> Enum.count()) + 1
  end
end
