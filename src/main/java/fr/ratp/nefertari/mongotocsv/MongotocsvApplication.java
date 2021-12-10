package fr.ratp.nefertari.mongotocsv;

import com.github.opendevl.JFlat;
import org.apache.commons.io.FilenameUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class MongotocsvApplication {
    private static final Logger logger = LoggerFactory.getLogger(MongotocsvApplication.class);

    public static void main(String[] args) throws Exception {
        if (args == null) {
            throw new JsonFileNotFoundException("veuillez introduire le chemin du fichier json");
        }
        String from = args[0];
        Path jsonPath = Paths.get(from);
        String str = new String(Files.readAllBytes(jsonPath));
        JFlat flatMe = new JFlat(str);
        //directly write the JSON document to CSV
        String jsonFileName = FilenameUtils.getBaseName(jsonPath.toFile().getName());
        String dateEtHeure = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd-MM-yyyy_HH-mm-ss"));
        String destinationFileName = String.format("%s/%s_%s.csv", jsonPath.getParent().toAbsolutePath(), jsonFileName, dateEtHeure);
        flatMe.json2Sheet().headerSeparator("/").write2csv(destinationFileName, '§');
        logger.info(String.format("Fichier généré : %s", destinationFileName));
    }
}
