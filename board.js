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
    const id = e.target.id;

    // Récupérer les coordonnées de lutin à partir de l'ID
    const [x, y] = id.split("-").slice(1, 3).map(Number); // Assumons que l'ID est sous forme "green-1-2"
    const color = gameState.currentPlayer;

    // Récupérer la liste des lutins du joueur courant
    const elves = gameState.elves[color];

    // Vérifier si le lutin existe déjà à ces coordonnées et appartient au joueur courant
    const elfAtPosition = elves.find(elf => elf.x === x - 1 && elf.y === y - 1); // -1 pour ajuster à la coordonnée zéro

    if (!elfAtPosition) {
        // Si aucun lutin n'est trouvé sur cette position, ou le lutin n'appartient pas au joueur courant, on empêche le drag
        console.warn(`Ce n'est pas votre lutin à la position ${x}, ${y}!`);
        console.log("Couleur du joueur :", color);
        console.log("Elves : ", elves);
        console.log("x: ",x," y: ",y);
        console.log("ElfAtPosition : ", elfAtPosition);
        console.log(gameState.elves);
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
const cells = document.querySelectorAll('.cell');

cells.forEach(cell => {
    cell.addEventListener('dragenter', dragEnter);
    cell.addEventListener('dragover', dragOver);
    cell.addEventListener('dragleave', dragLeave);
    cell.addEventListener('drop', drop);
});


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

        if (dropTarget.children.length === 0 || !dropTarget) { //si y'a pas de lutin sur la case
            dropTarget.appendChild(draggable); //on drop le lutin
        } else {
            originCell.appendChild(draggable); //sinon il retourne a la case d'origine
        }

 
    // Ajoute le lutin dans la cellule cible
    e.target.appendChild(draggable);
    draggable.classList.remove('hide');

    // Récupère les coordonnées de la cellule cible
    const targetId = e.target.id; // ex: "3-2"
    const [xStr, yStr] = targetId.split("-");
    const x = parseInt(xStr) - 1;
    const y = parseInt(yStr) - 1;

    // Utilise le joueur courant comme couleur
    const color = gameState.currentPlayer;
    const elfList = gameState.elves[color];

    // Met à jour ou ajoute l'elf
    console.log("iddddd",id);
    const existingIndex = elfList.findIndex(elf => elf.id === id);

    const newElf = { id, x, y, stuck: false };

    if (existingIndex !== -1) {
        elfList[existingIndex] = newElf;
    } else {
        elfList.push(newElf);
    }

    console.log(`Nouvelle position pour ${color} :`, elfList);
    console.log("elf =", 
    );
}