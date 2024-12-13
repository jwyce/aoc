defmodule DayThirteen do
  defmodule ClawSolver do
    import Nx

    def solve_bf(machine) do
      {ax, ay} = elem(machine, 0)
      {bx, by} = elem(machine, 1)
      {px, py} = elem(machine, 2)

      pairs = for a <- 0..100, b <- 0..100, do: {a, b}

      pairs
      |> Enum.reduce(:infinity, fn {a, b}, best ->
        {x, y} = {ax * a + bx * b, ay * a + by * b}
        if {x, y} == {px, py}, do: Kernel.min(best, 3 * a + b), else: best
      end)
    end

    def solve_sys_eq(machine) do
      {ax, ay} = elem(machine, 0)
      {bx, by} = elem(machine, 1)
      {px, py} = elem(machine, 2)
      {px, py} = {px + 10_000_000_000_000, py + 10_000_000_000_000}

      m = tensor([[ax, ay], [bx, by]], type: :f64) |> transpose()
      r = tensor([px, py], type: :f64)

      [a, b] = Nx.LinAlg.solve(m, r) |> to_flat_list()
      a = Kernel.round(a)
      b = Kernel.round(b)

      {x, y} = {a * ax + b * bx, a * ay + b * by}

      if {x, y} == {px, py},
        do: 3 * a + b,
        else: :infinity
    end

    def nums(strings) when is_list(strings) do
      Enum.map(strings, &nums/1)
      |> List.to_tuple()
    end

    def nums(str) do
      Regex.scan(~r/X[\+=](\d+), Y[\+=](\d+)/, str)
      |> Enum.at(0)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.chunk_every(3)
    |> Stream.map(fn line -> ClawSolver.nums(line) end)
    |> Enum.to_list()
    |> Enum.map(&ClawSolver.solve_bf/1)
    |> Enum.filter(&(&1 != :infinity))
    |> Enum.sum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.chunk_every(3)
    |> Stream.map(fn line -> ClawSolver.nums(line) end)
    |> Enum.to_list()
    |> Enum.map(&ClawSolver.solve_sys_eq/1)
    |> Enum.filter(&(&1 != :infinity))
    |> Enum.sum()
  end
end
