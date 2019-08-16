defmodule ExUnitAbsinthe.Case do
  defmacro __using__(_opts) do
    quote do
      import ExUnitAbsinthe.Case, only: [
        absinthe_schema: 1,
        absinthe_inspect_responses: 1,
        absinthe_test: 2,
        absinthe_test: 3,
        absinthe_test: 4,
      ]
    end
  end

  defmacro absinthe_schema(schema_module) do
    Module.put_attribute(__CALLER__.module, :ex_unit_absinthe_schema, schema_module)
    nil
  end

  defmacro absinthe_inspect_responses(should_inspect_responses) do
    Module.put_attribute(__CALLER__.module, :ex_unit_absinthe_should_inspect_responses, should_inspect_responses)
    nil
  end

  defmacro absinthe_test(query, assertion) do
    query = normalize_query(query)

    do_absinthe_test(query, quote(do: _), to_contents(__CALLER__.module, query, assertion))
  end

  defmacro absinthe_test(title, query, var \\ quote(do: context), assertion) do
    query = normalize_query(query)

    do_absinthe_test(title, var, to_contents(__CALLER__.module, query, assertion))
  end

  defp normalize_query(query) do
    query = String.trim(query)

    if String.starts_with?(query, "{") do
      query
    else
      "{" <> query <> "}"
    end
  end

  defp to_contents(module, query, assertion) do
    assertions = assertion_to_contents(assertion)

    schema = Module.get_attribute(module, :ex_unit_absinthe_schema)
    should_inspect_responses = Module.get_attribute(module, :ex_unit_absinthe_should_inspect_responses) === true

    quote do
      results = Absinthe.run!(unquote(query), unquote(schema))

      if unquote(should_inspect_responses) do
        IO.inspect(results, limit: :infinity)
      end

      case results do
        %{ errors: errors } ->
          assert errors === []
        %{ data: data } ->
          unquote(assertions)
      end
    end
  end

  defp assertion_to_contents([ do: assertion ]) do
    assertion_to_contents(assertion)
  end

  defp assertion_to_contents(assertion) do
    path_predicate_pairs = assertion_to_path_predicate_pairs(assertion)
    contents = path_predicate_pairs_to_contents(path_predicate_pairs)

    {:__block__, [], contents}
  end

  defp assertion_to_path_predicate_pairs({:%{}, _, kvs}) do
    kvs
    |> Enum.flat_map(fn {key, value} ->
      key = atom_to_string(key)

      assertion_to_path_predicate_pairs(value)
      |> Enum.map(fn { path, predicate } -> { [key | path], predicate } end)
    end)
  end

  defp assertion_to_path_predicate_pairs({:absinthe_list_of, _, [ {:%{}, _, kvs} ]}) do
    kvs
    |> Enum.flat_map(fn {key, value} ->
      key = atom_to_string(key)

      assertion_to_path_predicate_pairs(value)
      |> Enum.map(fn { path, predicate } -> { [], {:absinthe_list_of, [key | path], predicate} } end)
    end)
  end

  defp assertion_to_path_predicate_pairs({:absinthe_list_of, _, [ assertion, [ count: count ] ]}) do
    [
      {
        [],
        quote do
          fn list ->
            unquote(count).(Enum.count(list))
          end
        end
      }
    ] ++ assertion_to_path_predicate_pairs({:absinthe_list_of, nil, [ assertion ]})
  end

  defp assertion_to_path_predicate_pairs(predicate) do
    [
      { [], predicate }
    ]
  end

  defp atom_to_string(key) do
    key
    |> Atom.to_string()
    |> Recase.to_camel()
  end

  defp path_predicate_pairs_to_contents(path_predicate_pairs) do
    path_predicate_pairs
    |> Enum.map(&path_predicate_pair_to_contents/1)
  end

  defp path_predicate_pair_to_contents({ path, predicate }) do
    case predicate do
      {:absinthe_list_of, item_path, item_predicate} ->
        quote do
          data
          |> get_in(unquote(Macro.escape(path)))
          |> Enum.each(fn data ->
            unquote(path_predicate_pair_to_contents({item_path, item_predicate}))
          end)
        end

      predicate ->
        quote do
          assert unquote(predicate).(get_in(data, unquote(Macro.escape(path))))
        end
    end
  end

  defp do_absinthe_test(title, var, contents) do
    quote do
      test unquote(title), unquote(var) do
        unquote(contents)
      end
    end
  end
end
