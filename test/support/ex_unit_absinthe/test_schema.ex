defmodule ExUnitAbsinthe.TestSchema do
  use Absinthe.Schema

  object :test_type do
    field :test_field, :string
  end

  query do
    field :test_query, :test_type do
      arg :test_arg, :string

      resolve fn %{test_arg: x}, _ ->
        {:ok, %{test_field: x}}
      end
    end

    field :test_list_query, list_of(non_null(:test_type)) do
      arg :test_arg, :string
      arg :count, non_null(:integer)

      resolve fn %{test_arg: x, count: count}, _ ->
        {
          :ok,
          1..count
          |> Enum.map(fn _ -> %{test_field: x} end)
        }
      end
    end
  end
end
