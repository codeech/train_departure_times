defmodule Traindepartures.PageController do
  use Traindepartures.Web, :controller
  alias Traindepartures.Utils, as: Utils

  def index(conn, _params) do
      render conn, "index.html", Utils.get_departure_table_template_args()
  end

end
