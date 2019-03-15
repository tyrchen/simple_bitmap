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
iex> SimpleBitmap.msb(b, 10, skip: 2)
[10, 5, 0, 0, 0, 0, 0, 0, 0, 0]
iex> SimpleBitmap.msb(b, 10, cursor: 38)
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
Estimated total run time: 54 s


Benchmarking get msb list...
Benchmarking get msb list skip N...
Benchmarking get msb list with random cursor...
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
Generated benchmarks/output/bitmap_get_msb_list_with_random_cursor.html
Generated benchmarks/output/bitmap_load_bitmap.html
Generated benchmarks/output/bitmap_population_count.html
Generated benchmarks/output/bitmap_population_count_1.html
Generated benchmarks/output/bitmap_save_bitmap.html
Generated benchmarks/output/bitmap_set_random_bits.html
Generated benchmarks/output/bitmap_unset_random_bits.html

Name                                      ips        average  deviation         median         99th %
set random bits                      94140.89      0.0106 ms   ±110.23%     0.00900 ms      0.0330 ms
unset random bits                    46012.36      0.0217 ms    ±57.87%      0.0210 ms      0.0580 ms
load bitmap                           2433.74        0.41 ms    ±27.38%        0.39 ms        0.72 ms
save bitmap                           1132.84        0.88 ms    ±41.45%        0.84 ms        1.38 ms
get msb list                           651.70        1.53 ms    ±14.33%        1.48 ms        2.52 ms
get msb list with random cursor        511.99        1.95 ms    ±26.43%        1.84 ms        3.39 ms
get msb list skip N                    189.12        5.29 ms    ±32.41%        5.35 ms        8.62 ms
population count                        74.11       13.49 ms     ±5.06%       13.34 ms       16.19 ms
population count 1                      50.11       19.96 ms     ±3.97%       19.80 ms       23.25 ms

Comparison:
set random bits                      94140.89
unset random bits                    46012.36 - 2.05x slower
load bitmap                           2433.74 - 38.68x slower
save bitmap                           1132.84 - 83.10x slower
get msb list                           651.70 - 144.46x slower
get msb list with random cursor        511.99 - 183.87x slower
get msb list skip N                    189.12 - 497.79x slower
population count                        74.11 - 1270.31x slower
population count 1                      50.11 - 1878.82x slower
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



Name                                              ips        average  deviation         median         99th %
set random bits (1.2.0)                      94140.89      0.0106 ms   ±110.23%     0.00900 ms      0.0330 ms
unset random bits (1.2.0)                    46012.36      0.0217 ms    ±57.87%      0.0210 ms      0.0580 ms
load bitmap (1.2.0)                           2433.74        0.41 ms    ±27.38%        0.39 ms        0.72 ms
save bitmap (1.2.0)                           1132.84        0.88 ms    ±41.45%        0.84 ms        1.38 ms
get msb list (1.2.0)                           651.70        1.53 ms    ±14.33%        1.48 ms        2.52 ms
get msb list with random cursor (1.2.0)        511.99        1.95 ms    ±26.43%        1.84 ms        3.39 ms
get msb list skip N (1.2.0)                    189.12        5.29 ms    ±32.41%        5.35 ms        8.62 ms
population count (1.2.0)                        74.11       13.49 ms     ±5.06%       13.34 ms       16.19 ms
population count 1 (1.2.0)                      50.11       19.96 ms     ±3.97%       19.80 ms       23.25 ms

Comparison:
set random bits (1.2.0)                      94140.89
unset random bits (1.2.0)                    46012.36 - 2.05x slower
load bitmap (1.2.0)                           2433.74 - 38.68x slower
save bitmap (1.2.0)                           1132.84 - 83.10x slower
get msb list (1.2.0)                           651.70 - 144.46x slower
get msb list with random cursor (1.2.0)        511.99 - 183.87x slower
get msb list skip N (1.2.0)                    189.12 - 497.79x slower
population count (1.2.0)                        74.11 - 1270.31x slower
population count 1 (1.2.0)                      50.11 - 1878.82x slower
```

Benchmark code is in [benchmarks/bitmap.exs](./benchmarks/bitmap.exs).

## Installation

The package can be installed by adding `simple_bitmap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:simple_bitmap, "~> 1.3.0"}
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
