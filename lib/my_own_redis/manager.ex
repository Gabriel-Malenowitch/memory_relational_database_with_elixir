defmodule MyOwnRedis.Manager do
  alias MyOwnRedis.Models.{ Table, RelationalTable, RelationalTableRef }

  @spec create_table(list(%Table{} | %RelationalTable{}), String.t, list(String.t) | %RelationalTableRef{}) :: list(%Table{} | %RelationalTable{})
  def create_table(state, name, columns) do
    table = %Table{
      name: name,
      columns: columns,
      rows: []
    }

    [table | state]
  end

  @spec add_row(list(%Table{} | %RelationalTable{}), String.t, map() | :ref) :: list(%Table{} | %RelationalTable{})
  def add_row(state, table_name, row_data) do
    table = Enum.to_list(state) |> Enum.find(fn table -> table.name == table_name end)

    if(table == nil) do raise "Table not found" end

    parsed_table = %{ table | rows: [row_data | table.rows] }

    state_without_table = state |> Enum.to_list() |> Enum.filter(fn table -> table.name != table_name end)
    [parsed_table | state_without_table]
  end
end
