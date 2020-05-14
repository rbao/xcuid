defmodule XCUIDTest do
  use ExUnit.Case

  describe "timestamp/0" do
    test "generate timestamp in base 36" do
      unix_ts = :os.system_time(:millisecond)
      assert byte_size(XCUID.timestamp(unix_ts)) >= 8
    end
  end

  describe "counter/1" do
    test "format integer to 4 character" do
      assert byte_size(XCUID.counter(0)) == 4
      assert byte_size(XCUID.counter(376890)) == 4
    end
  end

  describe "finterprint/0" do
    test "generate the same 4 character for the same os process" do
      assert XCUID.fingerprint() == XCUID.fingerprint()
      assert byte_size(XCUID.fingerprint()) == 4
    end
  end

  describe "random/0" do
    test "genreate random 4 character" do
      assert XCUID.random() != XCUID.random()
      assert byte_size(XCUID.random()) == 4
    end
  end

  describe "generate/0" do
    test "generate a string of least 25 character" do
      cuid = XCUID.generate()

      assert is_binary(cuid)
      assert byte_size(cuid) >= 25
    end

    test "should not have collosion for 30 million generation using 1 thousand generator" do
      total_sample_size = 30_000_000
      num_generator = 1_000

      # Spawn generators
      pids =
        Enum.reduce(0..(num_generator - 2), [XCUID], fn i, acc ->
          name = String.to_atom("server_#{i}")
          {:ok, pid} = XCUID.start_link(name: name)
          acc ++ [pid]
        end)

      # Asychrously call all the generators
      per_generator_size = trunc(total_sample_size / num_generator)
      tasks =
        Enum.map(pids, fn pid ->
          Task.async(fn ->
            Stream.repeatedly(fn -> XCUID.generate(pid) end)
            |> Stream.take(per_generator_size)
            |> MapSet.new()
          end)
        end)

      # Keep all result in memory, this will use a few GB of memory
      set =
        Enum.reduce(tasks, MapSet.new(), fn task, acc ->
          set = Task.await(task, :infinity)
          MapSet.union(acc, set)
        end)

      assert MapSet.size(set) == total_sample_size
    end
  end
end
