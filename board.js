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
            const aboveRow = adjustedRow - 1;  
            const belowRow = adjustedRow + 1;  

            div.id = `${Math.floor((col / 2) + 1)}-${Math.floor(aboveRow / 2) + 1} - ${Math.floor((col / 2) + 1)}-${Math.floor(belowRow / 2) + 1}`;
        }

        else if (col % 2 === 1 && adjustedRow % 2 === 0) {
            div.className = "h-bridge-container";
            const leftCol = col - 1; 
            const rightCol = col + 1; 

            div.id = `${Math.floor(leftCol / 2) + 1}-${Math.floor(adjustedRow / 2) + 1} to ${Math.floor(rightCol / 2) + 1}-${Math.floor(adjustedRow / 2) + 1}`;
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


function dragStart(e) {
    console.log("START EST APPELE");
    const id = e.target.id;

    // Récupérer les coordonnées de lutin à partir de l'ID
    const [x, y] = id.split("-").slice(1, 3).map(Number); // Assumons que l'ID est sous forme "green-1-2"
    const color = gameState.currentPlayer;

    // Récupérer la liste des lutins du joueur courant
    const elves = gameState.elves[color];

    

    // Vérifier si le lutin existe déjà à ces coordonnées et appartient au joueur courant
    // const elfAtPosition = elves.find(elf => elf[0] === x - 1 && elf[1] === y - 1); // -1 pour ajuster à la coordonnée zéro

    let elfAtPosition = null;

    console.log("Dans dragStart(), gameState.currentPlayer = ", gameState.currentPlayer, " of type : ", typeof(gameState.currentPlayer));
    console.log("Dans dragStart(), gameState.elves = ", gameState.elves);
    console.log("Dans dragStart(), elves[gameState.currentPlayer] = ", elves[gameState.currentPlayer]);

    for(const elf of Object.values(elves)){
        console.log("Nouvel elf !!! : ", elf);
        if (elf[0] === x && elf[1] === y) {
            elfAtPosition = elf;
        }
    }

    console.log("elfAtPosition = ", elfAtPosition);
    if (!elfAtPosition) {
        // Si aucun lutin n'est trouvé sur cette position, ou le lutin n'appartient pas au joueur courant, on empêche le drag
        console.warn(`Ce n'est pas votre lutin à la position ${x}, ${y}!`);
        e.preventDefault(); // Annule le drag
        return;
    }

    // Si c'est bien le lutin du joueur courant, on permet le drag
    e.dataTransfer.setData('text/plain', id);
    originCell = e.target.parentElement;
    setTimeout(() => {
        // e.target.classList.add('hide'); // Optionnel: on peut cacher l'élément temporairement si nécessaire
    }, 0);
}






// Drop targets (cells)
// const cells = document.querySelectorAll('.cell');

// cells.forEach(cell => {
//     cell.addEventListener('dragenter', dragEnter);
//     cell.addEventListener('dragover', dragOver);
//     cell.addEventListener('dragleave', dragLeave);
//     cell.addEventListener('drop', drop);
// });


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

// function drop(e) {
//     e.target.classList.remove('drag-over');

//     // get the draggable element
//     const id = e.dataTransfer.getData('text/plain');
//     const draggable = document.getElementById(id);

//     // add it to the drop target
//     e.target.appendChild(draggable);

//     // display the draggable element
//     draggable.classList.remove('hide');
// }

function drop(e) {
    e.preventDefault();
    e.target.classList.remove('drag-over');

    const id = e.dataTransfer.getData('text/plain');
    const draggable = document.getElementById(id);
    const dropTarget = e.target.closest('.cell');

    // If no cell found -> cancel and put elf back on origin cell
    if (!dropTarget) {
        originCell.appendChild(draggable);
        return false;
    }

    // Get cells coords
    const [oldX, oldY] = originCell.id.split("-").map(Number);
    const [newX, newY] = dropTarget.id.split("-").map(Number);

    // Check if valid move
    if (isValidMove(oldX, oldY, newX, newY, gameState)) {
        // DOM update
        draggable.id = `lutin-${newX}-${newY}`;
        dropTarget.appendChild(draggable);

        // State update
        const color = gameState.currentPlayer;
        const elfIndex = gameState.elves[color].findIndex(elf => 
            elf[0] === oldX && elf[1] === oldY
        );
        
        if (elfIndex !== -1) {
            const wasStuck = gameState.elves[color][elfIndex][2];
            gameState.elves[color][elfIndex] = [newX, newY, wasStuck];
            return true;
        }
    }

    // Invalid move -> back to origin
    originCell?.appendChild(draggable);
    return false;
}

// function drop(e) {
//     e.preventDefault();
//     e.target.classList.remove('drag-over');

//     const id = e.dataTransfer.getData('text/plain');
//     const draggable = document.getElementById(id);
//     const dropTarget = e.target.closest('.cell');

//     if (!dropTarget) {
//         originCell.appendChild(draggable);
//         return;
//     }

//     // Récupérer les anciennes coordonnées
//     const [_, oldX, oldY] = id.split("-");
    
//     // Récupérer les nouvelles coordonnées
//     const [newX, newY] = dropTarget.id.split("-");
    
//     const color = gameState.currentPlayer;
//     const elfList = gameState.elves[color];

//     // Vérifier si le déplacement est valide
//     if (isValidMove(parseInt(oldX), parseInt(oldY), parseInt(newX), parseInt(newY), gameState)) {
//         // Mettre à jour la position dans le gameState
//         const elfIndex = elfList.findIndex(elf => elf[0] == oldX && elf[1] == oldY);
//         if (elfIndex !== -1) {
//             elfList[elfIndex] = [parseInt(newX), parseInt(newY), false];
            
//             // Mettre à jour l'ID et la position du lutin
//             draggable.id = `lutin-${newX}-${newY}`;
//             dropTarget.appendChild(draggable);
            
//             // Vérifier si le joueur est bloqué après ce mouvement
//             checkForLoser(gameState);
//         }
//     } else {
//         // Mouvement invalide, remettre le lutin à sa place
//         originCell.appendChild(draggable);
//     }
// }

function isValidMove(oldX, oldY, newX, newY, state) {
    // Vérifie si le déplacement est adjacent
    const dx = Math.abs(newX - oldX);
    const dy = Math.abs(newY - oldY);
    
    if ((dx === 1 && dy === 0) || (dx === 0 && dy === 1)) {
        // Vérifie s'il y a un pont entre les deux cases
        const bridgeExists = state.bridges.some(bridge => {
            const [x1, y1, x2, y2] = bridge[0];
            return (
                (x1 === oldX && y1 === oldY && x2 === newX && y2 === newY) ||
                (x1 === newX && y1 === newY && x2 === oldX && y2 === oldY)
            );
        });
        
        // Vérifie si la case de destination est libre
        const cellIsFree = checkIfCellIsFree(newX, newY, state);
        
        return bridgeExists && cellIsFree;
    }
    return false;
}