
const IAplacement = [];
const gameState = {
    boardSize: 6,
    players: [
      { colour: "vert", type: "human", elves: [], eliminated: false },
      { colour: "bleu", type: "AI", elves: [], eliminated: false },
      { colour: "jaune", type: "human", elves: [], eliminated: false },
      { colour: "rouge", type: "AI", elves: [], eliminated: false }
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
        // if (Array.isArray(bridgeCoords)) {
        //     const [[x1, y1], [x2, y2]] = bridgeCoords;
        //     const key = this.bridgeKey(x1, y1, x2, y2);
        //     this.bridges.delete(key);
        //     return true;
        // }

        this.bridges.delete(bridgeCoords);
        return true;

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
            { colour: "vert", type: "human", elves: [], eliminated: false },
            { colour: "bleu", type: "AI", elves: [], eliminated: false },
            { colour: "jaune", type: "human", elves: [], eliminated: false },
            { colour: "rouge", type: "AI", elves: [], eliminated: false }
        ];

        this.currentPlayerIndex = 0;

        this.phase = "placement";

        this.bridges = new Set();

        this.generateAllBridges(this.boardSize);

        console.log("newStateinit(): bridges = " + this.brdiges);
    }
}
  
const horizontalBridgeSource = 'images/horizontal_bridge.png';
const verticalBridgeSource   = 'images/vertical_bridge.png'

board = document.getElementById("board");

async function attendreMessageIA() {
    return new Promise((resolve) => {
        const handler = (e) => {
            window.removeEventListener('Message', handler); 

            const data = JSON.parse(e.detail);
            const result2 = data.result2;
            const coord_final = reformater_coord(result2);
             

            resolve(coord_final);
        };

        window.addEventListener('Message', handler);
    });
}


async function handlePlacementTurn(state) {
    let x, y;
    
    if (gameState.currentPlayerIndex === 0 || gameState.currentPlayerIndex === 2) {
        // Cas du joueur humain : attendre un clic
        do {
            const clickedCell = await waitForClickOnCell();
            const id = clickedCell.id;
            const parts = id.split("-");
            x = parseInt(parts[0], 10);
            y = parseInt(parts[1], 10);
        } while (!checkIfCellIsFree(x, y, state));
    } else if (gameState.currentPlayerIndex === 1 || gameState.currentPlayerIndex === 3) {
        
        if (gameState.phase === "placement") {
            sendtobackend(); // demande au backend

            const coord = await attendreMessageIA(); // on attend ici que le message arrive
            const parts = coord.replace(/[()]/g, "").split(", ");
            x = parseInt(parts[1], 10);
            y = parseInt(parts[2], 10);}
    }

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
        case "vert":
            elfImage.src = "images/lutin_vert.png";
            break;
        case "bleu":
            elfImage.src = "images/lutin_bleu.png";
            break;
        case "jaune":
            elfImage.src = "images/lutin_jaune.png";
            break;
        case "rouge":
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
    // Partie déplacement du lutin
    let moveCompleted = false;
    do {
        const result = await waitForValidDragAndDrop(state);
        moveCompleted = result.moved;
    } while (!moveCompleted);

    // Désactiver les événements de drag pour les cellules
    disableElvesDragEvents();

    // Partie gestion du pont
    await handleBridgeAction(state);

    // Réactiver les événements pour le prochain tour
    enableElvesDragEvents();
    
    return;
}

// function tryRotateBridge(coords, state) {
//     const [x1, y1, x2, y2] = coords;

//     // Déterminer l'orientation actuelle
//     const isHorizontal = y1 === y2;
//     const isVertical = x1 === x2;

//     if (!isHorizontal && !isVertical) return null;

//     // Calculer le centre du pont
//     const centerX = (x1 + x2) / 2;
//     const centerY = (y1 + y2) / 2;

//     // Calculer les nouvelles coordonnées après rotation de 90°
//     let newCoords;
//     if (isHorizontal) {
//         newCoords = [
//             centerX, centerY - 0.5,
//             centerX, centerY + 0.5
//         ];
//     } else {
//         newCoords = [
//             centerX - 0.5, centerY,
//             centerX + 0.5, centerY
//         ];
//     }

//     // Vérifier que c’est bien un pont valide (sur grille entière)
//     if (!Number.isInteger(newCoords[0]) || !Number.isInteger(newCoords[1]) ||
//         !Number.isInteger(newCoords[2]) || !Number.isInteger(newCoords[3])) {
//         return null;
//     }

//     // Vérifier qu’il n’y a pas déjà un pont à cet emplacement
//     const key = state.bridgeKey(...newCoords);
//     if (state.bridges.has(key)) return null;

//     // Optionnel : vérifie que les cellules sont dans les limites
//     // (ajoute un check selon la taille du plateau si besoin)

//     return newCoords;
// }

async function handleBridgeRotation(state, originalCoords) {
    // Supprimer temporairement le pont original (visuellement et dans le state)
    state.deleteBridge(originalCoords);
    // updateBridgeVisuals(state);

    // Calculer centre actuel du pont
    const [x1, y1, x2, y2] = originalCoords;

    const originX = x1;
    const originY = y1;

    // Attendre un clic sur une cellule
    let rotatedCoords = null;

    while (!rotatedCoords) {
        const cell = await waitForClickOnCell();
        const id = cell.id;
        const parts = id.split("-");
        destX = parseInt(parts[0], 10);
        destY = parseInt(parts[1], 10);

        // Tente une rotation en ce point
        rotatedCoords = tryRotateBridgeAt(originX, originY, destX, destY, originalCoords,state);

        if (!rotatedCoords) {
            alert("Rotation impossible à cet emplacement. Choisissez une autre cellule.");
        }
    }

    // Ajoute le pont tourné
    state.bridges.add(state.bridgeKey(...rotatedCoords));
    updateBridgeVisuals(state);
}

function tryRotateBridgeAt(x1, y1, x2, y2, originalCoords, state) {
    const [oldx1, oldy1, oldx2, oldy2] = originalCoords;
    const oldBridgeKey = state.bridgeKey(oldx1,oldy1,oldx2,oldy2);
    const newBridgeKey = state.bridgeKey(x1, y1, x2, y2);

    const isHorizontal = y1 === y2;
    const isVertical = x1 === x2;

    if (!isHorizontal && !isVertical) return null;

    // Check if rotation is not out of bounds (impossible)

    let newCoords;

    // Check if a the position x1,y1->x2,y2 is free or taken by an existing bridge
    if (state.doesBridgeExist(state.bridgeKey(x1,y1,x2,y2))) {
        // This spot is not free
        return null;
    }

    // delete bridge on old spot
    state.bridges.delete(oldBridgeKey);
    alert(oldBridgeKey)

    // add bridge on the new spot
    if (state.bridges.has(newBridgeKey)) return null;

    state.bridges.add(newBridgeKey);
    console.warn(newBridgeKey);    

    const oldBridgeElement = document.getElementById(oldBridgeKey);
    const newBrdigeElement = document.getElementById(newBridgeKey);

    // remove background from old bridge
    oldBridgeElement.style.background = "none";

    // add background to new bridge
    if (isHorizontal) newBrdigeElement.style.backgroundImage=     "url(" + horizontalBridgeSource +")";
    else if (isVertical) {
        newBrdigeElement.style.backgroundImage = "url(" + verticalBridgeSource +")"
        newBrdigeElement.style.backgroundPosition = "center";
        newBrdigeElement.style.backgroundSize     = "cover";
    };

    return newCoords;
}


async function handleBridgeAction(state) {
    // Attendre la sélection d’un pont et de l’action associée
    const selectedBridge = await waitForBridgeSelection(state);


    // Si l'utilisateur n'a rien sélectionné (timeout ou annulation)
    if (selectedBridge.action === 'cancel' || !selectedBridge.coords) {
        return;
    }

    // Appliquer l'action choisie
    switch (selectedBridge.action) {
        case 'destroy':
            const [x1,y1,x2,y2] = [selectedBridge.coords[0],selectedBridge.coords[1],selectedBridge.coords[2],selectedBridge.coords[3]];
            const bridgeKey = state.bridgeKey(x1,y1,x2,y2);

            state.deleteBridge(bridgeKey);
            // updateBridgeVisuals(state);
            const bridge = document.getElementById(bridgeKey);
            bridge.style.background = "none";
            break;

        case 'rotate':
            case 'rotate':
        await handleBridgeRotation(state, selectedBridge.coords);
            break;

        default:
            console.warn("Action inconnue :", selectedBridge.action);
    }
}

function createDestroyBridgeButton() {
    const btn = document.createElement('button');
    btn.id = 'destroy-bridge-btn';
    btn.textContent = 'Détruire le pont';
    btn.style.position = 'absolute';
    btn.style.top = '10px';
    btn.style.right = '10px';
    btn.style.zIndex = '1000';
    return btn;
}


async function waitForBridgeSelection(state) {
    return new Promise((resolve) => {
        let selectedBridgeCoords = null;
        let selectedBridgeElement = null;

        const cleanup = () => {
            document.querySelectorAll('.bridge').forEach(b => b.removeEventListener('click', bridgeHandler));
            document.querySelectorAll('.bridge').forEach(b => b.classList.remove('selected-bridge'));
            const menu = document.getElementById('bridge-action-menu');
            if (menu) menu.remove();
        };

        const bridgeHandler = (e) => {
            const clickedBridge = e.target.closest('.bridge');
            if (!clickedBridge) return;

            // Effacer les sélections précédentes
            document.querySelectorAll('.bridge').forEach(b => b.classList.remove('selected-bridge'));
            clickedBridge.classList.add('selected-bridge');
            selectedBridgeElement = clickedBridge;
            selectedBridgeCoords = parseBridgeId(clickedBridge.id);

            // Afficher le menu d’action
            if (!document.getElementById('bridge-action-menu')) {
                const menu = document.createElement('div');
                const rightContainer = document.getElementById("right-container");

                menu.id = 'bridge-action-menu';

                const rotateBtn = document.createElement('button');
                rotateBtn.textContent = '🔄 Tourner';
                rotateBtn.addEventListener('click', () => {
                    cleanup();
                    resolve({ action: 'rotate', coords: selectedBridgeCoords });
                });

                const destroyBtn = document.createElement('button');
                destroyBtn.textContent = '❌ Supprimer';
                destroyBtn.addEventListener('click', () => {
                    cleanup();
                    resolve({ action: 'destroy', coords: selectedBridgeCoords });
                });

                menu.appendChild(rotateBtn);
                menu.appendChild(destroyBtn);
                rightContainer.appendChild(menu);
            }
        };

        // Ajouter les listeners
        document.querySelectorAll('.bridge').forEach(bridge => {
            bridge.addEventListener('click', bridgeHandler);
        });

        // Timeout de sécurité (30s)
        // setTimeout(() => {
        //     cleanup();
        //     resolve({ action: 'cancel' });
        // }, 30000);
    });
}



async function handleBridgeMove(state, originalBridgeCoords) {
    // Supprimer temporairement le pont original
    state.deleteBridge(originalBridgeCoords);
    updateBridgeVisuals(state);

    // Attendre la sélection du nouveau pont
    let newBridgeCoords;
    do {
        const clickedBridge = await waitForClickOnBridge(state);
        newBridgeCoords = parseBridgeId(clickedBridge.id);
    } while (!isValidBridgeMove(originalBridgeCoords, newBridgeCoords, state));

    // Ajouter le nouveau pont
    state.bridges.add(state.bridgeKey(...newBridgeCoords));
    updateBridgeVisuals(state);
}

function isValidBridgeMove(oldCoords, newCoords, state) {
    // Implémentez la logique de validation pour le déplacement du pont
    // Par exemple, vérifiez que le nouveau pont est une rotation valide de l'ancien
    return true; // À adapter
}

function disableCellDragEvents() {
    const cells = document.querySelectorAll('.cell');
    cells.forEach(cell => {
        cell.removeEventListener('dragenter', dragEnter);
        cell.removeEventListener('dragover', dragOver);
        cell.removeEventListener('dragleave', dragLeave);
        cell.removeEventListener('drop', drop);
    });
}

function enableCellDragEvents() {
    const cells = document.querySelectorAll('.cell');
    cells.forEach(cell => {
        cell.addEventListener('dragenter', dragEnter);
        cell.addEventListener('dragover', dragOver);
        cell.addEventListener('dragleave', dragLeave);
        cell.addEventListener('drop', drop);
    });
}

function disableElvesDragEvents() {
    const elves = document.querySelectorAll('.lutin');
    elves.forEach(elf => {
        elf.removeEventListener('dragenter', dragEnter);
        elf.removeEventListener('dragover', dragOver);
        elf.removeEventListener('dragleave', dragLeave);
        elf.removeEventListener('drop', drop);
    });
}

function enableElvesDragEvents() {
    const elves = document.querySelectorAll('.lutin');
    elves.forEach(elf => {
        elf.addEventListener('dragenter', dragEnter);
        elf.addEventListener('dragover', dragOver);
        elf.addEventListener('dragleave', dragLeave);
        elf.addEventListener('drop', drop);
    });
}

function parseBridgeId(bridgeId) {
    // Convertit l'ID d'un pont en coordonnées
    const [part1, part2] = bridgeId.split('-');
    const [x1, y1] = part1.split(',').map(Number);
    const [x2, y2] = part2.split(',').map(Number);
    return [x1, y1, x2, y2];
}

function updateBridgeVisuals(state) {
    // Supprimer tous les ponts visuels
    document.querySelectorAll('.bridge').forEach(el => el.remove());
    
    // Recréer les ponts selon l'état actuel
    state.bridges.forEach(bridgeKey => {
        const [x1, y1, x2, y2] = bridgeKey.split('-').flatMap(coord => 
            coord.split(',').map(Number)
        );
        createBridgeElement(x1, y1, x2, y2);
    });
}

function createBridgeElement(x1, y1, x2, y2) {
    const bridge = document.createElement('div');
    bridge.className = 'bridge';
    bridge.id = `${x1},${y1}-${x2},${y2}`;
    
    // Positionnement et style du pont
    if (x1 === x2) { // Pont vertical
        bridge.classList.add('v-bridge');
        bridge.style.left = `${x1 * 50 - 5}px`;
        bridge.style.top = `${Math.min(y1, y2) * 50}px`;
        bridge.style.height = '50px';
    } else { // Pont horizontal
        bridge.classList.add('h-bridge');
        bridge.style.left = `${Math.min(x1, x2) * 50}px`;
        bridge.style.top = `${y1 * 50 - 5}px`;
        bridge.style.width = '50px';
    }
    
    document.getElementById('board').appendChild(bridge);
    return bridge;
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
        // setTimeout(() => {
        //     if (onDropCallback === onValidDrop) {
        //         cleanup();
        //         resolve({ moved: false });
        //     }
        // }, 120000);
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

        if (newX < 0 || newX > state.boardSize || newY < 0 || newY > state.boardSize) {
            continue;
        }

        let bridgeKey;
        if (newX > x || newY>y){
            bridgeKey = state.bridgeKey(x, y, newX, newY);
        }else{
            bridgeKey = state.bridgeKey(newX, newY, x, y);
        }
        
        if (state.bridges.has(bridgeKey)) {
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
    
    //eliminates the blocked elves
    for (const player of state.players){
        for (let i = 0; i<player.elves.length; i++){
            if (isElfBlocked(player.elves[i][0],player.elves[i][1], state)){
                player.elves[i][2] = true;
                console.log("cramptés\n");
                
            
                const cellId = `${player.elves[i][0]}-${player.elves[i][1]}`;
                const lutin_id = `lutin-${player.elves[i][0]}-${player.elves[i][1]}`;
                const elf = document.getElementById(lutin_id);
                const cell = document.getElementById(cellId);
                console.log(`cellID : ${cellId}`);
                console.log(`cell : ${cell}`);
                if (cell){
                    cell.classList.remove('drag-over');
                }

                if (elf) {
                    elf.remove(); // Supprime du DOM
                    console.log(`Removed elf`);
                }

                //player.elves.remove([player.elves[i][0],player.elves[i][1],true]);
                player.elves.pop(i);
            }
        }
    }
    
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
            if (player.elves.length < 4) return;
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
        if(gameState.phase === "playing" && (gameState.currentPlayerIndex === 1 || gameState.currentPlayerIndex === 3)){
            
            console.log("voila la phase", gameState.phase);
            sendtobackend()

            window.addEventListener('Message', (e) => {
                console.log("Message reçu dans un autre fichier:", e.detail);
                data = JSON.parse(e.detail);
                console.log("HEEEEEEEEEEEEEEEEERE", JSON.stringify(data));


                const result1 = data.result1;
                console.log("voici le premier resultat", JSON.stringify(result1));

                const premier_elem = result1[0]
                const deuxieme_elem = result1[1][0]
                const troisieme_elem = result1[1][1][0]
                const quatrieme_elem = result1[1][1][1]
                
                console.log("voici le premier elem", JSON.stringify(premier_elem));
                
                console.log("voici le 2eme elem", JSON.stringify(deuxieme_elem));
                
                console.log("voici le 3eme elem", JSON.stringify(troisieme_elem));
                
                console.log("voici le 4eme elem", JSON.stringify(quatrieme_elem));

                const coord_final = reformater_coord(premier_elem);
                console.log("FORMAT FINAL", coord_final);
                const coord_final2 = reformater_coord(deuxieme_elem);
                console.log("FORMAT FINAL 2", coord_final2);
                const coord_final3 = reformater_bridge(troisieme_elem);
                console.log("FORMAT FINAL 3", coord_final3);
                const coord_final4 = reformater_bridge(quatrieme_elem);
                console.log("FORMAT FINAL 4", quatrieme_elem);
              });
        
        }

        await playTurn(state);

        console.log(`Phase after playTurn: ${state.phase}`);
        i++;

        checkPhase(state);
        console.log(`Phase after checkPhase: ${state.phase}`);

        checkForLoser(state);
        console.log(`Players eliminated: ${state.players.filter(p => p.eliminated).map(p => p.colour)}`);

        setNextTurn(state);
        console.log(`Next player index: ${state.currentPlayerIndex}`);
        console.log("voila les lutins")
        
        
        
    }

    console.log("Game finished.");
}

function reformater_coord(element) {
    const elem = `(${element[0]}, ${element[1][0]}, ${element[1][1]})`;

    return elem;

}
function reformater_bridge(element) {
    const elem = `(${element[0][0]},${element[0][1]})-(${element[1][0]},${element[1][1]})`;

    return elem;

}
function sendtobackend() {
    //aide de chatgpt pour l'affichage
    const elfTuples = gameState.players.flatMap(player =>
        player.elves.map(elf => [player.colour, elf[0], elf[1]])
      );
      const tupleString =
      '[' + elfTuples.map(([c, x, y]) => `(${c},${x},${y})`).join(',') + ']';
      console.log(tupleString);

      const bridgeList = Array.from(gameState.bridges).map(bridge => {
        const [from, to] = bridge.split('-');
        const [x1, y1] = from.split(',');
        const [x2, y2] = to.split(',');
        return `(${x1},${y1})-(${x2},${y2})`;
      });
      const bridgeString = '[' + bridgeList.join(',') + ']';
      console.log("voici le currentplayr", gameState.currentPlayerIndex)
      
      let turnorder = [];
        if (gameState.currentPlayerIndex === 0) {
            turnorder = ['vert', 'bleu', 'jaune', 'rouge'];
        } else if (gameState.currentPlayerIndex === 1) {
            turnorder = ['bleu', 'jaune', 'rouge', 'vert'];
        } else if (gameState.currentPlayerIndex === 2) {
            turnorder = ['jaune', 'rouge', 'vert', 'bleu'];
        } else if (gameState.currentPlayerIndex === 3) {
            turnorder = ['rouge', 'vert', 'bleu', 'jaune'];
        }

        const turnorderstring = '[' + turnorder.join(',') + ']';
    
      const finalString = `(${tupleString}, ${bridgeString}, ${turnorderstring})`;
      console.log(finalString);

      const dataToSend = {
        message: {
          elves: elfTuples,       
          bridges: bridgeString,       
          turnorder: turnorderstring   
        }
      };
    
      socket.send(JSON.stringify(dataToSend));
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


