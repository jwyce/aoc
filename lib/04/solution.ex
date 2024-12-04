defmodule DayFour do
  defmodule WordSearch do
    def search(grid) do
      grid
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {_cell, x} ->
          search(grid, {x, y}, 0)
        end)
      end)
      |> Enum.sum()
    end

    defp search(grid, pos, count) do
      [:right, :down, :left, :up, :up_right, :down_right, :down_left, :up_left]
      |> Enum.reduce(count, fn dir, acc ->
        search(grid, pos, "", Enum.count(grid), dir) + acc
      end)
    end

    defp search(_grid, {x, y}, _curr, size, _dir) when x < 0 or y < 0 or x >= size or y >= size,
      do: 0

    defp search(grid, {x, y}, curr, size, dir)
         when x >= 0 and y >= 0 and x < size and y < size do
      word = curr <> at(grid, x, y)

      case "XMAS" do
        ^word ->
          1

        <<^word::binary, _::binary>> ->
          case dir do
            :right -> search(grid, {x + 1, y}, word, size, dir)
            :down -> search(grid, {x, y + 1}, word, size, dir)
            :left -> search(grid, {x - 1, y}, word, size, dir)
            :up -> search(grid, {x, y - 1}, word, size, dir)
            :up_right -> search(grid, {x + 1, y - 1}, word, size, dir)
            :down_right -> search(grid, {x + 1, y + 1}, word, size, dir)
            :down_left -> search(grid, {x - 1, y + 1}, word, size, dir)
            :up_left -> search(grid, {x - 1, y - 1}, word, size, dir)
          end

        _ ->
          0
      end
    end

    defp at(grid, x, y) do
      if x < 0 || y < 0 do
        nil
      else
        grid |> Enum.at(x) |> Enum.at(y)
      end
    end

    def diagonal_neighbors(grid, {x, y}) do
      [
        # up right
        {x + 1, y - 1},
        # down right
        {x + 1, y + 1},
        # down left
        {x - 1, y + 1},
        # up left
        {x - 1, y - 1}
      ]
      |> Enum.filter(fn {x, y} ->
        x >= 0 and y >= 0 and x < Enum.count(grid) and y < Enum.count(grid)
      end)
      |> Enum.map(fn {x, y} -> at(grid, y, x) end)
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    File.stream!(file, :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> (&WordSearch.search/1).()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    grid =
      File.stream!(file, :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()

    grid
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} ->
        neighbors = WordSearch.diagonal_neighbors(grid, {x, y})

        case cell do
          "A" ->
            case neighbors do
              ["M", "M", "S", "S"] -> 1
              ["M", "S", "S", "M"] -> 1
              ["S", "S", "M", "M"] -> 1
              ["S", "M", "M", "S"] -> 1
              _ -> 0
            end

          _ ->
            0
        end
      end)
    end)
    |> Enum.sum()
  end
end
