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
  def new(data \\ 0), do: %__MODULE__{data: data}

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
        bin |> :zlib.gunzip() |> to_bitmap() |> new()

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
  def set(bitmap, index) when index > 0, do: do_set(bitmap, index)

  @doc """
  Set the bit to 0 for given index.

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 2)
    iex> b = SimpleBitmap.set(b, 8)
    iex> SimpleBitmap.unset(b, 8)
    %SimpleBitmap{data: 4}
  """
  @spec unset(t(), non_neg_integer()) :: t()
  def unset(bitmap, index) when index > 0, do: do_unset(bitmap, index)

  @doc """
  Check if a bit is set to 1 for given index.

    iex> b = SimpleBitmap.new()
    iex> b = SimpleBitmap.set(b, 15)
    iex> b = SimpleBitmap.set(b, 16)
    iex> SimpleBitmap.set?(b, 15)
    true
  """
  @spec set?(t(), non_neg_integer()) :: boolean()
  def set?(bitmap, index) when index > 0, do: (bitmap.data >>> index &&& 1) === 1

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
    size = byte_size(rest) * 8
    get_msb(first) + size
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
  """
  @spec msb(t(), non_neg_integer()) :: [non_neg_integer()]
  def msb(bitmap, length) do
    do_msb(bitmap, length, [])
  end

  # private functions
  defp do_set(bitmap, index), do: %__MODULE__{bitmap | data: bitmap.data ||| 1 <<< index}
  defp do_unset(bitmap, index), do: %__MODULE__{bitmap | data: bitmap.data &&& ~~~(1 <<< index)}
  defp do_msb(_bitmap, 0, result), do: Enum.reverse(result)

  defp do_msb(bitmap, length, result) do
    pos = msb(bitmap)
    do_msb(do_unset(bitmap, pos), length - 1, [pos | result])
  end

  defp get_msb(i) do
    cond do
      (i &&& 1 <<< 8) !== 0 -> 8
      (i &&& 1 <<< 7) !== 0 -> 7
      (i &&& 1 <<< 6) !== 0 -> 6
      (i &&& 1 <<< 5) !== 0 -> 5
      (i &&& 1 <<< 4) !== 0 -> 4
      (i &&& 1 <<< 3) !== 0 -> 3
      (i &&& 1 <<< 2) !== 0 -> 2
      (i &&& 1 <<< 1) !== 0 -> 1
      (i &&& 1 <<< 0) !== 0 -> 0
      true -> 0
    end
  end

  defp to_binary(bitmap), do: :binary.encode_unsigned(bitmap.data)
  defp to_bitmap(bin), do: :binary.decode_unsigned(bin)
end
