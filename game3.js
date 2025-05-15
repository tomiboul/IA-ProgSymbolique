const gameStateOld = {
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

    currentPhase: 'starting',
    deadPlayersIndex: [],

    generateAllBridges(gridSize) {
        const bridges = [];
        
        // Ponts horizontaux, seul x varie
        for (let y = 0; y < gridSize; y++) {
            for (let x = 0; x < gridSize - 1; x++) {
                bridges.push([ x, y , x + 1, y ]); // (x,y) < (x+1,y)
            }
        }
        
        // Ponts verticaux seul y varie
        for (let x = 0; x < gridSize; x++) {
            for (let y = 0; y < gridSize - 1; y++) {
                bridges.push([ x, y, x, y + 1 ]); // (x,y) < (x,y+1)
            }
        }
        return bridges;
    }
}

// NEW GaemeState
const gameState = {
    boardSize: 6,
    players: [
      { colour: "green", type: "human", elves: [], eliminated: false },
      { colour: "blue", type: "AI", elves: [], eliminated: false },
      { colour: "yellow", type: "human", elves: [], eliminated: false },
      { colour: "red", type: "AI", elves: [], eliminated: false }
    ],
    currentPlayerIndex: 0,
    phase: "starting", // "starting" or "placement" or "playing"
    bridges: new Set(), // a bridge follows this format: "x1,y1-x2,y2", 
    // ex: "1,2-3,4" is a bridge that connects cells (1,2) and (3,4)
    // To check if a bridge exists, do gameState.bridges.has("x1,y1-x2,y2")

    doesBridgeExist(bridgeCoords) {
        if (Array.isArray(bridgeCoords)) {
            // Si bridgeCoords est un tableau de coordonnées [[x1, y1], [x2, y2]]
            const [[x1, y1], [x2, y2]] = bridgeCoords;
            const key = this.bridgeKey(x1, y1, x2, y2);
            return this.bridges.has(key);
        } else if (typeof bridgeCoords === "string") {
            // Si bridgeCoords est une chaîne de caractères "x1,y1-x2,y2"
            return this.bridges.has(bridgeCoords);
        } else {
            // Si l'entrée est invalide
            throw new Error("Invalid input to doesBridgeExist. Expected an array or string.");
        }
    },

    bridgeKey(x1, y1, x2, y2) {
        const a = `${x1},${y1}`;
        const b = `${x2},${y2}`;
        return a < b ? `${a}-${b}` : `${b}-${a}`;
    },

    generateAllBridges(boardSize) {
        const newBridges = new Set();

        // Generate horizontal bridges
        for (let y = 1; y <= boardSize; y++) {
            for (let x = 1; x < boardSize; x++) {
                const bridgeKey = `${x},${y}-${x + 1},${y}`;
                newBridges.add(bridgeKey);
            }
        }

        // Generate vertical bridges
        for (let x = 1; x <= boardSize; x++) {
            for (let y = 1; y < boardSize; y++) {
                const bridgeKey = `${x},${y}-${x},${y + 1}`;
                newBridges.add(bridgeKey);
            }
        }

        this.bridges = newBridges;
    },
    
    deleteBridge(bridgeCoords) {
        if (Array.isArray(bridgeCoords)) {
            const [[x1, y1], [x2, y2]] = bridgeCoords;
            const key = this.bridgeKey(x1, y1, x2, y2);
            this.bridges.delete(key);
            return true;
        }

        else if (typeof(bridgeCoords)) {
            this.bridges.delete(bridgeCoords);
            return true;
        }
        
        console.warn("Brdige (", key, ") deletion failed");
        return false;
    },

    getBridgePossibleRotations(bridgeCoords) {
        // Implement logic to return possible rotations for a bridge
        // Example: return [[x1, y1, x2, y2], [x3, y3, x4, y4]];
        console.warn("getBridgePossibleRotations is not implemented yet.");
        return [];
    },

    rotateBridge(bridgeCoords) {
        // Implement logic to rotate a bridge
        // Example: Update the bridge coordinates in the state
        console.warn("rotateBridge is not implemented yet.");
    },
     
    selectedPawn: null,

    newStateInit() {
        this.boardSize = 6;

        this.players = [
            { colour: "green", type: "human", elves: [], eliminated: false },
            { colour: "blue", type: "AI", elves: [], eliminated: false },
            { colour: "yellow", type: "human", elves: [], eliminated: false },
            { colour: "red", type: "AI", elves: [], eliminated: false }
        ];

        this.currentPlayerIndex = 0;

        this.phase = "placement";

        this.bridges = new Set();

        this.generateAllBridges(this.boardSize);

        console.log("newStateinit(): bridges = " + this.brdiges);
    }
}
  

board = document.getElementById("board");

async function handlePlacementTurn(state) {
    let x, y;
    do {
        const clickedCell = await waitForClickOnCell();
        const id = clickedCell.id;
        const parts = id.split("-");
        x = parseInt(parts[0], 10);
        y = parseInt(parts[1], 10);
    } while (!checkIfCellIsFree(x, y, state));

    const currentPlayer = state.players[state.currentPlayerIndex];
    // console.log("       handlePlacementTurn(): players before adding the elf: ");
    // console.log(state.players);
    state.players[state.currentPlayerIndex].elves.push([x, y, false]);
    // console.log("       handlePlacementTurn(): players after  adding the elf: ");
    // console.log(state.players)


// Add elf to the board
    const cell = document.getElementById(`${x}-${y}`);
    const elfImage = document.createElement("img");
    elfImage.id = `lutin-${x}-${y}`;
    elfImage.className = "lutin";
    elfImage.draggable = true;

    switch (currentPlayer.colour) {
        case "green":
            elfImage.src = "images/lutin_vert.png";
            break;
        case "blue":
            elfImage.src = "images/lutin_bleu.png";
            break;
        case "yellow":
            elfImage.src = "images/lutin_jaune.png";
            break;
        case "red":
            elfImage.src = "images/lutin_rouge.png";
            break;
    }

    cell.appendChild(elfImage);
    elfImage.addEventListener("dragstart", dragStart);
}

function waitForClickOnBridge(state) {
    return new Promise((resolve) => {
        const handler = (e) => {
            const clickedBridge = e.target.closest('.bridge');
            if (!clickedBridge) return; // Ignore clicks outside cells

                        document.querySelectorAll(".bridge").forEach(bridge => {
                bridge.removeEventListener("click", handler);
            });
            console.warn(clickedBridge);
            resolve(clickedBridge); // On retourne le pont cliqué
        };

        document.querySelectorAll(".bridge").forEach(bridge => {
            bridge.addEventListener("click", handler);
        });
    });
}

async function handlePlayingTurn(state) {
    let moveCompleted = false;

    // Elf part:
    do {
        const result = await waitForValidDragAndDrop(state);
        moveCompleted = result.moved;
    } while (!moveCompleted);

    cells = document.querySelectorAll(".cell");
    console.log("all cells:");
    console.log(cells);
    cells.forEach( cell => {cell.removeEventListener('dragenter', dragEnter),
        cell.removeEventListener('dragover', dragOver),
        cell.removeEventListener('dragleave', dragLeave),
        cell.removeEventListener('drop', drop)});

    // Bridge part:
    let x1,y1;
    let x2,y2;
    
    do {
        const clickedBridge = await waitForClickOnBridge(state);
        const id = clickedBridge.id;
        const cellsCoords = id.split("-");
        console.warn(cellsCoords);
        let originCoords = cellsCoords[0];
        let destinationCoords = cellsCoords[1];
        originCoords = originCoords.split(",");
        destinationCoords = destinationCoords.split(",");
        console.warn(originCoords);
        console.warn(destinationCoords);
        [x1,y1] = [parseInt(originCoords[0],10),parseInt(originCoords[1],10)];
        [x2,y2] = [parseInt(destinationCoords[0],10),parseInt(destinationCoords[1],10)];
    } while (!gameState.doesBridgeExist(gameState.bridgeKey(x1,y1,x2,y2)));

    do {

    }

    while(true)

    return;
}

async function playTurn(state) {
    if (state.phase === "placement") {
        console.log("Entering handlePlacementTurn()");
        await handlePlacementTurn(state);
    } else if (state.phase === "playing") {
        console.log("Entering handlePlayingTurn()");
        await handlePlayingTurn(state);
    }
}

// async function waitForValidDragAndDrop(state) {
//     return new Promise((resolve) => {
//         let moveCompleted = false;

//         const onValidDrop = (e) => {
//             if (drop(e)) {
//                 console.warn("ONVALIDDROOOOP")
//                 cleanup();
//                 if(!moveCompleted) {
//                     moveCompleted = true;
//                     resolve({ moved: true });
//                 }
//             }
//         };

//         const cleanup = () => {
//             const cells = document.querySelectorAll('.cell');
//             cells.forEach(c => c.removeEventListener('drop', onValidDrop));
//         };

//         const cells = document.querySelectorAll('.cell');
//         cells.forEach(cell => {
//             cell.addEventListener('drop', onValidDrop);
//         });

//         // Timeout de sécurité
//         setTimeout(() => {
//             if (!moveCompleted) {
//                 cleanup();
//                 resolve({ moved: false });
//             }
//         }, 120000);
//     });
// }

/* ChatGPT version: */
async function waitForValidDragAndDrop(state) {
    return new Promise((resolve) => {
        // Stocker la fonction de résolution globalement
        const onValidDrop = (result) => {
            cleanup();
            resolve(result);
        };

        // Configurer le callback
        setOnDropCallback(onValidDrop);

        // Nettoyage des écouteurs
        const cleanup = () => {
            setOnDropCallback(null);
        };

        // Timeout de sécurité
        setTimeout(() => {
            if (onDropCallback === onValidDrop) {
                cleanup();
                resolve({ moved: false });
            }
        }, 120000);
    });
}






// async function waitForValidDragAndDrop(state) {
//     return new Promise((resolve) => {
//         resolveDropPromise = resolve; // Stocke la fonction de résolution globalement
//     });
// }

function checkIfCellIsFree(x, y, state) {
    if (x < 0 || x > state.boardSize|| y < 0 || y > state.boardSize) {
        console.log("checkIfCellIsFree(): return false 1")
        return false; // Out of bounds
    }

    for (const player of state.players) {
        if (player.elves.some(([elfX, elfY]) => elfX === x && elfY === y)) {
            console.log("checkIfCellIsFree(): return false 2")
            console.log("There is an elf on cell: " + x+"-"+y);
            return false; // Cell is occupied
        }
    }

    console.log("checkIfCellIsFree(): return true");
    return true; // Cell is free
}

function checkElfOnCell(x, y, state) {
    if (x < 0 || x >= state.boardSize || y < 0 || y >= state.boardSize) {
        return null;
    }

    for (const player of state.players) {
        if (player.elves.some(([elfX, elfY]) => elfX === x && elfY === y)) {
            return player.colour === state.players[state.currentPlayerIndex].colour;
        }
    }

    return false;
}

function isValidMove(oldX, oldY, newX, newY, state) {
    // Vérifie si le déplacement est adjacent
    const dx = Math.abs(newX - oldX);
    const dy = Math.abs(newY - oldY);
    console.log("coords: " + oldX + "-" + oldY + " -> " + newX + "-" + newY);

    if ((dx === 1 && dy === 0) || (dx === 0 && dy === 1)) {
        // Vérifie s'il y a un pont entre les deux cases
        const bridgeExists = state.doesBridgeExist([[oldX, oldY], [newX, newY]]);
        console.log("Vérification bridge entre " + oldX+"-"+oldY+" et "+newX+"-"+newY);

        // Vérifie si la case de destination est libre
        const cellIsFree = checkIfCellIsFree(newX, newY,state);

        console.log("bridgeExists: " + bridgeExists);
        console.log("Bridges: ");
        console.log(state.bridges);
        console.log("cellIsFree: " + cellIsFree);
        return bridgeExists && cellIsFree;
    }
    return false; // Déplacement non adjacent
}

function checkIfElfCanMove(x, y, state) {
    const directions = [
        { dx: 0, dy: 1 }, // Up
        { dx: 0, dy: -1 }, // Down
        { dx: 1, dy: 0 }, // Right
        { dx: -1, dy: 0 } // Left
    ];

    for (const { dx, dy } of directions) {
        const newX = x + dx;
        const newY = y + dy;

        // Check if the move is valid
        console.log("calling isValidMove() from checkIfElfCanMove()");
        if (isValidMove(x, y, newX, newY, state)) {
            return true; // At least one valid move exists
        }
    }

    return false; // No valid moves available
}

function isElfBlocked(x, y, state) {
    const directions = [
        { dx: 0, dy: 1 },
        { dx: 0, dy: -1 },
        { dx: 1, dy: 0 },
        { dx: -1, dy: 0 }
    ];

    for (const { dx, dy } of directions) {
        const newX = x + dx;
        const newY = y + dy;

        if (newX < 0 || newX >= state.boardSize || newY < 0 || newY >= state.boardSize) {
            continue;
        }

        const bridgeKey = state.bridgeKey(x, y, newX, newY);
        if (state.bridges.has(bridgeKey) && checkIfCellIsFree(newX, newY, state)) {
            return false; // At least one valid move exists
        }
    }

    return true; // No valid moves available
}

async function waitForClickOnCell() {
    return new Promise((resolve) => {
        const handler = (e) => {
            const clickedCell = e.target.closest('.cell');
            if (!clickedCell) return; // Ignore clicks outside cells

                        document.querySelectorAll(".cell").forEach(cell => {
                cell.removeEventListener("click", handler);
            });

            resolve(clickedCell); // On retourne la cellule cliquée
        };

        document.querySelectorAll(".cell").forEach(cell => {
            cell.addEventListener("click", handler);
        });
    }); 
} 


// checkForLoser() mise à jour ✅
// returns the index of the eliminated player
function checkForLoser(state) {
    let eliminatedPlayers = [];
    
    if(state.phase === "playing") {
        let i = 0;
        for (const player of state.players) {
            if (player.elves.every(elf => elf[2])) {
                player.eliminated = true;
                eliminatedPlayers.push(i);
                console.log(`Player ${player.colour} eliminated since all of their elves were stuck`);
            }
        }
    }
    return eliminatedPlayers;
}

// checkIfGameFinished() mise à jour ✅
function checkIfGameFinished(state) {
    const activePlayers = state.players.filter(player => !player.eliminated);
    const amountActivePlayers = activePlayers.length;

    if (amountActivePlayers === 1) {
        state.phase = 'finished';
        console.log("Current phase was set to 'finished'");

        const winner = activePlayers[0];
        if (winner) {
            alert(`Game over! The winner is the ${winner.colour} player 👏🎉`);
        } else {
            console.error("No active players found, but the game is marked as finished.");
        }
        return true;
    }
    return false;
}


// setNextTurn() mise à jour ✅
function setNextTurn(state) {
    do {
        state.currentPlayerIndex = (state.currentPlayerIndex + 1) % state.players.length;
    } while (state.players[state.currentPlayerIndex].eliminated);

    console.log("(SetNextTurn) New current player index  : ", state.currentPlayerIndex);
}

// checkPhase() mise à jour ✅
function checkPhase(state) {
    if (state.phase === "placement") {
        for (const player of state.players) {
            if (player.elves.length < 1) return;
        }

        state.phase = "playing";
        console.log("Current phase was set to 'playing'");
    }
}

// pontuXL() mise à jour 
async function pontuXL(state) {
    let i = 1;

    // Main loop
    while (i<100 && state.phase !== 'finished' && !checkIfGameFinished(state)) {
        console.log(`Tour n°${i} - Joueur ${state.players[state.currentPlayerIndex].colour}`);
        console.log(`gameState au tour ${i} : `)
        console.log(gameState);
        console.log(`Current phase: ${state.phase}`);

        await playTurn(state);

        console.log(`Phase after playTurn: ${state.phase}`);
        i++;

        checkPhase(state);
        console.log(`Phase after checkPhase: ${state.phase}`);

        checkForLoser(state);
        console.log(`Players eliminated: ${state.players.filter(p => p.eliminated).map(p => p.colour)}`);

        setNextTurn(state);
        console.log(`Next player index: ${state.currentPlayerIndex}`);
    }

    console.log("Game finished.");
}

function deleteElvesFromDOM() {
    const elements = document.querySelectorAll('.lutin');
    elements.forEach(elf => elf.remove());

    const cells = document.querySelectorAll('cell');
    cells.forEach(cell => {
        cell.classList.remove('drag-over');
    });
}

const startButton = document.getElementById("startgame");
const confirmButton = document.getElementById("confirm-button");

document.getElementById("startgame").addEventListener("click", function() {
    // Check if no game is currently running
    if (gameState.phase !== 'finished' && gameState.phase !== undefined) {
        const confirmNewGame = confirm("⚠️ A game is already running!\nDo you want to abandon it and start a new game?");
        
        if (!confirmNewGame) {
            return; // If player refuses, cancel the launch of a new game
        }
        
        else {
            console.log("partie lancée");
            // Launch a new game
            deleteElvesFromDOM();
            // newGameInit(gameState);
            gameState.newStateInit();
            console.log(gameState);
            gameState.phase = 'placement';
            console.log("BRIDGES JUST CREATED: "+ gameState.bridges);
            pontuXL(gameState);
        }
    }
});


