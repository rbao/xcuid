defmodule XCUID do
  use GenServer

  @base 36
  @block_size 4
  @block_max_value :math.pow(@base, @block_size) |> trunc()

  # Use a start value that always have 4 character
  # so we can avoid using String.pad_leading/3 in
  # the beginning. When the value roll over we still
  # have to call String.pad_leading/3 though
  @counter_start_value String.to_integer("1000", @base)

  def generate(server \\ __MODULE__) do
    GenServer.call(server, :generate)
  end

  def start_link(opts) do
    opts = Keyword.merge([name: __MODULE__], opts)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    seed_rand!()

    {:ok, {fingerprint(), @counter_start_value}}
  end

  @impl true
  def handle_call(:generate, _, {f, c}) do
    unix_ts = :os.system_time(:millisecond)

    # Make sure roll over on May 25 2059 does not break
    # the monotonically increasing feature
    identifier = if unix_ts < 2_821_109_907_456, do: "c", else: "d"

    cuid = String.downcase(identifier <> timestamp(unix_ts) <> counter(c) <> f <> random() <> random())
    {:reply, cuid, {f, inc_count(c)}}
  end

  defp inc_count(c) do
    if c == @block_max_value - 1 do
      0
    else
      c + 1
    end
  end

  def timestamp(ts) do
    Integer.to_string(ts, @base)
  end

  def counter(count) do
    count
    |> Integer.to_string(@base)
    |> pad(4, "0")
  end

  def fingerprint do
    pid = String.to_integer(System.pid())
    finger1 =
      Integer.to_string(pid, @base)
      |> String.pad_leading(2, "0")
      |> String.slice(0..1)

    {:ok, hostname} = :inet.gethostname
    hostname = to_charlist(hostname)
    finger2 =
      Enum.sum(hostname) + Enum.count(hostname) + @base
      |> Integer.to_string(@base)
      |> String.pad_leading(2, "0")
      |> String.slice(0..1)

    finger1 <> finger2
  end

  def random do
    @block_max_value
    |> :rand.uniform()
    # we need -1 because uniform give us 1 <= x <= max
    # but we need 0 <= x <= max - 1
    |> Kernel.-(1)
    |> Integer.to_string(@base)
    |> pad(@block_size, "0")
  end

  def seed_rand! do
    # Seed with cryptographically strong seed
    <<i1::size(32), i2::size(32), i3::size(32)>> = :crypto.strong_rand_bytes(12)
    :rand.seed(:exsss, {i1, i2, i3})
  end

  # This is faster than using String.pad_leading/3 directly
  # in the case that no padding is needed
  defp pad(str, size, padder) do
    if byte_size(str) < size do
      String.pad_leading(str, @block_size, padder)
    else
      str
    end
  end
end
