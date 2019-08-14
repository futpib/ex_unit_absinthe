defmodule ExUnitAbsinthe.CaseTest do
  use ExUnit.Case
  use ExUnitAbsinthe.Case
  doctest ExUnitAbsinthe.Case

  absinthe_schema ExUnitAbsinthe.TestSchema

  setup do
    [test_context_value: "foo"]
  end

  absinthe_test """
  testQuery(testArg: "test without title or context") {
    testField
  }
  """, %{
    test_query: %{
      test_field: &(&1 === "test without title or context")
    }
  }

  absinthe_test "test with title and no context", """
  testQuery(testArg: "foo") {
    testField
  }
  """, %{
    test_query: %{
      test_field: &(&1 === "foo")
    }
  }

  absinthe_test "test with title and context", """
  testQuery(testArg: "foo") {
    testField
  }
  """, context do
    %{
      test_query: %{
        test_field: &(&1 === context.test_context_value)
      }
    }
  end
end
