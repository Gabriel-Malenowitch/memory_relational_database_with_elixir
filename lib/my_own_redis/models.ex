defmodule MyOwnRedis.Models.Table do
  @type t :: %__MODULE__{
    name: String.t,
    columns: list(String.t),
    rows: list(map())
  }

  defstruct [
    :name,
    :columns,
    :rows,
  ]
end

defmodule MyOwnRedis.Models.RelationalTableRef do
  @type t :: %__MODULE__{
    table_ref_name: String.t,
    column_name: String.t,
    column_source: String.t,
    column_result: String.t
  }

  defstruct [
    :table_ref_name,
    :column_name,
    :column_source,
    :column_result
  ]
end

defmodule MyOwnRedis.Models.RelationalTable do
  @type t :: %__MODULE__{
    name: String.t,
    columns: list(String.t | %MyOwnRedis.Models.RelationalTableRef{}),
    rows: list(map())
  }

  defstruct [
    :name,
    :columns,
    :rows,
  ]
end
