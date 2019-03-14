# Simple Bitmap

Simple bitmap is to provide very basic functionality for a bitmap, which allows to set arbitrary bits (within system limit), check the membership and get the index of the MSB (most significant bit).

## Usage

Below code illustrates typical use cases for the simple bitmap:

```elixir
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
```

If you'd know more, just look into the test cases and the source code itself. After all, the whole code is just < 200 LOC.

## Performance

We use [benchee](https://github.com/PragTob/benchee) to do the performance benchmark. The bitmap size is 1M bits. Here's the result for 1.0.0:

```bash
$ make bench
Benchmark the simple bitmap...
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-7820HQ CPU @ 2.90GHz
Number of Available Cores: 8
Available memory: 16 GB
Elixir 1.8.1
Erlang 21.2.4

Benchmark suite executing with the following configuration:
warmup: 1 s
time: 5 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 30 s


Benchmarking get msb list...
Benchmarking load bitmap...
Benchmarking save bitmap...
Benchmarking set random bits...
Benchmarking unset random bits...
Generated benchmarks/output/bitmap.html
Generated benchmarks/output/bitmap_comparison.html
Generated benchmarks/output/bitmap_get_msb_list.html
Generated benchmarks/output/bitmap_load_bitmap.html
Generated benchmarks/output/bitmap_save_bitmap.html
Generated benchmarks/output/bitmap_set_random_bits.html
Generated benchmarks/output/bitmap_unset_random_bits.html
Opened report using open

Name                        ips        average  deviation         median         99th %
set random bits         88.68 K       11.28 μs   ±196.30%           9 μs          38 μs
unset random bits       44.62 K       22.41 μs   ±176.87%          21 μs          60 μs
load bitmap              2.86 K      349.06 μs    ±17.69%         327 μs         553 μs
save bitmap              1.05 K      950.09 μs    ±29.21%         872 μs     1765.44 μs
get msb list             0.72 K     1391.21 μs    ±10.05%        1365 μs     1859.88 μs

Comparison:
set random bits         88.68 K
unset random bits       44.62 K - 1.99x slower
load bitmap              2.86 K - 30.95x slower
save bitmap              1.05 K - 84.25x slower
get msb list             0.72 K - 123.37x slower
Suite saved in external term format at benchmarks/benchee/bitmap.benchee
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-7820HQ CPU @ 2.90GHz
Number of Available Cores: 8
Available memory: 16 GB
Elixir 1.8.1
Erlang 21.2.4

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 0 ns



Name                                ips        average  deviation         median         99th %
set random bits (1.0.0)         88.68 K       11.28 μs   ±196.30%           9 μs          38 μs
unset random bits (1.0.0)       44.62 K       22.41 μs   ±176.87%          21 μs          60 μs
load bitmap (1.0.0)              2.86 K      349.06 μs    ±17.69%         327 μs         553 μs
save bitmap (1.0.0)              1.05 K      950.09 μs    ±29.21%         872 μs     1765.44 μs
get msb list (1.0.0)             0.72 K     1391.21 μs    ±10.05%        1365 μs     1859.88 μs

Comparison:
set random bits (1.0.0)         88.68 K
unset random bits (1.0.0)       44.62 K - 1.99x slower
load bitmap (1.0.0)              2.86 K - 30.95x slower
save bitmap (1.0.0)              1.05 K - 84.25x slower
get msb list (1.0.0)             0.72 K - 123.37x slower
```

Benchmark code is in [benchmarks/bitmap.exs](./benchmarks/bitmap.exs).

## Installation

The package can be installed by adding `simple_bitmap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:simple_bitmap, "~> 1.0.0"}
  ]
end
```
