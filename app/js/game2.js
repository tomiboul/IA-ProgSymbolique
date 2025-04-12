export const gameState = {
    elves: {
        // each elf is represented by its coord (x,y)
        green: [],
        blue: [],
        yellow: [],
        red: []
    },

    bridges: [],
    currentPlayerIndex: 0,
    playerOrder: ['green', 'blue', 'yellow', 'red'],

    get currentPlayer() {
        return this.playerOrder[this.currentPlayerIndex];
    },

    get currentPlayerElves() {
        return this.elves[this.currentPlayer];
    },

    currentPhase: 'placementPhase',
    deadPlayers: [],

    generateAllBridges(gridSize) {
        const bridges = [];
        
        // Ponts horizontaux, seul x varie
        for (let y = 0; y < gridSize; y++) {
            for (let x = 0; x < gridSize - 1; x++) {
                bridges.push([ [x, y , x + 1, y] ]); // (x,y) < (x+1,y)
            }
        }
        
        // Ponts verticaux seul y varie
        for (let x = 0; x < gridSize; x++) {
            for (let y = 0; y < gridSize - 1; y++) {
                bridges.push([ [x, y, x, y + 1] ]); // (x,y) < (x,y+1)
            }
        }
        return bridges;
    }
}

// const playersOrder = [green,blue,yellow,red];
const playersOrder = [state.elves.green, state.elves.blue, state.elves.yellow, state.elves.red];

const board = document.getElementById("board");

export function newGameInit(state) {
    // Init state
    state.elves.green  = [];
    state.elves.blue   = [];
    state.elves.yellow = [];
    state.elves.red    = [];

    // Init first player
    state.currentPlayerIndex = 0;

    // Init game phase 
    state.currentPhase = 'placementPhase';
            
    // Init bridges 
    state.bridges = state.generateAllBridges();
}

function playTurn(state){
        // wait for user to click on a cell
        board.addEventListener("click", () => {
            // Here, retrieve the coords of the selected cell
        })

        if(state.currentPhase === 'placementPhase') {
        // check if currentPlayer doesn't already have an elf on that cell

        // if currentPlayer has an elf on that cell -> display message

        // if another player has an elf on that cell -> display a different message

        // if no elf on that cell -> display some positive feeback (green border/...)
    }

    else if(state.currentPhase === 'playingPhase') {
        
    }
}

function checkForLoser(state) {
    const currentColor = state.playerOrder[state.currentPlayerIndex];
    const currentElves = state.elves[currentColor];

    // If player already eliminated -> ignore
    if (state.deadPlayers.includes(state.currentPlayerIndex)) {
        return;
    }

    // Check if ALL this player's elves are blocked 
    const allBlocked = currentElves.every(([x, y]) => isElfBlocked(x, y, state));

    // if ALL blocked -> add this player to deadPlayers
    if (allBlocked) {
        state.deadPlayers.push(state.currentPlayerIndex);
        console.log(`Player ${currentColor} eliminated (all elves blocked!)`);
        // *Display a list of dead players
    }
}

function isElfBlocked(x, y, state) {
    // All four directions :
    const directions = [
        {dx: 0, dy: 1}, 
        {dx: 1, dy: 0},  
        {dx: 0, dy: -1}, 
        {dx: -1, dy: 0}  
    ];

    for (const dir of directions) {
        const newX = x + dir.dx;
        const newY = y + dir.dy;

        // For each direction, check if destination is within the board
        // If not, pass this direction and go to the next one
        if (newX < 0 || newX >= 6 || newY < 0 || newY >= 6) {
            continue;
        }

        // Check if there is a bridge to get there
        let hasBridge = false;
        // *Function to find bridges aroud
        
        if (!hasBridge) continue;

        // Check if cell is free
        let cellFree = true;
        for (const color in state.elves) {
            for (const [ex, ey] of state.elves[color]) {
                if (ex === newX && ey === newY) {
                    cellFree = false;
                    break;
                }
            }
            if (!cellFree) break;
        }

        if (cellFree) {
            return false; // At least one possible way out -> elf not blocked
        }
    }

    return true; // No way out
}

function checkIfGameFinished(state) {
    // Amount of players alive
    const activePlayers = state.playerOrder.length - state.deadPlayers.length;
    
    if (activePlayers <= 1) {
        state.currentPhase = 'finished';
        
        // Find the winner
        const winner = state.playerOrder.find(
            (_, index) => !state.deadPlayers.includes(index)
        );
        
        alert(`Game over! Winner: ${winner}`);
        return true;
    }
    return false;
}

function updateBoardDisplay(state) {

}

async function pontuXL(state, playersOrder) {
    // Init a new game
    newGameInit(state); 
    
    // Main loop
    while(state.currentPhase !== 'finished') {
        await playTurn(state);
        checkForLoser(state);
        checkIfGameFinished(state);
        setNextTurn(state);
        updateBoardDisplay(state);
    }
    
    // When the game is over : 
    //...
}

start.addEventListener("click", () => {
    // Check if no game is currently running
    if (gameState.currentPhase !== 'finished' && gameState.currentPhase !== undefined) {
        const confirmNewGame = confirm("⚠️ A game is already running!\nDo you want to abandon it and start a new game?");
        
        if (!confirmNewGame) {
            return; // If player refuses, cancel the launch of a new game
        }
    }
    
    // Launch a new game
    pontuXL(gameState);
});