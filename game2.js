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

// const playersOrder = [green,blue,yellow,red];
const playersOrder = [gameState.elves.green, gameState.elves.blue, gameState.elves.yellow, gameState.elves.red];

board = document.getElementById("board");

function newGameInit(state) {
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

async function handlePlacementTurn(state) {
    let x = 9999999;
    let y = 9999999;
    while(!checkIfCellIsFree(x, y, state) ) {
    const clickedCell = await waitForClickOnCell();

            const id = clickedCell.id; 
            const parts = id.split("-"); 
            x = parseInt(parts[0], 10);
            y = parseInt(parts[1], 10);
    }

    checkElfOnCell(x, y, state);
    
    gameState.elves[gameState.currentPlayer].push([x, y, false]); // false = not stuck
    console.log(gameState.playerOrder[gameState.currentPlayerIndex] + " player's elves :" + gameState.elves[gameState.currentPlayer]); 
    
    // Add elf to the board
    const cell = document.getElementById(`${x}-${y}`);   
    const elfImage = document.createElement("img");
    elfImage.id = `lutin-${x}-${y}`; // add an id for each lutin for the drag and drop
    elfImage.className = "lutin"; 
    elfImage.draggable = true;

    console.log("currentPlayerIndex : ", gameState.currentPlayerIndex);
    switch (gameState.currentPlayerIndex) {
        case 0:
            elfImage.src = "images/lutin_vert.png";
            break;
        case 1:
            elfImage.src = "images/lutin_bleu.png";
            break;
        case 2:
            elfImage.src = "images/lutin_jaune.png";
            break;
        case 3:
            elfImage.src = "images/lutin_rouge.png";
            break;
    }
    cell.appendChild(elfImage); // Add the image to the cell
    elfImage.addEventListener('dragstart', dragStart);
}


async function handlePlayingTurn(state) {
    // while(false){
    // const clickedCell = await waitForClickOnCell(gameState);

    //         const id = clickedCell.id; 
    //         const parts = id.split("-"); 
    //         const x = parseInt(parts[0], 10);
    //         const y = parseInt(parts[1], 10);
    //         console.log('Coordonnées : x = ${x}, y = ${y}');
    // }

    let x = 9999999;
    let y = 9999999;
    while(!checkElfOnCell(x, y, state) ) {
    const clickedCell = await waitForClickOnCell();

            const id = clickedCell.id; 
            const parts = id.split("-"); 
            x = parseInt(parts[0], 10);
            y = parseInt(parts[1], 10);
    }


}

function checkIfCellIsFree(x, y, state) {
    if(x < 0 || x > 6 || y < 0 || y > 6) {
        return null;
    }

    const elves = gameState.elves;
    console.log("Checking if cell is free on this position : ", x, y);
    
    for (const playerColour of Object.keys(elves)) {
        for (const elf of elves[playerColour]) {
            const [thisElfX, thisElfY] = elf;
            if(thisElfX === x && thisElfY === y) {
                return false;
            }
        }
    }
    
    console.log("Cell is free on this position : ", x, y);
    return true;
}

function checkElfOnCell(x, y, state) {
    console.log("Checking if elf on cell : ", x, "-", y);
    if(x < 0 || x > 6 || y < 0 || y > 6) {
        return null;
    }

    // Check if there is an elf on the cell (x,y)
    // If elf -> check if elf colour == currentPlayer colour
    // return true if elf is on the cell and belongs to currentPlayer

    for (const playerColour of Object.keys(state.elves)) {
        for (const elf of state.elves[playerColour]) {
            console.log("playerColour : ", playerColour); 
            const [thisElfX, thisElfY] = elf;
            if(thisElfX === x && thisElfY === y) {
                return playerColour === state.currentPlayer; // true if elf belongs to currentPlayer
            }
        }
    }
}

function checkIfElfCanMove(x, y, state) {
    console.log('Checking if elf at (${x}, ${y}) can move...');

    if (x < 0 || x >= 6 || y < 0 || y >= 6) {
        console.log("Invalid coordinates.");
        return false;
    }

    const directions = [
        { dx: 0, dy: 1 }, 
        { dx: 0, dy: -1 },
        { dx: 1, dy: 0 }, 
        { dx: -1, dy: 0 }  
    ];

    // Check if the elf is blocked in all directions
    for (const { dx, dy } of directions) {
        const newX = x + dx;
        const newY = y + dy;

        // For each direction, check if destination is within the board
        if (newX < 0 || newX >= 6 || newY < 0 || newY >= 6) {
            continue; // Go to next direction
        }

        // Check if bridge exists there
        const bridgeExists = state.bridges.some(bridge => {
            const [x1, y1, x2, y2] = bridge[0];
            return (
                (x1 === x && y1 === y && x2 === newX && y2 === newY) || (x1 === newX && y1 === newY && x2 === x && y2 === y)
            );
        });

        if (!bridgeExists) {
             continue; // No bridge -> go to next direction
        }

        // Check if the target cell is free
        const isTargetCellFree = checkIfCellIsFree(newX, newY, state);

        if (isTargetCellFree) {
            console.log('Elf at (${x}, ${y}) can move to (${newX}, ${newY}).');
            return true; // Can move
        }
    }

    console.log('Elf at (${x}, ${y}) cannot move.');
    return false; // Elf cannot move in any direction
}

async function waitForClickOnCell() {
    return new Promise((resolve) => {
        const handler = (e) => {
            const clickedCell = e.target.closest('.cell');
            // if (!clickedCell) return;

            // Supprimer tous les écouteurs après le clic
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

async function playTurn(state){
        
        if(state.currentPhase === 'placementPhase') {
            
            await handlePlacementTurn(state);
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
        console.log('Player ${currentColor} eliminated (all elves blocked!)');
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
        
        alert('Game over! Winner: ${winner}');
        return true;
    }
    return false;
}

function updateBoardDisplay(state) {
    // Clear all cells
    document.querySelectorAll('.cell').forEach(cell => {
        cell.className = 'cell';
    });

    // Display elves
    Object.entries(state.elves).forEach(([color, elves]) => {
        elves.forEach(([x, y]) => {
            const cell = document.querySelector('.cell[data-x="${x}"][data-y="${y}"]');
            cell.classList.add('elf-${color}');
        });
    });

    // Display bridges (if any)
    state.bridges.forEach(bridge => {
        const [x1, y1, x2, y2] = bridge[0];
        const cell1 = document.querySelector('.cell[data-x="${x1}"][data-y="${y1}"]');
        const cell2 = document.querySelector('.cell[data-x="${x2}"][data-y="${y2}"]');
        cell1.classList.add('bridge');
        cell2.classList.add('bridge');
    });
}

function setNextTurn(state) {
    state.currentPlayerIndex = (state.currentPlayerIndex + 1) % state.playerOrder.length;
    console.log("New current player : ", state.currentPlayerIndex);
}

function checkPhase(state) {
    let number_of_elves = {};
    
    for (const playerColour of Object.keys(gameState.elves)) {
        number_of_elves[playerColour] = state.elves[playerColour].length;
    }
    if(number_of_elves['green'] == 4 && number_of_elves['blue'] == 4 && number_of_elves['yellow'] == 4 && number_of_elves['red'] == 4){
        gameState.currentPhase = 'playingPhase';
        return true
    }   
}

async function pontuXL(state, playersOrder) {
    // Init a new game
    newGameInit(state);
    
    let i = 1;

    // Main loop
    while(state.currentPhase !== 'finished') {
        console.log("Turn n°", i);
        await playTurn(state);
        i++
        if(checkPhase(state)) break;
        checkForLoser(state);
        //checkIfGameFinished(state);
        setNextTurn(state);
        // updateBoardDisplay(state);
    }
    
    // When the game is over : 
    //...
}

function deleteElvesFromDOM() {
    const elements = document.querySelectorAll('lutin');
    elements.forEach(elf => elf.remove());
}

const startButton = document.getElementById("startgame");
const confirmButton = document.getElementById("confirm-button");

document.getElementById("startgame").addEventListener("click", function() {
    // Check if no game is currently running
    if (gameState.currentPhase !== 'finished' && gameState.currentPhase !== undefined) {
        const confirmNewGame = confirm("⚠️ A game is already running!\nDo you want to abandon it and start a new game?");
        
        if (!confirmNewGame) {
            return; // If player refuses, cancel the launch of a new game
        }
    }
    console.log("partie lancée");
    // Launch a new game
    deleteElvesFromDOM();
    newGameInit(gameState);
    pontuXL(gameState);
});


// GPT : 

// État temporaire pour les visuels
// let tempUI = {
//     highlightedCells: [],
//     highlightedBridges: []
// };

// // --- FONCTIONS PRINCIPALES ---
// function playTurn(state) {
//     if (state.currentPhase === 'startingPhase') {
//         return handlePlacementPhase(state);
//     } else {
//         return handleMovementPhase(state);
//     }
// }

// // --- PHASE DE PLACEMENT ---
// function handlePlacementPhase(state) {
//     return new Promise((resolve) => {
//         const currentColor = state.playerOrder[state.currentPlayerIndex];
//         let selectedCell = null;

//         // 1. Mode sélection
//         board.onclick = (e) => {
//             const cell = e.target.closest('.cell');
//             if (!cell) return;

//             const x = parseInt(cell.dataset.x);
//             const y = parseInt(cell.dataset.y);

//             // Reset les anciens highlights
//             clearTempHighlights();

//             if (getElfAtPosition(state, x, y)) {
//                 showTempMessage("Case occupée !", 'error');
//             } else {
//                 selectedCell = cell;
//                 cell.classList.add('temp-selected');
//                 showTempMessage("Prêt à placer un lutin", 'success');
//             }
//         };

//         // 2. Confirmation
//         document.getElementById("confirm-button").onclick = () => {
//             if (!selectedCell) {
//                 showTempMessage("Sélectionnez une case d'abord", 'error');
//                 return;
//             }

//             const x = parseInt(selectedCell.dataset.x);
//             const y = parseInt(selectedCell.dataset.y);
//             state.elves[currentColor].push([x, y]);
            
//             // Met à jour l'affichage permanent
//             updateBoard(state);
//             resolve();
//         };
//     });
// }

// // --- PHASE DE MOUVEMENT ---
// function handleMovementPhase(state) {
//     return new Promise((resolve) => {
//         const currentColor = state.playerOrder[state.currentPlayerIndex];
//         let selectedElf = null;
//         let availableMoves = [];

//         // 1. Sélection du lutin
//         board.onclick = (e) => {
//             const cell = e.target.closest('.cell');
//             if (!cell) return;

//             const x = parseInt(cell.dataset.x);
//             const y = parseInt(cell.dataset.y);
//             const elf = getElfAtPosition(state, x, y);

//             clearTempHighlights();

//             if (!elf || elf.color !== currentColor) {
//                 showTempMessage("Sélectionnez votre lutin", 'error');
//                 return;
//             }

//             selectedElf = { x, y };
//             availableMoves = getValidMoves(state, x, y);
            
//             // Highlight visuel
//             cell.classList.add('temp-selected');
//             availableMoves.forEach(([mx, my]) => {
//                 const moveCell = document.querySelector('.cell[data-x="${mx}"][data-y="${my}"]');
//                 moveCell.classList.add('temp-available');
//                 tempUI.highlightedCells.push(moveCell);
//             });
//         };

//         // 2. Confirmation du mouvement
//         document.getElementById("confirm-button").onclick = () => {
//             if (!selectedElf) {
//                 showTempMessage("Sélectionnez un lutin d'abord", 'error');
//                 return;
//             }

//             // Ici vous devriez gérer la sélection de destination et des ponts
//             // (version simplifiée pour l'exemple)
//             updateBoard(state);
//             resolve();
//         };
//     });
// }

// // --- HELPERS SIMPLES ---
// function updateBoard(state) {
//     // Efface tout
//     document.querySelectorAll('.cell').forEach(cell => {
//         cell.className = 'cell';
//     });

//     // Affiche les lutins
//     Object.entries(state.elves).forEach(([color, elves]) => {
//         elves.forEach(([x, y]) => {
//             const cell = document.querySelector('.cell[data-x="${x}"][data-y="${y}"]');
//             cell.classList.add('elf-${color}');
//         });
//     });
// }

// function clearTempHighlights() {
//     tempUI.highlightedCells.forEach(cell => {
//         cell.classList.remove('temp-selected', 'temp-available');
//     });
//     tempUI.highlightedCells = [];
// }

// function showTempMessage(msg, type) {
//     const feedback = document.getElementById('feedback');
//     feedback.textContent = msg;
//     feedback.className = 'feedback ${type}';
//     setTimeout(() => feedback.className = 'feedback', 2000);
// }

// function getElfAtPosition(state, x, y) {
//     for (const [color, elves] of Object.entries(state.elves)) {
//         if (elves.some(([ex, ey]) => ex === x && ey === y)) {
//             return { color };
//         }
//     }
//     return null;
// }