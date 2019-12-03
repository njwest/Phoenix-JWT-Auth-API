defmodule MyApi.AccountsTest do
  use MyApi.DataCase

  alias MyApi.Accounts

  describe "users" do
    alias MyApi.Accounts.User

    @valid_attrs %{email: "email@mail.com", password: "some password", password_confirmation: "some password", password_hash: "some password_hash"}
    @update_attrs %{email: "updatedemail@mail.com", password: "some updated password", password_confirmation: "some updated password", password_hash: "some updated password_hash"}
    @invalid_attrs %{email: nil, password_hash: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      [user_data] = Accounts.list_users()

      assert user_data.email == user.email
      assert user_data.password_hash == user.password_hash
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      user_data = Accounts.get_user!(user.id)

      assert user_data.email == user.email
      assert user_data.password_hash == user.password_hash
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)

      assert user.email == "email@mail.com"
      assert Argon2.verify_pass(@valid_attrs.password, user.password_hash) == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "updatedemail@mail.com"
      assert Argon2.verify_pass(@update_attrs.password, user.password_hash) == true
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      user_data = Accounts.get_user!(user.id)

      assert user.email == user_data.email
      assert user.password_hash == user_data.password_hash
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()

      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
