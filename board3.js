const WS_PROTO = "ws://"
const WS_ROUTE = "/bridge"


let board = document.getElementById("board");

const boardSize = 6;
const totalSize = boardSize * 2 - 1;

for (let row = 0; row < totalSize; row++) { 
    for (let col = 0; col < totalSize; col++) {  
        const div = document.createElement("div");

        const adjustedRow = totalSize - row - 1; 

        if (col % 2 === 0 && (boardSize - adjustedRow) % 2 === 0) {
            div.className = "cell";

            div.id = `${Math.floor((col / 2) + 1)}-${Math.floor((adjustedRow / 2) + 1)}`;
            div.addEventListener('dragenter', dragEnter);
            div.addEventListener('dragover', dragOver);
            div.addEventListener('dragleave', dragLeave);
            div.addEventListener('drop', drop);
        }

        else if (col % 2 === 0 && adjustedRow % 2 === 1) {
            div.className = "v-bridge-container";
            div.classList.add("bridge");
            const aboveRow = adjustedRow - 1;  
            const belowRow = adjustedRow + 1;  

            div.id = `${Math.floor((col / 2) + 1)},${Math.floor(aboveRow / 2) + 1}-${Math.floor((col / 2) + 1)},${Math.floor(belowRow / 2) + 1}`;
        }

        else if (col % 2 === 1 && adjustedRow % 2 === 0) {
            div.className = "h-bridge-container";
            div.classList.add("bridge");
            const leftCol = col - 1; 
            const rightCol = col + 1; 

            div.id = `${Math.floor(leftCol / 2) + 1},${Math.floor(adjustedRow / 2) + 1}-${Math.floor(rightCol / 2) + 1},${Math.floor(adjustedRow / 2) + 1}`;
        }

        else {
            div.style.backgroundColor = "transparent";
        }

        board.appendChild(div);
    }
}

// Drag and drop 

/* draggable element from https://www.javascripttutorial.net/web-apis/javascript-drag-and-drop/*/
const items = document.querySelectorAll('.lutin');

items.forEach(item => {
    item.addEventListener('dragstart', dragStart);
});

let originCell = null;

// function dragStart(e) {
//     const id = e.target.id;
//     const [_, x, y] = id.split('-').map(Number);
//     const currentPlayer = gameState.players[gameState.currentPlayerIndex];

//     // Check if the elf belongs to the current player
//     const elf = currentPlayer.elves.find(([elfX, elfY]) => elfX === x && elfY === y);
//     if (!elf) {
//         console.warn("This is not your elf!");
//         e.preventDefault();
//         return;
//     }

//     e.dataTransfer.setData('text/plain', id);
//     originCell = e.target.parentElement;
// }

function dragStart(e) {
    // - check if the player dragging is the owner of the elf
    // - keep the initial cell in a variable

    const id = e.target.id;
    const parentId = e.target.parentElement.id;

    console.log(id);
    console.log(parentId);
    console.log("THIS IS THE ID OF THE DRAGGED ELEMENT: " + id);
    const [x, y] = parentId.split('-').map(Number);
    console.log("dragStart(): x=" + x + " and y=" + y);
    
    const playerIndex = gameState.currentPlayerIndex;
    console.log("dragStart(): current player index = " + playerIndex);
    console.log("dragStart(): current player elves: ");
    console.log(gameState.players[playerIndex].elves);

    const playerElf = gameState.players[playerIndex].elves.find(([elfX,elfY]) => elfX === x && elfY === y);
    console.log("dragStart(): player elf = "+ playerElf);
    console.log("           State: ");
    console.log(gameState)

    if (!playerElf) {
        console.warn("This is not your elf!");
        e.preventDefault();
        return;
    }
    e.dataTransfer.setData('text/plain', id);
    originCell = e.target.parentElement;
}

let onDropCallback = null;

function setOnDropCallback(cb) {
    onDropCallback = cb;
}

function drop(e) {
    e.preventDefault();

    const id = e.dataTransfer.getData('text/plain');
    const draggable = document.getElementById(id);
    const dropTarget = e.target.closest('.cell');

    if (!dropTarget) return;

    const [oldX, oldY] = originCell.id.split('-').map(Number);
    const [newX, newY] = dropTarget.id.split('-').map(Number);

    const validMove = isValidMove(oldX, oldY, newX, newY, gameState);

    if (validMove) {
        dropTarget.appendChild(draggable);
        dropTarget.classList.remove('drag-over');

        // Update state
        const currentPlayer = gameState.players[gameState.currentPlayerIndex];
        const elf = currentPlayer.elves.find(([elfX, elfY]) => elfX === oldX && elfY === oldY);
        if (elf) {
            elf[0] = newX;
            elf[1] = newY;
        }

        if (onDropCallback) {
            onDropCallback({ moved: true, oldX, oldY, newX, newY });
            onDropCallback = null;
        }

        draggable.removeEventListener('dragstart', dragStart);
    } else {
        originCell.appendChild(draggable);
        if (onDropCallback) {
            onDropCallback({ moved: false });
            onDropCallback = null;
        }
    }
}


let resolveDropPromise; // Global variable to store the resolve function of the promise

// function drop(e) {
//     e.preventDefault();
//     e.target.classList.remove('drag-over');

//     const id = e.dataTransfer.getData('text/plain');
//     const draggable = document.getElementById(id);
//     const dropTarget = e.target.closest('.cell');

//     console.log("Drop target:", dropTarget);
//     console.log("Draggable element:", draggable);

//     if (!dropTarget) {
//         console.warn("Invalid drop target.");
//         originCell.appendChild(draggable);
//         return;
//     }

//     const [oldX, oldY] = originCell.id.split('-').map(Number);
//     const [newX, newY] = dropTarget.id.split('-').map(Number);

//     if (isValidMove(oldX, oldY, newX, newY, gameState)) {
//         console.log("Valid move, updating DOM...");
//         dropTarget.appendChild(draggable);

//         // Notify that the drop was valid
//         if (resolveDropPromise) {
//             resolveDropPromise({ oldX, oldY, newX, newY });
//             resolveDropPromise = null; // Reset the promise resolver
//         }
//     } else {
//         console.warn("Invalid move, returning draggable to origin.");
//         originCell.appendChild(draggable);
//     }
// }

// function drop(e) {
//     e.preventDefault();
//     e.target.classList.remove('drag-over');

//     const id = e.dataTransfer.getData('text/plain');
//     const draggable = document.getElementById(id);
//     const dropTarget = e.target.closest('.cell');

//     if (!dropTarget) {
//         console.warn("Invalid drop target.");
//         originCell.appendChild(draggable);
//         return;
//     }

//     const [oldX, oldY] = originCell.id.split('-').map(Number);
//     const [newX, newY] = dropTarget.id.split('-').map(Number);

//     if (isValidMove(oldX, oldY, newX, newY, gameState)) {
//         console.log("Valid move detected.");
//         dropTarget.appendChild(draggable);

//         // Met à jour l'état du jeu
//         const currentPlayer = gameState.players[gameState.currentPlayerIndex];
//         const elf = currentPlayer.elves.find(elf => elf.x === oldX && elf.y === oldY);
//         if (elf) {
//             elf.x = newX;
//             elf.y = newY;
//         }

//         // Résout la promesse dans waitForValidDragAndDrop
//         if (resolveDropPromise) {
//             resolveDropPromise({ oldX, oldY, newX, newY });
//             resolveDropPromise = null; // Réinitialise la fonction de résolution
//         }
//     } else {
//         console.warn("Invalid move, returning draggable to origin.");
//         originCell.appendChild(draggable);
//     }
// }

function dragEnter(e) {
    e.preventDefault();
    e.target.classList.add('drag-over');
}

function dragOver(e) {
    e.preventDefault();
    e.target.classList.add('drag-over');
}

function dragLeave(e) {
    e.target.classList.remove('drag-over');
}