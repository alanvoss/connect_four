defmodule ConnectFour.Application do
  @moduledoc """
  The ConnectFour Application Service.

  The connect_four system business domain lives in this application.

  Exposes API to clients such as the `ConnectFour.Web` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      
    ], strategy: :one_for_one, name: ConnectFour.Supervisor)
  end
end
