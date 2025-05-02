const gameState = {
    elves: {
        // each elf is represented by its coord (x,y,stuck(bool))
        green: [],
        blue: [],
        yellow: [],
        red: []
    },

    bridges: [], //[ ((x1,y1),(x2,y2))]
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






const currentColor = state.playerOrder[state.currentPlayerIndex];

console.log(currentColor);