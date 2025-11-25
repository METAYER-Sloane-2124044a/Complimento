<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="style/style.css" />
    <title>Compliments</title>
  </head>
  <body>
    <div class="milieu-compliments">
      <h1>☆ La page des Compliments ☆</h1>
      <div class="mon_bloc-compliments">
        <img src="assets/images/cute.jpg" class="side-image" alt="side img" />
        <p id="txtCompliment"></p>
        <img src="assets/images/cute.jpg" class="side-image" alt="side img" />
      </div>
      <section class="buttons">
        <button class="compliment-btn" data-type="cute">
          Compliments cute
        </button>
        <button class="compliment-btn" data-type="romantique">
          Compliments romantique
        </button>
        <button class="compliment-btn" data-type="motivation">
          Compliments motivants
        </button>
        <button class="compliment-btn" data-type="drole">
          Compliments drôle
        </button>
      </section>
    </div>

    <p><a href="index.html">Retour à la page d'Accueil</a></p>
  </body>
  <script>
    const baseApiUrl = `${base_api_url}`;
    const txtCompliment = document.getElementById("txtCompliment");
    const complimentBtn = document.querySelectorAll(".compliment-btn");

    function changeText(newText) {
      txtCompliment.classList.remove("show");

      setTimeout(() => {
        txtCompliment.textContent = newText;
        txtCompliment.classList.add("show");
      }, 150);
    }

    for (const button of complimentBtn) {
      button.addEventListener("click", async () => {
        const typeBtn = button.dataset.type;

        try {
          // Call Lambda with API Gateway
          const response = await fetch(baseApiUrl + "?type=" + typeBtn);
          if (!response.ok) {
            throw new Error("Erreur HTTP : " + response.status);
          }

          const data = await response.json();
          console.log("data : ", data);

          changeText("☆" + data.message + "☆");
        } catch (err) {
          console.error("Erreur lors de l'appel à la Lambda :", err);
          changeText("☆" + "Impossible de récupérer le compliment." + "☆");
        }
      });
    }
  </script>
</html>
