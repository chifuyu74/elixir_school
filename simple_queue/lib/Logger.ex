defmodule Clog do
  defmacro log(msg) do
    if Application.get_env(:logger, :enabled) do
      quote do
        IO.puts("Logged message: #{unquote(msg)}")
      end
    end
  end
end

defmodule Baz.Foo do
  @spec tell(any()) :: :ok
  def tell(state \\ 456_456) do
    IO.puts(state)
  end
end

defmodule Example do
  require Clog
  require Baz.Foo
  # alias Baz.Foo, as: Qt
  # import Clog, only: [log: 1]

  def test do
    Baz.Foo.tell()
    Clog.log("this is a log msg...")
  end

  @spec sum_product(number()) :: number()
  def sum_product(a) do
    [1, 2, 3]
    |> Enum.map(fn el -> el * a end)
    |> Enum.sum()
  end

  def sum_times(a, params) do
    for i <- params.first..params.last do
      i
    end
    |> Enum.map(fn el -> el * a end)
    |> Enum.sum()
    |> round
  end

  defstruct first: nil, last: nil

  @type t(first, last) :: %Example{first: first, last: last}

  @typedoc """
    integer인 :first와 integer인 :last를 갖고 있는 Examples 구조체를 대표하는 타입.
  """
  @type t :: %Example{first: integer, last: integer}
end

defmodule Example.Worker do
  @callback init(state :: term) :: {:ok, new_state :: term} | {:error, reason :: term}
  @callback perform(args :: term, state :: term) ::
              {:ok, result :: term, new_state :: term}
              | {:error, reason :: term, new_state :: term}
end

defmodule Example.Downloader do
  alias Hex.HTTP
  @behaviour Example.Worker

  def init(opts), do: {:ok, opts}

  def perform(payload, opts) do
    payload
    # |> HTTPPoision.get!()
    # |> Map.fetch(:body)
    # |> write_file(opts[:path])
    |> compress
    |> respond(opts)
  end

  defp write_file({:ok, contents}, path) do
    path |> Path.expand() |> File.write(contents)
  end

  defp respond(:ok, opts), do: {:ok, opts[:path], opts}
  defp respond({:error, reason}, opts), do: {:error, reason, opts}

  defp compress({name, files}), do: :zip.create(name, files)
end

defimpl String.Chars, for: Tuple do
  def to_string(tuple) do
    interior =
      tuple
      |> Tuple.to_list()
      |> Enum.map(&Kernel.to_string/1)
      |> Enum.join(", ")

    "{#{interior}}"
  end
end

defprotocol AsAtom do
  def to_atom(data)
end

defimpl AsAtom, for: Atom do
  def to_atom(atom), do: atom
end

defimpl AsAtom, for: BitString do
  defdelegate to_atom(string), to: String
end

defimpl AsAtom, for: List do
  defdelegate to_atom(list), to: List
end

defimpl AsAtom, for: Map do
  def to_atom(map), do: List.first(Map.keys(map))
end
