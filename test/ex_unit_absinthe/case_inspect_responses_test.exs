defmodule ExUnitAbsinthe.CaseInspectResponsesTest do
  use ExUnit.Case
  use ExUnitAbsinthe.Case
  doctest ExUnitAbsinthe.Case

  absinthe_schema ExUnitAbsinthe.TestSchema
  absinthe_inspect_responses true

  setup do
    [test_context_value: "foo"]
  end

  absinthe_test """
  testQuery(testArg: "a response to be inspected") {
    testField
  }
  """, %{
    test_query: %{
      test_field: &(&1 === "a response to be inspected")
    }
  }
end
