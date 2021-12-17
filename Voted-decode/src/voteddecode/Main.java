package voteddecode;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

import java.net.URL;

public class Main extends Application {

    public static Stage stage=null;

    @Override
    public void start(Stage primaryStage) throws Exception{
        Parent root = FXMLLoader.load(getClass().getResource("mainForm.fxml"));
        primaryStage.setTitle("Decode Packages");
        primaryStage.setScene(new Scene(root, 683, 520));
        primaryStage.setMaximized(false);
        primaryStage.setResizable(false);
        Image image= new Image(this.getClass().getResource("logo.png").toString(), 100, 150, false, false);
        primaryStage .getIcons().add(image);
        primaryStage.show();
        Main.stage=primaryStage;
    }


    public static void main(String[] args) {
        launch(args);
    }
}
