defmodule MyApiWeb.UserControllerTest do
  use MyApiWeb.ConnCase

  alias MyApi.Accounts
  alias MyApi.Accounts.User

  alias MyApi.Guardian

  @create_attrs %{email: "e-mail@mail.com", password: "password", password_confirmation: "password", password_hash: "password_hash"}
  @sign_in_attrs %{email: "e-mail@mail.com", password: "password"}

  @update_attrs %{email: "updatedemail@mail.com", password: "some updated password", password_confirmation: "some updated password", password_hash: "some updated password_hash"}
  @invalid_attrs %{email: nil, password_hash: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      user = fixture(:user)

      {:ok, token, _} = Guardian.encode_and_sign(user)

      conn = conn
      |> put_req_header("authorization", "Bearer: " <> token)
      |> get(user_path(conn, :index))

      [rep] = json_response(conn, 200)["data"]

      assert rep["email"] == user.email
      assert Argon2.verify_pass(@create_attrs.password, user.password_hash) == true
    end
  end

  describe "login" do
    test "login successfully", %{conn: conn} do
      user = fixture(:user)

      conn = conn
      |> post(user_path(conn, :sign_in), @sign_in_attrs)

      {:ok, user_data, _claims} = Guardian.resource_from_token(json_response(conn, 200)["jwt"])

      assert user.id == user_data.id
      assert user.email == user_data.email
      assert user.password_hash == user_data.password_hash
    end

    test "login unsuccessfully", %{conn: conn} do
      conn = conn
      |> post(user_path(conn, :sign_in), @sign_in_attrs)

      assert json_response(conn, 401)["error"] == "Login error"
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = conn
      |> post(user_path(conn, :create), user: @create_attrs)
      |> post(user_path(conn, :sign_in), @sign_in_attrs)

      {:ok, user, _claims} = Guardian.resource_from_token(json_response(conn, 200)["jwt"])

      conn = get(conn, user_path(conn, :show, user.id))

      assert json_response(conn, 200)["id"] == user.id
      assert json_response(conn, 200)["email"] == user.email
      assert Argon2.verify_pass(@create_attrs.password, json_response(conn, 200)["password_hash"]) == true
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id}} do
      conn = conn
      |> post(user_path(conn, :sign_in), @sign_in_attrs)
      |> put(user_path(conn, :update, id), user: @update_attrs)

      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, user_path(conn, :show, id))

      assert json_response(conn, 200)["id"] == id
      assert json_response(conn, 200)["email"] == "updatedemail@mail.com"
      assert Argon2.verify_pass(@update_attrs.password, json_response(conn, 200)["password_hash"]) == true
    end

    test "renders errors when data is invalid", %{conn: conn, user: %User{id: id}} do
      conn = conn
      |> post(user_path(conn, :sign_in), @sign_in_attrs)
      |> put(user_path(conn, :update, id), user: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: %User{id: id}} do
      conn = conn
      |> post(user_path(conn, :sign_in), @sign_in_attrs)
      |> delete(user_path(conn, :delete, id))

      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, user_path(conn, :show, id)
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
