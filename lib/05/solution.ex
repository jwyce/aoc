defmodule DayFive do
  defmodule ListUtils do
    def find_indices(list, a, b) do
      idxA = Enum.find_index(list, fn x -> x == a end)
      idxB = Enum.find_index(list, fn x -> x == b end)
      {idxA, idxB}
    end

    def middle_element(list) do
      case length(list) do
        0 -> nil
        n -> Enum.at(list, div(n, 2))
      end
    end
  end

  def correct_order?(list, rules) do
    rules
    |> Enum.reduce(true, fn rule, acc ->
      {a, b} = rule
      {idxA, idxB} = ListUtils.find_indices(list, a, b)
      acc && (idxA < idxB || (idxA == nil || idxB == nil))
    end)
  end

  def sort([], _, result), do: result

  def sort(page, must_come_before, result) do
    available =
      Enum.filter(page, fn x ->
        deps = Map.get(must_come_before, x)

        if deps == nil,
          do: true,
          else: Enum.all?(deps, fn dep -> not Enum.member?(page, dep) end)
      end)

    if length(available) == 0 do
      result = [Enum.at(page, 0) | result]
      next = page |> Enum.filter(fn x -> x != Enum.at(page, 0) end)
      sort(next, must_come_before, result)
    else
      result = [Enum.at(available, 0) | result]
      next = page |> Enum.filter(fn x -> x != Enum.at(available, 0) end)
      sort(next, must_come_before, result)
    end
  end

  def a do
    file = Path.join(__DIR__, "input.txt")

    [rules, pages] =
      File.read!(file)
      |> String.split("\n\n")
      |> Enum.to_list()

    rules =
      rules
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "|"))
      |> Enum.map(fn pairs -> pairs |> Enum.map(&String.to_integer/1) end)
      |> Enum.map(&List.to_tuple/1)

    pages =
      pages
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn items -> items |> Enum.map(&String.to_integer/1) end)

    pages
    |> Enum.map(fn page ->
      if correct_order?(page, rules), do: ListUtils.middle_element(page), else: 0
    end)
    |> Enum.sum()
  end

  def b do
    file = Path.join(__DIR__, "input.txt")

    [rules, pages] =
      File.read!(file)
      |> String.split("\n\n")
      |> Enum.to_list()

    rules =
      rules
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "|"))
      |> Enum.map(fn pairs -> pairs |> Enum.map(&String.to_integer/1) end)
      |> Enum.map(&List.to_tuple/1)

    pages =
      pages
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn items -> items |> Enum.map(&String.to_integer/1) end)

    invalid_pages =
      pages
      |> Enum.filter(fn page -> not correct_order?(page, rules) end)

    invalid_pages
    |> Enum.map(fn page ->
      must_come_before =
        rules
        |> Enum.reduce(%{}, fn rule, acc ->
          {a, b} = rule

          if Enum.member?(page, a) && Enum.member?(page, b) do
            if acc[b] == nil, do: Map.put(acc, b, [a]), else: Map.put(acc, b, [a | acc[b]])
          else
            acc
          end
        end)

      sort(page, must_come_before, []) |> Enum.reverse() |> ListUtils.middle_element()
    end)
    |> Enum.sum()
  end
end
