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
        <img src="" class="side-image" />
        <div id="compliment-container">
          <p id="txt-compliment"></p>
          <button id="btn-delete" data-hover="Supprimer définitivement">
            Faire disparaître ce message ☆
          </button>
        </div>
        <img src="" class="side-image" />
      </div>
      <p id="info"></p>
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
    const urlImage = `${base_image_url}`;
    const txtCompliment = document.getElementById("txt-compliment");
    const complimentBtn = document.querySelectorAll(".compliment-btn");
    const imgs = document.querySelectorAll(".side-image");

    const btnDelete = document.getElementById("btn-delete");
    const info = document.getElementById("info");
    let currentComplimentId = null; // Variable pour stocker l'ID en cours

    btnDelete.addEventListener("click", async () => {
      if (!currentComplimentId) return;

      if (!confirm("Veux-tu vraiment supprimer ce compliment ?")) return;

      try {
        // Call DELETE on the API to delete the compliment
        const response = await fetch(baseApiUrl + "/" + currentComplimentId, {
          method: "DELETE",
        });

        if (response.ok) {
          changeText("☆ Le compliment a disparu dans le néant... ☆");
          btnDelete.style.display = "none"; // Hide delete button
          currentComplimentId = null;
        } else {
          info.textContent = "Erreur lors de la suppression";
        }
      } catch (e) {
        console.error(e);
        info.textContent = "Erreur réseau";
      }
    });

    function changeText(newText) {
      txtCompliment.style.opacity = 0;
      txtCompliment.style.transform = "translateY(-10px)";

      setTimeout(() => {
        txtCompliment.textContent = newText;
        txtCompliment.style.opacity = 1;
        txtCompliment.style.transform = "translateY(0)";
      }, 250);
    }

    function changeImage(name) {
      imgs.forEach((img) => {
        // Fade out
        img.style.opacity = 0;
        img.style.transform = "scale(0.95)";
      });

      const url = urlImage + name;

      setTimeout(() => {
        const url = urlImage + name;
        imgs.forEach((img) => {
          img.src = url;
          // Fade in
          img.style.opacity = 1;
          img.style.transform = "scale(1)";
        });
      }, 250); // Fade out duration
    }

    for (const button of complimentBtn) {
      button.addEventListener("click", async () => {
        const typeBtn = button.dataset.type;

        complimentBtn.forEach((btn) => (btn.disabled = true));

        try {
          // Call Lambda with API Gateway
          const response = await fetch(baseApiUrl + "?type=" + typeBtn);
          if (!response.ok) {
            throw new Error("Erreur HTTP : " + response.status);
          }

          const data = await response.json();
          console.log("data : ", data);

          if (response.ok) {
            changeText("☆" + data.message + "☆");
            changeImage(data.image);
          } else {
            info.textContent =
              data.error || "Erreur lors de la récupération du compliment.";
          }

          if (data.id) {
            currentComplimentId = data.id; // Save id
            btnDelete.style.display = "block"; // Display delete button
          }
        } catch (err) {
          console.log("Erreur lors de l'appel à la Lambda :", err);
          changeText("☆" + "Impossible de récupérer le compliment." + "☆");
        } finally {
          complimentBtn.forEach((btn) => (btn.disabled = false));
        }
      });
    }
  </script>
</html>
