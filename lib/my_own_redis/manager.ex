defmodule MyOwnRedis.Manager do
  alias MyOwnRedis.Models.{ Table, RelationalTable, RelationalTableRef }
  alias MyOwnRedis.MemoryManagerUtils

  @spec create_table(list(%Table{} | %RelationalTable{}), String.t, list(String.t) | %RelationalTableRef{}) :: list(%Table{} | %RelationalTable{})
  def create_table(state, name, columns) do
    table = %Table{
      name: name,
      columns: columns,
      rows: []
    }

    [table | state]
  end

  @spec get_table(list(%Table{} | %RelationalTable{}), String.t) :: %Table{}
  def get_table(state, name) do
    table = state |> Enum.to_list() |> Enum.find(fn table -> table.name == name end)
    if(table == nil) do raise "Table not found" end

    MemoryManagerUtils.find_table_data(state, name)
  end

  @spec drop_table(list(%Table{} | %RelationalTable{}), String.t) :: list(%Table{} | %RelationalTable{})
  def drop_table(state, name) do
    state |> Enum.to_list() |> Enum.filter(fn table -> table.name != name end)
  end

  @spec add_row(list(%Table{} | %RelationalTable{}), String.t, map() | :ref) :: list(%Table{} | %RelationalTable{})
  def add_row(state, table_name, row_data) do
    table = Enum.to_list(state) |> Enum.find(fn table -> table.name == table_name end)

    if(table == nil) do raise "Table not found" end

    parsed_table = %{ table | rows: [row_data | table.rows] }

    state_without_table = state |> Enum.to_list() |> Enum.filter(fn table -> table.name != table_name end)
    [parsed_table | state_without_table]
  end

  @spec remove_row(list(%Table{} | %RelationalTable{}), String.t, {String.t, String.t}) :: list(%Table{} | %RelationalTable{})
  def remove_row(state, table_name, {where, value}) do
    table = Enum.to_list(state) |> Enum.find(fn table -> table.name == table_name end)
    if(table == nil) do raise "Table not found" end

    parsed_table = %{
      table |
      rows: Enum.to_list(table.rows) |> Enum.filter(
        fn row ->
          row[String.to_existing_atom(where)] != value
        end
      )
    }

    state_without_table = state |> Enum.to_list() |> Enum.filter(fn table -> table.name != table_name end)
    [parsed_table | state_without_table]
  end

  @spec edit_row(list(%Table{} | %RelationalTable{}), String.t, {String.t, String.t}, map()) :: list(%Table{} | %RelationalTable{})
  def edit_row(state, table_name, {where, value}, row_data) do
    table = state |> Enum.to_list() |> Enum.find(fn table -> table.name == table_name end)
    if(table == nil) do raise "Table not found" end

    parsed_table = %{
      table |
      rows: table.rows |> Enum.to_list() |> Enum.map(
        fn row ->
          row[String.to_existing_atom(where)] == value && row_data || row
        end
      )
    }
    state_without_table = state |> Enum.filter(fn table -> table.name != table_name end)
    [parsed_table | state_without_table]
  end

  @spec remove_column(list(%Table{} | %RelationalTable{}), String.t, String.t) :: list(%Table{} | %RelationalTable{})
  def remove_column(state, table_name, column_name) do
    table = Enum.to_list(state) |> Enum.find(fn table -> table.name == table_name end)
    if(table == nil) do raise "Table not found" end

    parsed_table = %{
      %{
        table |
        columns: Enum.to_list(table.columns) |> Enum.filter(
          fn column ->
            is_map(column) && column.column_name != column_name || column != column_name
          end
        )
      } |
      rows: Enum.to_list(table.rows) |> Enum.map(
        fn row ->
          Map.delete(row, String.to_existing_atom(column_name))
        end
      )
    }

    state_without_table = state |> Enum.to_list() |> Enum.filter(fn table -> table.name != table_name end)
    [parsed_table | state_without_table]
  end

  @spec create_column(list(%Table{} | %RelationalTable{}), String.t, String.t) :: list(%Table{} | %RelationalTable{})
  def create_column(state, table_name, column_name) do
    table = Enum.to_list(state) |> Enum.find(fn table -> table.name == table_name end)
    if(table == nil) do raise "Table not found" end

    parsed_table = %{
      %{
        table |
        columns: [ table.columns | column_name ]
      } |
      rows: Enum.to_list(table.rows) |> Enum.map(
        fn row ->
          row_value = is_map(column_name) && :ref || ""
          Map.put(row, String.to_existing_atom(column_name), row_value)
        end
      )
    }

    state_without_table = state |> Enum.to_list() |> Enum.filter(fn table -> table.name != table_name end)
    [parsed_table | state_without_table]
  end


end
