defmodule TicTacToeWeb.DashboardLiveTests do
  @moduledoc false
  use TicTacToeWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "dashboard" do
    setup :register_and_log_in_user

    test "dashboard page is rendered", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Available Games</h1>"
      assert html =~ "Click to select which game mode you would like start play? </p>"
      assert html =~ "logout"
      assert html =~ "Multiplayer</button>"
      assert html =~ "Single Player</button>"
    end

    test "logout ", %{conn: conn} do
      conn = TicTacToeWeb.UserAuth.log_out_user(conn)
      refute get_session(conn, :user_token)

      assert redirected_to(conn) == "/users/log_in"
    end

    test "single player does not work", %{conn: conn} do
      %{conn: conn, user: _user} = register_and_log_in_user(%{conn: conn})
      {:ok, view, _html} = live(conn, "/")

      assert view
             |> element("[data-role='singleplayer-button']")
             |> render_click() =~ "Not yet implemented try again later"
    end

    test "multi-player", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      result =
        view
        |> element("[data-role='multiplayer-button']")
        |> render_click()

      {:ok, _view, game_html} = follow_redirect(result, conn)

      assert game_html =~ "Waiting for 2nd user to Join before starting"
    end
  end

  describe "multiplayer " do
    test "user can join a game on the dashboard", %{conn: conn} do
      %{conn: user_1_conn, user: _user_1} = register_and_log_in_user(%{conn: conn})

      user_2 = TicTacToe.AccountsFixtures.user_fixture(%{email: "test@test.com"})

      %{conn: user_2_conn, user: user_2} = register_and_log_in_user(%{conn: conn}, user_2)

      {:ok, view, _html} = live(user_1_conn, "/")

      result =
        view
        |> element("[data-role='multiplayer-button']")
        |> render_click()

      {:ok, user_1_game_view, user_1_game_html} = follow_redirect(result, user_1_conn)

      assert user_1_game_html =~ "Waiting for 2nd user to Join before starting"

      {:ok, view, _html} = live(user_2_conn, "/")

      result =
        view
        |> element("[data-role='join-game']")
        |> render_click()

      {:ok, _user_2_game_view, user_2_game_html} = follow_redirect(result, user_2_conn)

      assert render(user_1_game_view) =~ "player #{user_2.email} joined the game"
      assert user_2_game_html =~ "Game Board"
    end
  end
end
