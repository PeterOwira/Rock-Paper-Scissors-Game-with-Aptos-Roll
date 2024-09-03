address 0x1889d7e7c07ca72675e5e998820ee533fc76580ae115b4753c38075635ec8623 {

module RockPaperScissorsv1 {
    use std::signer;
    use aptos_framework::randomness;

    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;

    const PLAYER_WINS: u8 = 2;
    const DRAW: u8 = 1;
    const COMPUTER_WINS: u8 = 3;

    struct Game has key {
        player: address,
        player_wins: u8,
        computer_wins: u8,
        draws: u8,
        current_round: u8,
        player_move: u8,
        computer_move: u8,
        result: u8,
    }

    // Initializes a new game for the player.
    public entry fun start_game(account: &signer) acquires Game {
        let player = signer::address_of(account);
        
        if (exists<Game>(player)) {
            // If a game already exists, reset the game state
            let game = borrow_global_mut<Game>(player);
            game.player_move = 0;
            game.computer_move = 0;
            game.result = 0;
            game.current_round = game.current_round + 1;
        } else {
            // If no game exists, create a new one
            let game = Game {
                player,
                player_wins: 0,
                computer_wins: 0,
                draws: 0,
                current_round: 1,
                player_move: 0,
                computer_move: 0,
                result: 0,
            };
            move_to(account, game);
        }
    }


    public entry fun set_player_move(account: &signer, player_move: u8) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player_move = player_move;
    }

    #[randomness]
    entry fun randomly_set_computer_move(account: &signer) acquires Game {
        randomly_set_computer_move_internal(account);
    }

    public(friend) fun randomly_set_computer_move_internal(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        let random_number = randomness::u8_range(1, 4);
        game.computer_move = random_number;
    }

    public entry fun finalize_game_results(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.result = determine_winner(game.player_move, game.computer_move);
    }

    // Determines the winner based on the player's and computer's moves.
    fun determine_winner(player_move: u8, computer_move: u8): u8 {
        if (player_move == computer_move) {
            DRAW
        } else if (
            (player_move == ROCK && computer_move == SCISSORS) ||
            (player_move == PAPER && computer_move == ROCK) ||
            (player_move == SCISSORS && computer_move == PAPER)
        ) {
            PLAYER_WINS           
        } else {
            COMPUTER_WINS
        }
    }

    // Updates the win count and round number based on the game result.
    public entry fun update_game_stats(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));

        if (game.result == PLAYER_WINS) {
            game.player_wins = game.player_wins+1;
        } else if (game.result == COMPUTER_WINS) {
            game.computer_wins = game.computer_wins + 1;
        } else {
            game.draws = game.draws + 1;
        }

       
    }

    #[view]
    public fun get_player_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player_move
    }

    #[view]
    public fun get_computer_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).computer_move
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
    public fun get_player_wins(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player_wins
    }

    // Additional view function to get the computer wins number.
    #[view]
    public fun get_computer_wins(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).computer_wins
    }

}
}