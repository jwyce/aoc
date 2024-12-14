defmodule DayFourteen do
  @time 100
  @width 101
  @height 103

  defmodule RobotSim do
    # find the moment when there are no overlapping robots
    def find_christmas_tree(robots, t, width, height) do
      positions =
        Enum.map(robots, fn {{x, y}, {vx, vy}} ->
          {Integer.mod(x + vx * t, width), Integer.mod(y + vy * t, height)}
        end)

      unique_positions = Enum.uniq(positions)

      if length(unique_positions) == length(positions) do
        {t, positions}
      else
        find_christmas_tree(robots, t + 1, width, height)
      end
    end

    def quads(positions, width, height) do
      quads = Tuple.duplicate(0, 4)
      hm = (width - 1) / 2
      vm = (height - 1) / 2

      Enum.reduce(positions, quads, fn {x, y}, quads ->
        cond do
          x < hm && y < vm -> put_elem(quads, 0, elem(quads, 0) + 1)
          x > hm && y < vm -> put_elem(quads, 1, elem(quads, 1) + 1)
          x < hm && y > vm -> put_elem(quads, 2, elem(quads, 2) + 1)
          x > hm && y > vm -> put_elem(quads, 3, elem(quads, 3) + 1)
          true -> quads
        end
      end)
      |> Tuple.to_list()
    end

    def elapse(robots, time, width, height) do
      robots
      |> Enum.map(fn {{x, y}, {vx, vy}} ->
        {Integer.mod(x + vx * time, width), Integer.mod(y + vy * time, height)}
      end)
    end

    def view_positions(robots, width, height) do
      grid = for _ <- 1..height, do: for(_ <- 1..width, do: 0)

      Enum.reduce(robots, grid, fn {x, y}, grid ->
        if x in 0..(width - 1) and y in 0..(height - 1) do
          List.update_at(grid, y, fn row ->
            List.update_at(row, x, &(&1 + 1))
          end)
        else
          grid
        end
      end)
    end

    def nums(strings) when is_list(strings) do
      Enum.map(strings, &nums/1)
      |> List.to_tuple()
    end

    def nums(str) do
      Regex.scan(~r/(-?\d+),(-?\d+)/, str)
      |> Enum.map(fn x ->
        x |> Enum.drop(1) |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)
      |> List.to_tuple()
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> RobotSim.nums(line) end)
    |> Enum.to_list()
    |> RobotSim.elapse(@time, @width, @height)
    |> RobotSim.quads(@width, @height)
    |> Enum.reduce(1, &Kernel.*/2)

    # |> RobotSim.view_positions(@width, @height)
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    {time, _robots} =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn line -> RobotSim.nums(line) end)
      |> Enum.to_list()
      |> RobotSim.find_christmas_tree(0, @width, @height)

    time

    # grid = RobotSim.view_positions(robots, @width, @height)
    #
    # for row <- grid do
    #   IO.puts(Enum.map_join(row, "", &Integer.to_string/1))
    # end
  end
end
