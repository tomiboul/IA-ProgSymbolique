// import { gameState, isValidMove } from './game3.js';

// let originCell = null;

// export function initDragAndDrop(state) {
//     document.querySelectorAll('.cell').forEach(cell => {
//         cell.addEventListener('dragstart', dragStart);
//         cell.addEventListener('dragenter', dragEnter);
//         cell.addEventListener('dragover', dragOver);
//         cell.addEventListener('dragleave', dragLeave);
//     });
// }

// export function dragStart(e) {
//     const id = e.target.id;
//     const parentId = e.target.parentElement.id;

//     const [x, y] = parentId.split('-').map(Number);
//     const currentPlayer = gameState.players[gameState.currentPlayerIndex];

//     const isPlayerElf = currentPlayer.elves.some(([elfX, elfY]) => elfX === x && elfY === y);

//     if (!isPlayerElf) {
//         e.preventDefault();
//         return;
//     }

//     e.dataTransfer.setData('text/plain', `${id}-${x}-${y}`);
//     originCell = e.target.parentElement;
// }

// export function dragEnter(e) {
//     e.preventDefault();
//     e.target.classList.add('drag-over');
// }

// export function dragOver(e) {
//     e.preventDefault();
//     e.target.classList.add('drag-over');
// }

// export function dragLeave(e) {
//     e.target.classList.remove('drag-over');
// }

// export function waitForValidDragAndDrop(state) {
//     return new Promise((resolve) => {
//         const dropHandler = (e) => {
//             e.preventDefault();

//             const id = e.dataTransfer.getData('text/plain');
//             const draggable = document.getElementById(id);
//             const dropTarget = e.target.closest('.cell');
//             console.warn(dropTarget);

//             if (!dropTarget || !originCell) {
//                 cleanup();
//                 resolve({ moved: false });
//                 return;
//             }

//             dropTarget.classList.remove('drag-over');

//             const [oldX, oldY] = originCell.id.split('-').map(Number);
//             const [newX, newY] = dropTarget.id.split('-').map(Number);

//             const validMove = isValidMove(oldX, oldY, newX, newY, state);

//             if (validMove) {
//                 dropTarget.appendChild(draggable);

//                 const currentPlayer = state.players[state.currentPlayerIndex];
//                 const elf = currentPlayer.elves.find(([elfX, elfY]) => elfX === oldX && elfY === oldY);
//                 if (elf) {
//                     elf[0] = newX;
//                     elf[1] = newY;
//                 }

//                 cleanup();
//                 resolve({ moved: true, oldX, oldY, newX, newY });
//             } else {
//                 originCell.appendChild(draggable);
//                 cleanup();
//                 resolve({ moved: false });
//             }
//         };

//         function cleanup() {
//             document.querySelectorAll('.cell').forEach(cell => {
//                 cell.removeEventListener('drop', dropHandler);
//                 cell.classList.remove('drag-over');
//             });
//         }

//         document.querySelectorAll('.cell').forEach(cell => {
//             cell.addEventListener('drop', dropHandler, { once: true });
//         });
//     });
// }
