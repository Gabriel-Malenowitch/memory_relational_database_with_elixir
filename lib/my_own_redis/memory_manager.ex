defmodule MyOwnRedis.MemoryManager do
  alias MyOwnRedis.Models.{ RelationalTable, Table }

  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end
  def init(args), do: {:ok, args}

  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  @spec handle_cast({:edit, list(%Table{})}, list(%Table{})) :: {:noreply, list(%Table{})}
  def handle_cast({:edit, data},_state) do
    {:noreply, data}
  end

  @spec edit(list(%Table{} | %RelationalTable{})) :: any()
  def edit(data), do: GenServer.cast(__MODULE__, {:edit, data})

  @spec get_all() :: list(%Table{} | %RelationalTable{})
  def get_all, do: GenServer.call(__MODULE__, :get_all)

  def close do
    GenServer.stop(__MODULE__)
  end
end
