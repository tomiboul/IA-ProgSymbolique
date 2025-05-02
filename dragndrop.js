// /* draggable element */
// const items = document.querySelectorAll('.lutin');



// items.forEach(item => {
//     item.addEventListener('dragstart', dragStart);
// });

// function dragStart(e) {
//     e.dataTransfer.setData('text/plain', e.target.id);
//     setTimeout(() => {
//         e.target.classList.add('hide');
//     }, 0);
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

// export function drop(e) {
//     e.target.classList.remove('drag-over');

//     // get the draggable element
//     const id = e.dataTransfer.getData('text/plain');
//     const draggable = document.getElementById(id);

//     // add it to the drop target
//     e.target.appendChild(draggable);

//     // display the draggable element
//     draggable.classList.remove('hide');
// }