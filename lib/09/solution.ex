defmodule DayNine do
  defmodule DiskFrag do
    def decompress([], _id, blocks), do: blocks

    def decompress([head | tail], id, blocks) do
      if rem(id, 2) == 0 do
        new_id = Integer.to_string(div(id, 2))
        decompress(tail, id + 1, List.flatten([gen_block(new_id, head) | blocks]))
      else
        decompress(tail, id + 1, List.flatten([gen_block(".", head) | blocks]))
      end
    end

    defp gen_block(char, count) do
      String.duplicate(char <> " ", count) |> String.trim() |> String.split(" ")
    end

    def free_space(blocks, left, right, transform) do
      if left >= right do
        transform
      else
        {a, b} = {elem(blocks, left), elem(blocks, right)}

        cond do
          a == -1 and b >= 0 ->
            free_space(blocks, left + 1, right - 1, swap(transform, left, right))

          a == -1 and b == -1 ->
            free_space(blocks, left, right - 1, transform)

          true ->
            free_space(blocks, left + 1, right, transform)
        end
      end
    end

    def free_space_whole(blocks, left, right, id) do
      {a, file_size} = find_contiguous(blocks, right, id, {right, 0})
      {b, _} = find_contiguous(blocks, left, -1, file_size, {left, 0})

      if id == 0 do
        blocks
      else
        if b + file_size <= right && b < a do
          pairs = for x <- 0..(file_size - 1), do: {a - x, b + x}

          blocks = Enum.reduce(pairs, blocks, fn {a, b}, acc -> swap(acc, a, b) end)

          {first_free, _} = find_contiguous(blocks, left, -1, {left, 0})
          free_space_whole(blocks, first_free, right, id - 1)
        else
          free_space_whole(blocks, left, a - file_size, id - 1)
        end
      end
    end

    defp find_contiguous(blocks, idx, type, threshold \\ 1, {start, count}) do
      char = elem(blocks, idx)
      next = if type < 0, do: idx + 1, else: idx - 1

      if next < 0 or next >= tuple_size(blocks) do
        {start, count}
      else
        cond do
          char == type -> find_contiguous(blocks, next, type, threshold, {start, count + 1})
          count == 0 -> find_contiguous(blocks, next, type, threshold, {next, count})
          count > threshold - 1 -> {start, count}
          true -> find_contiguous(blocks, next, type, threshold, {next, 0})
        end
      end
    end

    def swap(tuple, index1, index2) when index1 != index2 do
      elem1 = elem(tuple, index1)
      elem2 = elem(tuple, index2)

      tuple
      |> put_elem(index1, elem2)
      |> put_elem(index2, elem1)
    end

    def checksum(blocks) do
      blocks
      |> Enum.map(fn x -> if x == -1, do: 0, else: x end)
      |> Enum.with_index()
      |> Enum.map(fn {x, i} -> x * i end)
      |> Enum.sum()
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    decompressed =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()
      |> Enum.at(0)
      |> Enum.map(&String.to_integer/1)
      |> DiskFrag.decompress(0, [])
      |> Enum.reverse()
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn x -> if x != ".", do: String.to_integer(x), else: -1 end)
      |> List.to_tuple()

    decompressed
    |> DiskFrag.free_space(0, tuple_size(decompressed) - 1, decompressed)
    |> Tuple.to_list()
    |> DiskFrag.checksum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    decompressed =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()
      |> Enum.at(0)
      |> Enum.map(&String.to_integer/1)
      |> DiskFrag.decompress(0, [])
      |> Enum.reverse()
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn x -> if x != ".", do: String.to_integer(x), else: -1 end)
      |> List.to_tuple()

    last = tuple_size(decompressed) - 1
    id = elem(decompressed, last)

    decompressed
    |> DiskFrag.free_space_whole(0, last, id)
    |> Tuple.to_list()
    |> DiskFrag.checksum()
  end
end
