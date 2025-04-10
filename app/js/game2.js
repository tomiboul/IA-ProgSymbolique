export const state = {
    elves : {
        green  : [],
        blue   : [],
        yellow : [],
        red    : []
    },

    bridges : [],

    generateAllBridges(gridSize) {
        const bridges = [];
        
        // Ponts horizontaux (x varie, y fixe)
        for (let y = 0; y < gridSize; y++) {
            for (let x = 0; x < gridSize - 1; x++) {
                bridges.push([ [x, y , x + 1, y] ]); // (x,y) < (x+1,y)
            }
        }
        
        // Ponts verticaux (x fixe, y varie)
        for (let x = 0; x < gridSize; x++) {
            for (let y = 0; y < gridSize - 1; y++) {
                bridges.push([ [x, y, x, y + 1] ]); // (x,y) < (x,y+1)
            }
        }
        
        return bridges;
    }
}

const players = [green,blue,yellow,red];

export function newGameStart() {
    // Initialiser le state
    state.elves.green  = [],
    state.elves.blue   = [],
    state.elves.yellow = [],
    state.elves.red    = [],

    bridges

    // Initialiser le premier joueur
    state.
}