   const socket = new WebSocket('ws://localhost:3000/echo');
    

     socket.onopen = function(event) {
           console.log("connexion ouverte");
 };

 const chatContainer = document.getElementById("chat-messages");
 const chatbotForm = document.querySelector(".chatbot-form");
 const userInput = document.getElementById("userMessage");

     function sendMessage(message) {
        
     if (socket.readyState === WebSocket.OPEN) {

       console.log("Message envoyé au serveur : ", message);
         socket.send(JSON.stringify({ message: message }));
       console.log('message envoyé');

     } else {
       console.error("La connexion WebSocket n'est pas ouverte !");
     }
   }

   socket.onmessage = function (event) {
     console.log("Réponse du serveur chatbot : ", event.data);

     const response = JSON.parse(event.data);
     
     console.log('reponse : ', response.message);

     const botBubble = document.createElement("div");
    botBubble.classList.add("chat-response");
    botBubble.textContent = "🦉 " + event.data;
    chatContainer.appendChild(botBubble);

    chatContainer.scrollTop = chatContainer.scrollHeight;
     
   };



     const startchatbot = document.getElementById("left-container");
   startchatbot.addEventListener("submit", function (e) {
     e.preventDefault();
     const usermessage = e.target.chatbot.value; 
     if (usermessage.trim()) {

        const userBubble = document.createElement("div");
        userBubble.classList.add("chat-user");
        userBubble.textContent = usermessage;
        chatContainer.appendChild(userBubble);

        // Envoie au serveur
        sendMessage(usermessage);

        // Vide le champ
        userInput.value = "";
      
       e.target.chatbot.value = "";
     }
   });

   socket.onclose = function(event) {
             console.log("La connexion WebSocket a été fermée", event);
};
  
