//   const socket = new WebSocket('ws://localhost:3000/echo');
    

//     socket.onopen = function(event) {
//           console.log("connexion ouverte");
// };

    

//     function sendMessage(message) {
//     if (socket.readyState === WebSocket.OPEN) {

//       console.log("Message envoyé au serveur : ", message);
//         socket.send(JSON.stringify({ message: message }));
//       console.log('message envoyé');

//     } else {
//       console.error("La connexion WebSocket n'est pas ouverte !");
//     }
//   }

//   socket.onmessage = function (event) {
//     console.log("Réponse du serveur chatbot : ", event.data);

//     const response = JSON.parse(event.data);
//     console.log('reponse : ', response.message);
//   };



//     const startchatbot = document.getElementById("chatbot");
//   startchatbot.addEventListener("submit", function (e) {
//     e.preventDefault();
//     const usermessage = e.target.chatbot.value; 
//     if (usermessage.trim()) {

//       sendMessage(usermessage);
      
//       e.target.chatbot.value = "";
//     }
//   });

//   socket.onclose = function(event) {
//             console.log("La connexion WebSocket a été fermée", event);
// };
  
