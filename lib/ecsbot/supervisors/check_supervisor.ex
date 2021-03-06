defmodule Ecsbot.Supervisor.CheckSupervisor do
  use Supervisor
  @callback enqueue(tuple()) :: atom()

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Ecsbot.Supervisor.CheckSupervisor)
  end

  def init([]) do
    children = [
      worker(Ecsbot.ServiceChecker, [], id: :one),
      worker(Ecsbot.ServiceChecker, [], id: :two)
    ]

    supervise(children, strategy: :one_for_one)
  end

  def enqueue_to do
    {_, pid, _, _} =
      Supervisor.which_children(__MODULE__)
      |> Enum.filter(fn x -> elem(x, 3) == [Ecsbot.ServiceChecker] end)
      |> Enum.random()

    pid
  end

  def enqueue(params) do
    enqueue_to() |> Ecsbot.ServiceChecker.send(params)
  end

  def count do
    Supervisor.count_children(Ecsbot.Supervisor.CheckSupervisor)
  end
end
