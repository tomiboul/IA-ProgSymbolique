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

function dragStart(e) {
    e.dataTransfer.setData('text/plain', e.target.id);
    setTimeout(() => {
        e.target.classList.add('hide');
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

function drop(e) {
    e.target.classList.remove('drag-over');

    // get the draggable element
    const id = e.dataTransfer.getData('text/plain');
    const draggable = document.getElementById(id);

    // add it to the drop target
    e.target.appendChild(draggable);

    // display the draggable element
    draggable.classList.remove('hide');
}


