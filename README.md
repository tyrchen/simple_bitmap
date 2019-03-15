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
iex> SimpleBitmap.msb(b, 10, 2)
[10, 5, 0, 0, 0, 0, 0, 0, 0, 0]
iex> SimpleBitmap.popcount(b)
4
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
Estimated total run time: 48 s


Benchmarking get msb list...
Benchmarking get msb list skip N...
Benchmarking load bitmap...
Benchmarking population count...
Benchmarking population count 1...
Benchmarking save bitmap...
Benchmarking set random bits...
Benchmarking unset random bits...
Generated benchmarks/output/bitmap.html
Generated benchmarks/output/bitmap_comparison.html
Generated benchmarks/output/bitmap_get_msb_list.html
Generated benchmarks/output/bitmap_get_msb_list_skip_n.html
Generated benchmarks/output/bitmap_load_bitmap.html
Generated benchmarks/output/bitmap_population_count.html
Generated benchmarks/output/bitmap_population_count_1.html
Generated benchmarks/output/bitmap_save_bitmap.html
Generated benchmarks/output/bitmap_set_random_bits.html
Generated benchmarks/output/bitmap_unset_random_bits.html

Name                          ips        average  deviation         median         99th %
set random bits          104.89 K     0.00953 ms   ±109.89%     0.00799 ms      0.0300 ms
unset random bits         48.05 K      0.0208 ms    ±61.20%      0.0200 ms      0.0570 ms
load bitmap                2.91 K        0.34 ms    ±15.75%        0.34 ms        0.54 ms
save bitmap                1.21 K        0.83 ms    ±12.19%        0.81 ms        1.12 ms
get msb list               0.68 K        1.48 ms     ±9.02%        1.46 ms        1.99 ms
get msb list skip N       0.194 K        5.14 ms    ±35.02%        5.13 ms        8.82 ms
population count         0.0762 K       13.13 ms     ±9.77%       12.93 ms       17.52 ms
population count 1       0.0526 K       19.02 ms     ±4.95%       18.86 ms       22.61 ms

Comparison:
set random bits          104.89 K
unset random bits         48.05 K - 2.18x slower
load bitmap                2.91 K - 36.09x slower
save bitmap                1.21 K - 86.94x slower
get msb list               0.68 K - 155.28x slower
get msb list skip N       0.194 K - 539.59x slower
population count         0.0762 K - 1377.02x slower
population count 1       0.0526 K - 1994.62x slower
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



Name                                  ips        average  deviation         median         99th %
set random bits (1.1.0)          104.89 K     0.00953 ms   ±109.89%     0.00799 ms      0.0300 ms
unset random bits (1.1.0)         48.05 K      0.0208 ms    ±61.20%      0.0200 ms      0.0570 ms
load bitmap (1.1.0)                2.91 K        0.34 ms    ±15.75%        0.34 ms        0.54 ms
save bitmap (1.1.0)                1.21 K        0.83 ms    ±12.19%        0.81 ms        1.12 ms
get msb list (1.1.0)               0.68 K        1.48 ms     ±9.02%        1.46 ms        1.99 ms
get msb list skip N (1.1.0)       0.194 K        5.14 ms    ±35.02%        5.13 ms        8.82 ms
population count (1.1.0)         0.0762 K       13.13 ms     ±9.77%       12.93 ms       17.52 ms
population count 1 (1.1.0)       0.0526 K       19.02 ms     ±4.95%       18.86 ms       22.61 ms

Comparison:
set random bits (1.1.0)          104.89 K
unset random bits (1.1.0)         48.05 K - 2.18x slower
load bitmap (1.1.0)                2.91 K - 36.09x slower
save bitmap (1.1.0)                1.21 K - 86.94x slower
get msb list (1.1.0)               0.68 K - 155.28x slower
get msb list skip N (1.1.0)       0.194 K - 539.59x slower
population count (1.1.0)         0.0762 K - 1377.02x slower
population count 1 (1.1.0)       0.0526 K - 1994.62x slower
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

## Caveats

If your bitmap size is > 10M and < 30M, please modify the benchmark script (change `max_index` to 10000000) and redo the benchmark. Please expect performance drop and see if the metrics are still good for your use case.

If you want a bitmap size > 30M, as for now this solution doesn't work due to system limit:

```elixir
iex(1)> b = SimpleBitmap.new()
%SimpleBitmap{data: 0}
iex(2)> SimpleBitmap.set(b, 33000000); :ok
:ok
iex(3)> SimpleBitmap.set(b, 34000000); :ok
** (SystemLimitError) a system limit has been reached
    (simple_bitmap) lib/simple_bitmap.ex:154: SimpleBitmap.do_set/2
```

A simple solution/workaround to that is to put a list of integers in the `data` field of the bitmap.
