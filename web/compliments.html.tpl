<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">>
    <title>Compliments</title>
</head>
<body>
    <h1>La page des Compliments</h1>

    <button id="cuteComplimentBtn">Complimentes moi (encore)</button>

    <p>**☆**</p>
    <p id="txtCompliment">**tie beau comme un camions**</p>
    
    <nav>
        <p><a href="index.html">Retour à la page d'Accueil</a></p>
    </nav>
</body>
<script>
    const baseApiUrl = "${base_api_url}";

    document.getElementById("cuteComplimentBtn").addEventListener("click", async () => {
      const resultDiv = document.getElementById("txtCompliment");
      resultDiv.textContent = "Chargement...";

      try {
        // Call Lambda with API Gateway
        const response = await fetch(baseApiUrl + "?type=cute");
        if (!response.ok) {
          throw new Error("Erreur HTTP : " + response.status);
        }
        const data = await response.json();
        console.log("data : ", data)
        resultDiv.textContent = data.message;
      } catch (err) {
        console.error("Erreur lors de l'appel à la Lambda :", err);
        resultDiv.textContent = "Impossible de récupérer le compliment.";
      }
    });
  </script>
</html>