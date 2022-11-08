defmodule TicTacToeWeb.GameLiveTests do
  @moduledoc false
  use TicTacToeWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "multiplayer" do
    setup %{conn: conn} do
      %{conn: user_1_conn, user: user_1} = register_and_log_in_user(%{conn: conn})
      user_2 = TicTacToe.AccountsFixtures.user_fixture(%{email: "test@test.com"})

      %{conn: user_2_conn, user: user_2} = register_and_log_in_user(%{conn: conn}, user_2)
      [user_1_conn: user_1_conn, user_1: user_1, user_2: user_2, user_2_conn: user_2_conn]
    end

    test "draw game", %{
      user_1_conn: user_1_conn,
      user_2_conn: user_2_conn,
      user_1: user_1,
      user_2: user_2
    } do
      {:ok, _view, _html} = live(user_1_conn, "/")

      # user_1 starts game
      {user_1_game_view, user_1_game_html} = user_start_game(user_1_conn)

      assert user_1_game_html =~ "Waiting for 2nd user to Join before starting"

      # user_2 joins game

      {user_2_game_view, user_2_game_html} = user_join_game(user_2_conn)

      assert render(user_1_game_view) =~ "player #{user_2.email} joined the game"
      assert user_2_game_html =~ "Game Board"

      # user_moves
      # user_1 move
      user_move(user_1_game_view, 0)
      # user_2 move
      user_move(user_2_game_view, 1)
      # user_1 move
      user_move(user_1_game_view, 2)
      # user_2 move
      user_move(user_2_game_view, 4)
      # user_1 move
      user_move(user_1_game_view, 3)
      # user_2 move
      user_move(user_2_game_view, 6)
      # user_2 move
      user_move(user_2_game_view, 6)

      # user_1 move
      user_move(user_1_game_view, 5)

      # user_1 move #extra move
      user_1_html = user_move(user_1_game_view, 7)
      # assert user cannot make 2 moves consectively
      assert user_1_html =~ "it is not your turn"

      # user_2 move
      user_move(user_2_game_view, 8)
      # user_1  move
      final_html_user_1 = user_move(user_1_game_view, 7)

      # assert draw

      assert final_html_user_1 =~ "Its a draw!!!"
      assert final_html_user_1 =~ "Player: #{user_1.email}"
      assert final_html_user_1 =~ "New Game</button>"
      # inform user 2 its a draw
      assert render(user_2_game_view) =~ "Its a draw!!!"
      assert render(user_2_game_view) =~ "New Game</button>"
    end

    test "win game", %{
      user_1_conn: user_1_conn,
      user_2_conn: user_2_conn,
      user_1: user_1,
      user_2: user_2
    } do
      {:ok, _view, _html} = live(user_1_conn, "/")

      # user_1 starts game
      {user_1_game_view, user_1_game_html} = user_start_game(user_1_conn)

      assert user_1_game_html =~ "Waiting for 2nd user to Join before starting"

      # user_2 joins game

      {user_2_game_view, user_2_game_html} = user_join_game(user_2_conn)

      assert render(user_1_game_view) =~ "player #{user_2.email} joined the game"
      assert user_2_game_html =~ "Game Board"

      # user_moves
      # user_1 move
      user_move(user_1_game_view, 0)
      # user_2 move
      user_move(user_2_game_view, 1)

      # assert user cannot make 2 moves consectively
      # user_2 move #extra move
      user_2_html = user_move(user_2_game_view, 4)

      assert user_2_html =~ "it is not your turn"

      # user_1 move
      user_move(user_1_game_view, 2)
      # user_2 move
      user_move(user_2_game_view, 3)
      # user_1 move
      user_move(user_1_game_view, 4)
      # user_2 move
      user_move(user_2_game_view, 5)
      # user_1 move
      user_move(user_1_game_view, 6)
      # user_2 move
      user_move(user_2_game_view, 7)
      # user_1  move
      final_html_user_1 = user_move(user_1_game_view, 8)

      # assert win

      assert final_html_user_1 =~ "You Won the game"
      assert final_html_user_1 =~ "Player: #{user_1.email}"
      assert final_html_user_1 =~ "New Game</button>"
      # inform user_2 that user_1 won the game
      assert render(user_2_game_view) =~ "#{user_1.email} won the game"
      assert render(user_2_game_view) =~ "New Game</button>"
    end
  end

  defp user_start_game(conn) do
    {:ok, view, _html} = live(conn, "/")

    result =
      view
      |> element("[data-role='multiplayer-button']")
      |> render_click()

    {:ok, user_game_view, user_game_html} = follow_redirect(result, conn)

    {user_game_view, user_game_html}
  end

  defp user_join_game(conn) do
    {:ok, view, _html} = live(conn, "/")

    result =
      view
      |> element("[data-role='join-game']")
      |> render_click()

    {:ok, user_game_view, user_game_html} = follow_redirect(result, conn)

    {user_game_view, user_game_html}
  end

  defp user_move(view, position) do
    view
    |> element("[data-role='position-#{position}']")
    |> render_click()
  end
end
