defmodule Aoc.D1 do
  def a do
    file_path = Path.join(__DIR__, "input.txt")

    case File.read(file_path) do
      {:ok, content} ->
        IO.puts(content)

      {:error, reason} ->
        IO.puts("Failed to read file: #{reason}")
    end

    :a
  end

  def b do
    :b
  end
end
