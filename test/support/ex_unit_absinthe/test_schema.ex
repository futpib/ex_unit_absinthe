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
  end
end
