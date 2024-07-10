defmodule MyOwnRedis do
  alias MyOwnRedis.{ MemoryManager, Manager }

  def start do
    IO.puts 'Starting MyOwnRedis'

    {:ok, _pid} = MemoryManager.start_link([])
    state = MemoryManager.get_all()
    new_state_0 = Manager.create_table(state, "users", ["id", "name", "email"])
    new_state_1 = Manager.add_row(
      new_state_0,
      "users",
      %{
        id: "1",
        name: "Bar Foo",
        email: "Bar Foo@gmail.com"
      }
    )
    new_state_2 = Manager.create_table(
      new_state_1,
      "posts",
      [
        %{
          table_ref_name: "users",
          column_source: "id",
          column_result: "email",
          column_name: "email"
        },
        "content"
      ]
    )
    MemoryManager.edit(new_state_2)

    MemoryManager.get_all() |> IO.inspect()

    :timer.sleep(1500)
    MemoryManager.close()
  end
end


MyOwnRedis.start()
