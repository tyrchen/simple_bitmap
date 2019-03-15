use Bitwise

max_index = 1_000_000

version = SimpleBitmap.MixProject.version()
m = SimpleBitmap.new()
m1 = SimpleBitmap.set(m, max_index)
m2 = SimpleBitmap.set(m, max_index - 1)

bitmap_random =
  Enum.reduce(1..1000, m, fn _, acc -> SimpleBitmap.set(acc, Enum.random(1..max_index)) end)

bitmap_empty = SimpleBitmap.set(m, max_index)
bitmap_full = SimpleBitmap.new(m1.data ^^^ m2.data)
SimpleBitmap.save(bitmap_full, "/tmp/bitmap_full_for_load")

Benchee.run(
  %{
    "set random bits" => fn -> SimpleBitmap.set(bitmap_empty, Enum.random(1..max_index)) end,
    "unset random bits" => fn -> SimpleBitmap.unset(bitmap_full, Enum.random(1..max_index)) end,
    "save bitmap" => fn -> SimpleBitmap.save(bitmap_full, "/tmp/bitmap_full") end,
    "load bitmap" => fn -> SimpleBitmap.load("/tmp/bitmap_full_for_load") end,
    "get msb list" => fn -> SimpleBitmap.msb(bitmap_random, 10) end,
    "get msb list skip N" => fn -> SimpleBitmap.msb(bitmap_random, 10, Enum.random(1..500)) end,
    "population count" => fn -> SimpleBitmap.popcount(bitmap_random) end,
    "population count 1" => fn -> SimpleBitmap.popcount1(bitmap_random) end
  },
  time: 5,
  warmup: 1,
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.Console
  ],
  save: [path: "benchmarks/benchee/bitmap.benchee", tag: version],
  formatter_options: [html: [file: "benchmarks/output/bitmap.html", auto_open: false]]
)

Benchee.run(%{}, load: "benchmarks/benchee/bitmap.benchee")
