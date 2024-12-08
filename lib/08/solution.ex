defmodule DayEight do
  defmodule Resonance do
    def antinodes(pairs, size) do
      pairs
      |> Enum.flat_map(fn {a, b} ->
        {ax, ay} = a
        {bx, by} = b
        {dx, dy} = {ax - bx, ay - by}

        [{ax + dx, ay + dy}, {bx - dx, by - dy}] |> Enum.filter(&in_bounds?(&1, size))
      end)
    end

    def general_antinodes(pairs, size) do
      pairs
      |> Enum.flat_map(fn {a, b} ->
        {ax, ay} = a
        {bx, by} = b
        {dx, dy} = {ax - bx, ay - by}

        positive = gen_antinodes(a, {dx, dy}, size, :plus, [a])
        negative = gen_antinodes(a, {dx, dy}, size, :minus, [a])
        Enum.concat(positive, negative)
      end)
    end

    defp gen_antinodes({x, y}, {dx, dy}, size, op, nodes) do
      next = if op == :plus, do: {x + dx, y + dy}, else: {x - dx, y - dy}

      if not in_bounds?(next, size),
        do: nodes,
        else: gen_antinodes(next, {dx, dy}, size, op, [next | nodes])
    end

    defp in_bounds?(pos, size) do
      {x, y} = pos
      x >= 0 and y >= 0 and x < size and y < size
    end

    def antenna?(char) do
      String.match?(char, ~r/^[a-zA-Z0-9]$/)
    end

    def gen_pairs([]), do: []
    def gen_pairs([_]), do: []

    def gen_pairs([head | tail]) do
      pairs_with_head = for elem <- tail, do: {head, elem}
      pairs_with_head ++ gen_pairs(tail)
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    map =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()

    map
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} -> if Resonance.antenna?(cell), do: {cell, {x, y}} end)
    end)
    |> Enum.filter(&is_tuple/1)
    |> Enum.reduce(%{}, fn {cell, pos}, acc ->
      Map.update(acc, cell, [pos], &[pos | &1])
    end)
    |> Map.new(fn {cell, positions} ->
      {cell, positions |> Resonance.gen_pairs()}
    end)
    |> Map.to_list()
    |> Enum.reduce(MapSet.new(), fn {_, pairs}, acc ->
      antinodes = MapSet.new(Resonance.antinodes(pairs, Enum.count(map)))
      MapSet.union(acc, antinodes)
    end)
    |> MapSet.size()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    map =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()

    map
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} -> if Resonance.antenna?(cell), do: {cell, {x, y}} end)
    end)
    |> Enum.filter(&is_tuple/1)
    |> Enum.reduce(%{}, fn {cell, pos}, acc ->
      Map.update(acc, cell, [pos], &[pos | &1])
    end)
    |> Map.new(fn {cell, positions} ->
      {cell, positions |> Resonance.gen_pairs()}
    end)
    |> Map.to_list()
    |> Enum.reduce(MapSet.new(), fn {_, pairs}, acc ->
      antinodes = MapSet.new(Resonance.general_antinodes(pairs, Enum.count(map)))
      MapSet.union(acc, antinodes)
    end)
    |> MapSet.size()
  end
end
