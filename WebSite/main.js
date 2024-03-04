
function addExperience() {
    const addExperienceDiv = document.getElementById("add-experience");
    const newExperienceForm = document.createElement('div');
    newExperienceForm.className = "new-experience"
    newExperienceForm.innerHTML = `
        <br><form action="db/db_addExperience.php" method="post">
            <label for="desc">Descrição Experiência</label>
            <input type="text" id="desc" name="desc" required><br>
            
            <label for="num_rats">Número Ratos</label>
            <input type="number" id="num_rats" name="num_rats" required><br>
            
            <label for="limit_rats">Limite Ratos</label>
            <input type="number" id="limit_rats" name="limit_rats" required><br>
            
            <label for="no_movement_time">Segundos sem Movimentos</label>
            <input type="number" id="no_movement_time" name="no_movement_time" required><br>
            
            <label for="ideal_temp">Temperatura Ideal</label>
            <input type="number" id="ideal_temp" name="ideal_temp"><br>
            
            <label for="max_temp_change">Variação Temperatura Máxima</label>
            <input type="text" id="max_temp_change" name="max_temp_change"><br>
            
            <label for="allowed_temp">Tolerância Temperatura</label>
            <input type="number" id="allowed_temp" name="allowed_temp"><br>
            
            <button type="submit" onclick="addToTable()">Criar Experiência</button>
            
        <form>
    `;

    addExperienceDiv.appendChild(newExperienceForm);

}