defmodule MyOwnRedis.MemoryManagerUtils do
  alias MyOwnRedis.Models.{ Table, RelationalTable, RelationalTableRef }

  def find_table_data(state, name) do
    table = state |> Enum.to_list() |> Enum.find(fn table -> table.name == name end)

    parsed_table_rows = table.rows |> Enum.to_list() |> Enum.map(
      fn row ->
        row |> Map.to_list() |> Enum.map(
          fn {cell_key, cell_value} ->
            row_index = Enum.find_index(table.rows, fn local_row -> local_row == row end)

            case cell_value do
              :ref ->
                local_ref_row_state = table.rows |> Enum.to_list() |> Enum.at(row_index)

                current_ref = table.columns |> Enum.to_list() |> Enum.find(
                  fn column ->
                    local_column_name_as_atom_or_false =
                      is_map(column) && Map.get(column, :local_column_name) |> String.to_existing_atom()
                    local_column_name_as_atom_or_false == cell_key
                  end
                )

                get_cell_data_by_ref(state, current_ref, local_ref_row_state)
              cell_valid_data ->
                cell_valid_data
            end
          end
        )
      end
    )

    %Table{
      name: table.name,
      columns: table.columns,
      rows: parsed_table_rows
    }
  end

  @spec get_cell_data_by_ref(list(%Table{} | %RelationalTable{}), %RelationalTableRef{}, map()) :: any()
  def get_cell_data_by_ref(state, ref, local_ref_row_state) do
    table = state |> Enum.to_list() |> Enum.find(fn table -> table.name == ref.table_ref_name end)

    row_index = table.rows |> Enum.to_list() |> Enum.find_index(
      fn row ->
        case Map.get(row, String.to_existing_atom(ref.column_source)) do
          nil ->
            raise "Inexistent row"
          value ->
            if Map.get(local_ref_row_state, String.to_existing_atom(ref.local_ref)) == value do
              true
            else
              false
            end
        end
      end
    )

    row_data = table.rows |> Enum.to_list() |> Enum.at(row_index)

    case Map.get(row_data, String.to_existing_atom(ref.column_result)) do
      nil ->
        raise "Inexistent column"
      :ref ->
        next_ref = table.columns |> Enum.to_list() |> Enum.find(
          fn column ->
            local_column_name_as_atom_or_false = is_map(column) && Map.get(column, :local_column_name)
            local_column_name_as_atom_or_false == ref.column_result
          end
        )

        get_cell_data_by_ref(state, next_ref, row_data)

      safe_cell_data ->
        safe_cell_data
    end
  end
end
