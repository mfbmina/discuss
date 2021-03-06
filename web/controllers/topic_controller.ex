defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  alias Discuss.Topic

  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  plug :check_topic_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)

    render conn, "index.html", topics: topics
  end

  def show(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)

    render conn, "show.html", topic: topic
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{})

    render conn, "new.html", changeset: changeset
  end

  def edit(conn, %{"id" => id}) do
    topic = Repo.get(Topic, id)

    changeset = Topic.changeset(topic)

    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def create(conn, %{"topic" => attributes}) do
    changeset = conn.assigns.user
      |> build_assoc(:topics)
      |> Topic.changeset(attributes)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
          |> put_flash(:info, "Topic created")
          |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def update(conn, %{"id" => id, "topic" => attributes}) do
    topic = Repo.get(Topic, id)

    changeset = Topic.changeset(topic, attributes)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
          |> put_flash(:info, "Topic updated")
          |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: topic
    end
  end

  def delete(conn, %{"id" => id}) do
    Repo.get!(Topic, id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  def check_topic_owner(conn, _) do
    %{params: %{"id" => id}} = conn

    if Repo.get(Topic, id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "Not allowed")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end
