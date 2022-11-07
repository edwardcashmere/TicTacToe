# TicTacToe

To start install depencies and run the server I added a make file to simplify setup.

*  Run **make** to list all the make commands possible and their definitions of what they will do.

* To setup the correct language versions using *asdf* , install dependencies, create database and run migrations run **asdf-setup** .

* However if you do not wish to use asdf make sure you have the correct versions of elixir, erlang, nodejs included in the *.tool-versions*  then run **make setup** to setup project and **make debug** to run the project.

* Run **maketest** to execute the tests.

Currenlty the support is only for a multiplayer setup. Single player support to be included later.

Once the project is setup and running. Navigate to 
> http://127.0.0.1/users/register

 
 
## Register Page

![empty board](/assets/images/register.png)

After sign up with email and password you will be logged in to the dashbaord which tracks ongoing games, here you can start a game. Then open incognito tab sign up as another user and the started game should be on the dashboard with a join button.

## Empty Dashboard
![empty board](/assets/images/dashboard.png)

## DashBoard With Game

![empty board](/assets/images/dashboard_join_game.png)




The game cannot be started until the 2nd user joins.
You can play the game to either draw or win and you will get a pop to start a new game and play again.

## Game Create 
![empty board](/assets/images/game_created.png)

## Empty Board
![empty board](/assets/images/board.png)

## Draw Game Board

![draw game](/assets/images/draw.png)

## Won Game Board

![draw game](/assets/images/Win.png)


---

Possible additional features :-

* Add real time chat feature for in the game session
* Track wins, loses and draws in db and game session
* Add leader board for all time wins on the dashboard
* Finish the single player mode feature
* Propally highlight the winning move
* Add SVG for the Naughts and Crosses.


Now you can visit [`localhost:4000`](http://localhost:4000/users/register) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
