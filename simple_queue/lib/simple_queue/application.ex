defmodule SimpleQueue.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # children spec을 여기에 inline으로 구현한 방식
      %{id: 456, start: {SimpleQueue, :start_link, [[1, 2, 3]]}, modules: [SimpleQueue]},

      # GenServer에는 이미 child_spec이 구현되어 있으므로 이를 불러온 방식
      TestQueue.child_spec([10, 11, 23, 40020, 12, 32, 20]),
      {Task.Supervisor, name: Chat.TaskSupervisor}
    ]

    opts = [
      strategy: :one_for_one,
      name: SimpleQueue.Supervisor
    ]

    Supervisor.start_link(children, opts)

    # 또는 start_link에 inline으로 매개변수를 넘기는 방식
    # Supervisor.start_link([{TestQueue, [4, 5, 6]}],
    #   strategy: :one_for_one,
    #   name: TestQueue.Supervisor
    # )
  end
end
