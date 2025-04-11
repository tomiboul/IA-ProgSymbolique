export const gameState = {
    elves: {
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

    currentPhase: 'startingPhase',
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


export function newGameInit(state) {
    // Init state
    state.elves.green  = [];
    state.elves.blue   = [];
    state.elves.yellow = [];
    state.elves.red    = [];

    // Init first player
    state.currentPlayerIndex = 0;

    // Init game phase 
    state.currentPhase = 'startingPhase';
            
    // Init bridges 
    state.bridges = state.generateAllBridges();
}

function playTurn(state){
    if(state.currentPhase === 'startingPhase') {
        // wait for user click on a cell
        // check if 
    }

    else if(state.currentPhase === 'playingPhase') {

    }
}

function setNextTurn(state) {
    // Find next player's index, skipping dead players
    nextId = (state.currentPlayerIndex + 1) % 3;
    while (state.deadPlayers.includes(nextId)){
        nextId = (NextId + 1) % 3
    }
    // Update currentPlayerIndex
    state.currentPlayerIndex = nextId;
}

function checkForLoser(state){

}

function checkForWinner(state){

}

function checkIfGameFinished(state) {
    if (state.deadPlayers.length >= state.playerOrder.length - 1) {
        state.currentPhase = 'finished';
    };

    alert("Game over, GG to the winner");
}

function pontuXL(state, playersOrder) {
    // Init a new game
    newGameInit(state); 
    
    // Main loop
    while(state.currentPhase !== 'finished') {
        playTurn(state);
        setNextTurn(state);
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

    // Réactive le bouton dans tous les cas (même en cas d'erreur)
    start.disabled = false;
});