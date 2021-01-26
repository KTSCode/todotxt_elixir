# TODO: think about the end user experience before writing anymore code
defmodule TodoTxt do
  @moduledoc """
  This module deals with parsing and structuring todo.txt data
  """
  defstruct todos: [%Todo{description: ""}], done_todos: [%Todo{description: "", done: true}]

  @doc """
  parse_todo_txt parses a list of raw todo strings from a todo file into a

  ## Examples

      iex> TodoTxt.parse_todo_txt(["x done", "todo"])
      %TodoTxt{todos: [%Todo{description: "todo", done: false}],
        done_todos: [%Todo{description: "done", done: true}]}
  """
  def parse_todo_txt(list_of_todos) do
    {done, undone} =
      list_of_todos
      |> Enum.map(&parse_todo/1)
      |> Enum.split_with(& &1.done)

    %TodoTxt{todos: undone, done_todos: done}
  end

  @doc """
  parse_todo parses a raw todo string into a Todo struct

  ## Examples

      iex> TodoTxt.parse_todo("x done")
      %Todo{description: "done", done: true}

      iex> TodoTxt.parse_todo("(A) top priority")
      %Todo{description: "top priority", priority: :A }
  """
  def parse_todo(todo_string) do
    {done_bool, undone_todo_string} = done_task_check(todo_string)
    {priority, deprioritized_string} = priority_task_check(undone_todo_string)

    %Todo{
      description: deprioritized_string,
      done: done_bool,
      priority: priority
    }
  end

  defp priority_task_check(todo_string) do
    priority_parsed =
      ~r/\([A-Z]\)/
      |> Regex.split(todo_string, include_captures: true)
      |> Enum.reject(&(&1 == ""))

    if Regex.match?(~r/\([A-Z]\)/, List.first(priority_parsed)) do
      [priority | deprioritized] = priority_parsed

      {String.to_atom(List.first(Regex.run(~r/[A-Z]/, priority))),
       String.trim(Enum.join(deprioritized, ""))}
    else
      {:none, todo_string}
    end
  end

  defp done_task_check(todo_string) do
    case todo_string do
      "x " <> clean_todo_string ->
        {true, clean_todo_string}

      clean_todo_string ->
        {false, clean_todo_string}
    end
  end
end
