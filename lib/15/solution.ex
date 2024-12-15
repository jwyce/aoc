defmodule DayFifteen do
  defmodule RobotSim do
    def to_move(grid, {x, y}, dir, set) do
      next =
        case dir do
          :up -> {x, y - 1}
          :down -> {x, y + 1}
          :left -> {x - 1, y}
          :right -> {x + 1, y}
        end

      cell = at(grid, {x, y})

      case cell do
        "#" ->
          MapSet.new()

        "." ->
          set

        _ ->
          set = MapSet.put(set, {{x, y}, cell})
          to_move(grid, next, dir, set)
      end
    end

    def to_move_wide(grid, {x, y}, dir, set) do
      next =
        case dir do
          :up -> {x, y - 1}
          :down -> {x, y + 1}
          :left -> {x - 1, y}
          :right -> {x + 1, y}
        end

      cell = at(grid, {x, y})
      {nx, ny} = next

      case cell do
        "#" ->
          MapSet.new()

        "." ->
          set

        _ ->
          cond do
            dir in [:left, :right] or cell == "@" ->
              set = MapSet.put(set, {{x, y}, cell})
              to_move_wide(grid, next, dir, set)

            dir in [:up, :down] ->
              case cell do
                "[" ->
                  set = MapSet.put(set, {{x, y}, cell})
                  set = MapSet.put(set, {{x + 1, y}, "]"})
                  {nx, ny} = next

                  b1 = to_move_wide(grid, next, dir, set)
                  b2 = to_move_wide(grid, {nx + 1, ny}, dir, set)

                  if MapSet.size(b1) == 0 or MapSet.size(b2) == 0 do
                    MapSet.new()
                  else
                    MapSet.union(b1, b2)
                  end

                "]" ->
                  set = MapSet.put(set, {{x, y}, cell})
                  set = MapSet.put(set, {{x - 1, y}, "["})

                  b1 = to_move_wide(grid, next, dir, set)
                  b2 = to_move_wide(grid, {nx - 1, ny}, dir, set)

                  if MapSet.size(b1) == 0 or MapSet.size(b2) == 0 do
                    MapSet.new()
                  else
                    MapSet.union(b1, b2)
                  end
              end
          end
      end
    end

    def move(grid, cells, dir) do
      grid = Enum.reduce(cells, grid, fn {{x, y}, _}, acc -> update(acc, x, y, ".") end)

      Enum.reduce(cells, grid, fn {{x, y}, cell}, acc ->
        case dir do
          :up -> update(acc, x, y - 1, cell)
          :down -> update(acc, x, y + 1, cell)
          :left -> update(acc, x - 1, y, cell)
          :right -> update(acc, x + 1, y, cell)
        end
      end)
    end

    def update(grid, x, y, cell) do
      row = put_elem(elem(grid, y), x, cell)
      put_elem(grid, y, row)
    end

    def at(grid, {x, y}) do
      grid
      |> elem(y)
      |> elem(x)
    end

    def scale(grid) do
      grid
      |> Tuple.to_list()
      |> Enum.map(fn row ->
        row
        |> Tuple.to_list()
        |> Enum.join("")
        |> String.replace(".", "..")
        |> String.replace("O", "[]")
        |> String.replace("#", "##")
        |> String.replace("@", "@.")
        |> String.graphemes()
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end

    def find_robot(grid) do
      grid
      |> Tuple.to_list()
      |> Enum.with_index()
      |> Enum.reduce_while(nil, fn {row, y}, _acc ->
        case find_in_row(row) do
          nil -> {:cont, nil}
          x -> {:halt, {x, y}}
        end
      end)
    end

    defp find_in_row(row) do
      row
      |> Tuple.to_list()
      |> Enum.find_index(&(&1 == "@"))
    end

    def find_boxes(grid, target) do
      grid
      |> Tuple.to_list()
      #
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        find_all_in_row(row, y, target)
      end)
    end

    defp find_all_in_row(row, y, target) do
      row
      |> Tuple.to_list()
      |> Enum.with_index()
      |> Enum.filter(fn {value, _x} -> value == target end)
      |> Enum.map(fn {_value, x} -> {x, y} end)
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    {grid, directions} =
      File.read!(file)
      |> String.split("\n\n")
      |> List.to_tuple()

    grid =
      String.split(grid, "\n")
      |> Enum.map(fn x -> x |> String.graphemes() |> List.to_tuple() end)
      |> List.to_tuple()

    dirs =
      String.replace(directions, "\n", "")
      |> String.split("", trim: true)
      |> Enum.map(fn x ->
        case x do
          "^" -> :up
          "v" -> :down
          "<" -> :left
          ">" -> :right
        end
      end)

    robot = RobotSim.find_robot(grid)

    {grid, _} =
      dirs
      |> Enum.reduce({grid, robot}, fn dir, {grid, {x, y}} ->
        to_move = RobotSim.to_move(grid, {x, y}, dir, MapSet.new())

        if MapSet.size(to_move) == 0 do
          {grid, {x, y}}
        else
          grid = RobotSim.move(grid, to_move, dir)
          {grid, RobotSim.find_robot(grid)}
        end
      end)

    RobotSim.find_boxes(grid, "O") |> Enum.map(&(elem(&1, 0) + 100 * elem(&1, 1))) |> Enum.sum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    {grid, directions} =
      File.read!(file)
      |> String.split("\n\n")
      |> List.to_tuple()

    grid =
      String.split(grid, "\n")
      |> Enum.map(fn x -> x |> String.graphemes() |> List.to_tuple() end)
      |> List.to_tuple()

    dirs =
      String.replace(directions, "\n", "")
      |> String.split("", trim: true)
      |> Enum.map(fn x ->
        case x do
          "^" -> :up
          "v" -> :down
          "<" -> :left
          ">" -> :right
        end
      end)

    grid = RobotSim.scale(grid)
    robot = RobotSim.find_robot(grid)

    {grid, _} =
      dirs
      |> Enum.reduce({grid, robot}, fn dir, {grid, {x, y}} ->
        to_move = RobotSim.to_move_wide(grid, {x, y}, dir, MapSet.new())

        if MapSet.size(to_move) == 0 do
          {grid, {x, y}}
        else
          grid = RobotSim.move(grid, to_move, dir)

          {grid, RobotSim.find_robot(grid)}
        end
      end)

    for row <- grid |> Tuple.to_list() do
      IO.puts(Enum.join(row |> Tuple.to_list(), ""))
    end

    RobotSim.find_boxes(grid, "[") |> Enum.map(&(elem(&1, 0) + 100 * elem(&1, 1))) |> Enum.sum()
  end
end
