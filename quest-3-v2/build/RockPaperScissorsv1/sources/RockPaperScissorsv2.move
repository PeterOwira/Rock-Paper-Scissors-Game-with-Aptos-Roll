address 0x88c55c218ec0e2fe84faf5fefa35b4c0ec0e05ffa3ebeecf39a9a6a6f5907c9e {

module RockPaperScissorsv2 {
    use std::signer;
    use aptos_framework::randomness;

    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;

    const PLAYER1_WINS: u8 = 2;
    const DRAW: u8 = 1;
    const PLAYER2_WINS: u8 = 3;

    struct Game has key {
        player1: address,
        player2: address,
        player1_wins: u8,
        player2_wins: u8,
        draws: u8,
        current_round: u8,
        player1_move: u8,
        player2_move: u8,
        result: u8,
    }

    // Initializes a new game for the player.
    public entry fun start_game(account1: &signer, account2: &signer) acquires Game {
        let player1 = signer::address_of(account1);
        let player2 = signer::address_of(account2);
        
        if (exists<Game>(player1)) {
            // If a game already exists, reset the game state
            let game = borrow_global_mut<Game>(player1);
            game.player1_move = 0;
            game.player2_move = 0;
            game.result = 0;
            game.current_round = game.current_round + 1;
        } else {
            // If no game exists, create a new one
            let game = Game {
                player1,
                player2,
                player1_wins: 0,
                player2_wins: 0,
                draws: 0,
                current_round: 1,
                player1_move: 0,
                player2_move: 0,
                result: 0,
            };
            move_to(account1, game);
        }
    }


    // Sets the move for player 1.
    public entry fun set_player1_move(account: &signer, player_move: u8) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player1_move = player_move;
    }

    // Sets the move for player 2.
    public entry fun set_player2_move(account: &signer, player_move: u8) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player2_move = player_move;
    }



    public entry fun finalize_game_results(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.result = determine_winner(game.player1_move, game.player2_move);
    }

    // Determines the winner based on the player1's and player2's moves.
    fun determine_winner(player1_move: u8, player2_move: u8): u8 {
        if (player1_move == player2_move) {
            DRAW
        } else if (
            (player1_move == ROCK && player2_move == SCISSORS) ||
            (player1_move == PAPER && player2_move == ROCK) ||
            (player1_move == SCISSORS && player2_move == PAPER)
        ) {
            PLAYER1_WINS           
        } else {
            PLAYER2_WINS
        }
    }

    // Updates the win count and round number based on the game result.
    public entry fun update_game_stats(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));

        if (game.result == PLAYER1_WINS) {
            game.player1_wins = game.player1_wins+1;
        } else if (game.result == PLAYER2_WINS) {
            game.player2_wins = game.player2_wins+1;
        } else {
            game.draws = game.draws + 1;
        }

       
    }

    #[view]
    public fun get_player1_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player1_move
    }

    #[view]
    public fun get_player2_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player2_move
    }

    #[view]
    public fun get_game_results(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).result
    }

    // Additional view function to get the current round number.
    #[view]
    public fun get_current_round(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).current_round
    }

    // Additional view function to get the player wins number.
    #[view]
    public fun get_player1_wins(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player1_wins
    }

    // Additional view function to get the player wins number.
    #[view]
    public fun get_player2_wins(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player2_wins
    }



}
}