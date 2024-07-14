defmodule MyOwnRedis do
  alias MyOwnRedis.{ MemoryManager, Manager }

  def start do
    IO.puts 'Starting MyOwnRedis'

    {:ok, _pid} = MemoryManager.start_link([])

    state = MemoryManager.get_all()

    new_state_0 = Manager.create_table(state, "users", ["id", "name", "email"])

    new_state_1 =
      Manager.add_row(
        new_state_0,
        "users",
        %{
          id: "1",
          name: "Bar Foo",
          email: "Bar Foo@gmail.com"
        }
      )
      |> Manager.add_row(
        "users",
        %{
          id: "2",
          name: "Bar Foo",
          email: "Bar 2 Foo@gmail.com"
        }
      )
      |> Manager.add_row(
        "users",
        %{
          id: "3",
          name: "Bar Foo",
          email: "Bar 3 Foo@gmail.com"
        }
      )

    new_state_2 = Manager.create_table(
      new_state_1,
      "messages",
      [
        "id",
        "user_id",
        %{
          table_ref_name: "users",
          column_source: "id",
          local_ref: "user_id",
          column_result: "email",
          local_column_name: "email"
        },
        "content"
      ]
    )

    new_state_3 =
      Manager.add_row(
        new_state_2,
        "messages",
        %{
          id: "123",
          user_id: "2",
          email: :ref,
          content: "Hello, World!"
        }
      )
      |> Manager.add_row(
        "messages",
        %{
          id: "431",
          user_id: "1",
          email: :ref,
          content: "AHA"
        }
      )
      |> Manager.add_row(
        "messages",
        %{
          id: "412",
          user_id: "3",
          email: :ref,
          content: "alsçknflçanklfgas"
        }
      )

    new_state_4 = Manager.create_table(
      new_state_3,
      "nãosei",
      [
        %{
          table_ref_name: "messages",
          column_source: "id",
          local_ref: "message_id",
          column_result: "email",
          local_column_name: "email"
        },
        "message_id"
      ]
    )

    new_state_5 = Manager.add_row(
      new_state_4,
      "nãosei",
      %{
        email: :ref,
        message_id: "412",
      }
    )

    MemoryManager.edit(new_state_5)

    MemoryManager.get_all() |> IO.inspect()
    # Manager.get_table(new_state_5, "messages") |> IO.inspect()
    # Manager.get_table(new_state_5, "nãosei") |> IO.inspect()

    :timer.sleep(1500)
    MemoryManager.close()
  end
end
