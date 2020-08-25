defmodule Proj4 do
    time_now = System.system_time(:millisecond)
    args = System.argv()
    task = Proj4.Main.start_main(args)
    Task.await(task, :infinity)
    IO.puts("Total time taken for the simulation: #{System.system_time(:millisecond) - time_now}ms")
    Process.sleep(1000)
  end
  