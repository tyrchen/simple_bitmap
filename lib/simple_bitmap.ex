defmodule SimpleBitmap do
  @moduledoc """
  Simple Bitmap to use the big integer to store (and extend) the bitmap.

  Example:

    iex> b = SimpleBitmap.new()
    %SimpleBitmap{data: 0}
    iex> b = SimpleBitmap.set(b, 5)
    %SimpleBitmap{data: 32}
    iex> b = SimpleBitmap.set(b, 10)
    %SimpleBitmap{data: 1056}
    iex> b = SimpleBitmap.set(b, 38)
    %SimpleBitmap{data: 274877908000}
    iex> b = SimpleBitmap.set(b, 179)
    %SimpleBitmap{data: 766247770432944429179173513575154591809369835969709088}
    iex> SimpleBitmap.msb(b)
    179
    iex> SimpleBitmap.msb(b, 10)
    [179, 38, 10, 5, 0, 0, 0, 0, 0, 0]
  """
  use Bitwise
  require Logger

  @type t :: %__MODULE__{}
  defstruct data: 0

  @doc """
  Initialize a bitmap.

    iex> SimpleBitmap.new()
    %SimpleBitmap{data: 0}
    iex> SimpleBitmap.new(1024)
    %SimpleBitmap{data: 1024}
  """
  @spec new(non_neg_integer()) :: t()
  def new(data \\ 0), do: do_new(data)

  @doc """
  Reverse a bitmap or an integer

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 1)
    iex> b = SimpleBitmap.set(b, 4)
    iex> b = SimpleBitmap.set(b, 9)
    iex> b = SimpleBitmap.set(b, 33)
    %SimpleBitmap{data: 8589935122}
    iex> SimpleBitmap.reverse(b)
    %SimpleBitmap{data: 310311387200}
  """
  @spec reverse(SimpleBitmap.t() | non_neg_integer()) :: SimpleBitmap.t()
  def reverse(%{data: data}), do: reverse(data)

  def reverse(num) do
    count = byte_size(:binary.encode_unsigned(num)) * 8 - 1

    result =
      Enum.reduce(0..count, 0, fn i, acc ->
        case (num &&& 1 <<< i) !== 0 do
          true -> acc ||| 1 <<< (count - i)
          _ -> acc
        end
      end)

    new(result)
  end

  @doc """
  Load a bitmap from a file

    iex> b = SimpleBitmap.new(1024)
    %SimpleBitmap{data: 1024}
    iex> b = SimpleBitmap.set(b, 9)
    %SimpleBitmap{data: 1536}
    iex> b = SimpleBitmap.set(b, 225)
    %SimpleBitmap{
      data: 53919893334301279589334030174039261347274288845081144962207220499968
    }
    iex> SimpleBitmap.save(b, "/tmp/simple_bitmap")
    iex> SimpleBitmap.load("/tmp/simple_bitmap")
    %SimpleBitmap{
      data: 53919893334301279589334030174039261347274288845081144962207220499968
    }
  """
  def load(filename) do
    case File.read(filename) do
      {:ok, bin} ->
        bin |> :zlib.gunzip() |> to_bitmap()

      {:error, error} ->
        Logger.warn("Failed to open #{filename}. Error: #{inspect(error)}")
        new(0)
    end
  end

  @doc """
  Save the bitmap into file
    iex> b = SimpleBitmap.new(1024)
    %SimpleBitmap{data: 1024}
    iex> b = SimpleBitmap.set(b, 9)
    %SimpleBitmap{data: 1536}
    iex> SimpleBitmap.save(b, "/tmp/simple_bitmap")
    :ok
  """
  @spec save(t(), binary()) :: :ok
  def save(bitmap, filename) do
    bin = bitmap |> to_binary() |> :zlib.gzip()
    File.write!(filename, bin)
  end

  @doc """
  Set the bit to 1 for given index.

    iex> b = SimpleBitmap.new()
    iex> SimpleBitmap.set(b, 3)
    %SimpleBitmap{data: 8}
  """
  @spec set(t(), non_neg_integer()) :: t()
  def set(bitmap, index) when index >= 0, do: do_set(bitmap, index)

  @doc """
  Set the bit to 0 for given index.

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 2)
    iex> b = SimpleBitmap.set(b, 8)
    iex> SimpleBitmap.unset(b, 8)
    %SimpleBitmap{data: 4}
  """
  @spec unset(t(), non_neg_integer()) :: t()
  def unset(bitmap, index) when index >= 0, do: do_unset(bitmap, index)

  @doc """
  Check if a bit is set to 1 for given index.

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 15)
    iex> b = SimpleBitmap.set(b, 16)
    iex> SimpleBitmap.set?(b, 15)
    true
  """
  @spec set?(t(), non_neg_integer()) :: boolean()
  def set?(bitmap, index) when index >= 0, do: (bitmap.data >>> index &&& 1) === 1

  @doc """
  Get the index of the most significant bit.

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 301)
    iex> b = SimpleBitmap.set(b, 4)
    iex> b = SimpleBitmap.set(b, 252)
    iex> SimpleBitmap.msb(b)
    301
  """
  @spec msb(t()) :: non_neg_integer()
  def msb(bitmap) do
    <<first::size(8), rest::binary>> = to_binary(bitmap)
    size = byte_size(rest) <<< 3
    get_msb(first, 0) + size
  end

  @doc """
  Get a list of most significant bits.

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 1)
    iex> b = SimpleBitmap.set(b, 4)
    iex> b = SimpleBitmap.set(b, 9)
    iex> b = SimpleBitmap.set(b, 33)
    iex> b = SimpleBitmap.set(b, 1753421)
    iex> b = SimpleBitmap.set(b, 9326887)
    iex> b = SimpleBitmap.unset(b, 32)
    iex> b = SimpleBitmap.unset(b, 9)
    iex> SimpleBitmap.msb(b, 10)
    [9326887, 1753421, 33, 4, 1, 0, 0, 0, 0, 0]
    iex> SimpleBitmap.msb(b, 10, skip: 3)
    [4, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    iex> SimpleBitmap.msb(b, 10, cursor: 33)
    [4, 1, 0, 0, 0, 0, 0, 0, 0, 0]
  """
  @spec msb(t(), non_neg_integer(), Keyword.t()) :: [non_neg_integer()]
  def msb(bitmap, length, opts \\ []) do
    cond do
      opts[:skip] != nil -> do_msb(bitmap, length, opts[:skip], [])
      opts[:cursor] != nil -> do_msb_cursor(bitmap, length, opts[:cursor], [])
      true -> do_msb(bitmap, length, 0, [])
    end
  end

  @doc """
  Get the index of the most significant bit.

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 301)
    iex> b = SimpleBitmap.set(b, 4)
    iex> b = SimpleBitmap.set(b, 252)
    iex> SimpleBitmap.lsb(b)
    4
  """
  @spec lsb(t()) :: non_neg_integer()
  def lsb(%{data: 0}), do: 0

  def lsb(bitmap) do
    arr = to_reverse_array(bitmap)

    {size, first} =
      Enum.reduce_while(arr, {0, 0}, fn item, {total, v} ->
        case item == 0 do
          true -> {:cont, {total + 1, v}}
          _ -> {:halt, {total, item}}
        end
      end)

    7 - get_msb(reverse(first).data, 0) + (size <<< 3)
  end

  @doc """
  Get a list of least significant bits.

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 1)
    iex> b = SimpleBitmap.set(b, 4)
    iex> b = SimpleBitmap.set(b, 9)
    iex> b = SimpleBitmap.set(b, 33)
    iex> b = SimpleBitmap.set(b, 1753421)
    iex> b = SimpleBitmap.set(b, 9326887)
    iex> b = SimpleBitmap.unset(b, 32)
    iex> b = SimpleBitmap.unset(b, 9)
    iex> SimpleBitmap.lsb(b, 10)
    [1, 4, 33, 1753421, 9326887, 0, 0, 0, 0, 0]
    iex> SimpleBitmap.lsb(b, 10, skip: 3)
    [1753421, 9326887, 0, 0, 0, 0, 0, 0, 0, 0]
    iex> SimpleBitmap.lsb(b, 10, cursor: 4)
    [33, 1753421, 9326887, 0, 0, 0, 0, 0, 0, 0]
  """
  @spec lsb(t(), non_neg_integer(), Keyword.t()) :: [non_neg_integer()]
  def lsb(bitmap, length, opts \\ []) do
    cond do
      opts[:skip] != nil -> do_lsb(bitmap, length, opts[:skip], [])
      opts[:cursor] != nil -> do_lsb_cursor(bitmap, length, opts[:cursor], [])
      true -> do_lsb(bitmap, length, 0, [])
    end
  end

  @doc """
  Population count for bitmap.

  Example:

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 1)
    iex> b = SimpleBitmap.set(b, 4)
    iex> b = SimpleBitmap.set(b, 9)
    iex> b = SimpleBitmap.set(b, 33)
    iex> SimpleBitmap.popcount(b)
    4
  """
  @spec popcount(t()) :: non_neg_integer()
  def popcount(bitmap), do: do_popcount(to_binary(bitmap), 0)

  @doc """
  Population count for bitmap, using algorithm from https://en.wikipedia.org/wiki/Hamming_weight. However, it is not as performant as `popcount()`.

  ```C
  //This is better when most bits in x are 0
  //This is algorithm works the same for all data sizes.
  //This algorithm uses 3 arithmetic operations and 1 comparison/branch per "1" bit in x.
  int popcount64d(uint64_t x)
  {
      int count;
      for (count=0; x; count++)
          x &= x - 1;
      return count;
  }
  ```
  Example:

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 1)
    iex> b = SimpleBitmap.set(b, 4)
    iex> b = SimpleBitmap.set(b, 9)
    iex> b = SimpleBitmap.set(b, 33)
    iex> SimpleBitmap.popcount(b)
    4
  """
  @spec popcount1(t()) :: non_neg_integer()
  def popcount1(bitmap), do: do_popcount1(bitmap.data, 0)

  # private functions
  defp do_popcount(<<>>, acc), do: acc

  defp do_popcount(<<bit::integer-size(1), rest::bitstring>>, sum),
    do: do_popcount(rest, sum + bit)

  defp do_popcount1(0, r), do: r
  defp do_popcount1(i, r), do: do_popcount1(i &&& i - 1, r + 1)

  defp do_set(bitmap, index), do: %__MODULE__{bitmap | data: bitmap.data ||| 1 <<< index}
  defp do_unset(bitmap, index), do: %__MODULE__{bitmap | data: bitmap.data &&& ~~~(1 <<< index)}

  defp do_msb(_bitmap, 0, _skip, result), do: Enum.reverse(result)

  defp do_msb(bitmap, length, 0, result) do
    pos = msb(bitmap)
    do_msb(do_unset(bitmap, pos), length - 1, 0, [pos | result])
  end

  defp do_msb(bitmap, length, skip, result) do
    skipped = bitmap |> to_binary() |> do_skip(skip, 0)
    size = 8 - (skipped |> :erlang.bit_size() |> rem(8))
    skipped = <<0::size(size), skipped::bitstring>>
    do_msb(to_bitmap(skipped), length, 0, result)
  end

  defp do_msb_cursor(bitmap, length, cursor, result) do
    cursor_map = do_new(0) |> do_set(cursor)
    new_map = do_new(bitmap.data &&& cursor_map.data - 1)
    do_msb(new_map, length, 0, result)
  end

  defp do_lsb(_bitmap, 0, _skip, result), do: Enum.reverse(result)

  defp do_lsb(bitmap, length, 0, result) do
    pos = lsb(bitmap)
    do_lsb(do_unset(bitmap, pos), length - 1, 0, [pos | result])
  end

  defp do_lsb(bitmap, length, skip, result) do
    len = (bitmap |> to_binary() |> byte_size()) * 8

    data =
      case skip >= len do
        true ->
          0

        _ ->
          initial = %{num: bitmap.data, i: 0, n: 0}

          data =
            Enum.reduce_while(1..len, initial, fn i, acc ->
              v = acc.num >>> 1

              acc =
                case (acc.num &&& 1) === 1 do
                  true -> %{acc | num: v, i: i, n: acc.n + 1}
                  _ -> %{acc | num: v, i: i, n: acc.n}
                end

              case acc.n === skip do
                true -> {:halt, acc}
                _ -> {:cont, acc}
              end
            end)

          data.num <<< data.i
      end

    do_lsb(new(data), length, 0, result)
  end

  defp do_lsb_cursor(bitmap, length, cursor, result) do
    new_map = do_new(bitmap.data >>> (cursor + 1) <<< (cursor + 1))
    do_lsb(new_map, length, 0, result)
  end

  defp do_skip(<<>>, _n, _acc), do: <<>>
  defp do_skip(bin, n, acc) when n == acc, do: bin
  defp do_skip(<<bit::integer-size(1), rest::bitstring>>, n, acc), do: do_skip(rest, n, acc + bit)

  defp get_msb(0, 0), do: 0
  defp get_msb(0, r), do: r - 1
  defp get_msb(i, r), do: get_msb(i >>> 1, r + 1)

  defp to_binary(bitmap), do: :binary.encode_unsigned(bitmap.data)

  defp to_bitmap(bin), do: bin |> :binary.decode_unsigned() |> do_new()
  defp do_new(data), do: %__MODULE__{data: data}

  defp to_reverse_array(%{data: data}), do: to_reverse_array(data)

  defp to_reverse_array(data),
    do: data |> :binary.encode_unsigned() |> :binary.bin_to_list() |> Enum.reverse()
end
