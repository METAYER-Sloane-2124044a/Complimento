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
        <p id="txtCompliment"></p>
        <img src="" class="side-image" />
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
    const urlImage = `${base_image_url}`;
    const txtCompliment = document.getElementById("txtCompliment");
    const complimentBtn = document.querySelectorAll(".compliment-btn");
    const imgs = document.querySelectorAll(".side-image");

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

          changeText("☆" + data.message + "☆");
          changeImage(data.image);
        } catch (err) {
          console.error("Erreur lors de l'appel à la Lambda :", err);
          changeText("☆" + "Impossible de récupérer le compliment." + "☆");
        } finally {
          complimentBtn.forEach((btn) => (btn.disabled = false));
        }
      });
    }
  </script>
</html>
